SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      TerryWatts
-- Create date: 24-JUN-2023
-- Description: gets the list of chemicals for 
--    a given crop and pathogen
-- =============================================
ALTER   FUNCTION [dbo].[fnRptGetChemicalForPathogenCrop]
(
    @pathogen  VARCHAR(60)
   ,@crop      VARCHAR(60)
)
RETURNS
@t TABLE
(
   crop     VARCHAR(60),
   pathogen VARCHAR(50),
   chemical VARCHAR(60)
)
AS
BEGIN
   INSERT INTO @t (crop, pathogen, chemical)
   SELECT crop_nm, pathogen_nm, chemical_nm
   FROM rpt_chemical_pathogen_crop_vw
   WHERE  (pathogen_nm = @pathogen OR @pathogen  IS NULL)
      AND (crop_nm = @crop OR @crop IS NULL)

   RETURN
END
/*
SELECT * FROM dbo.fnRptGetChemicalForPathogenCrop('Sigatoka', 'Banana');
SELECT * FROM dbo.fnRptGetChemicalForPathogenCrop(NULL, NULL);
*/


GO
