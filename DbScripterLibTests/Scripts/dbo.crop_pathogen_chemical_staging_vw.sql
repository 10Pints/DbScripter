SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 20-SEP-2023
-- Description: lists pathogens, chemicals and crops the chemical can be used on 
--              from the staging tables
--
-- CHANGES:
--    231007: uses the name fields now
-- ==============================================================================
ALTER VIEW [dbo].[crop_pathogen_chemical_staging_vw]
AS
SELECT TOP 200000 ch.chemical_nm, crp.crop_nm, p.pathogen_nm
FROM 
          PathogenChemicalStaging   pc
LEFT JOIN ChemicalStaging           ch    ON pc.chemical_nm   = ch.chemical_nm
LEFT JOIN PathogenStaging           p     ON p.pathogen_nm    = pc.pathogen_nm
LEFT join CropPathogenStaging       crpp  ON crpp.pathogen_nm = p.pathogen_nm
LEFT join CropStaging               crp   ON crp.crop_nm      = crpp.crop_nm
ORDER BY ch.chemical_nm, crp.crop_nm, p.pathogen_nm

/*
SELECT * FROM CropStaging
SELECT * FROM PathogenStaging
SELECT * FROM ChemicalStaging
SELECT * FROM PathogenChemicalStaging
SELECT * FROM crop_pathogen_chemical_staging_vw
*/

GO
