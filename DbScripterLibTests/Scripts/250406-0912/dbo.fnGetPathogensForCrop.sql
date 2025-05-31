SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 31-OCT-2024
-- Description: Lists the diseases for a given crop
--                uses the LIKE command
-- =============================================
ALTER FUNCTION [dbo].[fnGetPathogensForCrop]
(
   @crop_nm VARCHAR(60)
)
RETURNS
@t TABLE
(
    crop_nm       VARCHAR(100)
   ,pathogen_nm   VARCHAR(100)
)
AS
BEGIN
   INSERT INTO @t(crop_nm, pathogen_nm) --, pathogen_id)
   SELECT DISTINCT @crop_nm, value --crop_nm, pathogen_nm, pathogen_id 
   FROM Staging2 CROSS APPLY string_split(pathogens, ',') x
   WHERE crops LIKE CONCAT('%',@crop_nm,'%') AND value <> '';
   RETURN;
END
/*
SELECT * FROM dbo.[fnGetPathogensForCrop2]('Banana') ORDER BY pathogen_nm;
SELECT TOP 500 * FROM crop_pathogen_vw
SELECT distinct pathogens FROM Staging2 WHERE crops='Banana' and pathogens like '%grass%';

   SELECT top 100 
   id, crops,pathogens,ingredient
   FROM Staging2 
   WHERE crops LIKE '%Banana%';

*/


GO
