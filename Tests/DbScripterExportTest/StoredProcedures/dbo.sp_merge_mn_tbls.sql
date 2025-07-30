SET ANSI_NULLS ON
GO
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
--    PRE03: ChemicalActionStaging
--    PRE04: ChemicalProductStaging
--    PRE05: ChemicalUseStaging
--    PRE08: CropPathogenStaging
--    PRE10: PathogenChemicalStagng
--    PRE11: PathogenTypeStaging
--    PRE12: PathogenPathogenStaging
--    PRE12: ProductStaging
--    PRE13: ProductCompanyStaging
--    PRE14: ProductUseStaging
--
-- PRE02: import id session setting set or is a parameter
--
-- POSTCONDITIONS
-- DEL01: This is the deliverable set of output tables populated by this routine
-- POST 03: ChemicalAction table populated
-- POST 04: ChemicalProduct table populated
-- POST 05: ChemicalUse table populated
-- POST 08: CropPathogen table populated
-- POST 11: PathogenChemical table populated
-- POST 12: PathogenType table populated
-- POST 13: Product table populated
-- POST 14: ProductCompany table populated
-- POST 15: ProductUse table populated
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
-- 241027: It may be that that staging ids are different for a given name and may conflict other ids in the table.
--         In which case we need to assign a new id and use that in the associated link tables.
--         Make the main table id field auto incremental.
-- ==================================================================================================================================================
CREATE PROCEDURE [dbo].[sp_merge_mn_tbls]
AS
BEGIN
   SET NOCOUNT OFF;
   DECLARE 
       @fn        VARCHAR(30)  = N'sp_merge_mn_tbls'
      ,@error_msg VARCHAR(MAX)  = NULL
      ,@file_path VARCHAR(MAX)
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
      EXEC sp_mrg_mn_tbls_precndtn_hlpr @id OUTPUT, 'ChemicalActionStaging';
      EXEC sp_mrg_mn_tbls_precndtn_hlpr @id OUTPUT, 'ChemicalProductStaging';
      EXEC sp_mrg_mn_tbls_precndtn_hlpr @id OUTPUT, 'ChemicalUseStaging';
      EXEC sp_mrg_mn_tbls_precndtn_hlpr @id OUTPUT, 'CropPathogenStaging';
      EXEC sp_mrg_mn_tbls_precndtn_hlpr @id OUTPUT, 'PathogenChemicalStaging';
      EXEC sp_mrg_mn_tbls_precndtn_hlpr @id OUTPUT, 'PathogenTypeStaging';
      EXEC sp_mrg_mn_tbls_precndtn_hlpr @id OUTPUT, 'ProductStaging';
      EXEC sp_mrg_mn_tbls_precndtn_hlpr @id OUTPUT, 'ProductCompanyStaging';
      EXEC sp_mrg_mn_tbls_precndtn_hlpr @id OUTPUT, 'ProductUseStaging';
      -----------------------------------------------------------------------------------
      --  03: merging main primary tables
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'020: merging main primary tables   ';
      -- ??
      DELETE FROM DistributorManufacturer;
      DELETE FROM ProductCompany;
      DELETE FROM ProductUse;
      DELETE FROM PathogenChemical;
      DELETE FROM ChemicalUse;
      DELETE FROM ChemicalProduct;
      DELETE FROM CropPathogen;
      -----------------------------------------------------------------------------------
      -- 12: Merge Product table
      -----------------------------------------------------------------------------------
      -- 241027: It may be that that staging ids are different for a given name and may conflict other ids in the table.
      --         In which case we need to assign a new id and use that in the associated link tables.
      --         Make the main table id field auto incremental.
      EXEC sp_log 2, @fn, '110: merging Product table';
      MERGE Product          AS target
      USING ProductStaging   AS s
      ON target.product_nm=s.product_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  product_nm)
         VALUES (s.product_nm)
      WHEN NOT MATCHED BY SOURCE THEN DELETE
         ;
      EXEC sp_assert_tbl_pop 'Product';
      -----------------------------------------------------------------------------------
      -- ASSERTION: all the main primary tables merged
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'120: ASSERTION: all the main primary tables merged.';
      -----------------------------------------------------------------------------------
      -- 13: merging main link tables using the standard strategy:
      -----------------------------------------------------------------------------------
      -- Strategy:
      --    Join the staging link table to the 2 respective primary staging tables based on ids
      --    Join the staging tables to their respective main tables based on names
      --    Use the primary main table ids to populate the main link table
      ---------------------------------------------------
      EXEC sp_log 2, @fn,'130: merging main link tables   ';
      -----------------------------------------------------------------------------------
      -- Merge CropPathogen table
      -----------------------------------------------------------------------------------
      -- 241027: It may be that that staging ids are different for a given name and may conflict other ids in the table.
      --         In which case we need to assign a new id and use that in the associated link tables.
      --         Make the main table id field auto incremental.
      EXEC sp_log 2, @fn, '140 merging CropPathogen link table';
      SELECT * From CropPathogen
      MERGE CropPathogen          AS target
      USING
      (
         SELECT p.pathogen_nm, c.crop_id, c.crop_nm, p.pathogen_id
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
      EXEC sp_assert_tbl_pop 'CropPathogen';
      -----------------------------------------------------------------------------------
      -- 15: Merge ChemicalProduct table
      -----------------------------------------------------------------------------------
      -- 241027: It may be that that staging ids are different for a given name and may conflict other ids in the table.
      --         In which case we need to assign a new id and use that in the associated link tables.
      --         Make the main table id field auto incremental.
      EXEC sp_log 2, @fn, '150: merging ChemicalProduct link table';
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
      EXEC sp_assert_tbl_pop 'ChemicalProduct';
      -----------------------------------------------------------------------------------
      -- 16: Merge ChemicalAction table
      -----------------------------------------------------------------------------------
      -- POST 03: ChemicalAction table populated
      EXEC sp_log 2, @fn, '160: merging ChemicalAction link table';
      MERGE ChemicalAction          AS target
      USING
      (
         SELECT c.chemical_id, a.action_id, c.chemical_nm, a.action_nm
         FROM 
         ChemicalActionStaging cas
         LEFT JOIN ChemicalStaging cs ON cs.chemical_nm = cas.chemical_nm
         LEFT JOIN Chemical c ON c.chemical_nm = cas.chemical_nm
         LEFT JOIN [Action] a ON a.action_nm = cas.action_nm
      ) AS s
      ON target.chemical_nm = s.chemical_nm AND target.action_nm = s.action_nm
      WHEN NOT MATCHED BY target THEN
         INSERT ( chemical_id, action_id, chemical_nm, action_nm)
         VALUES ( chemical_id, action_id, chemical_nm, action_nm)
      ;
      EXEC sp_assert_tbl_pop 'ChemicalUse';
      -----------------------------------------------------------------------------------
      -- 16: Merge ChemicalUse table
      -----------------------------------------------------------------------------------
      -- 241027: It may be that that staging ids are different for a given name and may conflict other ids in the table.
      --         In which case we need to assign a new id and use that in the associated link tables.
      --         Make the main table id field auto incremental.
      EXEC sp_log 2, @fn, '160: merging ChemicalUse link table';
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
      EXEC sp_assert_tbl_pop 'ChemicalUse';
      -----------------------------------------------------------------------------------
      --17: Merge PathogenChemical table - needs the pathogen type info 2059 rows
      -----------------------------------------------------------------------------------
      -- 241027: It may be that that staging ids are different for a given name and may conflict other ids in the table.
      --         In which case we need to assign a new id and use that in the associated link tables.
      --         Make the main table id field auto incremental.
      BEGIN TRY
         EXEC sp_log 2, @fn, '170: merging PathogenChemical link table';
         EXEC sp_log 2, @fn, '180: checking PathogenChemical dependencies are populated';
         EXEC sp_assert_tbl_pop 'PathogenChemicalStaging';
         EXEC sp_assert_tbl_pop 'Pathogen';
         EXEC sp_assert_tbl_pop 'Chemical';
         --EXEC sp_assert_tbl_pop 'PathogenPathogenTypeStaging';
         EXEC sp_assert_tbl_pop 'PathogenTypeStaging';
         EXEC sp_assert_tbl_pop 'PathogenType';
         -- Update Pathogen.PathogenType_id and import
         UPDATE Pathogen 
         SET pathogenType_id = pt.pathogenType_id
         FROM Pathogen p JOIN PathogenType pt ON p.pathogenType_nm=pt.pathogenType_nm;
         EXEC sp_log 2, @fn, '190: merging PathogenChemical table';
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
         EXEC sp_assert_tbl_pop 'PathogenChemical';
      END TRY
      BEGIN CATCH
         EXEC dbo.sp_log_exception @fn;
         ------------------------------------------------------------------------------------------------------------------
         -- If the  error is trying to insert null pathogen_id into PathogenChemical: then this will help trace the issues
         ------------------------------------------------------------------------------------------------------------------
         SELECT 'MERGE PathogenChemical', pathogen_nm AS [mismatched pathogens] 
         FROM list_unmatched_PathogenChemicalStaging_pathogens_vw;
         THROW;
      END CATCH
      EXEC sp_assert_tbl_pop 'PathogenChemical';
      -----------------------------------------------------------------------------------
      -- 18: ProductUse table 
      -----------------------------------------------------------------------------------
      -- 241027: It may be that that staging ids are different for a given name and may conflict other ids in the table.
      --         In which case we need to assign a new id and use that in the associated link tables.
      --         Make the main table id field auto incremental.
      EXEC sp_log 2, @fn, '200: merging ProductUse link table';
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
      EXEC sp_assert_tbl_pop 'ProductUse';
      -----------------------------------------------------------------------------------
      -- 19: Update the ProductCompany link table with product nm & id and company nm & id 
      -----------------------------------------------------------------------------------
      -- 241027: It may be that that staging ids are different for a given name and may conflict other ids in the table.
      --         In which case we need to assign a new id and use that in the associated link tables.
      --         Make the main table id field auto incremental.
      EXEC sp_log 2, @fn, '210: merging ProductCompany link table';
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
      EXEC sp_assert_tbl_pop 'ProductCompany';
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '220: merging ChemicalAction link table';
      -----------------------------------------------------------------------------------
      EXEC sp_pop_chemicalAction;
      -----------------------------------------------------------------------------------
      -- 20: DistributorManufacturer
      -----------------------------------------------------------------------------------
      -- 241027: It may be that that staging ids are different for a given name and may conflict other ids in the table.
      --         In which case we need to assign a new id and use that in the associated link tables.
      --         Make the main table id field auto incremental.
      EXEC sp_log 2, @fn, '230: merging DistributorManufacturer link table';
      MERGE DistributorManufacturer as target
      USING
      (
         SELECT d.distributor_id, c.company_id
         FROM DistributorStaging_vw ds
         JOIN Distributor d ON ds.distributor_nm = d.distributor_nm
         JOIN Company     c ON c.company_nm      = ds.manufacturer_nm
      ) AS S
      ON target.distributor_id = s.distributor_id AND target.manufacturer_id = s.company_id
      WHEN NOT MATCHED BY target THEN
         INSERT (  distributor_id,   manufacturer_id)
         VALUES (s.distributor_id, s.company_id)
      ;
      EXEC sp_assert_tbl_pop 'DistributorManufacturer';
      -----------------------------------------------------------------------------------
      -- 21: do any main table fixup: 
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '240: do any main table fixup: currently none';
      -----------------------------------------------------------------------------------
      -- 22  POSTCONDITION checks
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '250: POSTCONDITION checks   ';
   -- POST 03: ChemicalAction table populated
   -- POST 04: ChemicalProduct table populated
   -- POST 05: ChemicalUse table populated
   -- POST 08: CropPathogen table populated
   -- POST 11: PathogenChemical table populated
   -- POST 12: PathogenType table populated
   -- POST 13: Product table populated
   -- POST 14: ProductCompany table populated
   -- POST 15: ProductUse table populated
   -- POST 18: DistributorManufacturer populated
      EXEC sp_mrg_mn_tbls_post_cks;
      -----------------------------------------------------------------------------------
      -- 23: Completed processing OK
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '400: Completed processing OK';
   END TRY
   BEGIN CATCH
      SET @error_msg = ERROR_MESSAGE();
      EXEC sp_log 4, @fn, '500: Caught exception: ', @error_msg;
      THROW;
   END CATCH
   EXEC sp_log 2, @fn, '999: leaving: OK';
END
/*
EXEC sp_import_callRegister 'D:\Dev\Farming\Data\CallRegister.txt';
EXEC sp_reset_CallRegister;
EXEC sp_mrg_mn_tbls;
*/
GO

