SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2021
-- Description: Helper rtn the fnCompare tests
--
-- Tested routine: INT dbo.fnCompare(@a NVARCHAR(4000), @b NVARCHAR(4000))
-- Description: increments @pos until a non whitespace charactes found
-- Returns:1 based index of the first non space character in @txt from index @pos
--              or 0 if not found
-- ==============================================================================
CREATE PROCEDURE [test].[hlpr_003_fnCompare]
       @test_num        NVARCHAR(100)
      ,@a               NVARCHAR(4000)
      ,@b               NVARCHAR(4000)
      ,@exp_pos         INT            = NULL
      ,@exp_char_a      NVARCHAR(5)    = NULL
      ,@exp_char_b      NVARCHAR(5)    = NULL
      ,@exp_ex_num      INT            = NULL
      ,@exp_ex_msg      NVARCHAR(500)  = NULL
      ,@exp_ex_st       INT            = NULL
AS
BEGIN
   DECLARE
--       @fn_num             INT            = 3
       @fn                 NVARCHAR(20)   = 'test_003_fnCompare'
      ,@NL                 NVARCHAR(2)    = NCHAR(13) + NCHAR(10)
      ,@act_pos            INT
      ,@len_a              INT
      ,@len_b              INT
      ,@act_char_a         NVARCHAR(5)
      ,@act_char_b         NVARCHAR(5)
   BEGIN TRY
      EXEC ut.test.sp_tst_hlpr_st  @fn, @test_num;
      -- Populate the IN/OUT params
      -- Run test specific setup
      SET @len_a   = dbo.fnLen(@a);
      SET @len_b   = dbo.fnLen(@b);
      -- Call the tested routine
      SET @act_pos = [dbo].[fnCompare](@a, @b);
      SET @act_char_a = iif(@len_a IS NULL, 'NULL', iif(@len_a >= @act_pos, SUBSTRING( @a, @act_pos, 1), 'NULL'));
      SET @act_char_b = iif(@len_b IS NULL, 'NULL', iif(@len_b >= @act_pos, SUBSTRING( @b, @act_pos, 1), 'NULL'));
      -- Test the result
      IF @exp_pos    IS NOT NULL EXEC [test].sp_tst_gen_chk N'01', @exp_pos   , @act_pos   , '1 pos'
      IF @act_char_a IS NOT NULL EXEC [test].sp_tst_gen_chk N'02', @exp_char_a, @act_char_a, '2 char a'
      IF @act_char_b IS NOT NULL EXEC [test].sp_tst_gen_chk N'03', @exp_char_b, @act_char_b, '2 char b'
      -- Check if an exception should have been thrown
      EXEC ut.test.sp_tst_hlpr_try_end @exp_ex_num, @exp_ex_msg, @exp_ex_st
   END TRY
   BEGIN CATCH
      DECLARE @_tmp     NVARCHAR(500) = ut.dbo.fnGetErrorMsg()
             ,@params   NVARCHAR(4000) = CONCAT(
                '@test_num  =[', @test_num,  ']', @NL
               ,'@a         =[', @a,         ']', @NL
               ,'@b         =[', @b,         ']', @NL
               ,'@exp_pos   =[', @exp_pos,   ']', @NL
               ,'@act_pos   =[', @act_pos,   ']', @NL
               ,'@exp_char_a=[', @exp_char_a,']', @NL
               ,'@act_char_a=[', @act_char_a,']', @NL
               ,'@exp_char_b=[', @exp_char_b,']', @NL
               ,'@act_char_b=[', @act_char_b,']', @NL
               , @NL
         );
      EXEC UT.test.sp_tst_hlpr_hndl_ex 
          @exp_ex_num = @exp_ex_num
         ,@exp_ex_msg = @exp_ex_msg
         ,@exp_ex_st  = @exp_ex_st
         ,@params     = @params
   END CATCH
   
   EXEC sp_log 1, @fn,'99: leaving ok';
END
/*
EXEC tSQLt.RunAll
EXEC tSQLt.Run '[test].[test_003_fnCompare]'
*/
GO

