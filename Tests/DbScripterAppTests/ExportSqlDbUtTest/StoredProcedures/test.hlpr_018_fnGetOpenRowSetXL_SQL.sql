SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================
-- Author:      Terry Watts
-- Create date: 17-JAN-2020
-- Description: Helper routine for
--              the dbo.fnGetOpenRowSetXL Tests
-- =====================================================
CREATE PROCEDURE [test].[hlpr_018_fnGetOpenRowSetXL_SQL]
       @test_num     NVARCHAR(100)
      ,@wrkbk        NVARCHAR(260)
      ,@range        NVARCHAR(50)
      ,@xl_cols      NVARCHAR(2000)          -- select XL column names: can be *
      ,@ext          NVARCHAR(50)   = NULL   -- default: 'HDR=NO;IMEX=1'
      ,@exp_sql      NVARCHAR(4000) = NULL
      ,@exp_ex_num   INT            = NULL
      ,@exp_ex_msg   NVARCHAR(4000) = NULL
      ,@exp_ex_st    INT            = NULL
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(40)   =  N'hlpr_018_fnGtOpnRowSetXL_SQL'
      ,@act_sql      NVARCHAR(4000)
      ,@NL           NVARCHAR(2)    = NCHAR(13) + NCHAR(10)
   BEGIN TRY
      EXEC ut.test.sp_tst_hlpr_st @fn, @test_num
      -- Populate the IN/OUT params
      -- Run test specific setup
      -- Call the tested routine
      SET @act_sql = ut.dbo.fnGetOpenRowSetXL_SQL(@wrkbk, @range, @xl_cols, @ext);
      PRINT CONCAT('ACT SQL: ', @NL, @act_sql);
      -- Check if an exception should have been thrown
      EXEC ut.test.sp_tst_hlpr_try_end @exp_ex_num, @exp_ex_msg,@exp_ex_st;
   END TRY
   BEGIN CATCH
      DECLARE @_tmp        NVARCHAR(500) = ut.dbo.fnGetErrorMsg()
             ,@act_ex_num  INT               = ERROR_NUMBER()
             ,@act_ex_msg   NVARCHAR(4000)   = ERROR_MESSAGE()
      EXEC sp_log 4, @fn, @test_num, ': CAUGHT exception ', @_tmp;
      /* Check the expected exception
      EXEC ut.test.sp_tst_hlpr_hndl_ex 
          @exp_ex_num = @exp_ex_num
         ,@exp_ex_msg = @exp_ex_msg
         ,@exp_ex_st  = @exp_ex_st
         ,@params     = @params;
      */
      IF @exp_ex_num IS NULL AND @exp_ex_msg IS NULL THROW;
      -- Assertion: expected an exception
      IF @exp_ex_num IS NOT NULL EXEC tSQLt.AssertEquals @exp_ex_num, @act_ex_num;
      IF @exp_ex_msg IS NOT NULL EXEC tSQLt.AssertEquals @exp_ex_msg, @act_ex_msg;
   END CATCH
   -- Test
   IF @exp_sql <> 'IGNORE' EXEC tSQLt.AssertEquals @exp_sql,@act_sql; --EXEC [test].[sp_tst_gen_chk] N'01', @exp_sql, @act_sql,'sql'
   EXEC sp_log 1, @fn, 'Test ',@test_num, ' PASSED';
END
/*
EXEC tSQLt.RunAll
EXEC tSQLt.Run 'test.test_018_fnGetOpenRowSetXL'
*/
GO

