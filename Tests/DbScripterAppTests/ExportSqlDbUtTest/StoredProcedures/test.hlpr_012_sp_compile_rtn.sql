SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--==================================================================================
-- Author:           Terry Watts
-- Create date:      24-Jul-2024
-- Description: test helper for the test.sp_compile_rtn routine tests 
--
-- Tested rtn description:
-- compiles the rtn @q_rtn_nm
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
--==================================================================================
CREATE PROCEDURE [test].[hlpr_012_sp_compile_rtn] -- fnCrtHlprCodeHlprSig
    @tst_num                NVARCHAR(50) -- fnCrtHlprSigParams 18
   ,@qrn                    NVARCHAR(100)
   ,@script_file_path       NVARCHAR(4000)
    -- fnCrtHlprSigExpParamsSp
   ,@exp_ex_num      INT            = NULL
   ,@exp_ex_msg      NVARCHAR(500)  = NULL
   ,@display_script  BIT            = 0
AS -- fnCrtHlprCodeBegin
BEGIN
   -- fnCrtHlprCodeDecl
   -- fnCrtHlprCodeDeclCoreParams
   DECLARE
       @fn              NVARCHAR(35) = N'hlpr_069_sp_compile_rtn'
      ,@act_ex_num      INT
      ,@act_ex_msg      NVARCHAR(500)
      ,@error_msg       NVARCHAR(1000)
      -- fnCrtHlprCodeDeclActParams
      ,@act_row_cnt        INT
   BEGIN TRY
      EXEC test.sp_tst_hlpr_st @fn, @tst_num;
      EXEC sp_log 2, @fn,'000: starting, params:
tst_num         :[',@tst_num         ,']
qrn             :[',@qrn             ,']
script_file_path:[',@script_file_path,']
exp_ex_num      :[',@exp_ex_num      ,']
exp_ex_msg      :[',@exp_ex_msg      ,']
display_script  :[',@display_script  ,']'
;
      -- SETUP:
      --EXEC test.sp_get_rtn_details @qrn, 900;
      -- fnCrtHlprCodeCallBloc
      -- RUN tested procedure: -- SP-RN-TST
      -- @rtn_ty_code:P
      WHILE 1 = 1 -- fnCrtHlprCodeCallProc]
      BEGIN
         BEGIN TRY
            EXEC sp_log 1, @fn, '010: Calling tested routine: test.sp_compile_rtn';
            EXEC test.sp_compile_rtn
                @qrn             = @qrn
               ,@script_file_path= @script_file_path
            ;
            IF @exp_ex_num IS NOT NULL OR @exp_ex_msg IS NOT NULL
            BEGIN
               EXEC sp_log 4, @fn, '010: oops! Expected exception was not thrown';
               THROW 51000, ' Expected exception was not thrown', 1;
            END
         END TRY
         BEGIN CATCH
            SET @act_ex_num = ERROR_NUMBER();
            SET @act_ex_msg = ERROR_MESSAGE();
            EXEC sp_log 1, @fn, '015: caught exception', @act_ex_num, @act_ex_msg;
               EXEC sp_log 1, @fn, '020 check ex num , exp: ', @exp_ex_num, ' act: ', @act_ex_num;
            EXEC sp_log_exception @fn;
            IF @exp_ex_num IS NULL AND @exp_ex_msg IS NULL
            BEGIN
               EXEC sp_log 4, @fn, '08: oops! Unexpected an exception here';
               THROW 51000, ' caught unexpected exception', 1;
            END
            ------------------------------------------------------------
            -- ASSERTION: if here then expected exception
            ------------------------------------------------------------
            IF @exp_ex_num IS NOT NULL EXEC tSQLt.AssertEquals @exp_ex_num, @act_ex_num        ,'ex_num mismatch';
            IF @exp_ex_msg IS NOT NULL EXEC tSQLt.AssertEquals @exp_ex_msg, @act_ex_msg        ,'ex_msg mismatch';
         
            EXEC sp_log 2, @fn, '030 test# ',@tst_num, ': exception test PASSED;'
            BREAK
         END CATCH
         -- TEST:
         EXEC sp_log 2, @fn, '10: running tests...';
         -- fnCrtHlprCodeChkExps
         EXEC sp_assert_rtn_exists @qrn;
         -- passed tests
         BREAK
      END --WHILE
      EXEC sp_log 2, @fn, '17: all tests ran OK'
      EXEC test.sp_tst_hlpr_hndl_success;
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
   EXEC sp_log 1, @fn, '999: leaving';
END
/*
   EXEC tSQLt.Run 'test.test_069_sp_compile_rtn';
   EXEC tSQLt.RunAll;
*/
GO

