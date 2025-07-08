SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==================================================================================
-- Author:      Terry Watts
-- Create date: 04-NOV-2023
-- Description: lists the chemicals and their associated uses from the main tables
-- ==================================================================================
CREATE   VIEW [dbo].[ChemicalUse_vw]
AS
SELECT TOP 100000 c.chemical_nm, u.use_nm, c.chemical_id, u.use_id
FROM ChemicalUse cu
LEFT JOIN Chemical c ON c.chemical_id = cu.chemical_id
LEFT JOIN [Use]    u ON u.use_id  = cu.use_id 
ORDER BY chemical_nm, use_nm;

/*
SELECT TOP 50 * FROM ChemicalUse_vw
*/


GO
