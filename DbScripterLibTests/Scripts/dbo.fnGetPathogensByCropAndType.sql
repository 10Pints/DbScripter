SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:		 Terry Watts
-- Create date: 28-OCT-2023
-- Description: returns pathogens that effect crops
-- =============================================
ALTER FUNCTION [dbo].[fnGetPathogensByCropAndType]
(
    @crop_nm            NVARCHAR(60)
   ,@pathogen_type_nm   NVARCHAR(60)
)
RETURNS 
@t TABLE
(
    pathogen_nm      NVARCHAR(60)
   ,pathogen_type_nm NVARCHAR(60)
   ,crop_nm          NVARCHAR(60)
   ,pathogen_id      INT
   ,crop_id          INT
)
AS
BEGIN
	INSERT INTO @t(pathogen_nm, crop_nm, crop_id, pathogen_id, pathogen_type_nm)
	SELECT TOP 10000 pathogen_nm, crop_nm, crop_id, pathogen_id, pathogenType_nm
   FROM   pathogens_by_type_crop_vw
   WHERE (crop_nm LIKE @crop_nm OR @crop_nm IS NULL) AND (pathogenType_nm LIKE @pathogen_type_nm OR @pathogen_type_nm IS NULL)
   ORDER BY crop_nm, pathogenType_nm ;
	RETURN 
END
/*
SELECT * from dbo.fnGetPathogensByCropAndType('Banana','Insect');
SELECT * from dbo.fnGetPathogensByCropAndType('Banana',NULL);
*/

GO
