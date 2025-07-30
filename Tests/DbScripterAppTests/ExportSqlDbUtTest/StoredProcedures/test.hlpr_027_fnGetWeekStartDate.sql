SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================
-- Author:      Terry Watts
-- Create date: 31-JAN-2021
-- Description: tests the dbo.GetWeekStartDate() routine
-- =======================================================
CREATE PROCEDURE [test].[hlpr_027_fnGetWeekStartDate] 
    @test_num        NVARCHAR(50)
   ,@dt              DATE
   ,@exp_wk_start_dt DATE
AS
BEGIN
   DECLARE 
       @fn              NVARCHAR(35) = 'hlpr_027_fnGetWeekStartDate'
      ,@act_wk_start_dt DATE
   EXEC ut.test.sp_tst_hlpr_st @fn, @test_num
   SET @act_wk_start_dt = dbo.fnGetWeekStartDate(@dt);
--   BEGIN TRY
   EXEC dbo.sp_assert_equal @exp_wk_start_dt, @act_wk_start_dt;
   PRINT CONCAT('test dt: ', @dt,' exp wk st: ', @exp_wk_start_dt, ' act wk st: ', @act_wk_start_dt, ' PASSED')
/*   IF CHARINDEX('fail', @msg) > 0
      THROW 50000, 'Expected test to fail, but it succeeded', 1
*/
--   END TRY
--   BEGIN CATCH
--      DECLARE @n INT;
--      SET @n = CHARINDEX('fail', @msg);
--      PRINT CONCAT('test dt: ', @dt,' exp wk st: ', @exp_wk_start_dt, ' act wk st: ', @act_wk_start_dt, ' FAILED, expected: ', @msg, iif(@n>0, ' OK', 'FAILED'));
--   END CATCH
END
/*
exec tSQLt.RunAll;
exec tSQLt.Run 'test.test_027_fnGetWeekStartDate';
EXEC test.chk_wk_start_dt '24-JAN-2021', '2021-01-24'
EXEC test.chk_wk_start_dt '30-JAN-2021', '2021-01-24', 'PASS'
EXEC test.chk_wk_start_dt '31-JAN-2021', '2021-01-31'
EXEC test.chk_wk_start_dt '06-FEB-2021', '2021-01-31'
EXEC test.chk_wk_start_dt '07-FEB-2021', '2021-01-31', 'FAIL'
EXEC test.chk_wk_start_dt '07-FEB-2021', '2021-02-07'
*/
GO

