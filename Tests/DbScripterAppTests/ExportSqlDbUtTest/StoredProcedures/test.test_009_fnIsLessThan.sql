SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================
-- Author:      Terry Watts
-- Create date: 01-FEB-2021
-- Description: Tests the fnChkEquals routine
-- ===============================================
CREATE PROCEDURE [test].[test_009_fnIsLessThan]
AS
BEGIN
   DECLARE
       @fn_num    NVARCHAR(3)    = N'026'
      ,@fn_num2   NVARCHAR(4)    = N'0260'
      ,@fn        NVARCHAR(100)  = N'test 009 fnIsLessThan'
      ,@int       INT            =  1
      ,@f         FLOAT          = -1.023
      ,@f2        FLOAT
      ,@f3        FLOAT
      ,@epsilon   FLOAT          =  1.0E-05
      ,@epsilon2  FLOAT          =  0.9E-03
      ,@r         REAL           = -11.023
      ,@n         NUMERIC        =   5.06
      ,@m         MONEY          =  21.56
      -- date time chks
      ,@dt1       DATE           = '24-JAN-2021'
      ,@dt2       DATE           = '25-JAN-2021'
      ,@dTTime1   DATETIME       = '24-JAN-2021 7:00:00 AM'
      ,@dTTime2   DATETIME       = '24-JAN-2021 7:00:01 AM'
   SET @f2 = @f - @epsilon
   SET @f3 = @f - @epsilon2
   EXEC ut.test.sp_tst_mn_st @fn
   BEGIN TRY
      WHILE 1 = 1
      BEGIN
         EXEC test.hlpr_009_fnIsLessThan '01', NULL,        NULL  ,  1 -- NULL checks
         EXEC test.hlpr_009_fnIsLessThan '02', -1.023,      NULL  ,  0
         EXEC test.hlpr_009_fnIsLessThan '03', NULL,        -1.023,  0
         EXEC test.hlpr_009_fnIsLessThan '04', NULL,        N'026',  0
         EXEC test.hlpr_009_fnIsLessThan '05', N'026',      NULL  ,  0
         EXEC test.hlpr_009_fnIsLessThan '06', 1,           1,       0  -- non null checks
         EXEC test.hlpr_009_fnIsLessThan '07', 4,           2,       0
         EXEC test.hlpr_009_fnIsLessThan '08', 3,           4,       1
         EXEC test.hlpr_009_fnIsLessThan '09', 7,           7,       0
         EXEC test.hlpr_009_fnIsLessThan '10', 1,           1,       0 -- 1 is nott less than 1
         EXEC test.hlpr_009_fnIsLessThan '11', @int,        1,       0 -- 1 is not less than 1
         -- Edge cases where edge tends to false
         EXEC test.hlpr_009_fnIsLessThan '12', -1.000,     -1.0000101,   0 -- EDGE case @epsilon = 0.00001 so @f is significantly gtr than @f2 therefore f is considered not less than f2
         EXEC test.hlpr_009_fnIsLessThan '13', -1.000,     -1.0000099,   0 -- EDGE case ABS(@f2-@f) = 0000099 which is < epsilon     therefore f is considered equal to f2, not less than
         EXEC test.hlpr_009_fnIsLessThan '14', -1.000,     -1.00001,     0 -- EDGE case ABS(@f2-@f) = 0.00001 = @epsilon             therefore f is considered equal to f2, not less than
         -- Edge cases where edge tends to true
         EXEC test.hlpr_009_fnIsLessThan '15', -1.00001,   -1.0000,   1  -- EDGE case right on    @epsilon therefore f is considered less than f2
         EXEC test.hlpr_009_fnIsLessThan '16', -1.0000099, -1.0000,   0  -- EDGE case a tad under @epsilon = 0.00001 herefore f is considered equal to f2, not less than f2
         EXEC test.hlpr_009_fnIsLessThan '17', -1.0000101, -1.0000,   1  -- EDGE case a tad over  @epsilon = 0.00001 so @f is significantly less than than @f2 f is considered less than f2
         RETURN
         EXEC test.hlpr_009_fnIsLessThan '18', @f,         @f2,     0 -- @f=-1.023, @f2=@f-@epsilon = -1.02301 so @f is significantly gtr than @f2 so res=0
         EXEC test.hlpr_009_fnIsLessThan '19', @f,         @f3,     0 -- @f=-1.023, @f3=@f-@epsilon2= -1.023009 so @f is in sig significantly gtr than @f3 so res=0
         EXEC test.hlpr_009_fnIsLessThan '21', 'aasdf',   'aasdf',  0
         EXEC test.hlpr_009_fnIsLessThan '22', 'aasdf',   'aasdfg', 1
         EXEC test.hlpr_009_fnIsLessThan '23', 'aasdf',   'aasdg',  1
         EXEC test.hlpr_009_fnIsLessThan '24', @dt1,      @dt2,     1
         EXEC test.hlpr_009_fnIsLessThan '25', 'aasdfg',  'aasdf',  0
         EXEC test.hlpr_009_fnIsLessThan '26', 'aasdg',   'aasdf',  0
         EXEC test.hlpr_009_fnIsLessThan '27', @fn_num,    @fn_num2,1 -- @fn_num='026', @fn_num2='0260' so '026' is < '0260' so res: 1
         EXEC test.hlpr_009_fnIsLessThan '28', 'aasdg',   'aasd',   0
         EXEC test.hlpr_009_fnIsLessThan '29', @f,        1.023,    0 -- float/numeric checks
         EXEC test.hlpr_009_fnIsLessThan '30', @f,       -1.02301,  0 -- float/numeric <= epsilon expect match i.e 0
         EXEC test.hlpr_009_fnIsLessThan '31', -1.023019, @f,       0 -- float/numeric > epsilon  expect match
         EXEC test.hlpr_009_fnIsLessThan '32', @dt2,      @dt1,     0
         EXEC test.hlpr_009_fnIsLessThan '33', @dt1,      @dt1,     0
         BREAK;  -- Do once loop
      END -- WHILE 1 = 1
      EXEC ut.test.sp_tst_mn_cls;
   END TRY
   BEGIN CATCH
      EXEC ut.test.sp_tst_mn_hndl_ex;
   END CATCH
END
/*
   EXEC tSQLt.RunAll;
   EXEC tSQLt.Run 'test.test_009_fnIsLessThan';
-------------------------------------------------------------------------------
   DECLARE @int INT = 1
   EXEC test.hlpr_009_fnIsLessThan '08.2', @int,       1,       0 -- 1 is not
-------------------------------------------------------------------------------
*/
GO

