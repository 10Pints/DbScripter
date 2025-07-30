SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =================================================
-- Author:      Terry Watts
-- Create date: 12-FEB-2021
-- Description: lists routiens and their defintion
--  from any database
/*RETURNS @t
   TABLE 
   (
       [name]           NVARCHAR(60)
      ,[schema]         NVARCHAR(60)
      ,[type_desc]      NVARCHAR(32)
      ,seq              INT
      ,ln_len           INT
      ,create_date      DATETIME
      ,def              NVARCHAR(4000)
   )
*/
-- =================================================
CREATE PROCEDURE [dbo].[sp_grep_rtns_by_len]
   @db_nm        NVARCHAR(60)   = NULL   --                                        default: current database
   ,@schemas      NVARCHAR(20)   = 'dbo'  -- comma separated list  like 'dbo.test'  default: dbol
   ,@rtn_filter   NVARCHAR(99)   = '%'    --                                        default: all
   ,@top          INT            = 2000
AS
BEGIN
DECLARE
   @sql NVARCHAR(4000)
   IF @db_nm IS NULL SET @db_nm = DB_NAME();
   SET @sql = CONCAT(
'SELECT TOP ', @top, '
      ''', @db_nm, '''        AS db
      ,ss.name       AS [schema]
      ,so.name       AS rtn_name
      ,SUM(LEN(sc.text))  AS ln_len
   FROM
                  ', @db_nm, '.sys.objects      AS so 
      INNER JOIN  ', @db_nm, '.sys.schemas      AS ss ON so.schema_id = ss.schema_id
      INNER JOIN  ', @db_nm, '.sys.syscomments  AS sc ON so.object_id = sc.id
   WHERE
       ss.name IN (''', @schemas, ''')
   AND so.name LIKE ''', @rtn_filter, '''
   GROUP BY ss.name, so.name
   ORDER BY db, ln_len DESC, ss.name, so.name'
   );
/*
SELECT TOP ', @top, '
      ''', @db_nm, '''        AS db
      ,ss.name       AS [schema]
      ,so.name       AS rtn_name
      ,so.type_desc
      ,sc.colid      AS seq
      ,LEN(sc.text)  AS ln_len
      ,so.create_date
      ,sc.text       AS def
   FROM
                  ', @db_nm, '.sys.objects      AS so 
      INNER JOIN  ', @db_nm, '.sys.schemas      AS ss ON so.schema_id = ss.schema_id
      INNER JOIN  ', @db_nm, '.sys.syscomments  AS sc ON so.object_id = sc.id
      
   WHERE
       ss.name IN (''', @schemas, ''')
   AND so.name LIKE ''', @rtn_filter, '''
   ORDER BY db, ss.name, so.name 
   ');
*/
   PRINT @sql;
   EXEC sp_executesql @sql;
END
GO

