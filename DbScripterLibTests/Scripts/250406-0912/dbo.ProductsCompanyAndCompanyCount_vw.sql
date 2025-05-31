SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ================================================================================================
-- Author:      Terry Watts
-- Create date: 09-OCT-2023
-- Description: lists the products and the companies and count of companies that market them
--
-- CHANGES:
--
-- ================================================================================================
ALTER   VIEW [dbo].[ProductsCompanyAndCompanyCount_vw]
AS
SELECT TOP 100000 pc.product_nm, pc.product_id, pcc.cnt_companies, pc.company_nm
FROM ProductsCompanyCount_vw pcc
JOIN ProductCompany_vw       pc ON  pc.product_id=pcc.product_id
ORDER BY pc.product_nm ASC, pc.company_nm ASC;
/*
SELECT * FROM ProductsCompanyAndCompanyCount_vw ORDER BY cnt_companies DESC, product_nm ASC, company_nm ASC;
*/


GO
