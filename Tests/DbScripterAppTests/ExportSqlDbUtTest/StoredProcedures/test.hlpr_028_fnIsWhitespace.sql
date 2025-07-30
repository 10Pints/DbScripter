SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ========================================================
-- Author:      Terry Watts
-- Create date: 08-JAN-2020
-- Description: Tests helper for the fnIsWhitespace tests
-- ========================================================
CREATE PROCEDURE [test].[hlpr_028_fnIsWhitespace]
       @test_num     NVARCHAR(20)
      ,@inp          NCHAR
      ,@exp          BIT            = NULL
      ,@exp_ex_num   INT            = NULL
      ,@exp_ex_msg   NVARCHAR(500)  = NULL
      ,@exp_ex_st    INT            = NULL
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(35)   = 'hlpr_028_fnIsWhitespace'
      ,@NL           NVARCHAR(2)    = NCHAR(13) + NCHAR(10)
      ,@act          BIT
      ,@len_act      INT
      ,@len_exp      INT
      ,@res          BIT
   BEGIN TRY
      EXEC ut.test.sp_tst_hlpr_st @fn, @test_num
      -- Populate the IN/OUT params
      -- Run test specific setup
      -- Call the tested routine
      SET @act = UT.dbo.fnIsWhitespace(@inp);
      -- Test
      IF @exp IS NOT NULL EXEC test.sp_tst_gen_chk N'01', @exp, @act,'exists'
      EXEC ut.test.sp_tst_hlpr_try_end @exp_ex_num, @exp_ex_msg,@exp_ex_st;
   END TRY
   BEGIN CATCH
      -- Log input parameters
      DECLARE @params NVARCHAR(4000) = CONCAT(
          '@test_num  =', @test_num  ,'', @NL
         ,'@inp        =', @inp        ,'', @NL
         ,'@exp        =', @exp        ,'', @NL
         ,'@exp_ex_num =', @exp_ex_num ,'', @NL
         ,'@exp_ex_msg =', @exp_ex_msg ,'', @NL
         ,'@exp_ex_st  =', @exp_ex_st  ,'', @NL
         );
      -- Check the expected exception
      EXEC ut.test.sp_tst_hlpr_hndl_ex 
          @exp_ex_msg   = @exp_ex_msg
         ,@exp_ex_num   = @exp_ex_num
         ,@exp_ex_st    = @exp_ex_st
         ,@params       = @params
   END CATCH
END
/*
exec tSQLt.RunAll;
exec tSQLt.Run 'test.test_028_fnIsWhitespace';
*/
GO

