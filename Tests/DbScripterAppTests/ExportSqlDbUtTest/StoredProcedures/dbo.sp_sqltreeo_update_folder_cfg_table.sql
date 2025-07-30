SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================
-- Author:      Terry Watts
-- Create date: 16-MAR-2020
--
-- Description: refreshes the SQLTreeOConfig table
-- USE when additions or changes to the dynamic sqltreeo folders
--    refreshes (merges) the SQLTreeOConfig table from the SQLTreeO extended properties.
--    Does a full merge add, update and delete
--
-- USE when additions or changes to the dynamic sqltreeo folders
--
-- ERROR CODES: none
-- =====================================================
CREATE PROCEDURE [dbo].[sp_sqltreeo_update_folder_cfg_table]
   @disp BIT   = 1
AS
BEGIN
   DECLARE
      @fn          NVARCHAR(20)   = N'POP_TST_CFG'
     ,@old_count   INT
   EXEC sp_log 1, @fn, '01: starting';
   SELECT @old_count = COUNT(*) FROM dbo.SQLTreeOConfig;
-- Create a temporary table to hold the updated or inserted values
-- from the OUTPUT clause.
   IF NOT EXISTS (SELECT 1 FROM [INFORMATION_SCHEMA].[TABLES] 
      WHERE table_name = 'SqlTreeoTempTable')
         CREATE TABLE SqlTreeoTempTable
         (
            [action]       NVARCHAR(20),
            inserted_nm    NVARCHAR(1000),
            inserted_val   NVARCHAR(1000),
            deleted_nm     NVARCHAR(1000),
            deleted_val    NVARCHAR(1000),
         );
   IF NOT EXISTS (SELECT 1 FROM [INFORMATION_SCHEMA].[TABLES] 
      WHERE table_name = 'SqlTreeoStatsTable')
         CREATE TABLE dbo.SqlTreeoStatsTable(
            updated  int NULL,
            inserted int NULL,
            deleted  int NULL
         );
   TRUNCATE TABLE SqlTreeoTempTable;
   TRUNCATE TABLE SqlTreeoStatsTable;
   MERGE dbo.SQLTreeOConfig c--(name, value)
   USING
   (
      SELECT name, CONVERT(NVARCHAR(500),[value]) as [value]
      FROM tempDB.sys.extended_properties
   ) h ON c.[name] = h.[name]
   WHEN MATCHED AND h.[value] <> c.[value] THEN UPDATE 
      SET [name] = h.[name], c.[value] = h.[value]
   WHEN NOT MATCHED THEN INSERT ([name], [value])
      VALUES (h.[name], h.[value])
   WHEN NOT MATCHED BY SOURCE 
      THEN DELETE
   OUTPUT $action, inserted.[name] as inserted_nm, inserted.[value] as inserted_val
         ,deleted.name as deleted_nm, deleted.value as deleted_val INTO SqlTreeoTempTable;
   -- stats
   IF @disp = 1
      SELECT * FROM SqlTreeoTempTable;
   -- merge and report changes
   INSERT INTO SqlTreeoStatsTable ( updated, inserted, deleted)
      SELECT A.updated AS updated, b.inserted as inserted, c.deleted as deleted
      FROM 
       (SELECT count(*) AS updated  FROM SqlTreeoTempTable WHERE [action] = 'UPDATE') A
      ,(SELECT count(*) AS inserted FROM SqlTreeoTempTable WHERE [action] = 'INSERT') B
      ,(SELECT count(*) AS deleted  FROM SqlTreeoTempTable WHERE [action] = 'DELETE') C;
   EXEC sp_log 1, @fn, '99: leaving';
END
/*
SELECT count(*) FROM SQLTreeOConfig
EXEC [dbo].[sp_sqltreeo_update_folder_cfg_table]
SELECT count(*) FROM SQLTreeOConfig
*/
GO

