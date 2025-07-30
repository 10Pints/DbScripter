SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================
-- Author:      Terry Watts
-- Create date: 05-JAN-2021
-- Description: Tests the fnIsFloat routine
-- =====================================================
CREATE PROCEDURE [test].[hlpr_025_fnIsFloat]
       @test_num     NVARCHAR(10)
      ,@v            SQL_VARIANT
      ,@exp          BIT
      ,@exp_ex_num      INT            = NULL
      ,@exp_ex_msg      NVARCHAR(500)  = NULL
      ,@exp_ex_st       INT            = NULL
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(35)   = 'hlpr_025_fnIsFloat'
      ,@NL           NVARCHAR(2)    = dbo.fnGetNL()
      ,@act          BIT
   BEGIN TRY
      EXEC ut.test.sp_tst_hlpr_st @fn, @test_num
      -- Populate the IN/OUT params
      -- Run test specific setup
      -- Call the tested routine
      SET @act = dbo.fnIsFloat(@v);
      -- Test the expected values if specified
      IF @exp IS NOT NULL EXEC ut.test.sp_tst_gen_chk N'01', @exp, @act,'1 exp'
      -- Check if an exception should have been thrown
      EXEC ut.test.sp_tst_hlpr_try_end @exp_ex_num, @exp_ex_msg,@exp_ex_st;
   END TRY
   BEGIN CATCH
      DECLARE @_tmp     NVARCHAR(500) = ut.dbo.fnGetErrorMsg()
             ,@params   NVARCHAR(4000) = CONCAT(
          '@test_num    =[', @test_num  ,']'                , @NL
         ,'@v           =[', CONVERT(NVARCHAR(50), @v),']'  , @NL
         ,'@exp         =[', @exp       ,']'                , @NL
         ,'@act         =[', @act       ,']'                , @NL
         );
      -- Check the expected exception
      EXEC UT.test.sp_tst_hlpr_hndl_ex 
          @exp_ex_num   = @exp_ex_num
         ,@exp_ex_msg   = @exp_ex_msg
         ,@exp_ex_st    = @exp_ex_st
         ,@params       = @params
   END CATCH
END
/*
exec tSQLt.RunALL;
exec tSQLt.Run 'test.test_025_fnIsFloat';
*/
GO

