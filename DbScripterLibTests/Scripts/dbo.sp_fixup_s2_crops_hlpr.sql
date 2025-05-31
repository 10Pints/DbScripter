SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================================
-- Author:		 Terry Watts
-- Create date: 16-JUL-2023
-- Description: Corrects entries in the crops column of the staging 1 table
--
-- CHANGES:
--    231007: parameter: @must_update now defaults to no not yes
--            added try catch and log error
--            added @idx out parmeter to help with finding error 
-- ==============================================================================
ALTER PROCEDURE [dbo].[sp_fixup_s2_crops_hlpr]
    @search_clause   NVARCHAR(250)
   ,@replace_clause  NVARCHAR(250)
   ,@not_clause      NVARCHAR(250)  = NULL
   ,@note_clause     NVARCHAR(250)  = ''
   ,@must_update     BIT            = 0
   ,@fixup_cnt       INT             OUTPUT
   ,@wrap_wc         BIT            = 1
   ,@idx             int            = null output
AS
BEGIN
   DECLARE 
       @fn              NVARCHAR(30)   = 'FIXUP_S2_CROPS_HLPR'
      ,@nl              NVARCHAR(1)    = NCHAR(13)
      ,@error_msg       NVARCHAR(500)
      ,@delta_fixup_cnt INT            = 0
      ,@sql             NVARCHAR(MAX)

   IF @idx IS NULL SET @idx = 0

   BEGIN TRY
	   SET NOCOUNT OFF;
   
      IF @fixup_cnt IS NULL SET @fixup_cnt = 0;

      SET @sql = CONCAT
      (
'UPDATE dbo.staging2 
   SET 
       crops = Replace(crops, ''', @search_clause,''',''', @replace_clause,''' )
      ,notes = CONCAT(notes, ''', @note_clause,''')
   WHERE crops like CONCAT(''',iif(@wrap_wc=1,'%',''), ''', ''',@search_clause, iif(@wrap_wc=1,'%''',''''),') ESCAPE ''\'''
   , IIF(@not_clause IS NOT NULL, CONCAT(' AND crops NOT LIKE ''%',@not_clause,'%'''), ''), '
   SET @delta_fixup_cnt = @@rowcount;
'); -- end concat

      EXEC sp_log 2, @fn, 'executing sql: ', @nl, @sql;

      EXEC sp_executesql @sql, N'@wrap_wc BIT, @delta_fixup_cnt INT OUT', @wrap_wc, @delta_fixup_cnt OUT;

      IF @delta_fixup_cnt = 0 AND @must_update <> 0
      BEGIN
         DECLARE @msg NVARCHAR(500)
         SET @msg = CONCAT('sp_correct_crops did not find any rows matching the search clause: [', @search_clause, ']');
         EXEC sp_log 4, ''',@fn, ''',@msg;
         THROW 56384, @msg, 1;     
      END

      SET @fixup_cnt = @fixup_cnt + @delta_fixup_cnt;
   END TRY
   BEGIN CATCH
      SET  @error_msg = ut.dbo.fnGetErrorMsg();
      EXEC sp_log 2, @fn, 'caught exception: ', @error_msg, '
idx            : [', @idx, ']        
search_clause  : [', @search_clause, ']
replace_clause : [', @replace_clause, ']
not_clause     : [', @not_clause,']
note_clause    : [', @note_clause,']
must_update    : [', @must_update,'] 
fixup_cnt      : [', @fixup_cnt  ,'] 
wrap_wc        : [', @wrap_wc    ,']';

      THROW;
   END CATCH

   EXEC sp_log 2, @fn, ' leaving OK:
idx            : [', @idx, ']        
search_clause  : [', @search_clause, ']
replace_clause : [', @replace_clause, ']
not_clause     : [', @not_clause,']
note_clause    : [', @note_clause,']
delta_fixup_cnt: [', @delta_fixup_cnt,'] 
must_update    : [', @must_update,'] 
fixup_cnt      : [', @fixup_cnt  ,'] 
wrap_wc        : [', @wrap_wc    ,'] 
row count      : [', @@ROWCOUNT,']'
;

   -- Increment for next time
   SET @idx = @idx +1;
END

/*
   DECLARE 
       @fn                 NVARCHAR(30) = 'FIXUP_S2_CROPS_HLPR: '
      ,@nl                 NVARCHAR(1)  = NCHAR(13)
      ,@error_msg          NVARCHAR(500)
      ,@delta_fixup_cnt    INT = 0
      ,@sql                NVARCHAR(MAX)
   EXEC sp_fixup_s2_crops_hlpr
    @search_clause='Crucifer'
   ,@replace_clause='Cruciferae'
   ,@note_clause=''
   ,@must_update=0
   ,@wrap_wc=0


---------------------------------------------------------------------------------
   DECLARE       @delta_fixup_cnt    INT = 0
   UPDATE dbo.staging2 
   SET 
       crops = Replace(crops, 'Cowpea and other beans','Cowpea,Beans' )
      ,notes = CONCAT(notes, '')
   WHERE crops like CONCAT('%', 'Cowpea and other beans%') ESCAPE '\';

   SET @delta_fixup_cnt = @@rowcount;
---------------------------------------------------------------------------------
*/

GO
