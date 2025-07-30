SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_crt_TSQLt_db]
    @db_name               SYSNAME        = N'TestDb'
   ,@PrepareServerScript   NVARCHAR(100)  = N'D:\Dev\tSQLt\prepareServer.sql'
   ,@TSQLtClassScript      NVARCHAR(100)  = N'D:\Dev\tSQLt\tSQLt.class.sql'
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
    @sql NVARCHAR(4000)
   ,@cmd VARCHAR(8000)
   ,@quotedDbName NVARCHAR(256) = QUOTENAME(@db_name);
   PRINT '=== 1. Dropping existing database if it exists ===';
   IF EXISTS (SELECT 1 FROM sys.databases WHERE name = @db_name)
   BEGIN
      PRINT '===> Forcing disconnect of active connections';
      SET @sql = 
N'ALTER DATABASE ' + @quotedDbName + ' SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE ' + @quotedDbName + ';';
      BEGIN TRY
         EXEC sp_executesql @sql;
      END TRY
      BEGIN CATCH
         DECLARE @msg VARCHAR(4000) = ERROR_MESSAGE()
         PRINT 'There was the following error creating the database: ' + @msg + ' continuing anyway'
      END CATCH
   END
   PRINT '=== 2. Creating new database ===';
   SET @sql = N'CREATE DATABASE ' + @quotedDbName;
   EXEC sp_executesql @sql;
   PRINT '=== 3. Running prepareServer.sql via sqlcmd ===';
   SET @sql = 
   'sqlcmd -S ' + CAST(@@SERVERNAME AS VARCHAR(128)) +
   ' -d ' + @db_name +
   ' -i "' + @PrepareServerScript + '"';
   PRINT '=== 3.5: Running 
   ' + @sql
   SET @cmd = CAST( @sql AS VARCHAR(MAX));
   EXEC xp_cmdshell @cmd;
   PRINT '=== 4. Running tSQLt.class.sql via sqlcmd ===';
   SET @sql = 
   'sqlcmd -S ' + CAST(@@SERVERNAME AS VARCHAR(128)) +
   ' -d ' + @db_name +
   ' -i "' + @TSQLTClassScript + '"';
   PRINT '=== 4.5: Running 
   ' + @sql
   SET @cmd = CAST( @sql AS VARCHAR(MAX));
   EXEC xp_cmdshell @cmd;
   PRINT '=== 5. Creating test class [Test] ===';
   SET @sql = N'EXEC ' + @quotedDbName + N'.tSQLt.NewTestClass ''Test'';';
   EXEC sp_executesql @sql;
   PRINT '=== 6 tSQLt test database reset complete ===';
END
/*
USE Ut;
go
dbo.sp_crt_TSQLt_db
    N'Test',
    @PrepareServerScript   = N'D:\Dev\tSQLt\prepareServer.sql',
    @TSQLtClassScript      = N'D:\Dev\tSQLt\tSQLt.class.sql';
sqlcmd -S DevI9 -d Test -i "D:\Dev\DbScripter\Tests\DbScripterTests\AppExportTest\Dorsu_dev schema.sql"
EXEC test.sp__crt_tst_rtns 'dbo.sp_appLog_display'
*/
GO

