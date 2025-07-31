SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--============================================================
-- Author:           Terry Watts
-- Create date:      06-Dec-2024
-- Rtn:              test.hlpr_054_fnIsLT
-- Description: test helper for the dbo.fnIsLT routine tests 
--
-- Tested rtn description:
-- fnGetRtnDesc
--============================================================
CREATE PROCEDURE [test].[hlpr_054_fnIsLT] -- fnCrtHlprCodeHlprSig
    @tst_num          NVARCHAR(50) -- fnCrtHlprSigParams 12
   ,@inp_a            SQL_VARIANT
   ,@inp_b            SQL_VARIANT
   ,@exp_out_val      BIT             = NULL
   ,@exp_ex_num       INT             = NULL
   ,@exp_ex_msg       NVARCHAR(500)   = NULL
AS -- fnCrtHlprCodeBegin
BEGIN
   -- fnCrtHlprCodeDecl
   -- fnCrtHlprCodeDeclCoreParams
   DECLARE
    @fn                      NVARCHAR(35)    = N'hlpr_054_fnIsLT'
   ,@error_msg               NVARCHAR(1000)
   -- fnCrtHlprCodeDeclActParams
   ,@act_out_val             BIT             = @exp_out_val
   ,@act_ex_num              INT             = @exp_ex_num
   ,@act_ex_msg              NVARCHAR(500)   = @exp_ex_msg
   BEGIN TRY
      EXEC test.sp_tst_hlpr_st @tst_num;
      EXEC sp_log 1, @fn ,' starting
tst_num    :[', @tst_num,']-- fnCrtHlprLogParams
inp_a      :[', @inp_a  ,']
inp_b      :[', @inp_b  ,']
exp_out_val:[', @exp_out_val,']
ex_num     :[', @exp_ex_num,']
ex_msg     :[', @act_ex_msg,']
';
      -- SETUP:
      -- <TBA>:
      -- fnCrtHlprCodeCallBloc rtn ty:FN
      -- @rtn_ty_code:FN
      WHILE 1 = 1
      BEGIN
         BEGIN TRY
            EXEC sp_log 1, @fn, '010: Calling the tested routine: dbo.fnIsLT';
            ------------------------------------------------------------
-- fnCrtHlprCodeCallFn
            SET @act_out_val = dbo.fnIsLT(@inp_a, @inp_b);
            ------------------------------------------------------------
            EXEC sp_log 1, @fn, '020: returned from dbo.fnIsLT';
            IF @exp_ex_num IS NOT NULL OR @exp_ex_msg IS NOT NULL
            BEGIN
               EXEC sp_log 4, @fn, '030: oops! Expected exception was not thrown';
               THROW 51000, ' Expected exception was not thrown', 1;
            END
         END TRY
         BEGIN CATCH
            SET @act_ex_num = ERROR_NUMBER();
            SET @act_ex_msg = ERROR_MESSAGE();
            EXEC sp_log 1, @fn, '040:  caught exception: ', @act_ex_num, ' ',      @act_ex_msg;
            EXEC sp_log 1, @fn, '050: check ex num: exp: ', @exp_ex_num, ' act: ', @act_ex_num;
            EXEC test.sp_tst_hlpr_hndl_failure;
            IF @exp_ex_num IS NULL AND @exp_ex_msg IS NULL
            BEGIN
               EXEC sp_log 4, @fn, '060: an unexpected exception was raised';
               THROW;
            END
            ------------------------------------------------------------
            -- ASSERTION: if here then expected exception
            ------------------------------------------------------------
            IF @exp_ex_num IS NOT NULL EXEC tSQLt.AssertEquals @exp_ex_num, @act_ex_num, 'ex_num mismatch';
            IF @exp_ex_msg IS NOT NULL EXEC tSQLt.AssertEquals @exp_ex_msg, @act_ex_msg, 'ex_msg mismatch';
            
            EXEC sp_log 2, @fn, '070 test# ',@tst_num, ': exception test PASSED;'
            BREAK
         END CATCH
         -- TEST:
         EXEC sp_log 2, @fn, '080: running tests...';
         -- fnCrtHlprCodeChkExps
         --IF @exp_row_cnt IS NOT NULL SELECT @act_row_cnt = COUNT(*) FROM [<TODO: enter table name here>]
         IF @exp_out_val IS NOT NULL EXEC tSQLt.AssertIsSubString @exp_out_val, @act_out_val,'out_val 1';
         ------------------------------------------------------------
         -- Passed tests
         ------------------------------------------------------------
         BREAK
      END --WHILE
      -- CLEANUP: -- fnCrtHlprCodeCloseBloc
      -- <TBD>
      EXEC sp_log 1, @fn, '990: all subtests PASSED';
   END TRY
   BEGIN CATCH
      EXEC test.sp_tst_hlpr_hndl_failure;
      THROW;
   END CATCH
   EXEC test.sp_tst_hlpr_hndl_success;
END
/*
   EXEC tSQLt.RunAll;
   EXEC tSQLt.Run 'test.test_054_fnIsLT';
*/
GO

