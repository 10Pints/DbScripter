SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ================================================
-- Author:      Terry Watts
-- Create date: 31-OCT-2024
-- Description: returns pathogens that effect crops
-- ================================================
ALTER FUNCTION [dbo].[fnGetPathogensByCropAndType]
(
    @crop_nm            VARCHAR(60)
   ,@pathogen_type_nm   VARCHAR(60)
)
RETURNS
@t TABLE
(
    pathogen_nm      VARCHAR(150)
   ,pathogen_type_nm VARCHAR(60)
   ,crop_nm          VARCHAR(60)
)
AS
BEGIN
   INSERT INTO @t(pathogen_nm, crop_nm)
   SELECT DISTINCT value, s.crops
   FROM  Staging2 s CROSS APPLY string_split(pathogens, ',') X
   LEFT JOIN Pathogen p ON X.value = p.pathogen_nm
   WHERE (s.crops LIKE CONCAT('%',@crop_nm, '%') OR @crop_nm IS NULL) AND (pathogenType_nm LIKE @pathogen_type_nm OR @pathogen_type_nm IS NULL)
   AND value <> ''
   RETURN;
END
/*
SELECT * from dbo.fnGetPathogensByCropAndType('Banana','Insect') ORDER BY pathogen_nm;
SELECT * from dbo.fnGetPathogensByCropAndType('Banana',NULL);
SELECT * from dbo.fnGetPathogensByCropAndType(NULL,'Crickets');
SELECT * FROM Pathogen
*/

GO
