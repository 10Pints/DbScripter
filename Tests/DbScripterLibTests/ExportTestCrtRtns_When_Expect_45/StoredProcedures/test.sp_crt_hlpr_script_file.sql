SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================================================
-- Author:     Terry Watts
-- Create date: 19-MAY-2024
-- Description:exports the test.HlprDef table to file specified by @file_path param
-- Preconditions:
-- PRE 01: test.HlprDef table populated 
-- Postconditions:                     EX
-- POST 01: the file exists OR EX 63201, 'The output file: [@file_path] does not exist
-- POST 02: write to file OK or  OR EX 63202, ''
-- =======================================================================================
CREATE PROCEDURE [test].[sp_crt_hlpr_script_file]
   @file_path VARCHAR(MAX)
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn           VARCHAR(35)   = N'sp_crt_hlpr_script_file'
      ,@ret_code     INT
      ,@file_system  INT
      ,@file_exists_ VARCHAR(35)
      ,@file_handle  INT
      ,@file_exists  BIT
      ,@line_cnt     INT = 0
      ,@line         VARCHAR(MAX)
      ,@NL           NCHAR(2)=NCHAR(13)+NCHAR(10)
   BEGIN TRY
      EXEC sp_log 2, @fn,'000: starting, params:
file  :[',@file_path,']'
;
      ----------------------------------------------------------------------------------------------------------------------------
      -- Create Scripting.FileSystemObject
      ----------------------------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'005: creating Scripting.FileSystemObject';
      EXECUTE @ret_code = sp_OACreate 'Scripting.FileSystemObject' , @file_system OUTPUT;
      IF (@@ERROR|@ret_code > 0 Or @file_system < 0)
      BEGIN
         EXEC sp_log 4, @fn,'010: could not create FileSystemObject';
         RAISERROR ('could not create FileSystemObject',16,1)
      END
      ----------------------------------------------------------------------------------------------------------------------------
      -- Open a new file for (over)writing
      ----------------------------------------------------------------------------------------------------------------------------
      --1 = for reading, 2 = for writing (will overwrite contents), 8 = for appending
      EXEC sp_log 1, @fn,'020: creating sql file to write rtn to';
      EXEC @ret_code = sp_OAMethod @file_system , 'OpenTextFile' , @file_handle OUTPUT , @file_path, 2, 1;
      IF (@@ERROR|@ret_code > 0 Or @file_handle < 0)
      BEGIN
         EXEC sp_log 4, @fn,'025: could not create sql file';
         RAISERROR ('could not create sql file',16,1);
      END
      ----------------------------------------------------------------------------------------------------------------------------
      -- Write the HlprDef table to the file line by line
      ----------------------------------------------------------------------------------------------------------------------------
      DECLARE row_cursor CURSOR READ_ONLY FOR
         SELECT line FROM test.HlprDef;
      EXEC sp_log 1, @fn,'030: opening cursor';
      OPEN row_cursor;
      FETCH NEXT FROM row_cursor INTO @line;
      ----------------------------------------------------------------------------------------------------------------------------
      -- Main loop: reads each line from the table and writes to file
      ----------------------------------------------------------------------------------------------------------------------------
      WHILE (@@fetch_status = 0)
      BEGIN
         SET @line = CONCAT(@line, @NL);
         EXECUTE @ret_code = sp_OAMethod @file_handle , 'Write' , NULL , @line;
         IF (@@ERROR|@ret_code > 0)
         BEGIN
           -- POST 02: write to file OK or  OR EX 63202, ''
            EXEC sp_log 4, @fn,'040: could not write to file: @@ERROR ',@@ERROR,' @ret_code: ', RetCode;
            THROW 63202, 'could not write to file',1;
         END
         SET @line_cnt = @line_cnt + 1;
         FETCH NEXT FROM row_cursor INTO @line
      END
      CLOSE row_cursor
      DEALLOCATE row_cursor
      EXEC sp_log 1, @fn,'050: exported ', @line_cnt, ' procedure lines';
      EXEC @ret_code = sp_OAMethod @file_handle , 'Close' , NULL;
      IF (@@ERROR|@ret_code > 0) RAISERROR ('Could not close file',16,1);
      EXEC sp_OADestroy @file_system;
      --------------------------------------------------------------------------------------
      -- Check post conditions
         --------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'900: checking post conditions   ';
      -- POST 01: the file exists OR EX 63201, 'The output file: [@file_path] does not exist
      EXEC sp_assert_file_exists @file_path, @ex_num=63201;
      ----------------------------------------------------------------------------------------
      --    Completed processing
      ----------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '10: Completed processing'
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

