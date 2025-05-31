SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =================================================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2024
-- Description: runs detailed post condition checks of any db state
--
-- PRECONDITIONS:
--    none
--
-- POSTCONDITIONS:
-- POST 01: no line feed only line separator
-- POST 02: crop name contains none of the following: (' Beans','  Popcorn)','Banana (Cavendish) (Post- harvest treatment)', 'Banana (Cavendish) as insecticidal soap','Cowpea and other beans','Soybeans & other beans'))
-- POST 03: no apostophe in pathogens
-- POST 04: Pathogen.pathogen_type_id IS NOT NULL
-- POST 05: Pathogen.pathogen_nm does not contain ('Bacterial wilt and','As foot ','Foot ','Golden apple Snails','Ripening')
-- POST 06:
-- POST 07:
-- POST 08:
--
-- STRATEGY:
-- 01: check no Character 10 without Character 13 - i.e. no line feed only line separator- XL data has several of these
-- 02: check no spc or spc in the critical columns: crops, pathogens
-- 03: test no blank spc only or NULL essential data
-- 04: check no Character 10 without Character 13 - line feed only - XL data has several of these
-- 02: check no  spc or spc in the critical columns: crops, pathogens
-- 03: test no blank spc only or NULL essential data

-- 05: Chemicals Table:
-- 05.1: Chlorpyrifos/plastech 20% M/b
-- 05.2: Chlorpyrifos/pyritiline 20 Pe M/b
-- 05.3: Mesotrione,Glyphosate,S-Metachlor

