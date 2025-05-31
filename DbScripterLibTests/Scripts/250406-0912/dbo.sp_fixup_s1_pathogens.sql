SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ---------------------------------------------------------------------------------------------------------------------
-- Author:      Terry Watts
-- Create date: 29-JAN-2024
-- Description: does the following std preprocess:
--    Remove header rows
--    fixup spelling errors:
--    [Perrenial] -> [Perennial]
--
-- RESPONSIBILITIES:
--  Fixup:
--    1. spelling errors:
--       [Perrenial] -> [Perennial]
--
-- POST CONDITIONS:
-- POST 01: no header rows exists in S1
-- POST 02: [Perennial] spelling errors corrected
--
-- CALLED BY: sp_fixup_s1
-- CHANGES:
-- 241105: Remove header rows 
-- 250107: pathogens: remove trailing commas
-- ---------------------------------------------------------------------------------------------------------------------
ALTER   PROCEDURE [dbo].[sp_fixup_s1_pathogens]
      @fixup_cnt       INT = 0 OUT
AS
BEGIN
   DECLARE
       @fn           VARCHAR(35)= 'S1_FIXUP_PATHOGENS'
      ,@row_count    INT
      ,@ndx          INT         = 3
      ,@spc          VARCHAR(1) = N' '

   SET NOCOUNT OFF;

   BEGIN TRY
      EXEC sp_log 2, @fn, '000: starting';

      -- ---------------------------------------------------------
      --    1. Remove header rows 
      -- ---------------------------------------------------------
      DELETE FROM Staging1 WHERE company = 'NAME OF COMPANY';
      SET @row_count = @@ROWCOUNT
      SET @fixup_cnt = @fixup_cnt + @row_count;
      EXEC sp_log 1, @fn, '005: removed ',@row_count, ' header rows from staging 1';

      -- ---------------------------------------------------------
      --    1. fixup spelling errors: 
      -- ---------------------------------------------------------
      EXEC sp_log 1, @fn, '010: fixup spelling errors [Perrenial]->[Perennial]';
      --       [Perrenial] -> [Perennial]
      UPDATE staging1 SET pathogens   = REPLACE(pathogens    , 'Perrenial', 'Perennial') WHERE company    LIKE  '%Perrenial%';
      SET @row_count = @@ROWCOUNT
      SET @fixup_cnt = @fixup_cnt + @row_count;
      EXEC sp_log 1, @fn, '020: fixup [Perrenial] -> [Perennial] updated ', @row_count, ' rows';

      -- 250107: pathogens: remove trailing commas
       UPDATE staging1 SET pathogens   = TRIM(',' FROM pathogens) WHERE pathogens LIKE '%,';
      SET @row_count = @@ROWCOUNT
      SET @fixup_cnt = @fixup_cnt + @row_count;
      EXEC sp_log 1, @fn, '030: removed trailing commas, updated ', @row_count, ' rows';

         -----------------------------------------------------------------------------------
         -- Completed processing
         -----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '800: fixup spelling errors completed';
   END TRY
   BEGIN CATCH
      DECLARE @msg VARCHAR(500);
      SET @msg = ERROR_MESSAGE();
      EXEC sp_log 4, @fn, '500: caught exception: ',@msg;
      throw;
   END CATCH

   EXEC sp_log 2, @fn, '999: leaving OK, @fixup_cnt: ', @fixup_cnt, @row_count = @fixup_cnt;
END
/*
EXEC sp_fixup_s1_pathogens;
*/


GO
