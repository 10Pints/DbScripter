SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================================
-- Author:      Terry Watts
-- Create date: 07-OCT-2023
-- Description: lists the products and their associated chemicals from the main tables
--
-- ==================================================================================
CREATE   VIEW [dbo].[ChemicalProduct_vw]
AS
SELECT TOP 100000 c.chemical_nm, p.product_nm, c.chemical_id, p.product_id
FROM ChemicalProduct cp
LEFT JOIN Product  p ON p.product_id  = cp.product_id 
LEFT JOIN Chemical c ON c.chemical_id = cp.chemical_id
ORDER BY chemical_nm, product_nm
/*
SELECT chemical_nm, product_nm FROM ChemicalProduct_vw WHERE product_nm liKE '%Brodan 31.5 Ec%'
SELECT chemical_nm, product_nm FROM ChemicalProduct_vw WHERE product_nm liKE '%Heneral 31.5 Ec%'
SELECT chemical_nm, product_nm FROM ChemicalProduct_vw WHERE chemical_nm IN ('Chlorpyrifos','Dimethoate','Thiamethoxam','Lambda Cyhalothrin')
SELECT * FROM Staging1 where product LIKE '%Brodan%'
*/
GO

