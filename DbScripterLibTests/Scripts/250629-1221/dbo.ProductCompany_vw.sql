SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==================================================================================
-- Author:      Terry Watts
-- Create date: 09-OCT-2023
-- Description: lists the products and the companies that market them
--
-- CHANGES:
--
-- ==================================================================================
CREATE   VIEW [dbo].[ProductCompany_vw]
AS
SELECT TOP 100000 p.product_nm, c.company_nm, p.product_id, c.company_id
FROM ProductCompany pc
JOIN Product  p ON p.product_id  = pc.product_id 
JOIN Company c ON c.company_id   = pc.company_id
ORDER BY p.product_nm, c.company_nm

/*
SELECT TOP 50 * FROM ProductCompany_vw
SELECT product_nm, count(company_id) as cnt_companies
FROM ProductCompany_vw
GROUP BY product_nm
ORDER BY count(company_id) DESC;

*/    



GO
