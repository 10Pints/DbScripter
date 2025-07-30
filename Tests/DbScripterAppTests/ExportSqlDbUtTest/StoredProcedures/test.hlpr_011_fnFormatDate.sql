SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 17-JAN-2020
-- Description: Helper routine the dbo.fnFormatDate Tests
-- =============================================
CREATE PROCEDURE [test].[hlpr_011_fnFormatDate]
       @test_num     NVARCHAR(10)
      ,@inp          DATE
      ,@exp          NVARCHAR(30)
      ,@exp_ex_num   INT
      ,@exp_ex_msg   NVARCHAR(500)
      ,@exp_ex_st    INT
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(30)   = N'hlpr_011_fnFormatDate'
      ,@NL           NVARCHAR(2)    = NCHAR(13) + NCHAR(10)
      ,@act          NVARCHAR(30)
   BEGIN TRY
      EXEC ut.test.sp_tst_hlpr_st @fn, @test_num
      -- Populate the IN/OUT params
      -- Run test specific setup
      -- Call the tested routine
      SET @act = dbo.fnFormatDate(@inp);
      IF @exp IS NOT NULL EXEC ut.test.sp_tst_gen_chk N'01', @exp, @act,'1 id'
      -- Check if an exception should have been thrown
      EXEC ut.test.sp_tst_hlpr_try_end @exp_ex_num, @exp_ex_msg,@exp_ex_st;
   END TRY
   BEGIN CATCH
      DECLARE
          @_tmp     NVARCHAR(500) = ut.dbo.fnGetErrorMsg()
         ,@params   NVARCHAR(4000) = CONCAT(
             '@test_num =[', @test_num   ,']', @NL
            ,'@inp      =[', @inp        ,']', @NL
            ,'@act      =[', @act        ,']', @NL
         );
      -- Check the expected exception
      EXEC ut.test.sp_tst_hlpr_hndl_ex 
          @exp_ex_num   = @exp_ex_num
         ,@exp_ex_msg   = @exp_ex_msg
         ;
   END CATCH
   EXEC test.sp_tst_hlpr_hndl_success;
END
/*
EXEC tSQLt.RunAll
EXEC tSQLt.Run 'test.test_011_fnFormatDate'
*/
GO

