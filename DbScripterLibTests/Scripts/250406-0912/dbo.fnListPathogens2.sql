SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ============================================================
-- Author:      Terry Watts
-- Create date: 21-JUN-20223
-- Description: List the Pathogens in order 
--  - use to look for duplicates and misspellings and errors
-- ============================================================
ALTER   FUNCTION [dbo].[fnListPathogens2]()
RETURNS 
@t TABLE (id INT, pathogen VARCHAR(400))
AS
BEGIN
   INSERT INTO @t(id, pathogen)
   SELECT DISTINCT TOP 1000000
   id, cs.value AS pathogen 
   FROM Staging2 
   CROSS APPLY string_split(pathogens, ',') cs
   WHERE cs.value <> ''
   ORDER BY pathogen, id
   RETURN 
END
/*
SELECT id, pathogen from dbo.fnListPathogens2() 
WHERE pathogen like 'A'
*/


GO
