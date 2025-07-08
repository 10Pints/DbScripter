SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==========================================================================
-- Author:      Terry Watts
-- Create date: 25-OCT-2023
-- Description: Fixup hlpr rtn for s2_entry_modes
--              modifies staging2
--
-- Changes:
-- 231030: only change the action if the ingredient 
--         is the only ingredient for the row 
-- 23113: added an exception handler that reports the  parameters and error
-- ==========================================================================
CREATE   PROCEDURE [dbo].[sp_pre_fixup_s2_action_specific_hlpr]
    @ingredient      VARCHAR(60)
   ,@replace_clause  VARCHAR(100)
   ,@fixup_cnt       INT OUT
AS
BEGIN
   DECLARE
       @fn              VARCHAR(35)=N'SP_FIXUP_S2_ACTION_SPEC_HLPR'
      ,@row_cnt         INT

   SET NOCOUNT OFF;
   EXEC sp_log 2, @fn, '000: starting';

   BEGIN TRY
      UPDATE staging2 
      SET entry_mode = @replace_clause 
      WHERE 
         ingredient = @ingredient
         --ingredient LIKE CONCAT('%', @ingredient, '%')
      ;

      SET @row_cnt = @@rowcount;
      SET @fixup_cnt = @fixup_cnt + @row_cnt;
   END TRY
   BEGIN CATCH
      DECLARE @error_msg VARCHAR(MAX);
      SET @error_msg = ERROR_MESSAGE();

      EXEC sp_log 4, @fn, '500: caught exception: 
@ingredient    :[', @ingredient,']
@replace_clause:[', @replace_clause, ']
error: ',@error_msg;

      THROW;
   END CATCH

      EXEC sp_log 2, @fn, '999: leaving: 
@fixup_cnt:l',@fixup_cnt,']',
@row_count = @row_cnt;

END 
/*
EXEC sp_fixup_s2_entry_modes_hlpr    
*/


GO
