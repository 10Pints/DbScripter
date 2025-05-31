SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 20-SEP-2023
-- Description: lists pathogens, chemicals and crops the chemical can be used on
--
-- CHANGES:
-- 231007: uses the main tables now
-- 240129: use names not ids
-- ==============================================================================
ALTER VIEW [dbo].[rpt_chemical_pathogen_crop_vw]
AS
SELECT
    ch.chemical_nm
   ,crop_nm
   ,pc.pathogen_nm
   ,ch.chemical_id
   ,crop_id
   ,pc.pathogen_id
FROM
          Chemical         ch 
LEFT JOIN PathogenChemical pc  ON ch.chemical_nm = pc.chemical_nm
LEFT JOIN Crop_pathogen_vw cpv ON cpv.pathogen_nm = pc.pathogen_nm
/*
SELECT * FROM chemical_pathogen_crop_vw
WHERE crop_nm = 'Banana' AND pathogen_nm='Sigatoka' 
ORDER BY chemical_nm, crop_nm, pathogen_nm
*/

GO
