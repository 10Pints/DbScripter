SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==================================================================================
-- Author:      Terry Watts
-- Create date: 07-OCT-2023
-- Description: lists the products and their associated chemicals from the main tables
--
-- ==================================================================================
ALTER   VIEW [dbo].[ProductChemical_vw]
AS
SELECT TOP 100000 c.chemical_nm, p.product_nm, c.chemical_id, p.product_id
FROM ChemicalProduct cp
LEFT JOIN Product  p ON p.product_id  = cp.product_id 
LEFT JOIN Chemical c ON c.chemical_id = cp.chemical_id
ORDER BY product_nm, chemical_nm

/*
SELECT TOP 50 * FROM ProductChemical_vw
*/    



GO
