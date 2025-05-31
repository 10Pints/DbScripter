SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================
-- Author:      Terry Watts
-- Create date: 15-MAR-2024
--    2. imports the LRAP register file either a tab separated file for Excel file
--
-- PRECONDITIONS: none
--
-- RESPONSIBILITIES:
-- R01: Clear the S1 and S2 tables
-- R02: Import the LRAP data file         DELEGATED
-- R03: assign the import id to new data  DELEGATED
--
-- POSTCONDITIONS:
-- POST 01:
--
-- CALLED BY: sp_main_import_stage_02
--
-- TESTS:
--
-- CHANGES:
-- 
-- ======================================================================================
ALTER PROCEDURE [dbo].[sp_import_LRAP_file]
    @LRAP_file    NVARCHAR(150)  = NULL
   ,@LRAP_range   NVARCHAR(100)  -- LRAP-221018 230813
   ,@import_id    INT = 221018 -- handles imports ids {1:221018, 2:230721} default: 221018
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35)   = 'IMPRT_LRAP_FILE'
      ,@is_xl     BIT

   EXEC sp_log 1, @fn, '00: starting
LRAP_file: [', @LRAP_file, ']
LRAP_range:[', @LRAP_range,']
import_id: [', @import_id, ']';

   BEGIN TRY
      EXEC sp_register_call @fn;

      --------------------------------------------------------------------
      -- R01: Clear the S1 and S2 tables
      --------------------------------------------------------------------
      EXEC sp_log 2, @fn, '10: truncating S1, s2';
      TRUNCATE TABLE Staging1;
      TRUNCATE TABLE Staging2;

      --------------------------------------------------------------------
      -- 2. determine the file type
      --------------------------------------------------------------------
      SET @is_xl = CHARINDEX('.xlsx', @LRAP_file);

      ------------------------------------------------------------------------------
      -- 3. R02: Import the LRAP data file
      ------------------------------------------------------------------------------
      if @is_xl = 1
      BEGIN
         -- is excel file
         EXEC sp_import_LRAP_file_xls @LRAP_file, @LRAP_range, @import_id;
      END
      ELSE
      BEGIN
         -- is tsv file
         EXEC sp_import_LRAP_file_tsv @LRAP_file, @import_id;
      END

      --------------------------------------------------------------------
      -- Processing complete';
      --------------------------------------------------------------------
      EXEC sp_log 2, @fn,'80: processing complete';
      END TRY
      BEGIN CATCH
         EXEC Ut.dbo.sp_log_exception @fn;
         throw
      END CATCH
   EXEC sp_log 1, @fn, '99: leaving';
   END
/*
EXEC sp_Reset_CallRegister;
EXEC sp_import_LRAP_file
    @LRAP_file = 'D:\Dev\Repos\Farming\Data\LRAP-221018-230813.xlsx'
   ,@LRAP_range     = 'LRAP-221018-230813$A:N'
   ,@import_id      = 221018;
*/

GO
