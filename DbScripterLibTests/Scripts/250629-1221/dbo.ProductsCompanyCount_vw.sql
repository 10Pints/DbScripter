SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==================================================================================
-- Author:      Terry Watts
-- Create date: 09-OCT-2023
-- Description: lists the products and the count of companies that market them
--
-- CHANGES:
--
-- ==================================================================================
CREATE   VIEW [dbo].[ProductsCompanyCount_vw]
AS
SELECT TOP 100000 product_nm, product_id, count(company_id) as cnt_companies
FROM ProductCompany_vw
GROUP BY product_nm, product_id
ORDER BY count(company_id) DESC, product_nm ASC;

/*
SELECT TOP 150 * FROM ProductsCompanyCount_vw;

SELECT TOP 50 * FROM ProductCompany_vw;

----------------------------------------------------
SELECT * 
FROM ProductsCompanyCount_vw pcc
JOIN ProductCompany_vw       pc ON  pc.
----------------------------------------------------
SELECT product_nm, count(company_id) as cnt_companies
FROM ProductCompany_vw
GROUP BY product_nm
ORDER BY count(company_id) DESC, product_nm ASC;

*/


GO
