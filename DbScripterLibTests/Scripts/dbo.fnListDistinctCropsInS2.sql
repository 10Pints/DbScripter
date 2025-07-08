SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===================================================
-- Author:      Terry Watts
-- Create date: 17-JUL-2023
-- Description: List the Crops in order - use to
--    look for duplicates and misspellings and errors
-- ===================================================
CREATE FUNCTION [dbo].[fnListDistinctCropsInS2]()
RETURNS
@t TABLE (crop VARCHAR(250))
AS
BEGIN
   INSERT INTO @t
   SELECT DISTINCT TOP 1000  cs.value AS crop
   FROM Staging2 
   CROSS APPLY string_split(crops, ',') cs
   WHERE cs.value NOT IN ('', '-','--')
   ORDER BY cs.value;

   RETURN;
END
/*
SELECT crop from dbo.fnListDistinctCropsInS2();
*/

GO
