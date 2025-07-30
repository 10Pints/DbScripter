SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 05-APR-2020
-- Description: Encapsulates the test helper close
-- =============================================
CREATE PROCEDURE [test].[sp_tst_hlpr_try_end]
       @exp_ex_num   INT            = NULL
      ,@exp_ex_msg   NVARCHAR(500)  = NULL
      ,@exp_ex_st    INT            = NULL
AS
BEGIN
   DECLARE
       @msg          NVARCHAR(1000)
      ,@line         NVARCHAR(100)  = REPLICATE('-', 100)
      ,@NL           NVARCHAR(2)    = NCHAR(13) + NCHAR(10)
      ,@TAB          NVARCHAR(1)    = NCHAR(9)
      ,@act_ex_num   INT            = ERROR_NUMBER()
      ,@act_ex_msg   NVARCHAR(4000) = ERROR_MESSAGE()
      ,@act_ex_st    INT            = ERROR_STATE()
      ,@disp_pass    INT            = 0
      ,@hlpr_fn      NVARCHAR(80)
   SET @hlpr_fn = test.fnGetCrntTstFn();
   SET @msg = CONCAT( dbo.fnPadRight( CONCAT(test.fnGetCrntTstNum(), ' All subtests'), 50), ': ');
   -- Check if an exception should have been thrown
   IF (@exp_ex_num IS NOT NULL OR @exp_ex_msg IS NOT NULL OR @exp_ex_st IS NOT NULL)
   BEGIN
      PRINT CONCAT(@NL, @Line);
      EXEC sp_log 1, @hlpr_fn, @msg, 'failed';
      IF @exp_ex_num IS NOT NULL
         SET @msg = CONCAT(@msg, 'Expected exception num: ', @exp_ex_num, ' which was not thrown: ', @NL);
      IF @exp_ex_msg IS NOT NULL
         SET @msg = CONCAT(@msg, 'Expected exception msg: ', @exp_ex_msg, ' which was not thrown: ', @NL);
      IF @exp_ex_st IS NOT NULL
         SET @msg = CONCAT(@msg, 'Expected exception st : ', @exp_ex_st, ' which was not thrown: ', @NL);
      EXEC sp_log 1, @hlpr_fn, @NL, @msg, @NL, @NL;
      PRINT CONCAT( @Line, @NL);
      THROW 50000, @msg, 1;
   END
   -- Log test passed if required
--   IF dbo.fnGetSessionContextAsInt(N'DISP_TST_RES') <> 0
--   BEGIN
--      SET @msg = CONCAT( dbo.fnPadRight( CONCAT(@test_num, ' All subtests'), 50), ': ');
--      EXEC sp_log '', @msg, 'pass', @dont_pad = 0,@force=1;
--   END
END
GO

