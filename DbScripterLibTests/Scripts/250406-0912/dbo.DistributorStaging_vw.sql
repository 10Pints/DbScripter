SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 05-MAR-2024
-- Description: separates the manufacturers
--
-- CHANGES:
--
-- ==============================================================================
ALTER   VIEW [dbo].[DistributorStaging_vw]
AS
SELECT distributor_nm, value as manufacturer_nm
FROM DistributorStaging CROSS APPLY string_split(manufacturers, ',');
/*
SELECT * FROM DistributorStaging_vw
*/


GO
