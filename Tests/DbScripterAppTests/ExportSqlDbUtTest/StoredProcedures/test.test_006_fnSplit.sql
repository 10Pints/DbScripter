SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 17-JAN-2020
-- Description: Tests the  fnSplit routine
-- =============================================
CREATE PROCEDURE [test].[test_006_fnSplit]
AS
BEGIN
   DECLARE
       @test_fn      NVARCHAR(80)   = N'test 006 fnSplit'
      ,@tab          NVARCHAR(1)    = NCHAR(9)
      ,@comma_str    NVARCHAR(20)   = 'A,BCD,drfg,15#$%,,34'
      ,@tabbed_str   NVARCHAR(20)   = 'A,BCD,drfg,15#$%,,34'
      ,@disp         BIT            = 0
   EXEC ut.test.sp_tst_mn_st @test_fn
   SET @tabbed_str = REPLACE(@comma_str, ',', @tab);
   BEGIN TRY
      WHILE 1 = 1
      BEGIN
         EXEC test.hlpr_006_fnSplit
             @test_num     = '001'
            ,@inp          = 'A,BCD'
            ,@sep          = ','
            ,@exp_cnt      = 2
            ,@id           = 1
            ,@exp_line     = 'A'
            ,@exp_ex_num   = NULL
            ,@exp_ex_msg   = NULL
         EXEC test.hlpr_006_fnSplit
             @test_num     = '002'
            ,@inp          = 'A,BCD'
            ,@sep          = ','
            ,@exp_cnt      = 2
            ,@id           = 2
            ,@exp_line     = 'BCD'
            ,@exp_ex_num   = NULL
            ,@exp_ex_msg   = NULL
         EXEC test.hlpr_006_fnSplit
             @test_num     = '003 comma'
            ,@inp          = 'A,BCD,'
            ,@sep          = ','
            ,@exp_cnt      = 2
            ,@id           = 1
            ,@exp_line     = 'A'
            ,@exp_ex_num   = NULL
            ,@exp_ex_msg   = NULL
         EXEC test.hlpr_006_fnSplit
             @test_num     = '004 comma'
            ,@inp          = 'A,BCD,'
            ,@sep          = ','
            ,@exp_cnt      = 2
            ,@id           = 2
            ,@exp_line     = 'BCD'
            ,@exp_ex_num   = NULL
            ,@exp_ex_msg   = NULL
         EXEC test.hlpr_006_fnSplit
             @test_num     = '005: Null test'
            ,@inp          = NULL
            ,@sep          = ','
            ,@exp_cnt      = 0
            ,@id           = NULL
            ,@exp_line     = NULL
            ,@exp_ex_num   = NULL
            ,@exp_ex_msg   = NULL
         EXEC test.hlpr_006_fnSplit
             @test_num     = '006: MT test'
            ,@inp          = ''
            ,@sep          = ','
            ,@exp_cnt      = 0
            ,@id           = NULL
            ,@exp_line     = NULL
            ,@exp_ex_num   = NULL
            ,@exp_ex_msg   = NULL
         EXEC test.hlpr_006_fnSplit
             @test_num     = '007: NN'
            ,@inp          = NULL
            ,@sep          = NULL
            ,@exp_cnt      = 0
            ,@id           = NULL
            ,@exp_line     = NULL
            ,@exp_ex_num   = NULL
            ,@exp_ex_msg   = NULL
--            ,@exp_ex_st    = NULL
--            ,@disp         = @disp
         EXEC test.hlpr_006_fnSplit
             @test_num     = '008: Null Sep'
            ,@inp          = 'A,BCD'
            ,@sep          = NULL
            ,@exp_cnt      = 0
            ,@id           = NULL
            ,@exp_line     = NULL
            ,@exp_ex_num   = NULL
            ,@exp_ex_msg   = NULL
--            ,@exp_ex_st    = NULL
--            ,@disp         = @disp
         EXEC test.hlpr_006_fnSplit
             @test_num     = '009: Null Sep Null'
            ,@inp          = NULL
            ,@sep          = NULL
            ,@exp_cnt      = 0
            ,@id           = NULL
            ,@exp_line     = NULL
            ,@exp_ex_num   = NULL
            ,@exp_ex_msg   = NULL
--            ,@exp_ex_st    = NULL
--            ,@disp         = @disp
         EXEC test.hlpr_006_fnSplit
             @test_num     = '010: Null Sep MT'
            ,@inp          = ''
            ,@sep          = NULL
            ,@exp_cnt      = 0
            ,@id           = NULL
            ,@exp_line     = NULL
            ,@exp_ex_num   = NULL
            ,@exp_ex_msg   = NULL
--            ,@exp_ex_st    = NULL
--            ,@disp         = @disp
         EXEC test.hlpr_006_fnSplit
             @test_num     = '011: MT Sep MT'
            ,@inp          = ''
            ,@sep          = ''
            ,@exp_cnt      = 0
            ,@id           = NULL
            ,@exp_line     = NULL
            ,@exp_ex_num   = NULL
            ,@exp_ex_msg   = NULL
