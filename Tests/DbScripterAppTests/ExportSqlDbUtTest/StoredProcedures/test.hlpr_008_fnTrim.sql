SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================
-- Author:      Terry Watts
-- Create date: 08-JAN-2020
-- Description: Tests helper for the fnTrim tests
-- ================================================
CREATE PROCEDURE [test].[hlpr_008_fnTrim]
       @tst_num      NVARCHAR(20)
      ,@inp          NVARCHAR(100)
      ,@exp          NVARCHAR(100)
      ,@msg          NVARCHAR(100)
      ,@exp_ex_num   INT
      ,@exp_ex_msg   NVARCHAR(500)
      ,@exp_ex_st    INT
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(35)   = 'hlpr_008_fnTrim'
      ,@NL           NVARCHAR(2)    = NCHAR(13) + NCHAR(10)
      ,@act          NVARCHAR(100)
      ,@len_act      INT
      ,@len_exp      INT
      ,@res          BIT
   BEGIN TRY
      EXEC ut.test.sp_tst_hlpr_st @fn, @tst_num;
      -- Populate the IN/OUT params
      -- Run test specific setup
      -- Call the tested routine
      SET @act = UT.dbo.fnTrim(@inp);
      IF @exp  IS NOT NULL EXEC [test].[sp_tst_gen_chk] N'01', @exp , @act, 'oops';
      EXEC ut.test.sp_tst_hlpr_try_end @exp_ex_num, @exp_ex_msg,@exp_ex_st;
   END TRY
   BEGIN CATCH
      -- Log input parameters
      DECLARE @params NVARCHAR(4000) = CONCAT(
          '@tst_num    =[', @tst_num    ,']', @NL
         ,'@inp        =[', @inp        ,']', @NL
         ,'@exp        =[', @exp        ,']', @NL
         ,'@msg        =[', @msg        ,']', @NL
         ,'@exp_ex_num =[', @exp_ex_num ,']', @NL
         ,'@exp_ex_msg =[', @exp_ex_msg ,']', @NL
         ,'@exp_ex_st  =[', @exp_ex_st  ,']', @NL
         );
      -- Check the expected exception
      EXEC ut.test.sp_tst_hlpr_hndl_ex
          @exp_ex_msg   = @exp_ex_msg
         ,@exp_ex_num   = @exp_ex_num
         ;
   END CATCH
   EXEC test.sp_tst_hlpr_hndl_success;
   EXEC sp_log 1, @fn, '99: leaving';
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_008_fnTrim';
*/
GO

