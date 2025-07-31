SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--=============================================================================================================
-- Author:           Terry Watts
-- Create date:      20-Sep-2024
-- Description: test helper for the dbo.GetFileDetails routine tests 
--
-- Tested rtn description:
-- Gets the file details from the supplied file path:
--    [Folder, File name woyhout ext, extension]
--
-- Tests:
--
-- CHANGES:
--=============================================================================================================
CREATE PROCEDURE [test].[hlpr_096_fnGetFileDetails]
    @tst_num            NVARCHAR(50)
   ,@inp_file_path      NVARCHAR(4000)
   ,@exp_folder         NVARCHAR(1000)  = NULL
   ,@exp_file_name      NVARCHAR(1000)  = NULL
   ,@exp_ext            NVARCHAR(1000)  = NULL
   ,@exp_fn_pos         INT             = NULL
   ,@exp_dot_pos        INT             = NULL
   ,@exp_len            INT             = NULL
   ,@exp_ex_num         INT             = NULL
   ,@exp_ex_msg         NVARCHAR(500)   = NULL
AS
BEGIN
   DECLARE
       @fn              NVARCHAR(35) = N'hlpr_096_fnGetFileDetails'
      ,@error_msg       NVARCHAR(1000)
      ,@act_folder      NVARCHAR(1000)
      ,@act_file_name   NVARCHAR(1000)
      ,@act_ext         NVARCHAR(1000)
      ,@act_fn_pos      INT
      ,@act_dot_pos     INT
      ,@act_len         INT
      ,@act_ex_num      INT
      ,@act_ex_msg      NVARCHAR(500)
   BEGIN TRY
      EXEC test.sp_tst_hlpr_st @fn, @tst_num;
      -- RUN tested procedure:
      DROP TABLE IF EXISTS test.Results;
      CREATE TABLE test.Results
      (
       folder         NVARCHAR(MAX)
      ,[file_name]    NVARCHAR(MAX)
      ,ext            NVARCHAR(MAX)
      ,fn_pos         INT
      ,dot_pos        INT
      ,[len]          INT
      );
      EXEC sp_log 1, @fn, '005: running fnGetFileDetails(',@inp_file_path,')';
      INSERT INTO test.Results ( folder, [file_name], ext, fn_pos, dot_pos,[len])
      SELECT folder, [file_name], ext, fn_pos, dot_pos,[len]
      FROM   dbo.fnGetFileDetails( @inp_file_path);
      EXEC sp_log 1, @fn, '006: ret frm fnGetFileDetails(',@inp_file_path,')';
      SELECT * FROM test.Results;
      -- Tests:
      SELECT
         @act_folder    = folder
        ,@act_file_name = [file_name]
        ,@act_ext       = ext
        ,@act_fn_pos    = fn_pos
        ,@act_dot_pos   = dot_pos
        ,@act_len       = [len]
     FROM test.Results;
     EXEC sp_log 1, @fn, '010: fn_pos';
      /*IF @exp_fn_pos    IS NOT NULL*/ EXEC tSQLt.AssertEquals @exp_fn_pos    ,@act_fn_pos    ,'fn_pos';
     EXEC sp_log 1, @fn, '015: dot_pos';
      /*IF @exp_dot_pos   IS NOT NULL*/ EXEC tSQLt.AssertEquals @exp_dot_pos   ,@act_dot_pos   ,'dot_pos';
     EXEC sp_log 1, @fn, '020: len';
      /*IF @exp_len       IS NOT NULL*/ EXEC tSQLt.AssertEquals @exp_len       ,@act_len       ,'len';
     EXEC sp_log 1, @fn, '025: folder';
      /*IF @exp_folder    IS NOT NULL*/ EXEC tSQLt.AssertEquals @exp_folder    ,@act_folder    ,'folder';
     EXEC sp_log 1, @fn, '030: file_name';
      /*IF @exp_file_name IS NOT NULL*/ EXEC tSQLt.AssertEquals @exp_file_name ,@act_file_name ,'file_name';
     EXEC sp_log 1, @fn, '035: ext';
      /*IF @exp_ext       IS NOT NULL*/ EXEC tSQLt.AssertEquals @exp_ext       ,@act_ext       ,'ext';
     EXEC sp_log 1, @fn, '040: ex_num';
      /*IF @exp_ex_num    IS NOT NULL*/ EXEC tSQLt.AssertEquals @exp_ex_num    ,@act_ex_num    ,'ex_num';
     EXEC sp_log 1, @fn, '045: ex_msg';
      /*IF @exp_ex_msg    IS NOT NULL*/ EXEC tSQLt.AssertEquals @exp_ex_msg    ,@act_ex_msg    ,'ex_msg';
      EXEC sp_log 1, @fn, '990: all subtests PASSED';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH
   EXEC test.sp_tst_hlpr_hndl_success;
END
/*
   EXEC tSQLt.Run 'test.test_096_fnGetFileDetails';
   EXEC tSQLt.RunAll;
*/
GO

