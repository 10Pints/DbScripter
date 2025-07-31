SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 27-DEC-2019
-- Description: Tests the helper procedure  sp_export_to_excel_validate
-- used by sp_export_to_excel helper sp_export_to_excel_validate
-- DROP PROCEDURE [test].[test 026 fnCheckTableExists]
/*
Considerations:
1: there are several types of whitespace
--
-- whitespace is: 
-- (NCHAR(9), NCHAR(10), NCHAR(11), NCHAR(12), 
-- NCHAR(13), NCHAR(14), NCHAR(32), NCHAR(160))
*/
-- =============================================
CREATE PROCEDURE [test].[test_028_fnIsWhitespace]
AS
BEGIN
   DECLARE
   --    @fn_num    NVARCHAR(3)    = N'008'
       @fn        NVARCHAR(60)   = N'fnIsWhitespace'
      ,@08        NCHAR          = NCHAR(8)
      ,@tab       NCHAR          = NCHAR(9)
      ,@10        NCHAR          = NCHAR(10)
      ,@11        NCHAR          = NCHAR(11)
      ,@12        NCHAR          = NCHAR(12)
      ,@lf        NCHAR          = NCHAR(13)
      ,@14        NCHAR          = NCHAR(14)
      ,@15        NCHAR          = NCHAR(15)
      ,@32        NCHAR          = NCHAR(32)
      ,@160       NCHAR          = NCHAR(160)
      ,@161       NCHAR          = NCHAR(161)
   SET NOCOUNT ON
   EXEC ut.test.sp_tst_mn_st @fn
   BEGIN TRY
      WHILE 1 = 1
      BEGIN
         EXEC test.hlpr_028_fnIsWhitespace
             @test_num     = '001: @tab'
            ,@inp          = @tab
            ,@exp          = 1
            ,@exp_ex_num   = null
            ,@exp_ex_msg   = null
            ,@exp_ex_st    = null
         EXEC test.hlpr_028_fnIsWhitespace
             @test_num     = '002: NCHAR(10)'
            ,@inp          = @10
            ,@exp          = 1
            ,@exp_ex_num   = null
            ,@exp_ex_msg   = null
            ,@exp_ex_st    = null
         EXEC test.hlpr_028_fnIsWhitespace
             @test_num     = '003: C10'
            ,@inp          = @10
            ,@exp          = 1
            ,@exp_ex_num   = null
            ,@exp_ex_msg   = null
            ,@exp_ex_st    = null
         EXEC test.hlpr_028_fnIsWhitespace
             @test_num     = '004: C11'
            ,@inp          = @11
            ,@exp          = 1
            ,@exp_ex_num   = null
            ,@exp_ex_msg   = null
            ,@exp_ex_st    = null
         EXEC test.hlpr_028_fnIsWhitespace
             @test_num     = '005: C12'
            ,@inp          = @12
            ,@exp          = 1
            ,@exp_ex_num   = null
            ,@exp_ex_msg   = null
            ,@exp_ex_st    = null
         EXEC test.hlpr_028_fnIsWhitespace
             @test_num     = '006: C13'
            ,@inp          = @lf
            ,@exp          = 1
            ,@exp_ex_num   = null
            ,@exp_ex_msg   = null
            ,@exp_ex_st    = null
         EXEC test.hlpr_028_fnIsWhitespace
             @test_num     = '007: C14'
            ,@inp          = @14
            ,@exp          = 1
            ,@exp_ex_num   = null
            ,@exp_ex_msg   = null
            ,@exp_ex_st    = null
         EXEC test.hlpr_028_fnIsWhitespace
             @test_num     = '008: C32'
            ,@inp          = @32
            ,@exp          = 1
            ,@exp_ex_num   = null
            ,@exp_ex_msg   = null
            ,@exp_ex_st    = null
         EXEC test.hlpr_028_fnIsWhitespace
             @test_num     = '009: C160'
            ,@inp          = @160
            ,@exp          = 1
            ,@exp_ex_num   = null
            ,@exp_ex_msg   = null
            ,@exp_ex_st    = null
         EXEC test.hlpr_028_fnIsWhitespace
             @test_num     = '010: C08: 0'
            ,@inp          = @08
            ,@exp          = 0
            ,@exp_ex_num   = null
            ,@exp_ex_msg   = null
            ,@exp_ex_st    = null
         EXEC test.hlpr_028_fnIsWhitespace
             @test_num     = '011: C15: 0'
            ,@inp          = @15
            ,@exp          = 0
            ,@exp_ex_num   = null
            ,@exp_ex_msg   = null
            ,@exp_ex_st    = null
         EXEC test.hlpr_028_fnIsWhitespace
             @test_num     = '011: C161: 0'
            ,@inp          = @161
            ,@exp          = 0
            ,@exp_ex_num   = null
            ,@exp_ex_msg   = null
            ,@exp_ex_st    = null
         EXEC test.hlpr_028_fnIsWhitespace
             @test_num     = '012: A: 1'
            ,@inp          = 'A'
            ,@exp          = 0
            ,@exp_ex_num   = null
            ,@exp_ex_msg   = null
            ,@exp_ex_st    = null
         EXEC test.hlpr_028_fnIsWhitespace
             @test_num     = '013: z: 0'
            ,@inp          = 'z'
            ,@exp          = 0
            ,@exp_ex_num   = null
            ,@exp_ex_msg   = null
            ,@exp_ex_st    = null
         EXEC test.hlpr_028_fnIsWhitespace
             @test_num     = '014: 0'
            ,@inp          = '0'
            ,@exp          = 0
            ,@exp_ex_num   = null
            ,@exp_ex_msg   = null
            ,@exp_ex_st    = null
         EXEC test.hlpr_028_fnIsWhitespace
             @test_num     = '015: 9: 0'
            ,@inp          = '9'
            ,@exp          = 0
            ,@exp_ex_num   = null
            ,@exp_ex_msg   = null
            ,@exp_ex_st    = null
         EXEC test.hlpr_028_fnIsWhitespace
             @test_num     = '016: $: 0'
            ,@inp          = '$'
            ,@exp          = 0
            ,@exp_ex_num   = null
            ,@exp_ex_msg   = null
            ,@exp_ex_st    = null
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
EXEC tSQLt.Run 'test.test_028_fnIsWhitespace';
EXEC test.test_028_fnIsWhitespace;
*/
GO

