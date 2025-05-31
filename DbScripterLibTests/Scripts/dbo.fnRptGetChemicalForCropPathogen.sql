SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      TerryWatts
-- Create date: 24-JUN-2023
-- Description: gets the list of chemicals for
--    a given crop and pathogen
-- =============================================
ALTER FUNCTION [dbo].[fnRptGetChemicalForCropPathogen]
(
    @crop      NVARCHAR(60)
   ,@pathogen  NVARCHAR(60)
)
RETURNS
@t TABLE
(
   crop     NVARCHAR(60),
   pathogen NVARCHAR(50),
   chemical NVARCHAR(60)
)
AS
BEGIN
   INSERT INTO @t (crop, pathogen, chemical)
   SELECT crop_nm, pathogen_nm, chemical_nm
   FROM rpt_chemical_pathogen_crop_vw
   WHERE  (pathogen_nm = @pathogen OR @pathogen IS NULL)
      AND (crop_nm     = @crop     OR @crop     IS NULL)

   RETURN
END
/*
SELECT * FROM dbo.fnRptGetChemicalForCropPathogen('Banana','Sigatoka');
SELECT * FROM dbo.fnRptGetChemicalForCropPathogen(NULL, NULL);

SELECT * FROM rpt_chemical_pathogen_crop_vw where pathogen_nm = 'Sigatoka'
*/

GO
