SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:		 Terry Watts
-- Create date: 08-OCT-2023
-- Description: Lists the diseases for a given crop
--                uses the LIKE command
-- CHANGES:
--
-- =============================================
ALTER FUNCTION [dbo].[fnGetPathogensForCrop]
(
	@crop_nm NVARCHAR(60)
)
RETURNS 
@t TABLE 
(
    crop_nm       NVARCHAR(100)
   ,pathogen_nm   NVARCHAR(100)
   ,pathogen_id   INT
)
AS
BEGIN
	INSERT INTO @t(crop_nm, pathogen_nm, pathogen_id)
   SELECT crop_nm, pathogen_nm, pathogen_id FROM crop_pathogen_vw WHERE crop_nm LIKE @crop_nm;
	
	RETURN 
END
/*
SELECT * FROM dbo.[fnGetPathogensForCrop]('Banana');
SELECT TOP 500 * FROM crop_pathogen_vw
SELECT distinct pathogens FROM Staging2 WHERE crops='Banana' and pathogens like '%grass%'
*/

GO
