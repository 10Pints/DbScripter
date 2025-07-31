SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 17-JAN-2020
-- Description: Tests the fnFormatDate routine
-- =============================================
CREATE PROCEDURE [test].[test_011_fnFormatDate]
AS
BEGIN
   DECLARE
       @fn_num       NVARCHAR(3) = N'012'
      ,@fn           NVARCHAR(60)= N'fnFormatDate'
      ,@NL           NVARCHAR(2) = NCHAR(13)+NCHAR(10)
      ,@act          SQL_VARIANT
   EXEC ut.test.sp_tst_mn_st @fn
   BEGIN TRY
      WHILE 1 = 1
      BEGIN
         EXEC test.hlpr_011_fnFormatDate
             @test_num  = '001'
            ,@inp       = NULL
            ,@exp       = NULL
            ,@exp_ex_num= NULL
            ,@exp_ex_msg= NULL
            ,@exp_ex_st = NULL
         BREAK;  -- Do once loop
      END -- WHILE 1 = 1
      EXEC ut.test.sp_tst_mn_cls;
   END TRY
   BEGIN CATCH
      DECLARE @_tmp     NVARCHAR(500) = ut.dbo.fnGetErrorMsg()
      EXEC ut.test.sp_tst_mn_hndl_ex;
   END CATCH
END
/*
EXEC tSQLt.RunAll
EXEC tSQLt.Run 'test.test_011_fnFormatDate'
*/
GO

