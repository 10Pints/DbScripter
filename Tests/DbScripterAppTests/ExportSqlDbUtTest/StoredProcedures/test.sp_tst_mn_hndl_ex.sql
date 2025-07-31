SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================================
-- Author:      Terry watts
-- Create date: 06-APR-2020
-- Description: Encapsulates the test helper exception handling
--              will re-trhrow the exception always
--              Calls sp_tst_main_close for convenience
--
-- RespS:       report the test num and sub nom and any error msg
-- =====================================================================
CREATE PROCEDURE [test].[sp_tst_mn_hndl_ex]
AS
BEGIN
   DECLARE
       @fnT          NVARCHAR(30)   = N'TST_MN_EX_HNDLR'
      ,@msg          NVARCHAR(1000)
      ,@NL           NVARCHAR(2)    = NCHAR(13) + NCHAR(10)
      ,@TAB          NVARCHAR(1)    = NCHAR(9)
      ,@line         NVARCHAR(100)  = REPLICATE('-', 100)
      ,@ex_msg       NVARCHAR(4000) = ERROR_MESSAGE()
      ,@ex_num       INT            = ERROR_NUMBER ()
      ,@ex_st        INT            = ERROR_STATE  ()
      ,@test_fn      NVARCHAR(100)
      ,@test_num     NVARCHAR(100)
      ,@test_sub_num NVARCHAR(100)
   SET @test_fn      = test.fnGetCrntTstFn();
   SET @test_num     = test.fnGetCrntTstNum();
   SET @test_sub_num = test.fnGetCrntTstSubNum();
   -- Display the errors if not a test chk failure
   --IF @ex_num <> 50000
      SET @msg = CONCAT
      (
          'tst   : ', @test_num,      @NL
         ,'tst#  : ', @test_num, '.', @test_sub_num, @NL
         ,'Ex num: ', @ex_num       , @NL
         ,'Ex msg: ', @ex_msg       , @NL
         ,'Ex st : ', @ex_st        , @NL
      );
   EXEC sp_log 1, '', @msg;
   EXEC test.sp_tst_mn_cls @msg
   -- Correct ex num if too low
   SET @ex_num = IIf( @ex_num < 50000, @ex_num + 50000, @ex_num);
   -- Finally always throw exception
   THROW @ex_num, 'test failed', @ex_st;
END
GO

