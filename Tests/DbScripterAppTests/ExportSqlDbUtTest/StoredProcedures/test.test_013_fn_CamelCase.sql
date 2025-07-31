SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 20-APR-2024
-- Description: Tests dbo.fn_CamelCase()
-- =============================================
CREATE PROCEDURE [test].[test_013_fn_CamelCase]
AS
BEGIN
   DECLARE
       @fn_num    NVARCHAR(3)    = N'008'
      ,@fn        NVARCHAR(4)
      ,@char13    NVARCHAR(1)    = NCHAR(13)
      ,@str       NVARCHAR(50)   = '  Some text  '
      ,@inp       NVARCHAR(50)
      ,@exp       NVARCHAR(50)
      ,@ret       NVARCHAR(50)
   SET NOCOUNT ON
   EXEC ut.test.sp_tst_mn_st N'T013_fn_CamelCase';
   BEGIN TRY
      WHILE 1 = 1
      BEGIN
         --                    T#     inp      exp       msg
         EXEC test.hlpr_013_fn_CamelCase
             @tst_num   = 'T001'
            ,@str       = 'xxx'
            ,@exp_res   = 'Xxx'
            ,@exp_ex_num= null
            ,@exp_ex_msg= null
            ;
         EXEC test.hlpr_013_fn_CamelCase
             @tst_num   = 'T001 null test'
            ,@str       = NULL
            ,@exp_res   = NULL
            ,@exp_ex_num = null
            ,@exp_ex_msg = null
            ;
         EXEC test.hlpr_013_fn_CamelCase
             @tst_num   = 'T002: empty test'
            ,@str       = ''
            ,@exp_res   = ''
            ,@exp_ex_num= null
            ,@exp_ex_msg = null
            ;
         EXEC test.hlpr_013_fn_CamelCase
             @tst_num   = 'T001'
            ,@str       = 'abc_def,gh'
            ,@exp_res   = 'Abc_def,gh'
            ,@exp_ex_num = null
            ,@exp_ex_msg = null
            ;
         BREAK;  -- Do once loop
      END -- WHILE 1 = 1
      EXEC ut.test.sp_tst_mn_cls;
   END TRY
   BEGIN CATCH
      EXEC ut.test.sp_tst_mn_hndl_ex;
   END CATCH
END
/*
EXEC tSQLt.Run 'test.test_013_fn_CamelCase';
EXEC tSQLt.RunAll;
*/
GO

