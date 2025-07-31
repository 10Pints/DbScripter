SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================
-- Author:      Terry Watts
-- Create date: 04-FEB-2021
-- Description: helper for the settings configuration accessors Tests
-- ==================================================================
CREATE PROCEDURE [test].[hlpr_030_chkTestConfig]
    @tst_num   NVARCHAR(100)
   ,@getterFn  NVARCHAR(60) = NULL
   ,@exp       NVARCHAR(60) = NULL
AS
BEGIN
   DECLARE
       @fn     NVARCHAR(60)   = 'hlpr_030_chkTestConfig'
      ,@act    NVARCHAR(60)      -- tested rtn ret value
      ,@cmd    NVARCHAR(4000)
      ,@msg    NVARCHAR(4000)
   SET NOCOUNT ON;
   BEGIN TRY
      --EXEC ut.test.sp_tst_hlpr_st @fn, @test_num
      EXEC ut.test.sp_tst_hlpr_st @fn, @tst_num;
      SET @msg = CONCAT(@fn, '(', @getterFn, ',', @exp, ')');
      SET @cmd = CONCAT('SET @act=', @getterFn, '(');
--      if @p1 IS NOT NULL SET @cmd = CONCAT(@cmd,       @p1);
--    if @p2 IS NOT NULL SET @cmd = CONCAT(@cmd, ', ', @p2);
      -- Add the final bracket
      SET @cmd = CONCAT(@cmd, ')');
      EXEC sp_log 1, @fn, '05: getter sql: ', @cmd;
      -- Run the routine
      EXEC sp_executesql @cmd, N'@act NVARCHAR(60) OUT', @act OUTPUT;--  @statement,N'@LabID int'
      -- test the result
      IF @exp IS NOT NULL 
      BEGIN
         EXEC sp_log 1, @fn, '010: ', @tst_num, ' exp: [',@exp,']';
         EXEC sp_log 1, @fn, '015: ', @tst_num, ' act: [',@act,'] checking...';
         EXEC dbo.sp_assert_equal @exp, @act, @msg;
         EXEC sp_log 1, @fn, '020: ', @tst_num, ' OK';
      END
      EXEC sp_log 1, @fn, '099: ', @tst_num, ' leaving: PASS';
   END TRY
   BEGIN CATCH
      DECLARE @err_msg NVARCHAR(4000) = dbo.fnGetErrorMsg();
--      PRINT CONCAT(@test_num, ': FAIL: ', ' ',@cmd, 'exp: ', @exp, ', act:',@act, ' err msg: ', @err_msg);
      EXEC sp_log 4, @fn, '500: ', @tst_num, ': CAUGHT exception: ', @err_msg;
      THROW
   END CATCH
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_030_chkTestConfig';
*/
GO

