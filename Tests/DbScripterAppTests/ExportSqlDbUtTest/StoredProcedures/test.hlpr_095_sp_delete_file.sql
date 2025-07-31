SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--=============================================================================================================
-- Author:           Terry Watts
-- Create date:      20-Sep-2024
-- Description: test helper for the dbo.sp_delete_file routine tests 
--
-- Tested rtn description:
-- Deletes the file on disk
--=============================================================================================================
CREATE PROCEDURE [test].[hlpr_095_sp_delete_file]
    @tst_num         NVARCHAR(50)
   ,@inp_file_path   NVARCHAR(500)
   ,@exp_ex_num      INT
   ,@exp_ex_msg      NVARCHAR(500)
AS
BEGIN
   DECLARE
    @fn              NVARCHAR(35) = N'hlpr_095_sp_delete_file'
   ,@error_msg       NVARCHAR(1000)
   ,@act_ex_num      INT
   ,@act_ex_msg      NVARCHAR(500)
   ,@file_exists     BIT
   ,@cpy_file_path   NVARCHAR(500)
   ,@folder          NVARCHAR(1000)  = NULL
   ,@file_name       NVARCHAR(1000)  = NULL
   ,@ext             NVARCHAR(1000)  = NULL
   ,@cmd             NVARCHAR(MAX)
   ,@params          NVARCHAR(MAX)
   ;
   BEGIN TRY
      SET @params = CONCAT(
'@tst_num:     [',@tst_num,']
@inp_file_path:[',@inp_file_path,']
@exp_ex_num:   [',@exp_ex_num,']
@exp_ex_msg    [',@exp_ex_msg,']'
         );
      EXEC test.sp_tst_hlpr_st @fn, @tst_num, @params;
      EXEC sp_log 1, @fn, '400: ';
      -- SETUP: make a copy of the file to delete, delete it if it exists first
      SELECT 
          @folder    = folder
         ,@file_name = file_name
         ,@ext       = ext
      FROM dbo.fnGetFileDetails(@inp_file_path);
      EXEC sp_log 1, @fn, '410: ';
      SET @cpy_file_path = CONCAT(@folder, '\', @file_name, '_cpy.', @ext);
      EXEC sp_log 1, @fn, '420: ';
      SET @file_exists = dbo.fnFileExists(@cpy_file_path);
      EXEC sp_log 1, @fn, '430: ';
      IF @file_exists = 1 -- delete it if it exists
      BEGIN
         EXEC sp_log 1, @fn, '005 deleting copy of the file: ', @inp_file_path;
         SET @cmd = CONCAT('xp_cmdshell ''del "', @cpy_file_path, '"''');
         EXEC (@cmd);
      END
      SET @cmd = CONCAT('exec xp_cmdshell ''copy /V /Y "', @inp_file_path, '"' , ' "', @cpy_file_path, '"''');
      EXEC sp_log 1, @fn, '010 copying file, @cmd: ', @cmd;
      EXEC (@cmd);
      SET @file_exists = dbo.fnFileExists(@cpy_file_path);
      EXEC tSQLt.AssertEquals 1, @file_exists, '015: failed to copyfile to @cpy_file_path';
      -- RUN tested procedure: -- SP-RN-TST fn ty: P
      EXEC sp_log 1, @fn, '015: running sp_delete_file ', @inp_file_path;
      -- @rtn_ty_code:P
      WHILE 1 = 1 -- fnCrtHlprCodeCallProc]
      BEGIN
         BEGIN TRY
            EXEC dbo.sp_delete_file @inp_file_path;
            IF @exp_ex_num IS NOT NULL OR @exp_ex_msg IS NOT NULL
            BEGIN
               EXEC sp_log 4, @fn, '020: oops! Expected exception was not thrown';
               THROW 51000, ' Expected exception was not thrown', 1;
            END
         END TRY
         BEGIN CATCH
            SET @act_ex_num = ERROR_NUMBER();
            SET @act_ex_msg = ERROR_MESSAGE();
            EXEC sp_log 1, @fn, '025: caught exception', @act_ex_num, @act_ex_msg;
               EXEC sp_log 1, @fn, '030 check ex num , exp: ', @exp_ex_num, ' act: ', @act_ex_num;
            EXEC sp_log_exception @fn;
            IF @exp_ex_num IS NULL AND @exp_ex_msg IS NULL
            BEGIN
               EXEC sp_log 4, @fn, '35: oops! Unexpected an exception here';
               THROW 51000, ' caught unexpected exception', 1;
            END
            ------------------------------------------------------------
            -- ASSERTION: if here then expected exception
            ------------------------------------------------------------
            IF @exp_ex_num IS NOT NULL EXEC tSQLt.AssertEquals @exp_ex_num, @act_ex_num        ,'ex_num mismatch';
            IF @exp_ex_msg IS NOT NULL EXEC tSQLt.AssertEquals @exp_ex_msg, @act_ex_msg        ,'ex_msg mismatch';
            EXEC sp_log 2, @fn, '040 test# ',@tst_num, ': exception test PASSED;'
            BREAK
         END CATCH
         -- TEST:
         EXEC sp_log 2, @fn, '10: running tests...';
         -- fnCrtHlprCodeChkExps
         SET @file_exists = dbo.fnFileExists(@inp_file_path);
         IF @file_exists = 1
         BEGIN 
            EXEC tSQLt.Fail 'File:[', @inp_file_path, '] still exists';
         END
         
         -- passed tests
         BREAK
      END --WHILE
      EXEC sp_log 2, @fn, '900: all tests ran OK'
      -- Tests:-- fnCrtHlprCodeTestBloc
      -- CLEANUP: -- fnCrtHlprCodeCloseBloc
      -- <TBD>
      EXEC sp_log 1, @fn, '990: all subtests PASSED';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH
   EXEC test.sp_tst_hlpr_hndl_success;
END
/*
   EXEC tSQLt.Run 'test.test_095_sp_delete_file';
   EXEC tSQLt.RunAll;
   SELECT * FROM dbo.fnGetFileDetails('CallRegister.txt');
   SELECT * FROM dbo.fnGetFileDetails('D:\Dev\Farming\Farming\Data\CallRegister.txt');
*/
GO

