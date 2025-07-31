SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      24-Nov-2023
-- Description:      test helper rtn for the sp_crt_tst_rtns rtn being tested
-- Tested rtn desc:
--  Creates both the main and the helper test rtns
--   for the given tested rtn
--
-- Changes:
-- 231124: added remove [] brckets to make it easier to set up tests
--
-- Tested rtn params:
--    @q_tstd_rtn    NVARCHAR(100),
--    @test_rtn_num  INT,
--    @crt_or_alter  NCHAR(2),
--    @fn_ret_ty     NVARCHAR(50)
--========================================================================================
CREATE PROCEDURE [test].[hlpr_068_sp__crt_tst_rtns]
    @tst_num      NVARCHAR(100)
   ,@qrn          NVARCHAR(100)
   ,@trn          INT
   ,@cora         NCHAR(1)
   ,@ad_stp       BIT
   ,@tst_mode     BIT
   ,@stop_stg     INT
   ,@folder       NVARCHAR(500)
   ,@exp_ex_num   INT            = NULL
   ,@exp_ex_msg   NVARCHAR(500)  = NULL
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(35)   = N'hlpr_068_sp__crt_tst_rtns'
      ,@cmd          NVARCHAR(500)
      ,@hlpr_rtn_nm  NVARCHAR(50)
      ,@rtn_nm       NVARCHAR(100)
      ,@tst_rtn_nm   NVARCHAR(50)
   EXEC test.sp_tst_hlpr_st @fn, @tst_num
   SELECT @rtn_nm = rtn_nm FROM dbo.fnSplitQualifiedName(@qrn);
---- SETUP:
   EXEC sp_log 1, @fn, '001: SETUP: removing the generated test routines if they exist';
   SET @tst_rtn_nm   = test.fnCreateTestRtnName(@rtn_nm, @trn, 'M');
   SET @hlpr_rtn_nm  = test.fnCreateTestRtnName(@rtn_nm, @trn, 'H');
   SET @cmd = CONCAT('Drop PROCEDURE IF EXISTS test.', @tst_rtn_nm);
   EXEC sp_log 1, @fn, '002: drop cmd: ', @cmd;
   EXEC(@cmd);
   SET @cmd = CONCAT('Drop PROCEDURE IF EXISTS test.', @hlpr_rtn_nm);
   EXEC sp_log 1, @fn, '003: drop cmd: ', @cmd;
   EXEC(@cmd);
---- RUN tested rtn:
   EXEC sp_log 1, @fn, '04: running tested rtn: EXEC test.sp_crt_tst_rtns @q_tstd_rtn,@test_rtn_num,@crt_or_alter,@fn_ret_ty;';
   IF @exp_ex_num IS NOT NULL
   BEGIN
      BEGIN TRY
         -- Expect an exception here
         EXEC sp_log 2, @fn, '05: Expect an exception here';
         EXEC test.sp__crt_tst_rtns --@q_tstd_rtn,@test_rtn_num,@crt_or_alter,@fn_ret_ty;
             @qrn     = @qrn
            ,@trn     = NULL
            ,@cora    = 'C'
            ,@ad_stp  = 0    -- used in testing to identify a step with a unique name (not an incremental int id)
            ,@tst_mode= 1
            ,@stop_stg= 99
            ,@folder  = @folder
            ;
         EXEC sp_log 4, @fn, '06: oops! Expected an exception here';
         THROW 51000, ' Expected an exception but none were thrown', 1;
      END TRY
      BEGIN CATCH
         EXEC sp_log 2, @fn, '07: caught expected exception';
      END CATCH
   END -- IF @exp_ex = 1
   ELSE
   BEGIN
      -- Do not expect an exception here so execute and then run tests
      EXEC sp_log 2, @fn, '08: Calling sp_crt_tst_rtns..';
      EXEC test.sp__crt_tst_rtns
          @qrn       = @qrn
         ,@trn       = NULL
         ,@cora      = 'C'
         ,@ad_stp    = 0    -- used in testing to identify a step with a unique name (not an incremental int id)
         ,@tst_mode  = 1
         ,@stop_stg  = 99
         ,@folder  = @folder
         ;
      EXEC sp_log 2, @fn, '09: Returned from tested rtn: no exception thrown';
   END -- ELSE -IF @exp_ex = 1
---- TEST:
      EXEC sp_log 2, @fn, '10: running tests...';
      --EXEC sp_raise_exception 60000, 'Not implemented', @fn=@fn;
   -- <TBD>
      EXEC sp_log 2, @fn, '11: all tests ran OK';
---- CLEANUP:
   -- <TBD>
   EXEC test.sp_tst_hlpr_hndl_success;
END
/*
   EXEC tSQLt.Run 'test.test_068_sp__crt_tst_rtns';
*/
GO

