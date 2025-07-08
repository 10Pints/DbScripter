SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==================================================================================================================================================
-- Author:      Terry Watts
-- Create date: 03-JAN-2025
-- Description: Merges the static data staging tables to theirassociated main static tables
--       and do any fixup
--
-- REQUIREMENTS:
-- R01: populate the DEL01 set using the PRE01 set of tables
--
-- PRECONDITIONS:
-- PRE01: the following set of staging tables are populated and fixed up
--    PRE01: ActionStaging
--    PRE02: ChemicalStaging
--    PRE06: CompanyStaging
--    PRE07: CropStaging
----  PRE09: PathogenStaging
--    PRE11: PathogenTypeStaging
--    PRE12: PathogenPathogenStaging
--    PRE15: TypeStaging
--    PRE16: UseStaging
--    PRE17: DistributorStaging
--
-- PRE02: import id session setting set or is a parameter
--
-- POSTCONDITIONS
-- POST 01: the following static data tables are populated and fixed up:
--    Action
--    Chemical
--    Company
--    Crop
--    Distributor
--    Pathogen
--    PathogenType
--    Type
--    Use
--
-- TESTS:
--
-- CHANGES:
-- ==================================================================================================================================================
CREATE PROCEDURE [dbo].[sp_merge_static_tbls]
AS
BEGIN
   SET NOCOUNT OFF;

   DECLARE
       @fn        VARCHAR(30)  = N'sp_merge_static_tbls'
      ,@error_msg VARCHAR(MAX)  = NULL
      ,@file_path VARCHAR(MAX)
      ,@id        INT = 1

   BEGIN TRY
      EXEC sp_log 2, @fn,'000: starting';

      -----------------------------------------------------------------------------------
      -- Precondition checks
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '010: checking preconditions';
      EXEC sp_assert_tbl_pop 'ActionStaging';
      EXEC sp_assert_tbl_pop 'ChemicalStaging';
      EXEC sp_assert_tbl_pop 'CompanyStaging';
      EXEC sp_assert_tbl_pop 'CropStaging';
      EXEC sp_assert_tbl_pop 'DistributorStaging';
      EXEC sp_assert_tbl_pop 'PathogenStaging';
      EXEC sp_assert_tbl_pop 'PathogenTypeStaging';
      EXEC sp_assert_tbl_pop 'TypeStaging';
      EXEC sp_assert_tbl_pop 'UseStaging';

      -----------------------------------------------------------------------------------
      --  03: merging static data tables
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'020: merging static data tables   ';

      DELETE FROM [Action];
      DELETE FROM Chemical;
      DELETE FROM Company;
      DELETE FROM Crop;
      DELETE FROM Distributor;
      DELETE FROM Pathogen;
      DELETE FROM PathogenType;
      DELETE FROM [Type];
      DELETE FROM [Use];

      -----------------------------------------------------------------------------------
      --  04: Merge Action table
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '030: merging Action table';
      MERGE [Action]        AS target
      USING ActionStaging   AS s
      ON target.action_nm = s.action_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  action_nm) -- use new id
         VALUES (s.action_nm)
      WHEN NOT MATCHED BY SOURCE THEN DELETE
      ;

      EXEC sp_assert_tbl_pop 'Action';

      -----------------------------------------------------------------------------------
      --  05: Merge Type table
      -----------------------------------------------------------------------------------
      -- 241027: It may be that that staging ids are different for a given name and may conflict other ids in the table.
      -- In which case we need to assign a new id and use that in the associated link tables.
      -- Make the main table id field auto incremental.
      EXEC sp_log 2, @fn, '040: merging Type table';
      MERGE [Type]        AS target
      USING TypeStaging   AS s
      ON target.type_nm = s.type_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  type_nm)
         VALUES (s.type_nm)
      WHEN NOT MATCHED BY SOURCE THEN DELETE
      ;

      EXEC sp_assert_tbl_pop 'Type';

      -----------------------------------------------------------------------------------
      --  Merge Use table
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '040: merging Use table';
      MERGE [Use]        AS target
      USING UseStaging   AS s
      ON target.use_nm = s.use_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  use_id,  use_nm)
         VALUES (s.use_id,s.use_nm)
      WHEN NOT MATCHED BY SOURCE THEN DELETE
      ;

      EXEC sp_assert_tbl_pop 'Use';

      -----------------------------------------------------------------------------------
      --  06: Merge PathogenType table
      -----------------------------------------------------------------------------------
      -- 241027: It may be that that staging ids are different for a given name and may conflict other ids in the table.
      -- In which case we need to assign a new id and use that in the associated link tables.
      -- Make the main table id field auto incremental.
      EXEC sp_log 2, @fn, '050: merging PathogenType table';
      MERGE PathogenType          AS target
      USING PathogenTypeStaging   AS s
      ON target.pathogenType_nm = s.pathogenType_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  pathogenType_nm)
         VALUES (s.pathogenType_nm)
      WHEN NOT MATCHED BY SOURCE THEN DELETE
      ;

      EXEC sp_assert_tbl_pop 'PathogenType';

      -----------------------------------------------------------------------------------
      --  07: Merge Pathogen table
      -----------------------------------------------------------------------------------
      -- 241027: It may be that that staging ids are different for a given name and may conflict other ids in the table.
      -- In which case we need to assign a new id and use that in the associated link tables.
      -- Make the main table id field auto incremental.
      EXEC sp_log 2, @fn, '060: merging Pathogen table';
      MERGE Pathogen AS target
      USING 
      (
         SELECT pt.pathogenType_id, ps.pathogen_nm, pt.pathogenType_nm, subtype, latin_nm, alt_common_nms, alt_latin_nms, ph_common_nms, crops, taxonomy, notes, urls, biological_cure
         FROM PathogenStaging ps
         LEFT JOIN PathogenType pt ON pt.pathogenType_nm = ps.pathogenType_nm
      )  AS s
      ON target.pathogen_nm = s.pathogen_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  pathogen_nm,  pathogenType_id,  pathogenType_nm,  subtype,  latin_nm,  alt_common_nms,  alt_latin_nms,  ph_common_nms,  crops,  taxonomy,  notes,  urls,  biological_cure)
         VALUES (s.pathogen_nm,s.pathogenType_id,s.pathogenType_nm,s.subtype,s.latin_nm,s.alt_common_nms,s.alt_latin_nms,s.ph_common_nms,s.crops,s.taxonomy,s.notes,s.urls,s.biological_cure)
      -- WHEN MATCHED THEN UPDATE SET target.pathogenType_id = S.pathogenType_id  -- should be a 1 off
      WHEN NOT MATCHED BY SOURCE THEN DELETE
      ;

      EXEC sp_assert_tbl_pop 'Pathogen';

      -----------------------------------------------------------------------------------
      --  08: Merge Chemical table
      -----------------------------------------------------------------------------------
      -- It may be that that staging ids are different for a given name and may conflict other ids in the table.
      -- In which case we need to assign a new id and use that in the associated link tables.
      -- Make the main table id field auto incremental.
      EXEC sp_log 2, @fn, '070: merging Chemical table';
      MERGE Chemical          AS target
      USING ChemicalStaging   AS s
      ON target.chemical_nm=s.chemical_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  chemical_nm)
         VALUES (s.chemical_nm)
      WHEN NOT MATCHED BY SOURCE THEN DELETE
         ;

      EXEC sp_assert_tbl_pop 'Chemical';

      -----------------------------------------------------------------------------------
      -- 09: Merge Company table
      -----------------------------------------------------------------------------------
      -- It may be that that staging ids are different for a given name and may conflict other ids in the table.
      -- In which case we need to assign a new id and use that in the associated link tables.
      -- Make the main table id field auto incremental.
      EXEC sp_log 2, @fn, '080: merging Company table';
      MERGE Company          AS target
      USING CompanyStaging   AS s
      ON target.company_nm = s.company_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  company_nm)
         VALUES (s.company_nm)
      WHEN NOT MATCHED BY SOURCE THEN DELETE
         ;

      EXEC sp_assert_tbl_pop 'Company';

      -----------------------------------------------------------------------------------
      -- 10: Merge Crop table
      -----------------------------------------------------------------------------------
      -- It may be that that staging ids are different for a given name and may conflict other ids in the table.
      -- In which case we need to assign a new id and use that in the associated link tables.
      -- Make the main table id field auto incremental.
      EXEC sp_log 2, @fn, '090: merging Crop table';
      DELETE FROM Crop;

      MERGE Crop          AS target
      USING 
      (
         SELECT * FROM CropStaging
      )   AS s
      ON target.crop_nm=s.crop_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  crop_nm, latin_nm, alt_latin_nms, alt_common_nms,taxonomy,notes)
         VALUES (s.crop_nm, latin_nm, alt_latin_nms, alt_common_nms,taxonomy,notes)
      WHEN NOT MATCHED BY SOURCE THEN DELETE
         ;

      EXEC sp_assert_tbl_pop 'Crop';

      -----------------------------------------------------------------------------------
      -- 11: Merge Distributor table
      -----------------------------------------------------------------------------------
      -- 241027: It may be that that staging ids are different for a given name and may conflict other ids in the table.
      --         In which case we need to assign a new id and use that in the associated link tables.
      --         Make the main table id field auto incremental.
      EXEC sp_log 2, '100: merging Distributor table';
      MERGE Distributor          AS target
      USING 
      (
        SELECT * FROM DistributorStaging
      ) AS s
      ON target.distributor_nm=s.distributor_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  distributor_nm)
         VALUES (s.distributor_nm)
      WHEN NOT MATCHED BY SOURCE THEN DELETE
         ;

      EXEC sp_assert_tbl_pop 'Distributor';

      -----------------------------------------------------------------------------------
      -- ASSERTION: all the main static data tables merged
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'120: ASSERTION: all the static data tables merged.';

      -----------------------------------------------------------------------------------
      -- POSTCONDITION checks
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '250: POSTCONDITION checks   ';
   -- POST 01: Action table populated
   -- POST 02: Chemical table populated
   -- POST 03: Company table populated
   -- POST 04: Crop table populated
   -- POST 05: Distributor table populated
   -- POST 06: Pathogen table populated
   -- POST 07: PathogenType table populated
   -- POST 08: Type table populated
   -- POST 09: Use table populated

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
SELECT COUNT(*) FROM Pathogenstaging;
EXEC sp_mrg_static_tbls;
SELECT COUNT(*) FROM Action;
SELECT COUNT(*) FROM Chemical;
SELECT COUNT(*) FROM Company;
SELECT COUNT(*) FROM Crop;
SELECT COUNT(*) FROM Distributor;
SELECT COUNT(*) FROM PathogenType;
SELECT COUNT(*) FROM Pathogen;
SELECT COUNT(*) FROM [Type];
SELECT COUNT(*) FROM [Use];
*/

GO
