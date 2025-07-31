SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 17-JAN-2020
-- Description: Tests the fnGetFunctionDetails routine
--
-- Changes: 
-- 231129: removed try catch bloc
-- =============================================
CREATE PROCEDURE [test].[test_016_fnGetRtnDetails]
AS
BEGIN
   DECLARE
       @fn     NVARCHAR(60) = N'fnGetRtnDetails'
   EXEC ut.test.sp_tst_mn_st @fn
   EXEC sp_log 2, @fn,'02: done standard setup';
   WHILE 1 = 1
   BEGIN
      EXEC sp_log 2, @fn,'10: calling test.hlpr_016_fnGetRtnDetails with TG001';
      -- fnGetFunctionDetails is type: 'IF'	SQL inline table-valued function
      EXEC test.hlpr_016_fnGetRtnDetails
          @test_num        = 'TG001'
         ,@schema_nm       = 'dbo'
         ,@rtn_nm          = 'fnGetRtnDetails'
         ,@exp_rtn_ty_code = 'TF'
      EXEC sp_log 2, @fn,'20: returned from test.hlpr_016_fnGetRtnDetails with TG001';
      EXEC sp_log 2, @fn,'40: done all tests: passed';
      BREAK;  -- Do once loop
   END -- WHILE 1 = 1
   EXEC ut.test.sp_tst_mn_cls;
   EXEC sp_log 2, @fn,'leaving';
END
/*
EXEC tSQLt.RunAll
EXEC tSQLt.Run 'test.test_016_fnGetRtnDetails'
*/
GO

