SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      24-Nov-2023
-- Description:      test helper rtn for the sp_crt_tst_fn_mn rtn being tested
-- Tested rtn desc:
--  sp version of test.fnCrtTstRtnMn  
--  
-- Test Rtns:  
--      
-- Changes:  
-- 231121: @q_tstd_rtn must exist or exception 56472, '<@q_tstd_rtn> does not exist'  
-- 231121: added a try catch handler to log errors  
--
-- Tested rtn params: 
--    @q_tstd_rtn_nm  NVARCHAR(100),
--    @tst_rtn_num    INT,
--    @crt_or_alter   NCHAR(2)
--========================================================================================
CREATE PROCEDURE [test].[hlpr_067_sp_crt_tst_mn]
    @test_num        NVARCHAR(50)
   ,@qrn             NVARCHAR(100)
   ,@trn             INT
   ,@cora            NCHAR(2)
   ,@ad_stp          BIT   -- used in testing to identify a step with a unique name (not an incremental int id)
   ,@tst_mode        BIT   -- for testing - copy tmp tables to permananent tables for teting
   ,@stop_stage      INT   -- stage 12 for testing - display script
   ,@throw_if_err    BIT
   ,@row_id          INT            = NULL -- for rtns that return a table
   ,@exp_table       DescTableType  READONLY
   ,@exp_ex_num      INT            = NULL
   ,@exp_ex_msg      NVARCHAR(500)  = NULL
   ,@display_script  BIT            = 0
AS
BEGIN
   DECLARE
    @fn              NVARCHAR(35)   = N'hlpr_067_sp_crt_tst_fn_mn'
   ,@act_ex_num      INT = NULL
   ,@act_ex_msg      NVARCHAR(500)  = NULL
   ,@act_table       DescTableType
   EXEC sp_log 2, @fn, '01: starting, @test#: ', @test_num;
   -- SETUP:
   EXEC test.sp_get_rtn_details @qrn, @trn,@cora, @ad_stp, @tst_mode, @stop_stage, @throw_if_err;
---- RUN tested rtn:
   EXEC sp_log 1, @fn, '04: running tested rtn: EXEC test.sp_crt_tst_fn_mn @q_tstd_rtn_nm,@tst_rtn_num,@crt_or_alter;';
   IF @exp_ex_num IS NOT NULL
   BEGIN
      BEGIN TRY
         -- Expect an exception here
         EXEC sp_log 2, @fn, '05: Expect an exception here';
         EXEC test.sp_crt_tst_mn;-- @q_tstd_rtn_nm, @tst_rtn_num,@crt_or_alter;
         EXEC sp_log 4, @fn, '06: oops! Expected an exception here';
         THROW 51000, ' Expected an exception but none were thrown', 1;
      END TRY
      BEGIN CATCH
         EXEC sp_log 2, @fn, '07: caught expected exception';
         IF @exp_ex_num <> -1
         BEGIN
            SET @act_ex_num = ERROR_NUMBER();
            EXEC tSQLt.AssertEquals @exp_ex_num, @act_ex_num
         END
         IF @exp_ex_msg IS NOT NULL
         BEGIN
            SET @act_ex_msg = ERROR_MESSAGE();
            EXEC tSQLt.AssertEquals @exp_ex_msg, @act_ex_msg
         END
      END CATCH
   END -- IF @exp_ex = 1
   ELSE
   BEGIN
      -- Do not expect an exception here
      EXEC sp_log 2, @fn, '08: Calling tested rtn: do not expect an exception now';
      EXEC test.sp_crt_tst_mn;--@q_tstd_rtn_nm,@tst_rtn_num,@crt_or_alter;
      EXEC sp_log 2, @fn, '09: Returned from tested rtn: no exception thrown';
---- TEST:
      EXEC sp_log 2, @fn, '10: running tests...';
      if @display_script = 1
         SELECT id, line as [line                                                                                                      .]
         FROM test.TstDef;
      IF @row_id IS NOT NULL
      BEGIN
         INSERT INTO @act_table
         SELECT id, line
         FROM test.TstDef
         WHERE id = @row_id;
/*         EXEC tSQLt.AssertEqualsTable
             @Expected  = @exp_table
            ,@Actual    = @act_table
            ,@Message   =' abcd'
            ,@FailMsg   ='failed def'
            ,@ColumnList='line';*/
      END
   END -- ELSE -IF @exp_ex = 1
   EXEC sp_log 2, @fn, '11: all tests ran OK';
---- CLEANUP:
   -- <TBD>
   EXEC sp_log 2, @fn, 'test ',@test_num, ': PASSED';
END
/*
   EXEC tSQLt.RunAll;
   EXEC tSQLt.Run 'test.test_067_sp_crt_tst_mn';
*/
GO

