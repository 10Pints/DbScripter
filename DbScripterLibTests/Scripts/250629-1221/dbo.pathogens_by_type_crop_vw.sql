SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =========================================================================
-- Author:      Terry Watts
-- Create date: 28-OCT-2023
-- Description: returns pathogens that effect crops
-- Lists the pathogen_is, pathogen_nm, pathogen type name, crop name and id
-- =========================================================================
CREATE   VIEW [dbo].[pathogens_by_type_crop_vw]
AS
SELECT  c.crop_nm, p.pathogen_nm, t.pathogenType_nm, cp.crop_id, p.pathogen_id, t.pathogenType_id
FROM        Pathogen p 
LEFT JOIN   PathogenType t  ON p.pathogenType_id = t.pathogenType_id
LEFT JOIN   CropPathogen cp ON cp.pathogen_id    = p.pathogen_id
LEFT JOIN   Crop         c  ON c.crop_id         = cp.crop_id
;
/*
SELECT *
FROM pathogens_by_type_crop_vw
WHERE crop_nm= 'Banana' AND pathogenType_nm = 'Fungus'
*/


GO
