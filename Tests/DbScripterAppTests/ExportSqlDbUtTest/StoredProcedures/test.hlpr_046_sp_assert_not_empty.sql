SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      15-Nov-2023
-- Description:      test helper rtn for the sp_assert_not_empty rtn being tested
-- Tested rtn desc:
--  Raises exception if @a is empty  
--
-- Tested rtn params: 
--    @a       SQL_VARIANT,
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
CREATE PROCEDURE [test].[hlpr_046_sp_assert_not_empty]
    @tst_num NVARCHAR(100)
   ,@val     NVARCHAR(3999)
   ,@msg     NVARCHAR(200)
   ,@msg2    NVARCHAR(200)
   ,@msg3    NVARCHAR(200)
   ,@msg4    NVARCHAR(200)
   ,@msg5    NVARCHAR(200)
   ,@msg6    NVARCHAR(200)
   ,@msg7    NVARCHAR(200)
   ,@msg8    NVARCHAR(200)
   ,@msg9    NVARCHAR(200)
   ,@msg10   NVARCHAR(200)
   ,@msg11   NVARCHAR(200)
   ,@msg12   NVARCHAR(200)
   ,@msg13   NVARCHAR(200)
   ,@msg14   NVARCHAR(200)
   ,@msg15   NVARCHAR(200)
   ,@msg16   NVARCHAR(200)
   ,@msg17   NVARCHAR(200)
   ,@msg18   NVARCHAR(200)
   ,@msg19   NVARCHAR(200)
   ,@msg20   NVARCHAR(200)
   ,@ex_num  INT
   ,@state   INT
   ,@exp_ex_num            INT            = NULL
   ,@exp_ex_msg            NVARCHAR(500)  = NULL
AS
BEGIN
   DECLARE
    @fn                 NVARCHAR(35)   = N'hlpr_046_sp_assert_not_empty'
   ,@line NVARCHAR(150) = REPLICATE('-', 150)
   ,@NL   NCHAR(2) = NCHAR(10)+NCHAR(13)
   EXEC test.sp_tst_hlpr_st @fn, @tst_num;
---- SETUP:
   -- <TBD>
---- RUN tested rtn:
   IF @exp_ex_num IS NOT NULL
   BEGIN
      BEGIN TRY
         -- Expect an exception here
   EXEC sp_log 1, @fn, '04: running tested rtn - Expect an exception'
         EXEC  sp_assert_not_empty @val, @msg,@msg2,@msg3,@msg4,@msg5,@msg6,@msg7,@msg8,@msg9,@msg10,@msg11,@msg12
         ,@msg13,@msg14,@msg15,@msg16,@msg17,@msg18,@msg19,@msg20,@ex_num,@state;
         EXEC sp_log 4, @fn, '05: oops! Expected an exception here';
         THROW 51000, ' Expected an exception but none were thrown', 1;
      END TRY
      BEGIN CATCH
         DECLARE @act_ex_num INT           = ERROR_NUMBER()
                ,@act_ex_msg NVARCHAR(500) = ERROR_MESSAGE();
         EXEC sp_log 2, @fn, '05: caught exception - chking ex details ', @act_ex_num,' ',@act_ex_msg
         EXEC tSQLt.AssertEquals @exp_ex_num, @act_ex_num, 'ex_num';
         IF @exp_ex_msg IS NOT NULL EXEC tSQLt.AssertEquals @exp_ex_msg, @act_ex_msg, 'ex_msg';
      END CATCH
   END -- IF @exp_ex = 1
   ELSE
   BEGIN
   EXEC sp_log 1, @fn, '04: running tested rtn - Do not expect an exception'
      -- Do not expect an exception here
      EXEC  sp_assert_not_empty @val, @msg,@msg2,@msg3,@msg4,@msg5,@msg6,@msg7,@msg8,@msg9,@msg10,@msg11,@msg12
      ,@msg13,@msg14,@msg15,@msg16,@msg17,@msg18,@msg19,@msg20,@ex_num,@state;
   END -- ELSE -IF @exp_ex = 1
---- TEST:
   -- <TBD>
---- CLEANUP:
   -- <TBD>
   EXEC test.sp_tst_hlpr_hndl_success;
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.RunTest 'test.test_046_sp_assert_not_empty;
*/
GO

