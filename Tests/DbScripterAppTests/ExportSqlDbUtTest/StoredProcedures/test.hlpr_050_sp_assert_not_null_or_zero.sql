SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      15-Nov-2023
-- Description:      test helper rtn for the sp_assert_not_null_or_zero rtn being tested
-- Tested rtn desc:
--  Raises exception if @a is null or zero  
--              this is meant for ints or floats  
--========================================================================================
CREATE PROCEDURE [test].[hlpr_050_sp_assert_not_null_or_zero]
    @tst_num      NVARCHAR(100)
   ,@val          INT
   ,@msg1          NVARCHAR(200)
   ,@msg2         NVARCHAR(200)
   ,@msg3         NVARCHAR(200)
   ,@msg4         NVARCHAR(200)
   ,@msg5         NVARCHAR(200)
   ,@msg6         NVARCHAR(200)
   ,@msg7         NVARCHAR(200)
   ,@msg8         NVARCHAR(200)
   ,@msg9         NVARCHAR(200)
   ,@msg10        NVARCHAR(200)
   ,@msg11        NVARCHAR(200)
   ,@msg12        NVARCHAR(200)
   ,@msg13        NVARCHAR(200)
   ,@msg14        NVARCHAR(200)
   ,@msg15        NVARCHAR(200)
   ,@msg16        NVARCHAR(200)
   ,@msg17        NVARCHAR(200)
   ,@msg18        NVARCHAR(200)
   ,@msg19        NVARCHAR(200)
   ,@msg20        NVARCHAR(200)
   ,@ex_num       INT
   ,@state        INT
   ,@st_empty     INT
   ,@exp_ex_num   INT           = NULL
   ,@exp_ex_msg   NVARCHAR(500) = NULL
AS
BEGIN
   DECLARE
      @fn                 NVARCHAR(35)   = N'hlpr_050_sp_assert_not_null_or_zero'
   EXEC test.sp_tst_hlpr_st @fn, @tst_num;
   -- RUN tested rtn:
   IF @exp_ex_num IS NOT NULL
   BEGIN
      BEGIN TRY
         -- Expect an exception here
         EXEC sp_log 1, @fn, '005: running sp_assert_not_null_or_zero, expect an exception here'
         EXEC sp_assert_not_null_or_zero @val, @msg1, @msg2,@msg3,@msg4,@msg5,@msg6,@msg7,@msg8,@msg9,@msg10,@msg11,@msg12
         ,@msg13,@msg14,@msg15,@msg16,@msg17,@msg18,@msg19,@msg20,@ex_num,@state,@st_empty;
      END TRY
      BEGIN CATCH
         -- TEST exception:
         DECLARE
             @act_ex_num   INT            = ERROR_NUMBER()
            ,@act_ex_msg   NVARCHAR(MAX)  = ERROR_MESSAGE()
            ,@pos          INT
         EXEC sp_log 2, @fn, '010: caught exception num: ', @act_ex_num, ' msg:[', @act_ex_msg,']';
         IF @exp_ex_num IS NOT NULL
         BEGIN
            EXEC tSQLt.AssertEquals @exp_ex_num, @act_ex_num, @fn, ' exp/act exception num mismatch';
            EXEC sp_log 1, @fn, '015: exp/act ex_num match OK';
         END
         IF @act_ex_msg IS NOT NULL
         BEGIN
            EXEC sp_log 2, @fn, '017: testing exception msg';
            SET @pos = CHARINDEX(@exp_ex_msg, @act_ex_msg)
            EXEC tSQLt.AssertNotEquals 0, @pos, '018:  exp/act exception msg mismatch exp:', @exp_ex_msg, '] act:[', @act_ex_msg, ']';
            EXEC sp_log 1, @fn, '020: exp/act ex_msg match OK, exp is a sub string of act';
         END
         RETURN
      END CATCH
      EXEC sp_log 4, @fn, '025: oops! Expected an exception here';
      THROW 51000, ' Expected an exception but none were thrown', 1;
   END -- IF @exp_ex = 1
   ELSE
   BEGIN
      EXEC sp_log 1, @fn, '030: running sp_assert_not_null_or_zero, do not expect an exception here'
      -- Do not expect an exception here
      EXEC  sp_assert_not_null_or_zero @val, @msg1, @msg2,@msg3,@msg4,@msg5,@msg6,@msg7,@msg8,@msg9,@msg10,@msg11,@msg12
      ,@msg13,@msg14,@msg15,@msg16,@msg17,@msg18,@msg19,@msg20,@ex_num,@state,@st_empty;
   END -- ELSE -IF @exp_ex = 1
   EXEC test.sp_tst_hlpr_hndl_success;
END
/*
   EXEC tSQLt.Run 'test.test_050_sp_assert_not_null_or_zero';
   EXEC tSQLt.RunAll;
*/
GO

