SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      15-Nov-2023
-- Description:      test helper rtn for the sp_assert_not_zero rtn being tested
-- Tested rtn desc:
--  Raises exception if @a is 0  
--
-- Tested rtn params: 
--    @a       INT,
--    @msg     NVARCHAR(200),
--    @msg2    NVARCHAR(200),
--    @msg3    NVARCHAR(200),
--    @msg4    NVARCHAR(200),
--    @msg5    NVARCHAR(200),
--    @msg6    NVARCHAR(200),
--    @msg7    NVARCHAR(200),
--    @msg8    NVARCHAR(200),
--    @msg9    NVARCHAR(200),
--    @msg10   NVARCHAR(200),
--    @msg11   NVARCHAR(200),
--    @msg12   NVARCHAR(200),
--    @msg13   NVARCHAR(200),
--    @msg14   NVARCHAR(200),
--    @msg15   NVARCHAR(200),
--    @msg16   NVARCHAR(200),
--    @msg17   NVARCHAR(200),
--    @msg18   NVARCHAR(200),
--    @msg19   NVARCHAR(200),
--    @msg20   NVARCHAR(200),
--    @ex_num  INT,
--    @state   INT,
--    @fn_     NVARCHAR(60),
--========================================================================================
CREATE PROCEDURE [test].[hlpr_051_sp_assert_not_zero]
    @tst_num      NVARCHAR(100)
   ,@val          INT
   ,@msg1         NVARCHAR(200)
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
   ,@state        INT
   ,@inp_ex_num   INT
   ,@exp_ex_num   INT           = NULL
   ,@exp_ex_msg   NVARCHAR(500) = NULL
AS
BEGIN
   DECLARE
      @fn                 NVARCHAR(35)   = N'hlpr_051_sp_assert_not_zero'
   EXEC test.sp_tst_hlpr_st @fn, @tst_num;
---- SETUP: <TBD>
---- RUN tested rtn:
   IF @exp_ex_num IS NOT NULL
   BEGIN
      BEGIN TRY
         -- Expect an exception here
         EXEC sp_log 1, @fn, '005: running sp_assert_not_zero, expect an exception here';
         EXEC  sp_assert_not_zero @val, @msg1, @msg2,@msg3,@msg4,@msg5,@msg6,@msg7,@msg8,@msg9,@msg10,@msg11,@msg12
         ,@msg13,@msg14,@msg15,@msg16,@msg17,@msg18,@msg19,@msg20,@inp_ex_num,@state;
         EXEC sp_log 4, @fn, '010: oops! Expected an exception here';
         THROW 51000, ' Expected an exception but none were thrown', 1;
      END TRY
      BEGIN CATCH
         -- TEST exception:
         DECLARE
             @act_ex_num   INT            = ERROR_NUMBER()
            ,@act_ex_msg   NVARCHAR(MAX)  = ERROR_MESSAGE()
            ,@pos          INT
         EXEC sp_log 2, @fn, '015: caught exception - this is expected
@act_ex_num:[', @act_ex_num,']
@act_ex_msg:[', @act_ex_msg,']'
;
         IF @exp_ex_num IS NOT NULL
         BEGIN
            EXEC tSQLt.AssertEquals @exp_ex_num, @act_ex_num, @fn, ' exp/act exception num mismatch';
            EXEC sp_log 1, @fn, '020: exp/act ex_num match OK';
         END
         IF @act_ex_msg IS NOT NULL
         BEGIN
            EXEC sp_log 2, @fn, '025: testing exception msg';
            SET @pos = CHARINDEX(@exp_ex_msg, @act_ex_msg)
            EXEC tSQLt.AssertNotEquals 0, @pos, '018:  exp/act exception msg mismatch exp:', @exp_ex_msg, '] act:[', @act_ex_msg, ']';
            EXEC sp_log 1, @fn, '030: exp/act ex_msg match OK, exp is a sub string of act';
         END
         RETURN
      END CATCH
   END -- IF @exp_ex = 1
   ELSE
   BEGIN
      -- Do not expect an exception here
      EXEC sp_log 1, @fn, '035: running sp_assert_not_null_or_zero, do not expect an exception here'
      EXEC  sp_assert_not_zero @val, @msg1, @msg2,@msg3,@msg4,@msg5,@msg6,@msg7,@msg8,@msg9,@msg10,@msg11,@msg12
      ,@msg13,@msg14,@msg15,@msg16,@msg17,@msg18,@msg19,@msg20,@inp_ex_num,@state;
   END -- ELSE -IF @exp_ex = 1
---- TEST:  <TBD>
---- CLEANUP: <TBD>
   EXEC test.sp_tst_hlpr_hndl_success;
END
/*
EXEC tSQLt.Run 'test.test_051_sp_assert_not_zero';
EXEC tSQLt.RunAll;
*/
GO

