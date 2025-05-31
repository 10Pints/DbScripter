SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==================================================================================================================================================
-- Author:      Terry Watts
-- Create date: 19-AUG-2023
-- Description: Merges the normalised staging tables to the associated main normalised tables
--       and do any main table fixup
--
-- REQUIREMENTS:
-- R01: populate the DEL01 set using the PRE01 set of tables
--
-- PRECONDITIONS:
-- PRE01: the following set of staging tables are populated and fixed up
--    PRE01: ActionStaging
--    PRE02: ChemicalStaging
--    PRE03: ChemicalActionStaging
--    PRE04: ChemicalProductStaging
--    PRE05: ChemicalUseStaging
--    PRE06: CompanyStaging
--    PRE07: CropStaging
--    PRE08: CropPathogenStaging
----    PRE09: PathogenStaging
--    PRE10: PathogenChemicalStagng
--    PRE11: PathogenTypeStaging
--    PRE12: PathogenPathogenStaging
--    PRE12: ProductStaging
--    PRE13: ProductCompanyStaging
--    PRE14: ProductUseStaging
--    PRE15: TypeStaging
--    PRE16: UseStaging
--    PRE17: DistributorStaging
--
-- PRE02: import id session setting set or is a parameter
--
-- POSTCONDITIONS
-- DEL01: This is the deliverable set of output tables populated by this routine
-- POST 01: Action table populated
-- POST 02: Chemical table populated
-- POST 03: ChemicalAction table populated
-- POST 04: ChemicalProduct table populated
-- POST 05: ChemicalUse table populated
-- POST 06: Company table populated
-- POST 07: Crop table populated
-- POST 08: CropPathogen table populated
-- POST 09: Distributor table populated
-- POST 10: Pathogen table populated
-- POST 11: PathogenChemical table populated
-- POST 12: PathogenType table populated
-- POST 13: Product table populated
-- POST 14: ProductCompany table populated
-- POST 15: ProductUse table populated
-- POST 16: Type table populated
-- POST 17: Use table populated
-- POST 18: DistributorManufacturer populated
--
-- TESTS:
-- 1. initially empty aLl tables,
--    run routine,
--    check all tables are populated
--
-- CHANGES:
-- 231006: added post condition checks for table population
-- 231008: do any main table fixup: 
--         Update the ProductCompany link table with product nm & id and company nm & id 
-- 231009: fix ChemicalProduct merge: the merge view needs to use ChemicalProductStaging table but supported by main tables linked on names not ids
--         else no rows affected
-- 231024: added sp_pop_chemicalEntryMode to populate the ChemicalEntryMode link table to relate the chemical to its modes of action
-- 231104: added PathogenChemical, removed ChemicalPathogen
-- 231108: added Action,Type and Use table merges
-- ==================================================================================================================================================
ALTER PROCEDURE [dbo].[sp_merge_normalised_tables]
AS
BEGIN
   SET NOCOUNT OFF;

   DECLARE 
       @fn        NVARCHAR(30)  = N'MRG_NORM_TBLS'
      ,@error_msg NVARCHAR(MAX)  = NULL
      ,@file_path NVARCHAR(MAX)
      ,@id        INT = 1

   BEGIN TRY
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'000: starting, running precondition validation checks';
      -----------------------------------------------------------------------------------
      EXEC sp_register_call @fn;

      -----------------------------------------------------------------------------------
      -- Precondition checks
      -----------------------------------------------------------------------------------

      -----------------------------------------------------------------------------------
      -- 02: check preconditions: PRE00: staging tables populated and fixed up
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '005: checking preconditions';
--    PRE01: ActionStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'ActionStaging';
--    PRE02: ChemicalStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'ChemicalStaging';
--    PRE03: ChemicalActionStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'ChemicalActionStaging';
--    PRE04: ChemicalProductStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'ChemicalProductStaging';
--    PRE05: ChemicalUseStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'ChemicalUseStaging';
--    PRE06: CompanyStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'CompanyStaging';
--    PRE07: CropStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'CropStaging';
--    PRE08: CropPathogenStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'CropPathogenStaging';
--    PRE09: PathogenStaging
--      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'PathogenStaging';
--    PRE10: PathogenChemicalStagng
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'PathogenChemicalStaging';
--    PRE11: PathogenTypeStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'PathogenTypeStaging';
--    PRE13: ProductStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'ProductStaging';
--    PRE13: ProductCompanyStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'ProductCompanyStaging';
--    PRE14: ProductUseStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'ProductUseStaging';
--    PRE15: TypeStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'TypeStaging';
--    PRE16: UseStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'UseStaging';
--    PRE17: DistributorStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'DistributorStaging';


      -----------------------------------------------------------------------------------
      --  03: merging main primary tables
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'020: merging main primary tables...';

      -----------------------------------------------------------------------------------
      --  04: Merge Action table
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '030: merging Action table';
      MERGE [Action]        AS target
      USING ActionStaging   AS s
      ON target.action_nm = s.action_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  action_id,   action_nm)
         VALUES (s.action_id, s.action_nm)
      WHEN NOT MATCHED BY SOURCE THEN DELETE
      ;

      -----------------------------------------------------------------------------------
      --  05: Merge Type table
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '040: merging Action table';
      MERGE [Type]        AS target
      USING TypeStaging   AS s
      ON target.type_nm = s.type_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  [type_id],   type_nm)
         VALUES (s.[type_id], s.type_nm)
      WHEN NOT MATCHED BY SOURCE THEN DELETE
      ;

      -----------------------------------------------------------------------------------
      --  06: Merge PathogenType table
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '050: merging PathogenType table';
      MERGE PathogenType          AS target
      USING PathogenTypeStaging   AS s
      ON target.pathogenType_nm = s.pathogenType_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  pathogenType_id,   pathogenType_nm)
         VALUES (s.pathogenType_id, s.pathogenType_nm)
      WHEN NOT MATCHED BY SOURCE THEN DELETE
      ;

