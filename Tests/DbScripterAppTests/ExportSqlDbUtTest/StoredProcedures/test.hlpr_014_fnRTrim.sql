SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 08-JAN-2020
-- Description: Tests helper for dbo.fnRTrim tests
-- =============================================
CREATE PROCEDURE [test].[hlpr_014_fnRTrim]
       @test_num NVARCHAR(20)
      ,@inp NVARCHAR(100)           = NULL
      ,@exp NVARCHAR(100)           = NULL
      ,@exp_ex_num   INT            = NULL
      ,@exp_ex_msg   NVARCHAR(MAX)  = NULL
      ,@exp_ex_st    INT            = NULL
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(35)   =  'hlpr_014_fnRTrim'
      ,@act          NVARCHAR(50)
      ,@NL           NVARCHAR(2)    = NCHAR(13) + NCHAR(10)
   BEGIN TRY
      EXEC ut.test.sp_tst_hlpr_st @fn, @test_num;
      -- Populate the IN/OUT params
      -- Run test specific setup
      -- Call the tested routine
      SET @act = dbo.fnRTrim(@inp);
      -- Test
      IF @exp IS NOT NULL EXEC [test].[sp_tst_gen_chk] N'01', @exp, @act,'exists'
      EXEC ut.test.sp_tst_hlpr_try_end @exp_ex_num, @exp_ex_msg,@exp_ex_st;
   END TRY
   BEGIN CATCH
     DECLARE @params NVARCHAR(4000) = CONCAT(
          '@test_num=[', @test_num,']', @NL
         ,'@inp     =[', @inp     ,']', @NL
         ,'@exp     =[', @exp     ,']', @NL
         ,'@act     =[', @act     ,']', @NL
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
EXEC tSQLt.RunAll
EXEC tSQLt.Run 'test.test_014_fnRTrim';
*/
GO

