SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===================================================
-- Author:      Terry Watts
-- Create date: 21-JUN-20223
-- Description: List the Pathogens in order - use to
--    look for duplicates and misspellings and errors
-- ===================================================
CREATE   VIEW [dbo].[distinct_pathogens_vw] 
AS
   SELECT DISTINCT TOP 100000 cs.value AS pathogen 
   FROM Staging2 
   CROSS APPLY string_split(pathogens, ',') cs
   WHERE cs.value <> ''
   ORDER BY pathogen

/*
 SELECT * FROM distinct_pathogens_vw;
*/


GO
