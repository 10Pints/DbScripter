SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ---------------------------------------------------------------------------------------------------------------------
-- Author:      Terry Watts
-- Create date: 29-JAN-2024
-- Description: does the following std preprocess:
--    1. fixup spelling errors:
--    [Perrenial] -> [Perennial]
--
-- RESPONSIBILITIES:
--  Fixup:
--    1. spelling errors:
--       [Perrenial] -> [Perennial]
--
-- CALLED BY: sp_fixup_s1
-- CHANGES:
-- ---------------------------------------------------------------------------------------------------------------------
ALTER PROCEDURE [dbo].[sp_fixup_s1_pathogens]
      @fixup_cnt       INT = 0 OUT
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(35)= 'FIXUP S1 PATHOGENS:'
      ,@row_count    INT
      ,@ndx          INT         = 3
      ,@spc          NVARCHAR(1) = N' '

      SET NOCOUNT OFF;

   BEGIN TRY
      EXEC sp_log 2, @fn, '01: starting';
      EXEC sp_register_call @fn;

      -- ------------------------------------------------------------------------------------------------
      --    1. fixup spelling errors: 
      -- ------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '02: fixup spelling errors';
      --       [Perrenial] -> [Perennial]
      UPDATE staging1 SET pathogens   = REPLACE(pathogens    , 'Perrenial', 'Perennial') WHERE company    LIKE  '%Perrenial%';
      SET @row_count = @@ROWCOUNT
      SET @fixup_cnt = @fixup_cnt + @row_count;
      EXEC sp_log 1, @fn, '04: fixup [Perrenial] -> [Perennial] updated ', @row_count, ' rows';

      EXEC sp_log 1, @fn, '20: fixup spelling errors completed';

   END TRY
   BEGIN CATCH
      DECLARE @msg NVARCHAR(500);
      SET @msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, '50: caught exception: ',@msg;
      throw;
   END CATCH

   EXEC sp_log 2, @fn, '99: leaving OK, @fixup_cnt: ',@row_count = @fixup_cnt;
END
/*
EXEC sp_fixup_s1_pathogens;
*/

GO
