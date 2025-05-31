SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 14-MAR-2024
-- Description: lists unmatched PathogenChemicalStaging pathogens that merge can't handle
--
-- Uses
--   in sp_merge_normalised_tables when the PathogenChemical merge fails due to mismatched pathogen names
-- ======================================================================================================
ALTER VIEW [dbo].[list_unmatched_PathogenChemicalStaging_pathogens_vw]
AS
SELECT DISTINCT TOP 1000 pcs.pathogen_nm
FROM
   PathogenChemicalStaging pcs
   LEFT JOIN Pathogen p      ON p.pathogen_nm      = pcs.pathogen_nm
   LEFT JOIN PathogenType pt ON pt.pathogenType_id = p.pathogenType_id
WHERE 
pt.pathogenType_id IS NULL
ORDER BY pcs.pathogen_nm;
/*
SELECT TOP 50 * FROM list_unmatched_PathogenChemicalStaging_pathogens_vw;
*/

GO
