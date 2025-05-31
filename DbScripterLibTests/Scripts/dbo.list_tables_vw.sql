SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================================
-- Author:		 Terry Watts
-- Create date: 05-OCT-2023
-- Description: lists the dbo tables - can be used to generate scripts
-- Can be used to generate scripts             
--
-- CHANGES:
-- ==============================================================================
ALTER VIEW  [dbo].[list_tables_vw]
AS
SELECT top 1000 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE='BASE TABLE' AND TABLE_SCHEMA='dbo' AND TABLE_NAME NOT IN ('JapChemical','ImportCorrectionsStaging_bak','staging1_bak_221008','staging1_bak','staging1', 'staging2'
,'staging2_bak_221008', 'staging3', 'staging4', 'sysdiagrams') 
ORDER BY TABLE_NAME;

/*
SELECT CONCAT('SELECT * FROM ', TABLE_NAME, ';') FROM list_tables_vw WHERE TABLE_NAME like '%_221008'
SELECT * FROM Chemical_221008;
SELECT * FROM ChemicalAction_221008;
SELECT * FROM ChemicalProduct_221008;
SELECT * FROM ChemicalUse_221008;
SELECT * FROM Company_221008;
SELECT * FROM Crop_221008;
SELECT * FROM CropPathogen_221008;
SELECT * FROM Pathogen_221008;
SELECT * FROM PathogenChemical_221008;
SELECT * FROM PathogenType_221008;
SELECT * FROM Product_221008;
SELECT * FROM ProductCompany_221008;
SELECT * FROM ProductUse_221008;
SELECT * FROM S1_221008;
SELECT * FROM S2_221008;


SELECT routine_name, created 
FROM INFORMATION_SCHEMA.ROUTINES
WHERE routine_schema='dbo'
AND 
*/


GO
