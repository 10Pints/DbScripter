SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =======================================================
-- Author:      Terry Watts
-- Create date: 21-JAN-2024
-- Description: Lists the staging table counts
-- use to check the import and staging pop processes
-- =======================================================
ALTER   VIEW [dbo].[list_stging_tbl_counts_vw]
AS
SELECT 'ActionStaging'       AS [table], COUNT(*) AS row_count  FROM ActionStaging                UNION
SELECT 'ChemicalStaging'               , COUNT(*)               FROM ChemicalStaging              UNION
SELECT 'ChemicalActionStaging'         , COUNT(*)               FROM ChemicalActionStaging        UNION
SELECT 'ChemicalUseStaging'            , COUNT(*)               FROM ChemicalUseStaging           UNION
SELECT 'CompanyStaging'                , COUNT(*)               FROM CompanyStaging               UNION
SELECT 'CropStaging'                   , COUNT(*)               FROM CropStaging                  UNION
SELECT 'CropPathogenStaging'           , COUNT(*)               FROM CropStaging                  UNION
SELECT 'PathogenStaging        '       , COUNT(*)               FROM PathogenStaging              UNION
SELECT 'PathogenChemicalStaging'       , COUNT(*)               FROM PathogenChemicalStaging      UNION
SELECT 'PathogenTypeStaging'           , COUNT(*)               FROM PathogenTypeStaging          UNION
SELECT 'ProductStaging'                , COUNT(*)               FROM ProductStaging               UNION
SELECT 'ProductCompanyStaging'         , COUNT(*)               FROM ProductCompanyStaging        UNION
SELECT 'ProductUseStaging'             , COUNT(*)               FROM ProductUseStaging            UNION
SELECT 'TypeStaging'                   , COUNT(*)               FROM TypeStaging                  UNION
SELECT 'UseStaging'                    , COUNT(*)               FROM UseStaging
;
/*
SELECT * FROM list_stging_tbl_counts_vw;
*/


GO
