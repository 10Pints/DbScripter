SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 Terry Watts
-- Create date: 15-DEC-2021
-- Description: C# Class Creator
-- =============================================
CREATE PROCEDURE [dbo].[sp_class_creator]
   @table_name  NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
SELECT 
    CONCAT('public ', a.NewType, ' ', a.COLUMN_NAME, ' {get;set;}', defn) as Line
    ,*
FROM (
    SELECT TOP 100 PERCENT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CASE 
        WHEN DATA_TYPE = 'varchar'   AND IS_NULLABLE = 'NO'  THEN 'string'
        WHEN DATA_TYPE = 'varchar'   AND IS_NULLABLE = 'YES' THEN 'string?'
        WHEN DATA_TYPE = 'nvarchar'  AND IS_NULLABLE = 'NO'  THEN 'string'
        WHEN DATA_TYPE = 'nvarchar'  AND IS_NULLABLE = 'YES' THEN 'string?'
        WHEN DATA_TYPE = 'char'      AND IS_NULLABLE = 'NO'  THEN 'string'
        WHEN DATA_TYPE = 'char'      AND IS_NULLABLE = 'YES' THEN 'string?'
        WHEN DATA_TYPE = 'timestamp' AND IS_NULLABLE = 'NO'  THEN 'DateTime'
        WHEN DATA_TYPE = 'timestamp' AND IS_NULLABLE = 'YES' THEN 'DateTime?'
        WHEN DATA_TYPE = 'varbinary' AND IS_NULLABLE = 'NO'  THEN 'byte[]'
        WHEN DATA_TYPE = 'varbinary' AND IS_NULLABLE = 'YES' THEN 'byte[]'
        WHEN DATA_TYPE = 'datetime'  AND IS_NULLABLE = 'NO'  THEN 'DateTime'
        WHEN DATA_TYPE = 'datetime'  AND IS_NULLABLE = 'YES' THEN 'DateTime?'
        WHEN DATA_TYPE = 'int'       AND IS_NULLABLE = 'NO'  THEN 'int'
        WHEN DATA_TYPE = 'int'       AND IS_NULLABLE = 'YES' THEN 'int?'
        WHEN DATA_TYPE = 'smallint'  AND IS_NULLABLE = 'NO'  THEN 'Int16'
        WHEN DATA_TYPE = 'smallint'  AND IS_NULLABLE = 'YES' THEN 'Int16?'
        WHEN DATA_TYPE = 'decimal'   AND IS_NULLABLE = 'NO'  THEN 'decimal'
        WHEN DATA_TYPE = 'decimal'   AND IS_NULLABLE = 'YES' THEN 'decimal?'
        WHEN DATA_TYPE = 'numeric'   AND IS_NULLABLE = 'NO'  THEN 'decimal'
        WHEN DATA_TYPE = 'numeric'   AND IS_NULLABLE = 'YES' THEN 'decimal?'
        WHEN DATA_TYPE = 'money'     AND IS_NULLABLE = 'NO'  THEN 'decimal'
        WHEN DATA_TYPE = 'money'     AND IS_NULLABLE = 'YES' THEN 'decimal?'
        WHEN DATA_TYPE = 'bigint'    AND IS_NULLABLE = 'NO'  THEN 'long'
        WHEN DATA_TYPE = 'bigint'    AND IS_NULLABLE = 'YES' THEN 'long?'
        WHEN DATA_TYPE = 'tinyint'   AND IS_NULLABLE = 'NO'  THEN 'byte'
        WHEN DATA_TYPE = 'tinyint'   AND IS_NULLABLE = 'YES' THEN 'byte?'
        WHEN DATA_TYPE = 'bit'       AND IS_NULLABLE = 'NO'  THEN 'bool'
        WHEN DATA_TYPE = 'bit'       AND IS_NULLABLE = 'YES' THEN 'bool?'
        WHEN DATA_TYPE = 'xml'       AND IS_NULLABLE = 'NO'  THEN 'string'
        WHEN DATA_TYPE = 'xml'       AND IS_NULLABLE = 'YES' THEN 'string?'
        ELSE                                                      DATA_TYPE
    END AS NewType,
    CASE WHEN IS_NULLABLE = 'NO'  THEN
       CASE
           WHEN DATA_TYPE = 'varchar'   AND IS_NULLABLE = 'NO'  THEN ' = "";'
           WHEN DATA_TYPE = 'nvarchar'  AND IS_NULLABLE = 'NO'  THEN ' = "";'
           WHEN DATA_TYPE = 'char'      AND IS_NULLABLE = 'NO'  THEN ' = "";'
           WHEN DATA_TYPE = 'timestamp' AND IS_NULLABLE = 'NO'  THEN ' = new DateTime();'
           WHEN DATA_TYPE = 'varbinary' AND IS_NULLABLE = 'NO'  THEN ' = new byte[](0);'
           WHEN DATA_TYPE = 'datetime'  AND IS_NULLABLE = 'NO'  THEN ' = new DateTime();'
           WHEN DATA_TYPE = 'xml'       AND IS_NULLABLE = 'NO'  THEN ' = "";'
           ELSE                                                      ''
         END
         ELSE ''
      END AS defn
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = @table_name
    ORDER BY ORDINAL_POSITION
) as A;
END
/*
PRINT DB_Name()
Select * FROM dbo.fnClassCreator('table_schema')
EXEC dbo.sp_class_creator 'table_schema'
*/
GO

