SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===================================================
-- Author:		 Terry Watts
-- Create date: 17-JUL-20223
-- Description: List the Crops in order - use to
--    look for duplicates and misspellings and errors
-- ===================================================
ALTER FUNCTION [dbo].[fnListCrops]()
RETURNS 
@t TABLE (crop NVARCHAR(250))
AS
BEGIN
   INSERT INTO @t
   SELECT DISTINCT 
   cs.value AS crop
   FROM Staging2 
   CROSS APPLY string_split(crops, ',') cs
   WHERE cs.value NOT IN ('', '-','--')

	RETURN 
END
/*
SELECT crop from dbo.fnListCrops()
*/

GO
