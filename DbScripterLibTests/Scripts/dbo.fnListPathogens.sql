SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ========================================================================================
-- Author:      Terry Watts
-- Create date: 21-JUN-20223
-- Description: List the Pathogens in order - use to
--    look for duplicates and misspellings and errors
--
--    *** NB: use list_unregistered_pathogens_vw in preference to fnListPathogens()
--    as fnListPathogens yields a false leading space on some items
-- ========================================================================================
ALTER FUNCTION [dbo].[fnListPathogens]()
RETURNS 
@t TABLE (pathogen NVARCHAR(400))
AS
BEGIN
   INSERT INTO @t
   SELECT DISTINCT TOP 100000 
   cs.value AS pathogen 
   FROM Staging2 
   CROSS APPLY string_split(pathogens, ',') cs
   WHERE cs.value <> ''
   ORDER BY pathogen;

   RETURN;
END
/*
SELECT pathogen from dbo.fnListPathogens();
*/

GO
