SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [test].[hlpr_020_fnGetReplacePhrase]
       @test_num        NVARCHAR(50)
      ,@table           VARCHAR(50)    = NULL
      ,@folder          VARCHAR(260)   = NULL
      ,@wrkbk_nm        VARCHAR(260)   = NULL
      ,@sheet_nm        VARCHAR(50)    = NULL
      ,@view_nm         VARCHAR(50)    = NULL
      ,@tmstmp          VARCHAR(11)    = NULL
      ,@exp_rc          INT            = NULL
      ,@exp_wrkbk_nm    VARCHAR(260)   = NULL
      ,@exp_sht_nm      VARCHAR(50)    = NULL
      ,@exp_view_nm     VARCHAR(50)    = NULL
      ,@exp_tmstmp      VARCHAR(11)    = NULL
      ,@exp_err_msg     VARCHAR(200)   = NULL
      ,@exp_ex_num      INT            = NULL
      ,@exp_ex_msg      NVARCHAR(500)  = NULL
AS
BEGIN
   DECLARE
       @fn_num          NVARCHAR(3)    =  N'020'
      ,@fn              NVARCHAR(4)    = 'hlpr_020_fnGetReplacePhrase'
      ,@act             NVARCHAR(50)
      ,@NL              NVARCHAR(2)    = NCHAR(13) + NCHAR(10)
      ,@act_rc          INT
      ,@act_wrkbk_nm    VARCHAR(260)
      ,@act_sht_nm      VARCHAR(50)
      ,@act_view_nm     VARCHAR(50)
      ,@act_tmstmp      VARCHAR(11)
      ,@act_err_msg     VARCHAR(200)
   BEGIN TRY
      EXEC ut.test.sp_tst_hlpr_st @fn, @test_num
      -- Populate the IN/OUT params
      -- Run test specific setup
      -- Call the tested routine
      SET @act_wrkbk_nm = @wrkbk_nm
      SET @act_sht_nm  = @sheet_nm
      SET @act_view_nm = @view_nm
      SET @act_tmstmp  = @tmstmp
      EXEC @act_rc = dbo.sp_exprt_to_xl_val 
          @tbl_spec= @table
         ,@folder  = @folder
         ,@wrkbk_nm= @act_wrkbk_nm OUTPUT
         ,@sht_nm  = @act_sht_nm  OUTPUT
         ,@vw_nm   = @act_view_nm OUTPUT
--         ,@error_msg   = @act_err_msg OUTPUT
         
      IF @exp_rc       IS NOT NULL EXEC [test].[sp_tst_gen_chk] N'01: rc'      , @exp_rc,      @act_rc      , 'oops';
      IF @exp_wrkbk_nm IS NOT NULL EXEC [test].[sp_tst_gen_chk] N'02: wrkbk_nm', @exp_wrkbk_nm,@act_wrkbk_nm, 'oops';
      IF @exp_sht_nm   IS NOT NULL EXEC [test].[sp_tst_gen_chk] N'03: sht_nm ' , @exp_sht_nm,  @act_sht_nm  , 'oops';
      IF @exp_view_nm  IS NOT NULL EXEC [test].[sp_tst_gen_chk] N'04: view_nm' , @exp_view_nm, @act_view_nm , 'oops';
      IF @exp_tmstmp   IS NOT NULL EXEC [test].[sp_tst_gen_chk] N'05: tmstmp ' , @exp_tmstmp,  @act_tmstmp  , 'oops';
      EXEC ut.test.sp_tst_hlpr_try_end @exp_ex_num, @exp_ex_msg;
   END TRY
   BEGIN CATCH
      DECLARE
         @act_ex_msg NVARCHAR(500) = ERROR_MESSAGE()
        ,@act_ex_num INT           = ERROR_NUMBER()
      -- Are we expecting an exception?
      IF @exp_ex_msg IS NULL AND @exp_ex_num IS NULL
         EXEC tSQLt.Fail 'Caught unexpected exception';
      -- ASSERTION: we expected an exception -check the expected exception
      IF @exp_ex_msg IS NOT NULL EXEC tSQLt.AssertEquals @exp_ex_msg, @act_ex_msg, 'subtest 01: exp/act ex msg mismatch'
      IF @exp_ex_num IS NOT NULL EXEC tSQLt.AssertEquals @exp_ex_num, @act_ex_num, 'subtest 02: exp/act ex num mismatch'
   END CATCH
   EXEC sp_log 1, @fn, 'test ', @test_num, ': passed';
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_020_fnGetReplacePhrase'
*/
GO

