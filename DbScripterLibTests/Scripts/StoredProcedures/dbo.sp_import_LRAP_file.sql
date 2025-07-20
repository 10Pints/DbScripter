SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================================================
-- Procedure:   <proc_nm>
-- EXEC tSQLt.Run 'test.test_021_sp_import_LRAP_file';
-- Description:
--    1. imports 1 LRAP files
--    2. returns the incremented fixup count
--
-- Author:      Terry Watts
-- Create date: 15-MAR-2024
--
-- Design: EA: Model.Conceptual Model.LRAP Import
-- Tests:
---- Preconditions: none
--
-- Responsibilities:
-- R01: Clear the S1 and S2 tables
-- R02: Import the LRAP data file
--
-- Postconditions:
-- POST 01: Staging1 contains all the rows from the import files
--
-- Called by: LRAP_Imprt_S02_ImprtStaticData
--
-- Changes:
--
-- ======================================================================================
CREATE PROCEDURE [dbo].[sp_import_LRAP_file]
    @import_file  VARCHAR(500)  -- include path, (and range if XL)
   ,@import_id    INT            --  1,2,3,4
AS
BEGIN
   DECLARE
       @fn        VARCHAR(35)   = 'sp_import_LRAP_file'
      ,@is_xl     BIT

      --------------------------------------------------------------------
      -- Determine the file type
      --------------------------------------------------------------------
   SET @is_xl = dbo.fnIsExcel(@import_file);

   EXEC sp_log 2, @fn, '000: starting
import_file: [', @import_file, ']
import_id: [', @import_id, ']
is_xl:     [', @is_xl,']'
;

   BEGIN TRY
      --------------------------------------------------------------------
      -- R01: Clear the S1 and S2 tables
      --------------------------------------------------------------------
      -- Drop and recreate the FKs
      EXEC sp_log 1, @fn, '010: truncating S1, s2';
      ALTER TABLE [dbo].[staging2] DROP CONSTRAINT [FK_staging2_staging1]
      TRUNCATE TABLE Staging1;
      TRUNCATE TABLE Staging2;
      ALTER TABLE [dbo].[staging2] WITH CHECK ADD  CONSTRAINT [FK_staging2_staging1] FOREIGN KEY([id]) REFERENCES [dbo].[staging1] ([id])
      ALTER TABLE [dbo].[staging2] CHECK CONSTRAINT [FK_staging2_staging1]

      ------------------------------------------------------------------------------
      -- 3. R02: Incrementally import the File to S1
      ------------------------------------------------------------------------------
      if @is_xl = 1
      BEGIN
         -- is excel file
         EXEC sp_log 1, @fn, '020:importing xls: calling sp_import_LRAP_file_xls';
         EXEC sp_import_LRAP_file_xls @import_file, @import_id, @clr_first=0;
      END
      ELSE
      BEGIN
         -- is tsv file
         EXEC sp_log 1, @fn, '030:importing tsv: calling sp_import_LRAP_file_tsv';
         EXEC sp_import_LRAP_file_tsv @import_file, @import_id, @clr_first=0;
      END

      ------------------------------------------------------------------------------
      -- Validate postconditions
      ------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '050: validating postconditions';
      --POST 01: s1 contains rows
      EXEC sp_assert_tbl_pop 'staging1';
      EXEC sp_log 1, @fn, '060: ASSERTION: validated postconditions';

      --------------------------------------------------------------------
      -- Processing complete';
      --------------------------------------------------------------------
      EXEC sp_log 1, @fn,'400: processing complete';
      END TRY
      BEGIN CATCH
         EXEC Ut.dbo.sp_log_exception @fn;
         THROW
      END CATCH
   EXEC sp_log 2, @fn, '999: leaving';
   END
/*
EXEC tSQLt.Run 'test.test_021_sp_import_LRAP_file';

EXEC tSQLt.RunAll;
*/

GO
