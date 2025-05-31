SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 16-JUL-2023
-- Description: Corrects entries in the crops column of the staging 1 table
--
-- CHANGES:
-- 231007: parameter: @must_update now defaults to no not yes
--    added try catch and log error
--    added @idx out parmeter to help with finding error
--
-- 241019: added some com sp fixup and 
   -- translate certain [A and B] to [A B]
   -- Annual and perrenial broadleaf weeds and grasses ETC.
-- ==============================================================================
ALTER   PROCEDURE [dbo].[sp_pre_fixup_s2_pathogens_hlpr]
    @search_clause   VARCHAR(250)
   ,@replace_clause  VARCHAR(250)
   ,@fixup_cnt       INT             OUTPUT
   ,@not_clause      VARCHAR(250)  = NULL
   ,@note_clause     VARCHAR(250)  = ''
AS
BEGIN
   DECLARE 
       @fn              VARCHAR(30)   = 'PREFXUP_S2_PATH_HLPR'
      ,@nl              VARCHAR(1)    = NCHAR(13)
      ,@error_msg       VARCHAR(500)
      ,@delta_fixup_cnt INT            = 0
      ,@sql             VARCHAR(MAX)

   BEGIN TRY
      SET NOCOUNT OFF;

      IF @fixup_cnt IS NULL SET @fixup_cnt = 0;
--    UPDATE dbo.staging2 SET pathogens = REPLACE(pathogens, @search_clause, @replace_clause) WHERE pathogens LIKE '%@search_clause%' AND pathogens NOT LIKE '%@replace_clause%';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      SET @sql = CONCAT
      (
          'UPDATE dbo.staging2 SET pathogens = REPLACE(pathogens, ''',@search_clause,''', ''',@replace_clause,''') WHERE pathogens LIKE ''%',@search_clause,'%'' AND pathogens NOT LIKE ''%',@replace_clause,'%'';'
      ); -- end concat

      EXEC sp_log 2, @fn, 'executing sql: ', @nl, @sql;
      EXEC sp_executesql @sql;
      SET @delta_fixup_cnt = @@ROWCOUNT;
      SET @fixup_cnt = @fixup_cnt + @delta_fixup_cnt;
      
      IF @delta_fixup_cnt = 0
         EXEC sp_log 3, '*** No rows updated ***';

      /*
      IF @delta_fixup_cnt = 0 AND @must_update <> 0
      BEGIN
         DECLARE @msg VARCHAR(500)
         SET @msg = CONCAT('sp_correct_crops did not find any rows matching the search clause: [', @search_clause, ']');
         EXEC sp_log 4, ''',@fn, ''',@msg;
         THROW 56384, @msg, 1;     
      END
      */
   END TRY
   BEGIN CATCH
      SET  @error_msg = ERROR_MESSAGE();
      EXEC sp_log 2, @fn, 'caught exception: ', @error_msg, '
search_clause  : [', @search_clause, ']
replace_clause : [', @replace_clause, ']
not_clause     : [', @not_clause,']
note_clause    : [', @note_clause,']
delta_fixup_cnt: [', @delta_fixup_cnt,'] 
fixup_cnt      : [', @fixup_cnt  ,']'
;

      THROW;
   END CATCH

   EXEC sp_log 2, @fn, ' leaving OK:
search_clause  : [', @search_clause, ']
replace_clause : [', @replace_clause, ']
not_clause     : [', @not_clause,']
delta_fixup_cnt: [', @delta_fixup_cnt,'] 
fixup_cnt      : [', @fixup_cnt  ,']'
;

   -- Increment for next time
   --SET @idx = @idx +1;
END


GO
