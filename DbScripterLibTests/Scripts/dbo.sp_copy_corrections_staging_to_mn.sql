SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 28-JUN-2023
-- Description: copies the import corecctions staging table
--              to the main corrections table
--
-- CALLED BY:   sp__main_import_Pesticide_Import_corrections
--
-- ERROR HANDLING by exception handling
--
-- RETURNS 0
-- CHANGES:
-- 231103: turned auto increment off so SET IDENTITY_INSERT ON/OFF not needed
-- 231108: added better row count capture
-- ==============================================================================
ALTER PROCEDURE [dbo].[sp_copy_corrections_staging_to_mn]
AS
BEGIN
   SET NOCOUNT OFF;
   DECLARE
       @fn     NVARCHAR(30)   = N'CPY CORRECTNS STG->MN'
      ,@rc     INT            = 0
      ,@msg    NVARCHAR(500)  = ''
      ,@rowcnt INT = -1;

   BEGIN TRY
      EXEC sp_log 2, @fn, '01: starting copying frm staging tbl to the main corrections tbl';
      EXEC sp_register_call @fn;

      INSERT INTO ImportCorrections(
                  id, [command], search_clause, not_clause, replace_clause, case_sensitive, latin_name, common_name, local_name, alt_names, note_clause, crops, doit, must_update, chk, created)
      SELECT      id, [command], search_clause, not_clause, replace_clause, case_sensitive, latin_name, common_name, local_name, alt_names, note_clause, crops, doit, must_update, chk, created
      FROM ImportCorrectionsStaging
      WHERE id IS NOT NULL;

      SET @rowcnt = @@ROWCOUNT;
      SET @rc     = @@ERROR;

      IF @rc <> 0
      BEGIN
         SET @msg = ERROR_MESSAGE();
         EXEC sp_log 4, @fn,  '90: caught exception: ', @msg;
         THROW 55000, @msg, 1;
      END

      EXEC sp_log 2, @fn, '60: processing complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn,  '99: leaving, RC: ', @rc, @row_count=@rowcnt;
   RETURN @rc;
END
/*
SET XACT_ABORT ON
EXEC sp_copy_corrections_staging_to_mn;
SELECT * from ImportCorrections order by id;
SELECT * from ImportCorrectionsStaging order by id;
*/


GO
