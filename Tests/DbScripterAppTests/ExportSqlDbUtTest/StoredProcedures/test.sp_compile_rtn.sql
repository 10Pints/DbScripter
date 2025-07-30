SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 16-APR-2024
-- Description: compiles the rtn @q_rtn_nm
--
-- Preconditions
--
-- Postconditions:                     EX
-- POST 01: rtn exists in db or EX 63200, 'failed to compile the main test script'
--
-- Algorithm:
-- Compile the script
--
-- Tests:
--    test_012_sp_crt_tst_mn_compile
--    test_066_sp_crt_tst_mn
--
-- Changes:
-- 231121: @qrn must exist or exception 56472, '<@qrn> does not exist'
-- 231121: added a try catch handler to log errors
-- 240406: redesign see EA: ut/Model/Use Case Model/Test Automation
-- =============================================
CREATE PROCEDURE [test].[sp_compile_rtn]
    @qrn                NVARCHAR(100)
   ,@script_file_path   NVARCHAR(MAX)
AS
BEGIN
   DECLARE 
    @fn                 NVARCHAR(35)   = 'sp_compile_rtn'
   ,@db                 NVARCHAR(60)   
   ,@server             NVARCHAR(90)   
   ,@cmd                NVARCHAR(500)
   ,@file_nm            NVARCHAR(500)
   ,@out_file           NVARCHAR(MAX)
   BEGIN TRY
      SET @db                = DB_NAME();
      SET @server            = @@SERVERNAME --CONCAT('\',@@SERVERNAME); -- 
      SET @file_nm           = test.fnCrtScriptFileName(@qrn);
      SET @out_file          = CONCAT(@script_file_path, '.compile.txt');
      
      EXEC sp_log 2, @fn,'000: starting, params:
qrn             :[',@qrn,']
script_file_path:[',@script_file_path ,']
out_file        :[',@out_file ,']
db              :[',@db       ,']
server          :[',@server   ,']'
;
/*
      ----------------------------------------------------------------------------------
      -- Compile the script
      ----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'025: compiling the script...';
*/
      SET @cmd = 
         CONCAT
         (
             '''"C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\SQLCMD.EXE"'
            ,' -S '   ,@server
            ,' -E -d ',@db
            ,' -i "'  ,@script_file_path,'"'
            ,' -o '   ,@out_file      
            , ''''
         );
      EXEC sp_log 1, @fn,'compile sql: 
', @cmd;
      EXEC master..xp_cmdshell @cmd;
      ----------------------------------------------------------------------------------
      -- Check the postconditions
      ----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'030: check the postconditions...';
      -- POST 01: rtn exists in db or EX 63200, 'failed to compile the main test script'
      -- TLW: 240429: dont stop because of this EXEC sp_chk_rtn_exists @tst_rtn_nm, 1;
      EXEC sp_log 1, @fn,'035: check the compiled rtn exists...'
      IF EXISTS (SELECT 1 FROM dbo.fnChkRtnExists(@qrn))
      BEGIN
         EXEC sp_log 4, @fn, '040: Failed to compile the rtn: [', @qrn, ']';
         EXEC sp_log 1, @fn, '045: Processing complete';
      END
      ELSE
      BEGIN
         EXEC sp_log 4, @fn, '050: Failed to compile the rtn: [', @qrn, ']';
      END
      ----------------------------------------------------------------------------------
      -- Processing complete
      ----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'800: Processing complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH
   EXEC sp_log 2, @fn, '999 leaving, OK';
END
/*
EXEC tSQLt.Run 'test.test_012_sp_crt_tst_mn_compile';
EXEC tSQLt.RunAll;
*/
GO

