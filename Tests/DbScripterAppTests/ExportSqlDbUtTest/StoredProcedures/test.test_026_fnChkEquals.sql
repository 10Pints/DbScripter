SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================
-- Author:      Terry Watts
-- Create date: 05-JAN-2021
-- Description: Tests the fnChkEquals routine
-- ===============================================
CREATE PROCEDURE [test].[test_026_fnChkEquals]
AS
BEGIN
   DECLARE
       @fn_num    NVARCHAR(3)    = N'026'
      ,@fn_num2   NVARCHAR(4)    = N'0260'
      ,@fn        NVARCHAR(4)
      ,@int       INT            =  1
      ,@f         FLOAT          = -1.023
      ,@f2        FLOAT
      ,@f3        FLOAT
      ,@epsilon   FLOAT          =  1.0E-05
      ,@epsilon2  FLOAT          =  1.1E-05
      ,@r         REAL           = -11.023
      ,@n         NUMERIC        =   5.06
      ,@m         MONEY          =  21.56
   SET @f2 = @f - @epsilon
   SET @f3 = @f - @epsilon2
RETURN
   EXEC ut.test.sp_tst_mn_st @fn_num, 'test 026 fnChkEquals'
   BEGIN TRY
      WHILE 1 = 1
      BEGIN
         -- NULL checks
         EXEC test.hlpr_026_fnChkEquals 1, NULL,    NULL,       1;
         EXEC test.hlpr_026_fnChkEquals 2, @f,      NULL,       0;
         EXEC test.hlpr_026_fnChkEquals 3, NULL,    @fn_num,    0;
                                                                 ;
         -- non null checks                                      ;
         EXEC test.hlpr_026_fnChkEquals 4, @int,    @int,       1;
         EXEC test.hlpr_026_fnChkEquals 5, @int,    1,          1;
         EXEC test.hlpr_026_fnChkEquals 6, @f,      @f2,        1;
         EXEC test.hlpr_026_fnChkEquals 7, @f,      @f3,        0;
         EXEC test.hlpr_026_fnChkEquals 8, @fn_num, @fn_num,    1;
         EXEC test.hlpr_026_fnChkEquals 9, @fn_num, @fn_num2,   0;
                                                                 ;
         -- float/numeric checks                                 ;
         EXEC test.hlpr_026_fnChkEquals 10,@f,      -1.023,     1;
         -- float/numeric <= epsilon expect match                ;
         EXEC test.hlpr_026_fnChkEquals 11,@f,      -1.02301,   1;
         -- float/numeric > epsilon expect mismatch              ;
         EXEC test.hlpr_026_fnChkEquals 12,@f,      -1.0230101, 0;
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
   EXEC tSQLt.Run 'test.test_026_fnChkEquals'
*/
GO

