SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 27-JUL-2023
-- Description: splits the individual crop out of the staging2 crops field
--    filters out empty an - or -- entries
--
-- PRECONDITIONS: Dependencies: Staging2 upto date
--   Dependencies: staging2
--
-- ======================================================================================================
CREATE   VIEW [dbo].[crop_staging_vw]
AS
SELECT id, cs.value as crop FROM staging2 
CROSS Apply string_split(crops, ',') cs WHERE cs.value not in ('', '-','--');

/*
SELECT TOP 50 * FROM crop_staging_vw;
SELECT TOP 50 * FROM CropStaging
*/


GO
