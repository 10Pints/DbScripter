SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 15-DEC-2021
-- Description: C# Class Creator
-- =============================================
CREATE FUNCTION [dbo].[fnClassCreator]
(
   @table_name  NVARCHAR(50)
)
RETURNS @t TABLE
(
    ordinal       INT
   ,line          NVARCHAR(250)
   ,column_name   NVARCHAR(60)
   ,data_type     NVARCHAR(20)
   ,is_nullable   NVARCHAR(20)
   ,[type]        NVARCHAR(20)
   ,defn          NVARCHAR(60)
   ,table_nm      NVARCHAR(60)
)
AS
BEGIN
   INSERT INTO  @t(line, ordinal, is_nullable, data_type, column_name, table_nm )
   (
   SELECT 
      CONCAT('public ', a.[type], ' ', a.COLUMN_NAME, ' {get;set;}', defn) as Line, ORDINAL_POSITION, is_nullable, DATA_TYPE, column_name, TABLE_NAME
   FROM (
      SELECT TOP 100 PERCENT
      ORDINAL_POSITION,
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
      END AS [type],
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
       ,TABLE_NAME
      FROM INFORMATION_SCHEMA.COLUMNS 
      WHERE TABLE_NAME = @table_name
      ORDER BY ORDINAL_POSITION
      ) as A
   );
   RETURN;
END
/*
SELECt  * FROM INFORMATION_SCHEMA.COLUMNS 
USE Telepat
GO
--SELECT * FROM  dbo.fnClassCreator('AppLog');
SELECT * FROM ut.dbo.fnClassCreator('ContactDetail');
SELECT * FROM  dbo.fnClassCreator('ContactDetail');
EXEC dbo.sp_class_creator 'ContactDetail'
PRINT DB_Name()
*/
GO

