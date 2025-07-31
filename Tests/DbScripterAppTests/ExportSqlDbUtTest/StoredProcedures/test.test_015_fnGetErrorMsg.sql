SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 17-JAN-2020
-- Description: Tests the fnGetErrorMsg routine
-- =============================================
CREATE PROCEDURE [test].[test_015_fnGetErrorMsg]
AS
BEGIN
   DECLARE
      @fn           NVARCHAR(50) = N'test 015 fnGetErrorMsg'
   EXEC ut.test.sp_tst_mn_st @fn
   BEGIN TRY
      WHILE 1 = 1
      BEGIN
         PRINT 'T015 ErrMsgTst 1';
         EXEC test.hlpr_015_fnGetErrorMsg
             @test_num     = '001: 51000, Exception Msg st:1'
            ,@inp_ex_num   = 51000
            ,@inp_ex_msg   = N'Exception Msg'
            ,@inp_ex_st    = 14
            ,@exp_ex_msg1  = N'Exception Msg'
            ,@exp_ex_msg2  = N't: 14';
         PRINT 'T15ErrMsgTst 2'
         BREAK;  -- Do once loop
      END -- WHILE 1 = 1
      PRINT 'T15ErrMsgTst 3'
      EXEC ut.test.sp_tst_mn_cls;
      PRINT 'T15ErrMsgTst 4'
   END TRY
   BEGIN CATCH
      PRINT 'T15ErrMsgTst 5'
      EXEC ut.test.sp_tst_mn_hndl_ex;
      PRINT 'T15ErrMsgTst 6'
   END CATCH
   PRINT 'T15ErrMsgTst 99'
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_015_fnGetErrorMsg';
*/
GO

