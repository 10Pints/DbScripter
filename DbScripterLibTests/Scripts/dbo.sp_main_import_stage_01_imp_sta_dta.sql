SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =======================================================================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2024
-- Description: clear out staging and main tables, S1 and S2, then import the static data
--
-- PRECONDITIONS: none
--
-- POSTCONDITIONS:
-- POST 01: UseStaging and Use tables populated
-- =======================================================================================
ALTER PROCEDURE [dbo].[sp_main_import_stage_01_imp_sta_dta]
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35)   = 'MAIN_IMPRT_STG_01'

   BEGIN TRY
      EXEC sp_log 1, @fn, '00: starting';
      EXEC sp_register_call @fn;
      EXEC sp_import_ForeignKey_XL 'D:\Dev\Repos\Farming\Data\ForeignKey.xlsx', 'Sheet1$';
      EXEC sp_log 2, @fn,'05: clearout all tables and import Actions and Uses';
      EXEC sp_log 2, @fn,'102: truncate the main tables';

      --------------------------------------------------------------------------------------------
      -- import all static data tables:
      -- ActionStaging, UseStaging, PathogenTypeStaging, PathogenPathogenTypeStaging, TypeStaging
      -- Also the Distributors table
      --------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'20: calling sp_import_static_data';
      EXEC sp_import_static_data;

      --------------------------------------------------------------------------------
      -- Merge the Use Table
      EXEC sp_log 2, @fn,'30:Merge use table';
      --------------------------------------------------------------------------------
      DELETE FROM [use];
      MERGE [use]       AS target
      USING  useStaging AS S
      ON target.use_nm = s.use_nm
      WHEN NOT MATCHED BY target THEN
      INSERT (  use_id,  use_nm)
      VALUES (s.use_id, s.use_nm)
      WHEN NOT MATCHED BY SOURCE
      THEN DELETE
      ;

      ---------------------------------------------------------------------
      -- Postconditon checks: POST 01: UseStaging and Use tables populated
      ---------------------------------------------------------------------
      EXEC sp_chk_tbl_populated 'UseStaging';
      EXEC sp_chk_tbl_populated 'Use';
      ---------------------------------------------------------------------
      -- ASSERTION: POST 01: UseStaging and Use tables populated
      ---------------------------------------------------------------------
      EXEC sp_log 1, @fn, '80:processing complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '99: leaving, OK';
END
/*
EXEC sp_main_import_stage_01_imp_sta_dta;
*/

GO
