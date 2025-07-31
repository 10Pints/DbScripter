SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 26-MAR-2020
-- Description: Tests the sp_tst_handle_known_symbol routine
--
-- Tested Item:
-- Description: handles a multi_character token 
--              valid characters: @,a-z A-Z
-- Returns:
--              0 if end
--              1 if found
-- pos:         next non white space character after token
-- token_name:  the multi character token 
-- token_id:    if found the id of the keyword + 1000
--              else 1
--
-- ERROR CODES: none
-- =============================================
--[@tSQLt:SkipTest]('Temporarily disabled while refactoring')
CREATE PROCEDURE [test].[test_053_fnEatWhitespace]
AS
BEGIN
   BEGIN TRY
      WHILE 1 = 1
      BEGIN
         SET NOCOUNT ON
         -- 1 off setup
         EXEC UT.test.sp_tst_mn_st  N'test 002 fnEatWhitespace'
         -- GREEN 
         EXEC [test].[h 002 fnEatWhitespace]  
                @test_num     = '001: ''c'' P1 X1'  -- known key word
               ,@txt          = 'c'
               ,@pos          = 1
               ,@exp_pos      = 1
               ,@exp_char     = 'c'
               ,@exp_ex_num   = NULL
               ,@exp_ex_msg   = NULL
               ,@exp_ex_st    = NULL
         EXEC [test].[h 002 fnEatWhitespace]  
                @test_num     = '002: NULL T and pos X0'  -- known key word
               ,@txt          = NULL
               ,@pos          = NULL
               ,@exp_pos      = 1
               ,@exp_char     = NULL
               ,@exp_ex_num   = NULL
               ,@exp_ex_msg   = NULL
               ,@exp_ex_st    = NULL
         EXEC [test].[h 002 fnEatWhitespace]  
                @test_num     = '003: MTstr X0'  -- known key word
               ,@txt          = ''
               ,@pos          = 0
               ,@exp_pos      = 1
               ,@exp_char     = NULL
               ,@exp_ex_num   = NULL
               ,@exp_ex_msg   = NULL
               ,@exp_ex_st    = NULL
         -- GREEN 
         EXEC [test].[h 002 fnEatWhitespace]  
                @test_num     = '004: ''c'' P0 X1'  -- known key word
               ,@txt          = 'c'
               ,@pos          = 0
               ,@exp_pos      = 1
               ,@exp_char     = 'c'
               ,@exp_ex_num   = NULL
               ,@exp_ex_msg   = NULL
               ,@exp_ex_st    = NULL
         --  GREEN
         EXEC [test].[h 002 fnEatWhitespace] 
                @test_num     = '005: P1 X7'  -- only spaces
               ,@txt          = '       '
               ,@pos          = 1
               ,@exp_pos      = 8
               ,@exp_char     = NULL
               ,@exp_ex_num   = NULL
               ,@exp_ex_msg   = NULL
               ,@exp_ex_st    = NULL
         --  GREEN
         EXEC [test].[h 002 fnEatWhitespace]  
                @test_num     = '006 ''    f ''P1X5' -- known key word
               ,@txt          = '    f '
               ,@pos          = 1
               ,@exp_pos      = 5
               ,@exp_char     = 'f'
               ,@exp_ex_num   = NULL
               ,@exp_ex_msg   = NULL
               ,@exp_ex_st    = NULL
         --  checking that a negative pos gets set 1 and does not cause problem
         EXEC [test].[h 002 fnEatWhitespace] 
                @test_num     = '007: Singl sps str P-1X-1'  -- known key word
               ,@txt          = ' '
               ,@pos          = -1
               ,@exp_pos      = 2
               ,@exp_char     = NULL
               ,@exp_ex_num   = NULL
               ,@exp_ex_msg   = NULL
               ,@exp_ex_st    = NULL
         EXEC [test].[h 002 fnEatWhitespace]  
                @test_num     = '008: P5 X5  asdf   '
               ,@txt          = '  asdf   '
               ,@pos          = 5
               ,@exp_pos      = 5
               ,@exp_char     = NULL
               ,@exp_ex_num   = NULL
               ,@exp_ex_msg   = NULL
               ,@exp_ex_st    = NULL
         BREAK
      END -- WHILE
      -- Cleanup after all tests
      EXEC test.sp_tst_mn_cls
   END TRY
   BEGIN CATCH
      DECLARE @_tmp NVARCHAR(500) = ut.dbo.fnGetErrorMsg();
      EXEC ut.test.sp_tst_mn_hndl_ex;
   END CATCH
END
/*
EXEC test.test_053_fnEatWhitespace
EXEC tSQLt.Run 'test.test_053_fnEatWhitespace'
EXEC tSQLt.RunAll
*/
GO

