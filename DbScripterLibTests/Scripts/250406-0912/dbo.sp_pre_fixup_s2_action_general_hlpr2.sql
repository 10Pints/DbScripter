SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ========================================================
-- Author:      Terry Watts
-- Create date: 04-FEB-2024
-- Description: fixup the entry mode or (mode of) actions
-- ========================================================
ALTER   PROCEDURE [dbo].[sp_pre_fixup_s2_action_general_hlpr2]
       @index                    VARCHAR(10)
      ,@replace_clause           VARCHAR(MAX)
      ,@ingredient_search_clause VARCHAR(MAX)
      ,@entry_mode_operator      VARCHAR(15)   = NULL
      ,@entry_mode_clause        VARCHAR(MAX)  = NULL
      ,@fixup_cnt                INT            OUTPUT
      ,@must_update              BIT   = 0
AS
BEGIN
   DECLARE
       @fn        VARCHAR(35)   = 'SP_FIXUP_S2_ACTION_GEN_HLPR2'
      ,@sql       VARCHAR(MAX)
      ,@error_msg VARCHAR(2000)

   SET NOCOUNT OFF;

   EXEC sp_log 1, @fn, '00: starting
 @index                    :[',@index         ,']
,@replace_clause           :[',@replace_clause,']
,@ingredient_search_clause :[',@ingredient_search_clause ,']
,@entry_mode_operator      :[',@entry_mode_operator ,']
,@ingredient_search_clause :[',@ingredient_search_clause ,']
,@ingredient_search_clause :[',@ingredient_search_clause ,']
,@must_update              :[',@must_update   ,']
   ';

   SET @sql = CONCAT('UPDATE staging2 SET entry_mode=''', @replace_clause
   , ''' WHERE ingredient LIKE ''', @ingredient_search_clause, ''''
   ,IIF(@entry_mode_operator IS NULL, '', CONCAT(' AND entry_mode ', @entry_mode_operator, ' ''', @entry_mode_clause, '''')));

   BEGIN TRY
      PRINT @sql;
      EXEC (@sql);
      SET @fixup_cnt = @fixup_cnt + @@rowcount;

      END TRY
      BEGIN CATCH
         SET @error_msg = Ut.dbo.fnGetErrorMsg();
         EXEC sp_log 4, @fn, '50: caught exception
  exception:      [', @error_msg, ']'
   ;

         THROW;
      END CATCH

   EXEC sp_log 1, @fn, @index,': @fixup_cnt: ', @fixup_cnt, @row_count = @fixup_cnt;
END


GO
