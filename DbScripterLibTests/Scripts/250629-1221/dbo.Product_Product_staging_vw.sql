SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 05-OCT-2023
-- Description: relates teh new and exisiting product ids
--
-- CHANGES:
--    
-- ==============================================================================
CREATE   VIEW [dbo].[Product_Product_staging_vw]
AS
SELECT ps.product_nm as new_product_nm, p.product_nm AS existing_product_nm, p.product_id as existing_product_id
FROM Product p LEFT JOIN ProductStaging ps ON p.product_nm = ps.product_nm;


GO
