SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =====================================================================
-- Author:      Terry Watts
-- Create date: 13-NOV-2024
-- Description: Creates the sql t create a table from an existing table
-- =====================================================================
CREATE   PROCEDURE [dbo].[sp_crt_tbl_sql_frm_tbl]
   @qrn VARCHAR(80)
AS
BEGIN
   SET NOCOUNT ON;

   DECLARE
    @sql       VARCHAR(MAX)

    SET @sql = dbo.fnCrtTblSqlFrmTbl(@qrn);
    PRINT @sql;
    EXEC(@sql);

    SET @sql = CONCAT('SELECT TOP 1000 * FROM ', @qrn);
    EXEC(@sql);
END
/*
EXEC dbo.sp_crt_tbl_sql_frm_tbl 'MosaicVirus';
SELECT
    MAX(dbo.fnLen([Species])) AS [Species]
   ,MAX(dbo.fnLen([Crops]))   AS [Crops]
   ,MAX(dbo.fnLen([Genus]))   AS [Genus]
   ,MAX(dbo.fnLen([Subfamily]) AS [Subfamily]
   ,MAX(dbo.fnLen([Family]))  AS [Family]
   ,MAX(dbo.fnLen([Order]))   AS [Order]
   ,MAX(dbo.fnLen([Class]))   AS [Class]
   ,MAX(dbo.fnLen([Subphylum] AS [Subphylum]
   ,MAX(dbo.fnLen([Phylum]))  AS [Phylum]
   ,MAX(dbo.fnLen([Kingdom])) AS [Kingdom]
   ,MAX(dbo.fnLen([Realm]))   AS [Realm]
   ,MAX(dbo.fnLen([Genome]))  AS [Genome]
   ,MAX(dbo.fnLen([Vector]))  AS [Vector]
   ,MAX(dbo.fnLen([OPPO_code] AS [OPPO_code]
FROM [MosaicVirus];
*/


GO
