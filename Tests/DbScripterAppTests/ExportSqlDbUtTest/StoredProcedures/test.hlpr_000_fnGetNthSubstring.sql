SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================
-- Author:      Terry Watts
-- Create date: 27-MAY-2020
-- Description: Tests the fnGetNthSubstring function
-- =====================================================
CREATE PROCEDURE [test].[hlpr_000_fnGetNthSubstring]
       @tst_num     NVARCHAR(10)
      ,@str          NVARCHAR(4000)
      ,@sep          NVARCHAR(4000)
      ,@n            INT
      ,@exp_res      NVARCHAR(4000 ) = NULL
      ,@exp_ex_num   INT             = NULL
      ,@exp_ex_msg   NVARCHAR(500)   = NULL
      ,@exp_ex_st    INT             = NULL
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(35)    = 'H_000_fnGetNthSubstring'
      ,@NL           NVARCHAR(2)    = NCHAR(13) + NCHAR(10)
      ,@act_res      NVARCHAR(4000 )= NULL
   BEGIN TRY
      EXEC ut.test.sp_tst_hlpr_st @fn, @tst_num;
      EXEC sp_log 1, @fn, '005: params:
@tst_num   :[',@tst_num   ,']
@str       :[',@str       ,']
@sep       :[',@sep       ,']
@n         :[',@n         ,']
@exp_res   :[',@exp_res   ,']
@exp_ex_num:[',@exp_ex_num,']
@exp_ex_msg:[',@exp_ex_msg,']
@exp_ex_st :[',@exp_ex_st ,']'
;
      -- Populate the IN/OUT params
      -- Run test specific setup
      -- Call the tested routine
      EXEC sp_log 1, @fn, '010: calling dbo.fnGetNthSubstring';
      SET @act_res = dbo.fnGetNthSubstring(@str, @sep, @n);
      IF @exp_ex_num IS NOT NULL OR @exp_ex_msg  IS NOT NULL
      BEGIN
         DECLARE @msg   NVARCHAR(500);
         SET @msg = CONCAT('015: expected exception ',@exp_ex_num,' [',@exp_ex_msg,'] to be thrown, but it was not');
         EXEC sp_log 4, @fn, @msg;
         EXEC tSQLt.Fail @msg;
      END
      -- test the result
      EXEC tSQLt.AssertEquals @exp_res, @act_res, ' 1 res'
      -- Check if an exception should have been thrown
      EXEC ut.test.sp_tst_hlpr_try_end @exp_ex_num, @exp_ex_msg, @exp_ex_st
   END TRY
   BEGIN CATCH
      DECLARE @_tmp NVARCHAR(500) = ut.dbo.fnGetErrorMsg()
             ,@params   NVARCHAR(4000) = CONCAT(
                ' @tst_num[', @tst_num           ,']'
               ,' @str    [', @str               ,']'
               ,' @sep    [', @sep               ,']'
               ,' @n      [', @n                 ,']'
               ,' @act_res[', @act_res           ,']'
               );
      -- sp_tst_hlpr_hndl_ex will re-throw if @exp_ex_num not specified
      EXEC UT.test.sp_tst_hlpr_hndl_ex @exp_ex_num, @exp_ex_msg--@params = @params;
   END CATCH
   EXEC test.sp_tst_hlpr_hndl_success;
END
/*
EXEC tSQLt.RunAll
EXEC tSQLt.Run 'test.test_000_fnGetNthSubstring'
   DECLARE
       @fn           NVARCHAR(4)    = 'H_000_fnGetNthSubstring'
      ,@fn_num       NVARCHAR(3)    =  '000'
      ,@NL           NVARCHAR(2)    = NCHAR(13) + NCHAR(10)
      ,@act_res      NVARCHAR(4000 )= NULL
      ,@tst_num      NVARCHAR(10)   =  'T002'
      ,@str          NVARCHAR(4000)
      ,@sep          NVARCHAR(4000)
      ,@n            INT
SET @act_res = dbo.fnGetNthSubstring('abc,def',  ':', @n);
*/
GO

