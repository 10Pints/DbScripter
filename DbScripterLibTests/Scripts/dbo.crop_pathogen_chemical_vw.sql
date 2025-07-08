SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 30-NOV-2024
-- Description: lists pathogens, chemicals and crops the chemical can be used on 
--              from the staging tables
--
-- CHANGES:
--    231007: uses the name fields now
-- ==============================================================================
CREATE   VIEW [dbo].[crop_pathogen_chemical_vw]
AS
SELECT TOP 10000 ch.chemical_nm, crp.crop_nm, p.pathogen_nm
FROM 
          PathogenChemical   pc
LEFT JOIN Chemical           ch    ON pc.chemical_nm   = ch.chemical_nm
LEFT JOIN Pathogen           p     ON p.pathogen_nm    = pc.pathogen_nm
LEFT join CropPathogen       crpp  ON crpp.pathogen_nm = p.pathogen_nm
LEFT join Crop               crp   ON crp.crop_nm      = crpp.crop_nm
ORDER BY ch.chemical_nm, crp.crop_nm, p.pathogen_nm

/*
SELECT * FROM crop_pathogen_chemical_vw

SELECT TOP 1000 pc.*
FROM 
          PathogenChemical   pc
LEFT JOIN Chemical           ch    ON pc.chemical_nm   = ch.chemical_nm
LEFT JOIN Pathogen           p     ON p.pathogen_nm    = pc.pathogen_nm
LEFT join CropPathogen       crpp  ON crpp.pathogen_nm = p.pathogen_nm
LEFT join Crop               crp   ON crp.crop_nm      = crpp.crop_nm
ORDER BY ch.chemical_nm, crp.crop_nm, p.pathogen_nm

SELECT * FROM CropStaging
SELECT * FROM PathogenStaging
SELECT * FROM ChemicalStaging
SELECT * FROM PathogenChemicalStaging
*/


GO
