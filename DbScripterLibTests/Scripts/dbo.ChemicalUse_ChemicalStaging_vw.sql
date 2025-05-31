SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ============================================================================================
-- Author:       Terry Watts
-- Create date:  06-OCT-2023
-- Description:  list the main table and staging table ids and names for th echemicals
--
-- Dependencies: PRECONDITION: ChemicalUse and Use tables popd with the new rows if any 
--
-- CHANGES:
--    240121: removed import_id
-- ============================================================================================
ALTER VIEW [dbo].[ChemicalUse_ChemicalStaging_vw]
AS
SELECT TOP 20000 chemical_nm, use_nm
FROM ChemicalUseStaging cs 
ORDER BY chemical_nm, use_nm;
/*
SELECT * FROM ChemicalUse_ChemicalStaging_vw;
SELECT * FROM ChemicalUseStaging;
SELECT * FROM ChemicalStaging;
*/

GO
