SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =====================================================
-- Author:      Terry Watts
-- Create date: 31-MAR-2024
-- Description: lists all rows for all staging tables
--
-- CHANGES:
-- 231007:removed row limit, added order by clause
-- 231007: added views where ids only
-- =====================================================
ALTER PROCEDURE [dbo].[sp_list_main_table_rows]
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @cmd       NVARCHAR(4000)
      ,@table_nm  NVARCHAR(32) = 'CropStaging' -- ActionStaging,

/*   SET @cmd='SELECT CONCAT(''SELECT * FROM ['',table_nm,'']'') FROM TableDef WHERE table_type=''staging''';
   PRINT @cmd;
   EXEC (@cmd);
   */
   DROP TABLE If EXISTS temp;
   SET @cmd = CONCAT('SELECT '''' AS [',@table_nm, '],* FROM [',@table_nm,']');
   PRINT CONCAT('@cmd:
', @cmd);

   -----------------------------------------------------------------
   SELECT x.cmd INTO temp
   FROM 
   (
      SELECT CONCAT('SELECT '''' AS [',table_nm, '],* FROM [',table_nm,']') as cmd 
      FROM TableDef WHERE table_type='main'
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
EXEC sp_list_main_table_rows;
*/

GO