/*
      -----------------------------------------------------------------------------------
      --  07: Merge Pathogen table
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '060: merging Pathogen table';
      MERGE Pathogen AS target
      USING 
      (
         SELECT pt.pathogenType_id, ps.pathogen_nm, pt.pathogenType_nm
         FROM PathogenStaging ps
         LEFT JOIN PathogenType pt ON pt.pathogenType_nm = ps.pathogenType_nm
      )  AS s
      ON target.pathogen_nm = s.pathogen_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  pathogen_nm,   pathogenType_id, import_id)
         VALUES (s.pathogen_nm, s.pathogenType_id, 1) -- @import_id
      -- WHEN MATCHED THEN UPDATE SET target.pathogenType_id = S.pathogenType_id  -- should be a 1 off
      WHEN NOT MATCHED BY SOURCE THEN DELETE
      ;
*/
      -----------------------------------------------------------------------------------
      --  08: Merge Chemical table
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '070: merging Chemical table';
      MERGE Chemical          AS target
      USING ChemicalStaging   AS s
      ON target.chemical_nm=s.chemical_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  chemical_nm)
         VALUES (s.chemical_nm)
      WHEN NOT MATCHED BY SOURCE THEN DELETE
         ;

      -----------------------------------------------------------------------------------
      -- 09: Merge Company table
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '080: merging Company table';
      MERGE Company          AS target
      USING CompanyStaging   AS s
      ON target.company_nm = s.company_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  company_nm)
         VALUES (s.company_nm)
      WHEN NOT MATCHED BY SOURCE THEN DELETE
         ;

      -----------------------------------------------------------------------------------
      -- 10: Merge Crop table
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '090: merging Crop table';
      MERGE Crop          AS target
      USING 
      (
         SELECT * FROM CropStaging
      )   AS s
      ON target.crop_nm=s.crop_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  crop_nm)
         VALUES (s.crop_nm)
      WHEN NOT MATCHED BY SOURCE THEN DELETE
         ;

      -----------------------------------------------------------------------------------
      -- 11: Merge Distributor table
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, '100: merging Distributor table';
      MERGE Distributor          AS target
      USING 
      (
        SELECT * FROM DistributorStaging
      ) AS s
      ON target.distributor_name=s.distributor_name
      WHEN NOT MATCHED BY target THEN
         INSERT (  distributor_id,  distributor_name)
         VALUES (s.distributor_id,s.distributor_name)
      WHEN NOT MATCHED BY SOURCE THEN DELETE
         ;

      -----------------------------------------------------------------------------------
      -- 12: Merge Product table
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '110: merging Product table';
      MERGE Product          AS target
      USING ProductStaging   AS s
      ON target.product_nm=s.product_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  product_nm)
         VALUES (s.product_nm)
      WHEN NOT MATCHED BY SOURCE THEN DELETE
         ;

      -- ASSERTION: all the main primary tables contain all the relevant new import data

      -----------------------------------------------------------------------------------
      -- 13: merging main link tables using the standard strategy:
      -----------------------------------------------------------------------------------
      -- Strategy:
      --    Join the staging link table to the 2 respective primary staging tables based on ids
      --    Join the staging tables to their respective main tables based on names
      --    Use the primary main table ids to populate the main link table
      ---------------------------------------------------
      EXEC sp_log 2, @fn,'120: merging main link tables...';

      -----------------------------------------------------------------------------------
      -- 14: Merge CropPathogen table
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '130 merging CropPathogen link table';

      MERGE CropPathogen          AS target
      USING
      (
         SELECT c.crop_nm, p.pathogen_nm, c.crop_id, p.pathogen_id
         FROM
            CropPathogenStaging cps
            LEFT JOIN CropStaging   cs ON cs.crop_nm = cps.crop_nm
            LEFT JOIN Crop          c  ON c. crop_nm = cs .crop_nm
            LEFT JOIN Pathogen      p  ON p .pathogen_nm = cps.pathogen_nm
         WHERE 
                cs.crop_nm IS NOT NULL 
            AND cs.crop_nm <>''
            AND p.pathogen_nm IS NOT NULL
            AND p.pathogen_nm <>''
      )       AS s
      ON target.crop_nm = s.crop_nm AND target.pathogen_nm = s.pathogen_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  crop_id,   pathogen_id,  crop_nm,   pathogen_nm)
         VALUES (s.crop_id, s.pathogen_id,s.crop_nm, s.pathogen_nm)
         ;

      -----------------------------------------------------------------------------------
      -- 15: Merge ChemicalProduct table
      -----------------------------------------------------------------------------------
      -- join ChemicalProductStaging, ChemicalStaging, Chemical, ProductStaging, Product
      EXEC sp_log 2, @fn, '140: merging ChemicalProduct link table';
      MERGE ChemicalProduct AS target
      USING
      (
         SELECT c.chemical_id, p.product_id, c.chemical_nm, p.product_nm
         FROM
         ChemicalProductStaging cps
         LEFT JOIN ChemicalStaging   cs ON cs.chemical_nm = cps.chemical_nm
         LEFT JOIN Chemical          c  ON c. chemical_nm = cs .chemical_nm
         LEFT JOIN ProductStaging    ps ON ps.product_nm  = cps.product_nm
         LEFT JOIN Product           p  ON p. product_nm  = ps .product_nm
      ) AS s
      ON target.chemical_nm = s.chemical_nm AND target.product_nm=s.product_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  chemical_id,   product_id,   chemical_nm,   product_nm)
         VALUES (s.chemical_id, s.product_id, s.chemical_nm, s.product_nm)
     ;

      -----------------------------------------------------------------------------------
      -- 16: Merge ChemicalUse table
      -----------------------------------------------------------------------------------
      -- join ProductUseStaging, ProductStaging, Product,Use
      EXEC sp_log 2, @fn, '150: merging ChemicalUse link table';
      MERGE ChemicalUse          AS target
      USING 
      (
         SELECT c.chemical_id, u.use_id, c.chemical_nm, u.use_nm
         FROM 
         ChemicalUseStaging cus 
         LEFT JOIN ChemicalStaging cs ON cs.chemical_nm = cus.chemical_nm
         LEFT JOIN Chemical c ON c.chemical_nm = cs.chemical_nm
         LEFT JOIN [Use] u ON u.use_nm = cus.use_nm
      ) AS s
      ON target.chemical_nm = s.chemical_nm AND target.use_nm = s.use_nm
      WHEN NOT MATCHED BY target THEN
         INSERT ( chemical_id, use_id, chemical_nm, use_nm)
         VALUES ( chemical_id, use_id, chemical_nm, use_nm)
      ;
      -----------------------------------------------------------------------------------
      --17: Merge PathogenChemical table - needs the pathogen type info 2059 rows
      -----------------------------------------------------------------------------------
      BEGIN TRY
         EXEC sp_log 2, @fn, '160: merging PathogenChemical link table';
         EXEC sp_log 2, @fn, '162: checking PathogenChemical dependencies are populated';
         EXEC sp_chk_tbl_populated 'PathogenChemicalStaging';
         EXEC sp_chk_tbl_populated 'Pathogen';
         EXEC sp_chk_tbl_populated 'Chemical';
         --EXEC sp_chk_tbl_populated 'PathogenPathogenTypeStaging';
         EXEC sp_chk_tbl_populated 'PathogenTypeStaging';
         EXEC sp_chk_tbl_populated 'PathogenType';

         -- Update Pathogen.PathogenType_id and import
         UPDATE Pathogen 
         SET pathogenType_id = pt.pathogenType_id
         FROM Pathogen p JOIN PathogenType pt ON p.pathogenType_nm=pt.pathogenType_nm;

         EXEC sp_log 2, @fn, '164: merging PathogenChemical table';
         /*----------------------------------------------------------------------------------------------------------------
          * If this yields null pathogenType_id which PathogenChemical wont accept then use this view to trace the issues
          * list_unmatched_PathogenChemicalStaging_pathogens_vw
          *----------------------------------------------------------------------------------------------------------------*/
         MERGE PathogenChemical AS target
         USING
         (
            SELECT p.pathogen_id, p.pathogen_nm, c.chemical_id, c.chemical_nm, pt.pathogenType_id 
            FROM 
               PathogenChemicalStaging pcs
               LEFT JOIN Pathogen p ON p.pathogen_nm = pcs.pathogen_nm
               LEFT JOIN Chemical c ON c.chemical_nm = pcs.chemical_nm
               LEFT JOIN PathogenType pt ON pt.pathogenType_id=p.pathogenType_id
         ) AS s
         ON target.pathogen_nm = s.pathogen_nm AND target.chemical_nm = s.chemical_nm
         WHEN NOT MATCHED BY target THEN
            INSERT ( pathogen_id, chemical_id, pathogen_nm, chemical_nm, pathogenType_id)
            VALUES ( pathogen_id, chemical_id, pathogen_nm, chemical_nm, pathogenType_id)
            ;

         EXEC sp_chk_tbl_populated 'PathogenChemical';
      END TRY
      BEGIN CATCH
         EXEC Ut.dbo.sp_log_exception @fn;

         ------------------------------------------------------------------------------------------------------------------
         -- If the  error is trying to insert null pathogen_id into PathogenChemical: then this will help trace the issues
         ------------------------------------------------------------------------------------------------------------------
         SELECT 'MERGE PathogenChemical', pathogen_nm AS [mismatched pathogens] 
         FROM list_unmatched_PathogenChemicalStaging_pathogens_vw;
         THROW;
      END CATCH

      -----------------------------------------------------------------------------------
      -- 18: ProductUse table 
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '170: merging ProductUse link table';
      MERGE ProductUse          AS target
      USING 
      (
         SELECT p.product_id, u.use_id, p.product_nm, u.use_nm FROM 
         ProductUseStaging pus 
         LEFT JOIN ProductStaging ps ON ps.product_nm = pus.product_nm
         LEFT JOIN Product p ON p.product_nm = ps.product_nm
         LEFT JOIN [Use] u ON u.use_nm = pus.use_nm
      ) AS s
      ON target.product_nm = s.product_nm AND target.use_nm = s.use_nm
      WHEN NOT MATCHED BY target THEN
         INSERT ( product_id, use_id, product_nm, use_nm)
         VALUES ( product_id, use_id, product_nm, use_nm)
         ;

      -----------------------------------------------------------------------------------
      -- 19: Update the ProductCompany link table with product nm & id and company nm & id 
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '180: merging ProductCompany link table';

      MERGE ProductCompany as target
      USING
      (
         SELECT p.product_id, c.company_id, p .product_nm, c.company_nm
         FROM ProductCompanyStaging  pcs 
         JOIN ProductStaging ps ON ps.product_nm = pcs.product_nm
         JOIN Product        p  ON p .product_nm = ps.product_nm
         JOIN CompanyStaging cs ON cs.company_nm = pcs.company_nm
         JOIN Company        c  ON c.company_nm  = cs.company_nm
      ) AS S
      ON target.product_nm = S.product_nm AND target.company_nm = s.company_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  product_id,   company_id,   product_nm,   company_nm)
         VALUES (s.product_id, s.company_id, s.product_nm, s.company_nm)
      ;

      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '190: Populating ChemicalAction link table';
      -----------------------------------------------------------------------------------
      EXEC sp_pop_chemicalAction;

      -----------------------------------------------------------------------------------
      -- 20: DistributorManufacturer
      -----------------------------------------------------------------------------------
      MERGE DistributorManufacturer as target
      USING
      (
         SELECT d.distributor_id, c.company_id
         FROM DistributorStaging_vw ds
         JOIN Distributor d ON ds.distributor_name = d.distributor_name
         JOIN Company     c ON c.company_nm  = ds.manufacturer_name
      ) AS S
      ON target.distributor_id = s.distributor_id AND target.manufacturer_id = s.company_id
      WHEN NOT MATCHED BY target THEN
         INSERT (  distributor_id,   manufacturer_id)
         VALUES (s.distributor_id, s.company_id)
      ;

      -----------------------------------------------------------------------------------
      -- 21: do any main table fixup: 
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '200: do any main table fixup: currently none';

      -----------------------------------------------------------------------------------
      -- 22  POSTCONDITION checks
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '210: POSTCONDITION checks...';
      -- POST 01: Chemical table populated
      EXEC dbo.sp_chk_tbl_populated 'Chemical';
      -- POST 02: ChemicalAction table populated
      EXEC dbo.sp_chk_tbl_populated 'ChemicalAction';
      -- POST 03: ChemicalProduct table populated
      EXEC dbo.sp_chk_tbl_populated 'ChemicalProduct';
      -- POST 04: ChemicalUse table populated
      EXEC dbo.sp_chk_tbl_populated 'ChemicalUse';
      -- POST 05 Company table populated
      EXEC dbo.sp_chk_tbl_populated 'Company';
      -- POST 06: Crop table populated
      EXEC dbo.sp_chk_tbl_populated 'Crop';
      -- POST 07: CropPathogen populated
      EXEC dbo.sp_chk_tbl_populated 'CropPathogen';
      -- POST 08: Distributor table populated
      EXEC dbo.sp_chk_tbl_populated 'Distributor';
      -- POST 09: Pathogen table populated
      EXEC dbo.sp_chk_tbl_populated 'Pathogen';
      -- POST 10: PathogenChemical table populated
      EXEC dbo.sp_chk_tbl_populated 'PathogenChemical';
      -- POST 11: PathogenType table populated
      EXEC dbo.sp_chk_tbl_populated 'PathogenType';
      -- POST 12: Product table populated
      EXEC dbo.sp_chk_tbl_populated 'Product';
      -- POST 13: ProductCompany table populated
      EXEC dbo.sp_chk_tbl_populated 'ProductCompany';
      -- POST 14: ProductUse table populated
      EXEC dbo.sp_chk_tbl_populated 'ProductUse';
      -- POST 15: Type table populated
      EXEC dbo.sp_chk_tbl_populated 'Type';
      -- POST 16: Use table populated
      EXEC dbo.sp_chk_tbl_populated 'Use';

      -----------------------------------------------------------------------------------
      -- 23: Completed processing OK
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '220: Completed processing OK';
   END TRY
   BEGIN CATCH
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, '500: Caught exception: ', @error_msg;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '999: leaving: OK';
END
/*
EXEC sp_reset_CallRegister;
EXEC sp_merge_normalised_tables 1
*/

GO
