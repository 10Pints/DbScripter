SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================
-- Author:      Terry Watts
-- Create date: 01-FEB-2021
-- Description: Tests the fnChkEquals routine
-- ===============================================
CREATE PROCEDURE [test].[hlpr_009_fnIsLessThan]
       @test_num     NVARCHAR(10)
      ,@a            SQL_VARIANT
      ,@b            SQL_VARIANT
      ,@exp          BIT
      ,@exp_ex_num   INT            = NULL
      ,@exp_ex_msg   NVARCHAR(500)  = NULL
      ,@exp_ex_st    INT            = NULL
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(30)   = N'h 009 fnIsLessThan'
      ,@fn_num       INT            =  9
      ,@tfn          NVARCHAR(50)   = 'fnIsLessThan'
      ,@hfn          NVARCHAR(50)   = 'h 009 fnIsLessThan'
      ,@act          BIT
      ,@NL           NVARCHAR(2)    = NCHAR(13) + NCHAR(10)
      ,@strA         NVARCHAR(4000) = CONVERT(NVARCHAR(4000), @a)
      ,@strB         NVARCHAR(4000) = CONVERT(NVARCHAR(4000), @b)
   BEGIN TRY
      EXEC ut.test.sp_tst_hlpr_st @fn, @test_num;
      -- Populate the IN/OUT params
      -- Run test specific setup
      -- Call the tested routine
      SET @act = dbo.fnIsLessThan(@a, @b);
      IF @exp IS NOT NULL EXEC ut.test.sp_tst_gen_chk N'01', @exp, @act,'1';
      EXEC ut.test.sp_tst_hlpr_try_end @exp_ex_num, @exp_ex_msg,@exp_ex_st;
   END TRY
   BEGIN CATCH
      DECLARE @params NVARCHAR(4000) = CONCAT(
          '@test_num  =[', @test_num,']', @NL
         ,'@a         =[', @strA    ,']', @NL
         ,'@b         =[', @strB    ,']', @NL
         ,'@exp       =[', @exp     ,']', @NL
         ,'@act       =[', @act     ,']', @NL
         );
      -- Check if an exception should have been thrown
      EXEC ut.test.sp_tst_hlpr_hndl_ex
                @exp_ex_num = @exp_ex_num
               ,@exp_ex_msg = @exp_ex_msg
   END CATCH
   EXEC test.sp_tst_hlpr_hndl_success;
END
/*
   EXEC tSQLt.RunAll
   EXEC tSQLt.Run 'test.test_009_fnIsLessThan'
*/
GO

