SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--=============================================================================================================
-- Author:           Terry Watts
-- Create date:      11-May-2024
-- Description: test helper for the dbo.fnGetNthSubstring routine tests 
--
-- Tested rtn description:
-- gets the n-th substring in str separated by sep
--              1 based numbering but [0] and [1] return
--                the first element in the sequence
-- if there are double quotes in the string then the seps in the double quotes section should be ignored
--
-- Preconditions: none
--
-- Postconditions
-- POST 00: @sub returns the @ndx substring from @input_str using sep to separate the items
--          or
--=============================================================================================================
CREATE PROCEDURE [test].[hlpr_094_fnGetNthSubstring] -- fnCrtHlprCodeHlprSig
    @tst_num            NVARCHAR(50) -- fnCrtHlprSigParams 14
   ,@inp_input_str      NVARCHAR(4000)
   ,@inp_sep            NVARCHAR(100)
   ,@inp_ndx            INT
   ,@exp_out_val        NVARCHAR(4000)
          -- fnCrtHlprSigExpParamsFn
         ,@exp_rtn NVARCHAR(4000) = NULL
AS -- fnCrtHlprCodeBegin
BEGIN
   -- fnCrtHlprCodeDecl
   -- fnCrtHlprCodeDeclCoreParams
   DECLARE
       @fn          NVARCHAR(35) = N'hlpr_094_fnGetNthSubstring'
      ,@act_ex_num  INT
      ,@act_ex_msg  NVARCHAR(500)
      ,@error_msg   NVARCHAR(1000)
   -- fnCrtHlprCodeDeclActParams
      ,@act_out_val        NVARCHAR(4000)
   BEGIN TRY
      EXEC test.sp_tst_hlpr_st @fn, @tst_num;
      -- SETUP:
      -- <TBA>:
      -- fnCrtHlprCodeCallBloc
      -- RUN tested procedure: -- SP-RN-TST
      EXEC sp_log 1, @fn, '005: running ';
      -- @rtn_ty_code:FN
         SET @act_out_val = dbo.fnGetNthSubstring
         (
            @inp_input_str, @inp_sep, @inp_ndx
         )
      -- Tests:-- fnCrtHlprCodeTestBloc
      -- [fnCrtHlprCodeTestBlocFn]
      IF @exp_out_val IS NOT NULL EXEC tSQLt.AssertEquals @exp_out_val, @act_out_val, 'out_val';
      -- CLEANUP: -- CRT-HLPR-CLS-BLOC
      -- <TBD>
      EXEC sp_log 1, @fn, '990: all subtests PASSED';
      EXEC test.sp_tst_hlpr_hndl_success;
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH
   EXEC sp_log 2, @fn, '99: leaving OK';
END
/*
   EXEC tSQLt.Run 'test.test_094_fnGetNthSubstring';
*/
GO

