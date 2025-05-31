SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 29-JUL-2023
-- Description: splits the individual pathogen out of the pathogens column in Staging2 
--
-- PRECONDITIONS: 
-- Dependencies: Staging2 table
-- ======================================================================================================
ALTER   VIEW [dbo].[pathogen_staging_vw]
AS
SELECT TOP 100000 id, cs.value AS pathogen_nm
FROM staging2 
CROSS APPLY STRING_SPLIT(pathogens, ',') cs 
WHERE cs.value NOT IN ('')
ORDER BY id, cs.value
;

/*
SELECT TOP 50 * FROM pathogen_staging_vw;
*/


GO
