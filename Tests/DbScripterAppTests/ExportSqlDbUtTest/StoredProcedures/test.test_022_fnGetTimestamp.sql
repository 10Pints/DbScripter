SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================
-- Author:      Terry Watts
-- Create date: 17-JAN-2020
-- Description: Tests the fnGetTimestamp routine
-- ==============================================
CREATE PROCEDURE [test].[test_022_fnGetTimestamp]
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(35) = 'test_022_fnGetTimestamp'
      ,@NL           NVARCHAR(2)  = NCHAR(13) + NCHAR(10)
      ,@exp          NVARCHAR(13)
   EXEC ut.test.sp_tst_mn_st @fn;
   BEGIN TRY
      WHILE 1 = 1
      BEGIN
         EXEC test.hlpr_022_fnGetTimestamp
          @tst_num      = 'T001'
         ,@inp          = '24-MAY-2020 13:05:29'
         ,@exp          = '200524-1305'
         ,@exp_ex_num   = NULL
         ,@exp_ex_msg   = NULL
         ,@exp_ex_st    = NULL
         ;
         EXEC test.hlpr_022_fnGetTimestamp
          @tst_num      = 'T002'
         ,@inp          = '29-FEB-2020 07:05:30'
         ,@exp          = '200229-0706'
         ,@exp_ex_num   = NULL
         ,@exp_ex_msg   = NULL
         ,@exp_ex_st    = NULL
         ;
         -- Might be unlucky with this test 
         -- FORMAT rounds the time
         SET @exp = LEFT(FORMAT(GetDate(),  'yyMMdd-HHmmss'), 11);
         EXEC test.hlpr_022_fnGetTimestamp
          @tst_num      = '003'
         ,@inp          = NULL
         ,@exp          = @exp
         ,@exp_ex_num   = NULL
         ,@exp_ex_msg   = NULL
         ,@exp_ex_st    = NULL
         ;
         BREAK;  -- D= 
      END -- WHILE 1 = 1
      EXEC ut.test.sp_tst_mn_cls;
   END TRY
   BEGIN CATCH
      EXEC ut.test.sp_tst_mn_hndl_ex;
   END CATCH
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_022_fnGetTimestamp';
*/
GO

