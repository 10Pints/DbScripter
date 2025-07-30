SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 17-JAN-2020
-- Description: Helper routine for the 
--              dbo.fnGetErrorMsg Tests
-- =============================================
CREATE PROCEDURE [test].[hlpr_015_fnGetErrorMsg]
       @test_num     NVARCHAR(10)
      ,@inp_ex_num   INT
      ,@inp_ex_msg   NVARCHAR(4000)
      ,@inp_ex_st    INT
      ,@exp_ex_msg1  NVARCHAR(4000)   = NULL
      ,@exp_ex_msg2  NVARCHAR(4000)   = NULL
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(40)   = N'h 015 fnGetErrorMsg'
      ,@act          NVARCHAR(50)
      ,@NL           NVARCHAR(2)    = NCHAR(13) + NCHAR(10)
   BEGIN TRY
      EXEC ut.test.sp_tst_hlpr_st @fn, @test_num;
      -- Populate the IN/OUT params
      -- Run test specific setup
      -- Call the tested routine
      THROW @inp_ex_num, @inp_ex_msg, @inp_ex_st;
      -- ASSERTION: if here then error: because should have 
      EXEC ut.test.sp_tst_hlpr_try_end @inp_ex_num, @exp_ex_msg1, @inp_ex_st;
   END TRY
   BEGIN CATCH
      DECLARE
          @act_ex_msg      NVARCHAR(500) = ut.dbo.fnGetErrorMsg()
         ,@act_st_clause   NVARCHAR(20);
      SET @act_st_clause = SUBSTRING(@act_ex_msg, CHARINDEX(' st: ', @act_ex_msg) + 5, 99);
      IF (
         (@exp_ex_msg1 IS NOT NULL) 
         AND (
               (CHARINDEX ( @exp_ex_msg1, @act_ex_msg) = 0)
            OR (CHARINDEX ( @exp_ex_msg2, @act_ex_msg) = 0)
            )
         )
      BEGIN
         -- ASSERTION: if here then error: message did not match the expected
         DECLARE @params NVARCHAR(4000) = CONCAT(
             '@test_num    =[', @test_num    ,']', @NL
            ,'@inp_ex_msg  =[', @inp_ex_msg  ,']', @NL
            ,'@inp_ex_num  =[', @inp_ex_num  ,']', @NL
            ,'@inp_ex_st   =[', @inp_ex_st   ,']', @NL
            ,'@act_ex_msg  =[', @act_ex_msg  ,']', @NL
            ,'@exp_ex_msg1 =[', @exp_ex_msg1 ,']', @NL
            ,'@exp_ex_msg2 =[', @exp_ex_msg2 ,']', @NL
            );
         EXEC ut.test.sp_tst_hlpr_hndl_ex
             @exp_ex_msg = @exp_ex_msg1
            ,@exp_ex_num = @inp_ex_num
            ,@exp_ex_st  = @inp_ex_st
      END
      ELSE
      BEGIN
         EXEC test.sp_tst_hlpr_hndl_success
      END
   END CATCH
END
/*
EXEC tSQLt.RunAll
EXEC tSQLt.Run 'test.test_015_fnGetErrorMsg'
*/
GO

