SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 17-JAN-2020
-- Description: Helper routine for the 
--                   dbo.fnGetTimestamp Tests
-- =============================================
CREATE PROCEDURE [test].[hlpr_022_fnGetTimestamp]
       @tst_num      NVARCHAR(10)
      ,@inp          DATETIME2
      ,@exp          NVARCHAR(13)
      ,@exp_ex_num   INT
      ,@exp_ex_msg   NVARCHAR(MAX)
      ,@exp_ex_st    INT
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(35)    =  'hlpr_022_fnGetTimestamp'
      ,@act          NVARCHAR(50)
      ,@NL           NVARCHAR(2)    = NCHAR(13) + NCHAR(10)
      ,@inp2_dt      DATETIME2
      ,@act2_dt      DATETIME2
      ,@diff         INT
      ,@msg          NVARCHAR(100)
   BEGIN TRY
      EXEC ut.test.sp_tst_hlpr_st @fn, @tst_num;
      -- Populate the IN/OUT params
      -- Run test specific setup
      -- Call the tested routine
      SET @act = dbo.fnGetTimestamp(@inp);
      EXEC sp_log 1, @fn, '001: params:
test_num  :[', @tst_num   ,']
inp       :[', @inp       ,']
exp       :[', @exp       ,']
act       :[', @act       ,']
exp_ex_num:[', @exp_ex_num,']
exp_ex_msg:[', @exp_ex_msg,']
exp_ex_st :[', @exp_ex_st ,']'
;
      -- Passing a null input date will cause the testd rtn to get the current date-time
      -- but now there could be different time - so we nee to check the 2 date times are within a tolerance
      SET @inp2_dt = COALESCE(@inp, GetDate());
      -- [200524-1305]
      SET @act2_dt = dbo.fnGetDateTimeFromSting(@act);
      SET @diff    = abs(DATEDIFF(second, @inp2_dt, @act2_dt));
      SET @msg     = CONCAT('time span: [', @diff, '] sec');
      EXEC sp_log 1, @fn, '010:
@inp2_dt:[', @inp2_dt,']
@act2_dt:[', @act2_dt,']
@diff   :[', @diff,']
@msg    :[', @msg,']'
;
      EXEC sp_assert_less_than @diff, 60, @msg;
      EXEC ut.test.sp_tst_hlpr_try_end @exp_ex_num, @exp_ex_msg,@exp_ex_st;
   END TRY
   BEGIN CATCH
      DECLARE @_tmp NVARCHAR(500) = ut.dbo.fnGetErrorMsg()
      -- Log input parameters
      EXEC sp_log 1, @fn,  'caught exception: ', @_tmp, @NL
         ,'@test_num  =[', @tst_num   ,']', @NL
         ,'@inp       =[', @inp       ,']', @NL
         ,'@exp       =[', @exp       ,']', @NL
         ,'@act       =[', @act       ,']', @NL
         ,'@exp_ex_num=[', @exp_ex_num,']', @NL
         ,'@exp_ex_msg=[', @exp_ex_msg,']', @NL
         ,'@exp_ex_st =[', @exp_ex_st ,']', @NL
         , @NL
      -- Check the expected exception
      EXEC ut.test.sp_tst_hlpr_hndl_ex 
          @exp_ex_num = @exp_ex_num
         ,@exp_ex_msg = @exp_ex_msg
   END CATCH
END
/*
EXEC tSQLt.RunAll
EXEC tSQLt.Run 'test.test_022_fnGetTimestamp'
*/
GO

