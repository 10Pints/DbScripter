SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===================================================
-- Author:      Terry Watts
-- Create date: 17-JUL-20223
-- Description: List the Pathogens in order - use to
--    look for duplicates and misspellings and errors
-- ===================================================
ALTER   VIEW [dbo].[distinct_s1_crop_vw] 
AS
   SELECT DISTINCT TOP 100000 cs.value AS crop 
   FROM Staging1 
   CROSS APPLY string_split(crops, ',') cs
   WHERE cs.value NOT IN ('','-','--')
   ORDER BY crop

/*
SELECT TOP 50 * FROM distinct_s1_crop_vw
*/


GO
