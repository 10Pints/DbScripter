SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==========================================================================
-- Author:		 Terry Watts
-- Create date: 25-OCT-2023
-- Description: Fixup hlpr rtn for s2_entry_modes
--              modifies staging2
--
-- Changes:
-- 231030: only change the action if the ingredient 
--         is the only ingredient for the row 
-- 23113: added an exception handler that reports the  parameters and error
-- ==========================================================================
ALTER PROCEDURE [dbo].[sp_fixup_s2_action_specific_hlpr]
    @ingredient      NVARCHAR(60)
   ,@replace_clause  NVARCHAR(100)
   ,@delta_fixup_cnt INT = NULL OUT
AS
BEGIN
   DECLARE 
       @fn              NVARCHAR(35)=N'SP_FIXUP_S2_ACTION_SPEC_HLPR'
      ,@row_cnt         INT

	SET NOCOUNT OFF;
   EXEC sp_log 2, @fn, '01: starting';

   BEGIN TRY
      UPDATE staging2 
      SET entry_mode = @replace_clause 
      WHERE 
         ingredient = @ingredient
         --ingredient LIKE CONCAT('%', @ingredient, '%')
      ;

      SET @row_cnt = @@rowcount;
      EXEC sp_log 2, @fn, '99: leaving: 
   @ingredient    :[', @ingredient,']
   @replace_clause:[',@replace_clause, ']
   ', @row_count = @row_cnt;
      SET @delta_fixup_cnt = @delta_fixup_cnt + @row_cnt;
   END TRY
   BEGIN CATCH
      DECLARE @error_msg NVARCHAR(MAX);
      EXEC Ut.dbo.sp_get_error_msg @error_msg OUT;

      EXEC sp_log 4, @fn, '50: caught exception: 
@ingredient    :[', @ingredient,']
@replace_clause:[', @replace_clause, ']
error: ',@error_msg;

      THROW;
   END CATCH
END 
/*
EXEC sp_fixup_s2_entry_modes_hlpr ...
*/

GO