--            ,@exp_ex_st    = NULL
--            ,@disp         = @disp
         EXEC test.hlpr_006_fnSplit
             @test_num     = '012 Big'
            ,@inp          = 'A,BCD,drfg,15#$%,,34'
            ,@sep          = @tab
            ,@exp_cnt      = 1
            ,@id           = 1
            ,@exp_line     = 'A,BCD,drfg,15#$%,,34'
            ,@exp_ex_num   = NULL
            ,@exp_ex_msg   = NULL
--            ,@exp_ex_st    = NULL
--            ,@disp         = @disp
         EXEC test.hlpr_006_fnSplit
             @test_num     = '013 Big'
            ,@inp          = '#$%,BCD,drfg,15#$%,,34'
            ,@sep          = ','
            ,@exp_cnt      = 6
            ,@id           = 1
            ,@exp_line     = '#$%'
            ,@exp_ex_num   = NULL
            ,@exp_ex_msg   = NULL
--            ,@exp_ex_st    = NULL
--            ,@disp         = @disp
         EXEC test.hlpr_006_fnSplit
             @test_num     = '014 Big'
            ,@inp          = 'A,BCD,drfg,15#$%,,34'
            ,@sep          = ','
            ,@exp_cnt      = 6
            ,@id           = 6
            ,@exp_line     = '34'
            ,@exp_ex_num   = NULL
            ,@exp_ex_msg   = NULL
--            ,@exp_ex_st    = NULL
--            ,@disp         = @disp
         EXEC test.hlpr_006_fnSplit
             @test_num     = '015 Big'
            ,@inp          = 'A,BCD,drfg,15#$%,,34'
            ,@sep          = ','
            ,@exp_cnt      = 6
            ,@id           = 5
            ,@exp_line     = ''
            ,@exp_ex_num   = NULL
            ,@exp_ex_msg   = NULL
--            ,@exp_ex_st    = NULL
--            ,@disp         = @disp
         EXEC test.hlpr_006_fnSplit
             @test_num     = '016 Big Tab'
            ,@inp          = @tabbed_str
            ,@sep          = @tab
            ,@exp_cnt      = 6
            ,@id           = 5
            ,@exp_line     = ''
            ,@exp_ex_num   = NULL
            ,@exp_ex_msg   = NULL
--            ,@exp_ex_st    = NULL
--            ,@disp         = @disp
         EXEC test.hlpr_006_fnSplit
             @test_num     = '017 Big Tab'
            ,@inp          = @tabbed_str
            ,@sep          = @tab
            ,@exp_cnt      = 6
            ,@id           = 1
            ,@exp_line     = 'A'
            ,@exp_ex_num   = NULL
            ,@exp_ex_msg   = NULL
--            ,@exp_ex_st    = NULL
--            ,@disp         = @disp
         EXEC test.hlpr_006_fnSplit
             @test_num     = '018 Big Tab'
            ,@inp          = @tabbed_str
            ,@sep          = @tab
            ,@exp_cnt      = 6
            ,@id           = 6
            ,@exp_line     = '34'
            ,@exp_ex_num   = NULL
            ,@exp_ex_msg   = NULL
--            ,@exp_ex_st    = NULL
--            ,@disp         = @disp
         -- ' ,BCD,drfg,15#$%,,34'
         DECLARE @tab_str_wi_spc NVARCHAR(30)= REPLACE(@tabbed_str, 'A', ' ');
         PRINT CONCAT('[', @tabbed_str, '] comma str:[', @comma_str, ']');
         EXEC test.hlpr_006_fnSplit
             @test_num     = '19 Big Tab wi spc'
            ,@inp          = @tab_str_wi_spc
            ,@sep          = @tab
            ,@exp_cnt      = 6
            ,@id           = 1
            ,@exp_line     = ' '
            ,@exp_ex_num   = NULL
            ,@exp_ex_msg   = NULL
         -- ' ,BCD,drfg,15#$%,,34'
         EXEC test.hlpr_006_fnSplit
             @test_num     = '20 Big Tab wi spc'
            ,@inp          = @tabbed_str
            ,@sep          = @tab
            ,@exp_cnt      = 6
            ,@id           = 2
            ,@exp_line     = 'BCD'
            ,@exp_ex_num   = NULL
            ,@exp_ex_msg   = NULL
         BREAK;  -- Do once loop
      END -- WHILE 1 = 1
      EXEC ut.test.sp_tst_mn_cls;
   END TRY
   BEGIN CATCH
      EXEC ut.test.sp_tst_mn_hndl_ex;
   END CATCH
END
/*
EXEC tSQLt.RunAll
EXEC tSQLt.Run 'test.test 006 fnSplit'
*/
GO

