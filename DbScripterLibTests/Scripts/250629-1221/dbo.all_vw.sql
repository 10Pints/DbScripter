SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 29-JUL-2023
-- Description: this is the S2 main view relating all fields, it splits out the multiple value fields
--              into a field that holds only 1 value. 
--              Examples are [Pathogens, Pathogen], [Uses Use], [Ingredient, Chemical]
--
-- PRECONDITIONS: Dependencies:
--                Tables: Staging2, [Use], ChemicalStaging, CropStaging, PathogenStaging, ProductStaging
--
-- CHANGES:
-- 20-JAN-2024 now uses only the staging2 table
-- 22-JAN-2024 added actions
-- ======================================================================================================
CREATE VIEW [dbo].[all_vw]
AS
SELECT
       s.id
      ,company
      ,product        AS product_nm
      ,ingredient     AS chemicals
      ,Chem.    value AS chemical_nm
      ,entry_mode     AS actions
      ,E.       value AS action_nm
      ,crops
      ,Crp.     value AS crop_nm
      ,pathogens
      ,P.       value AS pathogen_nm
      ,s.uses
      ,u.       value AS use_nm
FROM 
   Staging2 s 
   CROSS APPLY string_split(ingredient, '+') as Chem
   CROSS APPLY string_split(crops     , ',') as Crp
   CROSS APPLY string_split(pathogens , ',') as P
   CROSS APPLY string_split(uses      , ',') as U
   CROSS APPLY string_split(entry_mode, ',') as E
/*
SELECT * FROM all_vw
*/

GO
