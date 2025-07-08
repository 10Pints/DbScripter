SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===========================================================================
-- Author:      Terry Watts
-- Create date: 28-OCT-2023
-- Description: returns the chemicals and products that can be used against
--              the pathogens that effect crops
-- ===========================================================================
CREATE   FUNCTION [dbo].[fnRptGetChemicalProductForCropPathogenActionUse]
(
    @crop_nm      VARCHAR(60)
   ,@pathogen_nm  VARCHAR(60)
   ,@action_nm    VARCHAR(60)
   ,@use          VARCHAR(25)
)
RETURNS
@t TABLE
(
    chemical_nm      VARCHAR(60)
   ,product_nm       VARCHAR(60)
   ,company_nm       VARCHAR(60)
   ,action_nm        VARCHAR(60)
   ,crop_nm          VARCHAR(60)
   ,pathogen_nm      VARCHAR(60)
   ,use_nm           VARCHAR(25)
   ,product_id       INT
   ,chemical_id      INT
   ,crop_id          INT
   ,pathogen_id      INT
   ,use_id           INT
)
AS
BEGIN
   INSERT INTO @t
            (   chemical_nm,    product_nm, company_nm, action_nm, crop_nm, pathogen_nm,   use_nm,    product_id,    chemical_id, crop_id, pathogen_id,   use_id)
      SELECT cu.chemical_nm, pv.product_nm, company_nm, action_nm, crop_nm, pathogen_nm, u.use_nm, pv.product_id, pv.chemical_id, crop_id, pathogen_id, u.use_id
      FROM   rpt_product_chemical_pathogen_crop_vw pv
      JOIN   ChemicalUse       cu ON cu.chemical_id = pv.chemical_id
      JOIN   [Use]             u  ON u.use_id       = cu.use_id
      JOIN   ProductCompany_vw pcv ON pcv.product_id=pv.product_id
      WHERE 
             (crop_nm     LIKE @crop_nm     OR @crop_nm     IS NULL)
         AND (pathogen_nm LIKE @pathogen_nm OR @pathogen_nm IS NULL)
         AND (action_nm   LIKE @action_nm   OR @action_nm   IS NULL)
         AND (u.use_nm    LIKE @use         OR @use         IS NULL)
     ORDER BY chemical_nm, product_nm, company_nm;

   RETURN;
END
/*
SELECT * from dbo.fnRptGetChemicalProductForCropPathogenActionUse('Banana', 'Thrips', NULL, 'Insecticide');
SELECT * from dbo.fnRptGetChemicalProductForCropPathogenActionUse('Banana', NULL, NULL, 'Insecticide');
SELECT * from dbo.fnRptGetChemicalProductForCropPathogenActionUse('Banana', 'Aphid%', NULL, NULL);
SELECT * from dbo.fnRptGetChemicalProductForCropPathogenActionUse('Banana', 'Sigatoka', 'Sys%', NULL);
SELECT * from dbo.fnRptGetChemicalProductForCropPathogenActionUse('Banana', 'Fusarium Wilt', NULL, NULL);
SELECT * from dbo.fnRptGetChemicalProductForCropPathogenActionUse('Melon', NULL, NULL, NULL);
*/


GO
