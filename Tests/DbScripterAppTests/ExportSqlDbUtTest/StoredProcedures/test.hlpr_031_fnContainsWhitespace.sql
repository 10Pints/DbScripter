SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2021
-- Description: Tests the dbo.fnContainsWhitespace routine
-- =====================================================
CREATE PROCEDURE [test].[hlpr_031_fnContainsWhitespace]
       @test_num     NVARCHAR(50)
      ,@inp          NVARCHAR(4000)   = NULL
      ,@exp_res      BIT = NULL
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(35) = 'hlpr_026_fnChkEquals'
      ,@tested_fn    NVARCHAR(80) = N'h 031 fnContainsWhitespace'
      ,@NL           NVARCHAR(2)  = NCHAR(13) + NCHAR(10)
      ,@act_res      BIT
      ,@msg          NVARCHAR(500)
   BEGIN TRY
      EXEC ut.test.sp_tst_hlpr_st @fn, @test_num;
      -- Populate the IN/OUT params
      -- Run test specific setup
      -- Call the tested routine
      SET @act_res = dbo.fnContainsWhitespace(@inp);
      -- Test the result
      IF @exp_res IS NOT NULL 
         EXEC ut.test.sp_tst_gen_chk
             N'01'
            ,@exp_res
            ,@act_res
            ,'1: res'
      -- Check if an exception should have been thrown N/A as a fn
      -- EXEC UT.test.sp_tst_helper_try_end @test_num, @fn, @exp_ex_num, @exp_ex_msg
   END TRY
   BEGIN CATCH
      DECLARE @act_ex_msg NVARCHAR(MAX) = UT.dbo.fnGetErrorMsg()
      DECLARE @_tmp     NVARCHAR(500) = ut.dbo.fnGetErrorMsg()
             ,@params   NVARCHAR(4000) = CONCAT(
       ' @test_num   ', @test_num   ,'', @NL
      ,' @inp        ', @inp        ,'', @NL
      ,' @exp_res    ', @exp_res    ,'', @NL
      ,' @act_res    ', @act_res    ,'', @NL
         );
      EXEC UT.test.sp_tst_hlpr_hndl_ex 
          @params     = @params
   END CATCH
END
/*
EXEC tSQLt.RunAll
EXEC tSQLt.Run 'test.test_031_fnContainsWhitespace'
*/
GO

