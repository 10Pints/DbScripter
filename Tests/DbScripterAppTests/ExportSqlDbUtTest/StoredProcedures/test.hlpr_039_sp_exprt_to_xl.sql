SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ========================================================================================
-- Author:           Terry Watts
-- Create date:      11-Nov-2023
-- Description:      test helper rtn for the sp_exprt_to_xl rtn being tested
-- Tested rtn desc:
-- Creates an Excel xls file as a TSV
-- N.B.: It needs to be loaded by Excel to actual make a .xls formatted file, however
-- Excel will open a CSV or TSV as an Excel file with a warning prompt
--
-- Process:
--  Validate parameters
--      Mandatory parameters
--          table name
--          folder
--
--  set paramter defaults as needed
--      file name       <table>.xlsx
--      sheet_name:     <table>
--      view:           <table>View
--      timestamp:      <current time and date> Fprmat YYMMDD-HHmm
--
-- Tested rtn params:
--    @tbl_nm      NVARCHAR(50),
--    @folder      NVARCHAR(260),
--    @wrkbk_nm    NVARCHAR(260),
--    @sht_nm      NVARCHAR(50),
--    @vw_nm       NVARCHAR(50),
--    @filter      NVARCHAR(MAX),
--    @crt_tmstmp  BIT,
--    @max_rows    INT
-- ========================================================================================
CREATE PROCEDURE [test].[hlpr_039_sp_exprt_to_xl]
    @tst_num     NVARCHAR(100)
   ,@tbl_spec    NVARCHAR(50)
   ,@folder      NVARCHAR(260)
   ,@wrkbk_nm    NVARCHAR(260)
   ,@sht_nm      NVARCHAR(50)
   ,@vw_nm       NVARCHAR(50)
   ,@filter      NVARCHAR(MAX)
   ,@crt_tmstmp  BIT
   ,@max_rows    INT
   ,@exp_ex_num  INT            = NULL
   ,@exp_ex_msg  NVARCHAR(500)  = NULL
AS
BEGIN
   DECLARE
    @fn          NVARCHAR(35)   = N'hlpr_039_sp_exprt_to_xl'
   ,@act_ex_num  INT            = NULL
   ,@act_ex_msg  NVARCHAR(500)  = NULL
   EXEC ut.test.sp_tst_hlpr_st @fn, @tst_num;
   EXEC sp_log 1, '005, params:
tst_num   :[', @tst_num   ,']
tbl_spec  :[', @tbl_spec  ,']
folder    :[', @folder    ,']
wrkbk_nm  :[', @wrkbk_nm  ,']
sht_nm    :[', @sht_nm    ,']
vw_nm     :[', @vw_nm     ,']
filter    :[', @filter    ,']
crt_tmstmp:[', @crt_tmstmp,']
max_rows  :[', @max_rows  ,']
exp_ex_num:[', @exp_ex_num,']
exp_ex_msg:[', @exp_ex_msg,']'
;
---- SETUP:
   -- <TBD>
---- RUN tested rtn:
   EXEC sp_log 1, @fn, '04: running tested rtn '
   IF @exp_ex_num IS NOT NULL
   BEGIN
      BEGIN TRY
         -- Expect an exception here
         EXEC sp_log 2, @fn, '05: calling sp_exprt_to_xl. Expect an exception';
         EXEC dbo.sp_exprt_to_xl
                @tbl_spec
               ,@folder
               ,@wrkbk_nm
               ,@sht_nm
               ,@vw_nm
               ,@filter
               ,@crt_tmstmp
               ,@max_rows
         ;
         EXEC sp_log 4, @fn, '06: oops! Expected an exception here';
         THROW 51000, ' Expected an exception but none were thrown', 1;
      END TRY
      BEGIN CATCH
         SET @act_ex_num = ERROR_NUMBER();
         SET @act_ex_msg = ERROR_MESSAGE();
         EXEC sp_log 2, @fn, '07: caught exception as expected, act ex details:
act_ex_num:[', @act_ex_num, ']
act_ex_msg:[', @act_ex_msg, ']
';
         EXEC tSQLt.AssertEquals @exp_ex_num, @act_ex_num
         IF @exp_ex_msg IS NOT NULL
         BEGIN
            EXEC tSQLt.AssertEquals @exp_ex_msg, @act_ex_msg
         END
         RETURN;
      END CATCH
   END -- IF @exp_ex IS NOT NULL
   ELSE
   BEGIN
      -- Do not expect an exception here
      EXEC sp_log 2, @fn, '08: Calling tested rtn: do not expect an exception now';
      EXEC dbo.sp_exprt_to_xl
             @tbl_spec   = @tbl_spec
            ,@folder     = @folder
            ,@wrkbk_nm   = @wrkbk_nm
            ,@sht_nm     = @sht_nm
            ,@vw_nm      = @vw_nm
            ,@filter     = @filter
            ,@crt_tmstmp = @crt_tmstmp
            ,@max_rows   = @max_rows
      ;
   EXEC sp_log 2, @fn, '09: Returned from tested rtn: no exception thrown';
---- TEST:
   EXEC sp_log 2, @fn, '10: running tests...';
   END  -- ELSE -IF @exp_ex_num IS NOT NULL
---- TEST:
   -- <TBD>
---- CLEANUP:
   -- <TBD>
--END
   EXEC test.sp_tst_hlpr_hndl_success;
   EXEC sp_log 1, @fn, '99: leaving'
END
/*
EXEC tSQLt.Run 'test.test_039_sp_exprt_to_xl';
EXEC tSQLt.RunAll;
*/
GO

