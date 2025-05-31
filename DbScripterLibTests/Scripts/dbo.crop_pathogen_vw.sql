SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==================================================================================
-- Author:		 Terry Watts
-- Create date: 15-SEP-2023
-- Description: lists the crops and their associated pathogens from the main tables
--
-- PRECONDITIONS:
-- Dependencies:
--  Pathogen_staging_vw -> Staging2 table
--  PathogenStaging     -> 
--  Crop_staging_vw     -> Staging2 table
--  CropStaging         -> 
-- ==================================================================================
ALTER VIEW [dbo].[crop_pathogen_vw]
AS
SELECT TOP 10000 c.crop_nm, p.pathogen_nm, c.crop_id, p.pathogen_id
FROM Crop c
LEFT JOIN CropPathogen cp ON c.crop_id     = cp.crop_id
LEFT JOIN Pathogen p      ON p.pathogen_id = cp.pathogen_id
ORDER BY crop_nm, pathogen_nm

/*
SELECT TOP 50 * FROM crop_pathogen_vw;
SELECT pathogen_nm FROM Pathogen;
*/    

GO
