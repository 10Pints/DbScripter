SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:		 TerryWatts
-- Create date: 24-JUN-2023
-- Description: gets the crops for a given pathogen
-- =============================================
ALTER FUNCTION [dbo].[fnRptGetCropsAffectedByPathogen]( @pathogen NVARCHAR(60))
RETURNS 
@t TABLE 
(
   crop     NVARCHAR(60), 
   pathogen NVARCHAR(1000)
)
AS
BEGIN
   INSERT INTO @t (crop, pathogen) 
   SELECT crop_nm, pathogen_nm FROM crop_pathogen_vw where pathogen_nm = @pathogen
   --SELECT DISTINCT CROPS, pathogens from staging2 WHERE Pathogens LIKE CONCAT('%', @pathogen, '%');
	
	RETURN 
END

/*
   SELECT * FROM fnRptGetCropsAffectedByPathogen('Sigatoka');
   SELECT * FROM fnRptGetCropsAffectedByPathogen('hopper') WHERE CROPs LIKE'%Mango%';
   SELECT * FROM crop_pathogen_vw;
   SELECT * FROM chemical_pathogen_crop_staging_vw;
*/

GO
