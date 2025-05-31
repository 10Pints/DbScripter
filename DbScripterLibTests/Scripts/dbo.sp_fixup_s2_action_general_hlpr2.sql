SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ========================================================
-- Author:      Terry Watts
-- Create date: 04-FEB-2024
-- Description: fixup the entry mode or (mode of) actions
-- ========================================================
ALTER PROCEDURE [dbo].[sp_fixup_s2_action_general_hlpr2]
       @index                    NVARCHAR(10)
      ,@replace_clause           NVARCHAR(MAX)
      ,@ingredient_search_clause NVARCHAR(MAX)
      ,@entry_mode_operator      NVARCHAR(15)   = NULL
      ,@entry_mode_clause        NVARCHAR(MAX)  = NULL
      ,@fixup_cnt                INT            = NULL OUT
      ,@must_update              BIT   = 0
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35)   = 'SP_FIXUP_S2_ACTION_GEN_HLPR2'
      ,@delta     INT
      ,@sql       NVARCHAR(MAX)
      ,@error_msg NVARCHAR(2000)

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
      SET @delta = @@rowcount;

      IF @fixup_cnt IS NOT NULL SET @fixup_cnt   = @fixup_cnt + @delta;
      ELSE                      SET @fixup_cnt = @delta;
      END TRY
      BEGIN CATCH
         SET @error_msg = Ut.dbo.fnGetErrorMsg();
         EXEC sp_log 4, @fn, '50: caught exception
  exception:      [', @error_msg, ']'
   ;

         THROW;
      END CATCH

   EXEC sp_log 1, @fn, @index,': @delta: ', @delta , ', @sql: ', @sql, @row_count = @fixup_cnt;
END

GO
