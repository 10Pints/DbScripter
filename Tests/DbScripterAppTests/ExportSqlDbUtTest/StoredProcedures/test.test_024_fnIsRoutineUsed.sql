SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 17-JAN-2020
-- Description: Tests the fnIsRoutineUsed routine
-- =============================================
CREATE PROCEDURE [test].[test_024_fnIsRoutineUsed]
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(40) = 'test_024_fnIsRoutineUsed'
   EXEC ut.test.sp_tst_mn_st @fn;
      WHILE 1 = 1
      BEGIN
         EXEC sp_log 1, '10: call hlpr test 001';
         EXEC test.hlpr_024_fnIsRoutineUsed @test_num='001', @rtn_nm ='non existant rtn', @exp_ex_num = 8134
         , @exp_ex_msg='Divide by zero error encountered.'
         EXEC sp_log 1, '20: ret frm hlpr_024';
         BREAK;  -- Do once loop
      END -- WHILE 1 = 1
      EXEC sp_log 1, '30: calling sp_tst_mn_cls';
      EXEC ut.test.sp_tst_mn_cls;
      EXEC sp_log 1, '99: test_024_fnIsRoutineUsed passed';
END
/*
EXEC tSQLt.RunAll
EXEC tSQLt.Run 'test.test_024_fnIsRoutineUsed'
*/
GO

