SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--=============================================================================================================
-- Author:           Terry Watts
-- Create date:      19-Sep-2024
-- Description: test helper for the dbo.fnGetFileExtension routine tests 
--
-- Tested rtn description:
-- Gets the file extension from the supplied file path
--
-- Tests:
--
-- CHANGES:
--=============================================================================================================
CREATE PROCEDURE [test].[hlpr_092_fnGetFileExtension] -- fnCrtHlprCodeHlprSig
    @tst_num          NVARCHAR(50) -- fnCrtHlprSigParams 12
   ,@inp_path         NVARCHAR(4000)
   ,@exp_out_val      NVARCHAR(200)
   ,@exp_ex_num       NVARCHAR(50)
   ,@exp_ex_msg       NVARCHAR(500)
AS -- fnCrtHlprCodeBegin
BEGIN
   -- fnCrtHlprCodeDecl
   -- fnCrtHlprCodeDeclCoreParams
   DECLARE
       @fn              NVARCHAR(35) = N'hlpr_901_fnGetFileExtension'
      ,@error_msg       NVARCHAR(1000)
      -- fnCrtHlprCodeDeclActParams
      ,@act_out_val     NVARCHAR(200)
      ,@act_ex_num      INT
      ,@act_ex_msg      NVARCHAR(500)
      ,@params          NVARCHAR(MAX)
      ,@res             NVARCHAR(50)
   BEGIN TRY
      SET @params = CONCAT
(
   'params: 
    @tst_num    =|',COALESCE(@tst_num    , '<NULL>') ,'|
   ,@inp_path   =|',COALESCE(@inp_path   , '<NULL>') ,'|
   ,@exp_out_val=|',COALESCE(@exp_out_val, '<NULL>'),'|
   ,@exp_ex_num =|',COALESCE(@exp_ex_num , '<NULL>'),'|
   ,@exp_ex_msg =|',COALESCE(@exp_ex_msg , '<NULL>'),'|'
);
      EXEC test.sp_tst_hlpr_st @fn, @tst_num, @params;
      -- SETUP:
      -- <TBA>:
      -- fnCrtHlprCodeCallBloc
      -- RUN tested procedure: -- SP-RN-TST fn ty: FN
      EXEC sp_log 1, @fn, '005: running ';
      -- @rtn_ty_code:FN
      SET @act_out_val = dbo.fnGetFileExtension
      (
         @inp_path
      )
      IF @act_out_val IS NULL PRINT 'Result IS <NULL>' ELSE PRINT CONCAT('Result: |', @act_out_val, '|');
      -- Tests:-- fnCrtHlprCodeTestBloc
      -- [fnCrtHlprCodeTestBlocFn]
                                  EXEC tSQLt.AssertEquals @exp_out_val ,@act_out_val ,'out_val';
      IF @exp_ex_num  IS NOT NULL EXEC tSQLt.AssertEquals @exp_ex_num  ,@act_ex_num  ,'ex_num';
      IF @exp_ex_msg  IS NOT NULL EXEC tSQLt.AssertEquals @exp_ex_msg  ,@act_ex_msg  ,'ex_msg';
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
EXEC tSQLt.Run 'test.test_092_fnGetFileExtension';
EXEC tSQLt.RunAll;
----------------------------------------------------------------------------
DECLARE @res NVARCHAR(50)
SET @res =dbo.fnGetFileExtension(NULL);
IF @act_out_val IS NULL PRINT 'IS NULL' ELSE PRINT CONCAT('|', @act_out_val, '|');
----------------------------------------------------------------------------
*/
GO

