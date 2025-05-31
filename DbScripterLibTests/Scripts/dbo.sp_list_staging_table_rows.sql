SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =====================================================
-- Author:      Terry Watts
-- Create date: 05-OCT-2023
-- Description: lists all rows for all staging tables
--
-- CHANGES:
-- 231007:removed row limit, added order by clause
-- 231007: added views where ids only
-- =====================================================
ALTER PROCEDURE [dbo].[sp_list_staging_table_rows]
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @cmd       NVARCHAR(4000)
      ,@table_nm  NVARCHAR(32) = 'CropStaging' -- ActionStaging,

   DROP TABLE If EXISTS temp;
   SET @cmd = CONCAT('SELECT '''' AS [',@table_nm, '],* FROM [',@table_nm,']');
   PRINT CONCAT('@cmd:
', @cmd);

   -----------------------------------------------------------------
   SELECT x.cmd INTO temp
   FROM 
   (
      SELECT CONCAT('SELECT '''' AS [',table_nm, '],* FROM [',table_nm,']') as cmd 
      FROM TableDef WHERE table_type='staging'
   ) X

   -- SELECT * FROM temp;

   -----------------------------------------------------------------
   DECLARE @cursor CURSOR

   SET @cursor = CURSOR FOR
      SELECT cmd from temp

   OPEN @cursor;
   FETCH NEXT FROM @cursor INTO @cmd;

   WHILE (@@FETCH_STATUS = 0)
   BEGIN
      EXEC(@cmd);
      FETCH NEXT FROM @cursor INTO @cmd;
   END
END
/*
EXEC sp_list_staging_table_rows
SELECT '' AS [ActionStaging],* FROM [ActionStaging]
SELECT '' AS [CropStaging],* FROM [CropStaging]

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   SELECT '01 ActionStaging'                 AS [01 ActionStaging]             , * FROM ActionStaging                       ORDER BY action_nm
   SELECT '02 ChemicalStaging'               AS [02 ChemicalStaging]           , * FROM ChemicalStaging                     ORDER BY chemical_nm
   SELECT '03 ChemicalActionStaging'         AS [03 ChemicalActionStaging]     , * FROM ChemicalActionStaging               ORDER BY chemical_nm, action_nm
   SELECT '04 ChemicalProductStaging'        AS [04 ChemicalProductStaging]    , * FROM ChemicalProductStaging              ORDER BY chemical_nm, product_nm
   SELECT '05 ChemicalUseStaging'            AS [05 ChemicalUseStaging]        , * FROM ChemicalUseStaging                  ORDER BY chemical_nm, use_nm
   SELECT '06 CompanyStaging'                AS [06 CompanyStaging]            , * FROM CompanyStaging                      ORDER BY company_nm
   SELECT '07 CropStaging'                   AS [07 CropStaging]               , * FROM CropStaging                         ORDER BY crop_nm
   SELECT '08 CropPathogenStaging'           AS [08 CropPathogenStaging]       , * FROM CropPathogenStaging                 ORDER BY crop_nm, pathogen_nm
   SELECT '09 PathogenStaging'               AS [09 PathogenStaging]           , * FROM PathogenStaging                     ORDER BY pathogen_nm
   SELECT '10 PathogenChemicalStaging'       AS [10 PathogenChemicalStaging]   , * FROM PathogenChemicalStaging             ORDER BY pathogen_nm, chemical_nm
   SELECT '11 PathogenTypeStaging'           AS [11 PathogenTypeStaging]       , * FROM PathogenTypeStaging                 ORDER BY pathogenType_nm
   SELECT '12 ProductStaging'                AS [13 ProductStaging]            , * FROM ProductStaging                      ORDER BY product_nm
   SELECT '13 ProductUseStaging'             AS [14 ProductUseStaging]         , * FROM ProductUseStaging                   ORDER BY product_nm, use_nm
   SELECT '14 TypeStaging'                   AS [15 TypeStaging]               , * FROM TypeStaging                         ORDER BY type_nm
   SELECT '15 UseStaging'                    AS [16 UseStaging]                , * FROM UseStaging                          ORDER BY use_nm
   SELECT '16 Import'                        AS [17 Import]                    , * FROM Import                              ORDER BY import_nm
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   */

GO
