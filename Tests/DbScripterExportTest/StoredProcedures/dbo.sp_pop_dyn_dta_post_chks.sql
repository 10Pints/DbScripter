SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================================================================================================
-- Author:      Terry Watts
-- Create date: 28-OCT-2024
-- Description: validates sp_pop_staging_tables postconditions
--
-- POSTCONDITIONS
-- POST 01: ActionStaging populated
-- POST 02: ChemicalActionStaging populated
-- POST 03: ChemicalProductStaging populated
-- POST 04: ChemicalStaging populated
-- POST 05: ChemicalUseStaging populated
-- POST 06: CompanyStaging populated
-- POST 07: CropPathogenStaging populated
-- POST 08: CropStaging populated
-- POST 09: DistributorStaging populated
-- POST 10: MosaicVirusStaging
-- POST 11: PathogenChemicalStaging populated
-- POST 12: PathogenStaging populated
-- POST 13: PathogenTypeStaging populated
-- POST 14: ProductCompanyStaging populated
-- POST 15: ProductStaging populated
-- POST 16: ProductUseStaging populated
-- POST 17: TypeStaging populated
-- POST 18: UseStaging populated
--
-- TESTS:
--
-- CHANGES:
-- ==================================================================================================================================================
CREATE   PROCEDURE [dbo].[sp_pop_dyn_dta_post_chks]
AS
BEGIN
   SET NOCOUNT OFF;
   DECLARE 
       @fn        VARCHAR(30)  = N'pop_dyn_dta_post_chks'
      ,@error_msg VARCHAR(MAX)  = NULL
      ,@file_path VARCHAR(MAX)
      ,@id        INT = 1
   BEGIN TRY
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'000: starting, running postcondition validation checks';
      -----------------------------------------------------------------------------------
      -----------------------------------------------------------------------------------
      -- 1 Tables are populated
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '210: POSTCONDITION checks   ';
      EXEC dbo.sp_assert_tbl_pop 'ActionStaging';
      EXEC dbo.sp_assert_tbl_pop 'ChemicalStaging';
      EXEC dbo.sp_assert_tbl_pop 'ChemicalActionStaging';
      EXEC dbo.sp_assert_tbl_pop 'ChemicalProductStaging';
      EXEC dbo.sp_assert_tbl_pop 'ChemicalUseStaging';
      EXEC dbo.sp_assert_tbl_pop 'CompanyStaging';
      EXEC dbo.sp_assert_tbl_pop 'CropPathogenStaging';
      EXEC dbo.sp_assert_tbl_pop 'CropStaging';
      EXEC dbo.sp_assert_tbl_pop 'DistributorStaging';
      EXEC dbo.sp_assert_tbl_pop 'MosaicVirusStaging';
      EXEC dbo.sp_assert_tbl_pop 'PathogenChemicalStaging';
      EXEC dbo.sp_assert_tbl_pop 'PathogenStaging';
      EXEC dbo.sp_assert_tbl_pop 'PathogenTypeStaging';
      EXEC dbo.sp_assert_tbl_pop 'ProductCompanyStaging';
      EXEC dbo.sp_assert_tbl_pop 'ProductStaging';
      EXEC dbo.sp_assert_tbl_pop 'ProductUseStaging';
      EXEC dbo.sp_assert_tbl_pop 'TypeStaging';
      EXEC dbo.sp_assert_tbl_pop 'UseStaging';
      -----------------------------------------------------------------------------------
      -- Detailed checks
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'200: detailed checks';
      EXEC sp_log 2, @fn,'205: ActionStaging';
      EXEC sp_check_field_not_null 'ActionStaging','action_id';
      EXEC sp_check_field_not_null 'ActionStaging','action_nm';
      EXEC sp_log 2, @fn,'210: ChemicalStaging';
      EXEC sp_check_field_not_null 'ChemicalStaging','chemical_nm';
      EXEC sp_log 2, @fn,'215: ProductStaging';
      EXEC sp_check_field_not_null 'ProductStaging','product_nm';
      EXEC sp_log 2, @fn,'220: TypeStaging';
      EXEC sp_check_field_not_null 'TypeStaging','type_id';
      EXEC sp_check_field_not_null 'TypeStaging','type_nm';
      EXEC sp_log 2, @fn,'225: UseStaging';
      EXEC sp_check_field_not_null 'UseStaging','use_id';
      EXEC sp_check_field_not_null 'UseStaging','use_nm';
      EXEC sp_log 2, @fn,'230: ChemicalActionStaging';
      EXEC sp_check_field_not_null 'ChemicalActionStaging','chemical_nm';
      EXEC sp_check_field_not_null 'ChemicalActionStaging','action_nm';
      EXEC sp_log 2, @fn,'235: CompanyStaging';
      EXEC sp_check_field_not_null 'CompanyStaging','company_nm';
      EXEC sp_log 2, @fn,'240: CropStaging';
      EXEC sp_check_field_not_null 'CropStaging','crop_nm';
      EXEC sp_log 2, @fn,'245: DistributorStaging';
      EXEC sp_check_field_not_null 'DistributorStaging','distributor_id';
      EXEC sp_check_field_not_null 'DistributorStaging','distributor_nm';
      EXEC sp_check_field_not_null 'DistributorStaging','region';
      EXEC sp_check_field_not_null 'DistributorStaging','province';
      EXEC sp_check_field_not_null 'DistributorStaging','address';
      --EXEC sp_check_field_not_null 'DistributorStaging','manufacturers';
      EXEC sp_log 2, @fn,'250: PathogenStaging';
      EXEC sp_check_field_not_null 'PathogenStaging','pathogen_nm';
      EXEC sp_check_field_not_null 'PathogenStaging','pathogenType_nm';
      EXEC sp_log 2, @fn,'255: PathogenTypeStaging';
      EXEC sp_check_field_not_null 'PathogenTypeStaging','pathogenType_id';
      EXEC sp_check_field_not_null 'PathogenTypeStaging','pathogenType_nm';
      EXEC sp_log 2, @fn,'260: ChemicalProductStaging';
      EXEC sp_check_field_not_null 'ChemicalProductStaging','chemical_nm';
      EXEC sp_check_field_not_null 'ChemicalProductStaging','product_nm';
      EXEC sp_log 2, @fn,'265: ChemicalUseStaging';
      EXEC sp_check_field_not_null 'ChemicalUseStaging','chemical_nm';
      EXEC sp_check_field_not_null 'ChemicalUseStaging','use_nm';
      EXEC sp_log 2, @fn,'270: CropPathogenStaging';
      EXEC sp_check_field_not_null 'CropPathogenStaging','crop_nm';
      EXEC sp_check_field_not_null 'CropPathogenStaging','pathogen_nm';
      EXEC sp_log 2, @fn,'280: PathogenChemicalStaging';
      EXEC sp_check_field_not_null 'PathogenChemicalStaging','pathogen_nm';
      EXEC sp_check_field_not_null 'PathogenChemicalStaging','chemical_nm';
      EXEC sp_log 2, @fn,'285: ProductCompanyStaging';
      EXEC sp_check_field_not_null 'ProductCompanyStaging','product_nm';
      EXEC sp_check_field_not_null 'ProductCompanyStaging','company_nm';
      EXEC sp_log 2, @fn,'290: ProductUseStaging';
      EXEC sp_check_field_not_null 'ProductUseStaging','product_nm';
      EXEC sp_check_field_not_null 'ProductUseStaging','use_nm';
      IF EXISTS (SELECT 1 FROM ChemicalStaging         WHERE chemical_nm IS NULL)                        SELECT * FROM ChemicalStaging          WHERE chemical_nm IS NULL;
      IF EXISTS (SELECT 1 FROM ChemicalActionStaging   WHERE chemical_nm IS NULL OR action_nm IS NULL)   SELECT * FROM ChemicalActionStaging    WHERE chemical_nm IS NULL OR action_nm IS NULL
      IF EXISTS (SELECT 1 FROM ChemicalProductStaging  WHERE chemical_nm IS NULL OR product_nm IS NULL)  SELECT * FROM ChemicalProductStaging   WHERE chemical_nm IS NULL OR product_nm IS NULL
      IF EXISTS (SELECT 1 FROM ChemicalUseStaging      WHERE chemical_nm IS NULL OR use_nm IS NULL)      SELECT * FROM ChemicalUseStaging       WHERE chemical_nm IS NULL OR use_nm IS NULL
      IF EXISTS (SELECT 1 FROM CompanyStaging          WHERE company_nm IS NULL)                         SELECT * FROM CompanyStaging           WHERE company_nm IS NULL
      IF EXISTS (SELECT 1 FROM MosaicVirusStaging      WHERE species IS NULL OR crops IS NULL)           SELECT * FROM MosaicVirusStaging       WHERE species IS NULL OR crops IS NULL
      IF EXISTS (SELECT 1 FROM PathogenChemicalStaging WHERE pathogen_nm IS NULL OR chemical_nm IS NULL) SELECT * FROM PathogenChemicalStaging  WHERE pathogen_nm IS NULL OR chemical_nm IS NULL
      IF EXISTS (SELECT 1 FROM ProductStaging          WHERE product_nm IS NULL)                         SELECT * FROM ProductStaging           WHERE product_nm IS NULL
      IF EXISTS (SELECT 1 FROM ProductCompanyStaging   WHERE product_nm IS NULL OR company_nm IS NULL)   SELECT * FROM ProductCompanyStaging    WHERE product_nm IS NULL OR company_nm IS NULL
      IF EXISTS (SELECT 1 FROM ProductUseStaging       WHERE product_nm IS NULL OR use_nm IS NULL)       SELECT * FROM ProductUseStaging        WHERE product_nm IS NULL OR use_nm IS NULL
      -----------------------------------------------------------------------------------
      -- 23: Completed processing OK
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '400: Completed processing OK';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH
   EXEC sp_log 2, @fn, '999: leaving: OK';
END
/*
EXEC sp_pop_dyn_dta_post_chks;
EXEC sp_check_field_not_null 'ActionStaging','action_id';
SELECT CONCAT('EXEC sp_check_field_not_null ''',c.TABLE_NAME,''',''',COLUMN_NAME,''';')  
FROM INFORMATION_SCHEMA.COLUMNS c
JOIN list_tables_vw  tv ON c.TABLE_NAME = tv.TABLE_NAME
WHERE c.TABLE_NAME LIKE '%staging' AND c.TABLE_NAME NOT IN ('ImportCorrectionsStaging','MosaicVirusStaging') order by c.TABLE_NAME,ordinal_position;
*/
GO

