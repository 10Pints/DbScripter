SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 05-OCT-2023
-- Description: relates the new and old chemical ids based on name match
--              
-- CHANGES:
--    
-- ==============================================================================
CREATE   VIEW [dbo].[Chemical_Chemical_staging_vw]
AS
SELECT cs.chemical_nm as new_chemical_nm, c.chemical_nm AS existing_chemical_nm, c.chemical_id as existing_chemical_id
FROM ChemicalStaging cs  LEFT JOIN Chemical c  ON c.chemical_nm = cs.chemical_nm



GO
