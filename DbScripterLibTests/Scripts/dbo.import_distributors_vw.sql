SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================
-- Author:      Terry Watts
-- Create date: 29-OCT-2023
-- Description: used to import distributors to the staging table
-- ==============================================================
ALTER VIEW [dbo].[import_distributors_vw]
AS
SELECT  distributor_id, region, province, distributor_name, [address], [phone 1], [phone 2]
FROM    DistributorStaging
;

/*
SELECT * FROM import_distributors_vw
WHERE region= 'Region 11'
*/

GO
