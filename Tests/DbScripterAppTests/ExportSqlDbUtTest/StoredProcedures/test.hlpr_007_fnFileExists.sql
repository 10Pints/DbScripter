SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 17-JAN-2020
-- Description: Helper routine the dbo.fnFileExists Tests
-- =============================================
CREATE PROCEDURE [test].[hlpr_007_fnFileExists] 
       @test_num     NVARCHAR(90)
      ,@inp_file     NVARCHAR(500)
      ,@exp          BIT            = NULL
      ,@exp_ex_num   INT            = NULL
      ,@exp_ex_msg   NVARCHAR(500)  = NULL
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(35)   = 'hlpr_007_fnFileExists'
      ,@act          BIT
      ,@NL           NVARCHAR(2)    = NCHAR(13) + NCHAR(10)
      ,@params       NVARCHAR(MAX)
   BEGIN TRY
      SET @params = CONCAT(
'@test_num: [',@test_num,']
@inp_file:  [',@inp_file,']
@exp:       [',@exp,']
@exp_ex_num:[',@exp_ex_num,']
@exp_ex_msg:[',@exp_ex_msg,']'
         );
      EXEC sp_log 1, @fn, '005: starting, @subtest: ', @test_num;
      EXEC ut.test.sp_tst_hlpr_st @fn, @test_num, @params
      -- Populate the IN/OUT params
      -- Run test specific setup
      -- Call the tested routine
      EXEC sp_log 1, @fn, '010: calling: dbo.fnFileExists(', @inp_file, ')', @act;
      SET @act = dbo.fnFileExists(@inp_file);
      EXEC sp_log 1, @fn, '015: file exists?: ', @act;
      IF @exp IS NOT NULL EXEC ut.test.sp_tst_gen_chk N'01', @exp, @act, 'asd'
      -- Check if an exception should have been thrown
      EXEC ut.test.sp_tst_hlpr_try_end @exp_ex_num, @exp_ex_msg;
   END TRY
   BEGIN CATCH
      DECLARE @_tmp     NVARCHAR(500) = ut.dbo.fnGetErrorMsg()
      EXEC sp_log 4, @fn, 'caught exception ',@_tmp;
      -- Check the expected exception
      EXEC ut.test.sp_tst_hlpr_hndl_ex
          @exp_ex_num   = @exp_ex_num
         ,@exp_ex_msg   = @exp_ex_msg
         ;
      IF @exp_ex_num IS NULL THROW;
   END CATCH
   --EXEC test.sp_tst_hlpr_hndl_success;
   EXEC sp_log 1, @fn, '99: leaving test ',@test_num,' passed';
END
/*
EXEC tSQLt.RunAll
EXEC tSQLt.Run 'test.test_007_fnFileExists';
*/
GO

