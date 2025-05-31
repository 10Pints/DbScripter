SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===========================================================
-- Author:      Terry Watts
-- Create date: 04-NOV-2023
-- Description: lists the chemicals and their associated uses.
-- ===========================================================
ALTER   VIEW [dbo].[ChemicalUses_vw]
AS
SELECT chemical_nm, string_agg(use_nm, ',') as uses
FROM
(
SELECT distinct chemical_nm, use_nm
FROM ChemicalUse
) X
GROUP BY chemical_nm
/*
SELECT * FROM ChemicalUses_vw where chemical_nm Like '%2,4-d%'
ORDER BY chemical_nm;
*/


GO
