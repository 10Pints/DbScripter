SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================================================================
-- Author:		 Terry Watts
-- Create date: 29-JUL-2023
-- Description: Capitalises the first letter of each pathogen in staging2
--
-- PRECONDITIONS: 
--    Dependencies: staging2 Table
-- ======================================================================================================
ALTER VIEW [dbo].[pathogens_initial_cap_vw]
AS
SELECT stg2_id, STRING_AGG( ut.dbo.fnInitialCap(cs.value), ',') as agPathogens
FROM staging2
CROSS APPLY string_split(pathogens, ',') cs
GROUP BY stg2_id;

/*
SELECT TOP 500 * FROM pathogens_initial_cap_vw;
*/

GO
