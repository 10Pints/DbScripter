SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==================================================================================
-- Author:      Terry Watts
-- Create date: 28-OCT-2023
-- Description: lists the products and chemicals used in crops against pathogens
--
-- PRECONDITIONS:
-- ==================================================================================
ALTER VIEW [dbo].[rpt_product_chemical_pathogen_crop_vw]
AS
SELECT 
    p.product_nm
   ,cpc.chemical_nm
   ,a.action_nm
   ,crop_nm
   ,pathogen_nm
   ,p.product_id
   ,cp.chemical_id
   ,a.action_id
   ,cpc.crop_id
   ,pathogen_id
FROM        rpt_Chemical_pathogen_crop_vw  cpc
INNER JOIN  ChemicalProduct            cp ON cp.chemical_id = cpc.chemical_id
INNER JOIN  Product                    p  ON p.product_id   = cp.product_id
INNER JOIN  ChemicalAction_vw          ca ON ca.chemical_id = cp.chemical_id
INNER JOIN  [Action]                   a  ON a.action_id    = ca.action_id;
/*
SELECT * FROM rpt_product_chemical_pathogen_crop_vw WHERE crop_nm ='Banana' AND pathogen_nm='Sigatoka' ORDER BY product_nm, chemical_nm, action_nm, crop_nm, pathogen_nm;
SELECT * FROM rpt_product_chemical_pathogen_crop_vw WHERE crop_nm ='Banana' AND pathogen_nm='Fusarium Wilt' ORDER BY product_nm, chemical_nm, action_nm, crop_nm, pathogen_nm;
*/

GO