-- 06: ChemPathCrp vw
-- 07: ChemicalProduct_vw
-- 08: ChemicalUse
-- 09: Company Table
-- 10: Crop table
-- 11: Pathogen: 1: pathogen_type_id field is populated, 2: crop_pathogen_vw has the pathogen type info id, nm, 3: nm: 'Bacterial wilt and'
-- 12: Import table
-- 13: ProductChemical_vw
-- 14: Pathogen table
-- 15: Product table
-- 16: ProductUse_vw
-- 17: Type table
-- 18: Use table
--
-- CHANGES:
-- =================================================================
ALTER PROCEDURE [dbo].[sp_main_import_stage_09_post_cks]
AS
BEGIN
   DECLARE
    @fn        NVARCHAR(35)   = 'MAIN_IMPRT_STG_09'
   ,@cnt                INT            = 0
   ,@err_cnt            INT            = 1
   ,@err_msg            NVARCHAR(250)  = NULL
   ,@msg                NVARCHAR(250)  = NULL
   ,@table              NVARCHAR(100)  = NULL
   ,@field_nm           NVARCHAR(100)  = NULL
   ,@value              NVARCHAR(100)  = NULL

   EXEC sp_log 1, @fn, '00: starting';
   EXEC sp_register_call @fn;

   -----------------------------------------------------------------------------------
   -- Perform the post condition checks for all data
   -----------------------------------------------------------------------------------
   -- 1: test are performed in a do while looop - break on first error
   WHILE 1=1
   BEGIN
      -- 01: staging 1 tests
      -- 02: check no Character 10 without Character 13 - line feed only - XL data has several of these
      -- 03: check no extra spaces in the critical columns: crops, pathogens
      -- 04: test no blank spc only or NULL essential data
      -- 05: Chemicals Table:
      -- 05.1: Chlorpyrifos/plastech 20% M/b
      -- 05.2: Chlorpyrifos/pyritiline 20 Pe M/b
      -- 05.3: Mesotrione,Glyphosate,S-Metachlor
      
      -- 06: ChemPathCrp vw:
      -- 07: ChemicalProduct_vw:
      -- 08: ChemicalUse:
      -- 09: Company Table:

      -- 10: Crop table:
      --  Beans	NULL
      --  Popcorn)
      -- Banana (Cavendish) (Post- harvest treatment)
      -- Banana (Cavendish) as insecticidal soap
      -- Corn (Sweet and Popcorn)
      -- Corn (Sweet corn
      -- Field
      -- foot
      EXEC sp_log 2, @fn,'02: POST 02: Crop name contains none of the following';
      If EXISTS (Select 1 from Crop where crop_nm IN (' Beans','  Popcorn)','Banana (Cavendish) (Post- harvest treatment)', 'Banana (Cavendish) as insecticidal soap','Cowpea and other beans','Soybeans & other beans'))
      BEGIN
         SET @msg      = ''
         SET @table    = 'Crop'
         SET @field_nm = 'crop_nm'
         SET @value    = 'has at least one of these values: [ Beans] or [ Popcorn)] or [Banana (Cavendish) (Post- harvest treatment)] or [Banana (Cavendish) as insecticidal soap], [Cowpea and other beans], [Soybeans & other beans]';
         BREAK;
      END

      -- 231019
     EXEC sp_log 2, @fn,'03: POST 03: no apostophe in pathogens';
     IF EXISTS (SELECT 1 FROM Staging2 where pathogens LIKE '''%')
      BEGIN
            SET @msg = '*** Staging2.pathogens: leading apostophe still exists';
            SET @table    = 'Staging2'
            SET @field_nm = 'pathogens'
            SET @value    = '''';
            BREAK;
      END


-- EXEC sp_investigate_s2_crops '% Beans%'
--                         count
-- Cowpea and other beans	30
-- Soybeans & other beans	17
-- SELECT * from staging2 WHERE crops LIKE '%Cowpea and other beans%' -- now rows
-- SELECT * from staging1 WHERE crops LIKE '%Cowpea and other beans%' -- 30 rows
-- Implies the crops list was taken BEFORE the crops data scrub or the main tables already had the bad data? -> ACT: main tables already had the bad data.
     -- [ Popcorn)]
      -- Banana (Cavendish) (Post- harvest treatment)
      -- Banana (Cavendish) as bunch spray
      -- Banana (Cavendish) as disinfectant
      -- Banana (Cavendish) as insecticidal soap
      -- Banana (Cavendish) as tool disinfectant
      -- Corn (Sweet and Popcorn)
      -- Corn (Sweet corn
      -- Corn (Sweet corn)
      -- Field
      -- foot
      -- Grassland -> Grass
      -- Soil and Space Fumigant
      -- Soil fumigant
      -- Soybean
      -- Soybeans
      -- Soybeans & other beans
      -- Soybeans/Mungbeans
      -- Squash
      -- Stored commodities & processed foods
      -- Stored grain

      -- 11: crop_pathogen_vw:  
      -- Test 1: pathogen_type_id field is populated, 
      -- Test 2: crop_pathogen_vw has the pathogen type info id, nm, 
      -- Test 3: nm: 'Bacterial wilt and','As foot ','Foot ','Golden apple Snails','Ripening'  exists  

      -- Test 1: pathogen_type_id field is populated
      EXEC sp_log 2, @fn,'04: POST 04: Pathogen.pathogen_type_id IS NOT NULL';
      SET @cnt= (SELECT COUNT(*) FROM Pathogen where pathogenType_id IS NULL);

      If @cnt > 0
      BEGIN
         SET @msg      = 'Test 11'
         SET @table    = 'Pathogen'
         SET @field_nm = 'pathogen_type_id'
         SET @value    = CONCAT('has ',@cnt, ' NULLs');

         -- Display all Pathogen rows where pathogenType_id is null
         SELECT pathogen_nm FROM Pathogen where pathogenType_id IS NULL;
         BREAK;
      END

      -- Test 2: crop_pathogen_vw has the pathogen type info id, nm
      -- Test 3: nm: 'Bacterial wilt and','As foot ','Foot ','Golden apple Snails','Ripening'  exists  
      EXEC sp_log 2, @fn,'05: Pathogen.pathogen_nm in ''Bacterial wilt and'',''As foot '',''Foot '',''Golden apple Snails'',''Ripening''';
      -- Select * FROM Pathogen WHERE pathogen_nm IN ('Bacterial wilt and','As foot ','Foot ','Golden apple Snails','Ripening');
      If EXISTS (Select 1 FROM Pathogen WHERE pathogen_nm IN ('Bacterial wilt and','As foot ','Foot ','Golden apple Snails','Ripening'))
      BEGIN
         SET @msg      = ''
         SET @table    = 'Pathogen'
         SET @field_nm = 'pathogen_nm'
         SET @value    = 'has at least one of these values: ''Bacterial wilt and'',''As foot '',''Foot '',''Golden apple Snails'',''Ripening''';
         SELECT * FROM Pathogen WHERE pathogen_nm IN ('Bacterial wilt and','As foot ','Foot ','Golden apple Snails','Ripening');
         BREAK;
      END

      -- 12: Import table: 2 rows 
      --    1: "id,company,ingredient,product,concentration,formulation_type,uses,toxicity_category,registration,expiry,entry_mode,crops,pathogens"
      --    2: 230721	'rate, mrl, phi, re-entry_period'

      -- 13: ProductChemical_vw:
      --       duplicate rows:
      -- chemical_nm	product_nm	chemical_id	product_id
      -- Benomyl	Benomax 50 Wp	37	108
      -- Benomyl	Benomex 50 Wp	37	109


      -- 14: Pathogen table:
      -- As foot 
      -- Bacterial wilt and
      -- Cabagge moth
      -- Corn
      -- Foot 
      -- Golden apple Snail, Golden apple Snails
      -- hoppers-> Hoppers
      -- Leaf
      -- Leaf miner,Leafminer
      -- Leaf roller, Leafroller
      -- Pineaple mites -> Pineapple mites
      -- Ripening
      -- Tire 
      -- Tool

      -- 15: Product table:
      -- Choice 10 Sc *
      -- ** Productshould have a company field FK


      -- 16: ProductUse_vw
      -- 17: Type table:
      -- 18: Use table:
      SET @err_cnt = 0;
      EXEC sp_log 2, @fn, '95: completed tests ok, ret: ', @err_cnt;
      BREAK;
   END
   -- IF error
   IF @err_cnt > 0
   BEGIN
      SET @err_msg = CONCAT('*** Error *** :  table: ', @table, ' field: ', @field_nm, ' value: [', @value, ']');
      EXEC sp_log 2, @fn, @err_msg;
      THROW 56821, @err_msg,1;
   END

   EXEC sp_log 2, @fn, '90: processing complete';
   EXEC sp_log 1, @fn, '99: leaving';
END
/*
   EXEC sp_main_import_stage_09;
   EXEC sp_clear_call_register 'SP_MAIN_IMPORT_STAGE_09';
*/

GO
