SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==================================================================================
-- Author:      Terry Watts
-- Create date: 07-OCT-2023
-- Description: lists the products and their associated uses from the staging tables
-- ==================================================================================
ALTER VIEW [dbo].[ProductUseStaging_vw]
AS
SELECT TOP 100000 product_nm, use_nm
FROM ProductUseStaging pu
ORDER BY product_nm, use_nm

/*
SELECT TOP 200 * FROM ProductUseStaging_vw
*/

GO
