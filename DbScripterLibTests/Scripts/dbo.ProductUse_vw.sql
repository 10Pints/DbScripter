SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==================================================================================
-- Author:		 Terry Watts
-- Create date: 07-OCT-2023
-- Description: lists the products and their associated uses from the main tables
-- ==================================================================================
ALTER VIEW [dbo].[ProductUse_vw]
AS
SELECT TOP 100000 p.product_nm, u.use_nm, p.product_id, u.use_id
FROM ProductUse pu
LEFT JOIN Product p ON p.product_id = pu.product_id 
LEFT JOIN [use]   u ON u.use_id     = pu.use_id
ORDER BY product_nm, use_nm

/*
SELECT TOP 200 * FROM ProductUse_vw
SELECT TOP 200 * FROM ProductUse
SELECT TOP 200 * FROM ProductUseStaging
SELECT TOP 200 * FROM ProductUseStaging_vw
SELECT TOP 200 * FROM Product
SELECT TOP 200 * FROM [Use]
*/    

GO
