SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      15-Nov-2023
-- Description:      test helper rtn for the sp_assert_gtr_than_or_equal rtn being tested
-- Tested rtn desc:
--  Raises exception if a is less than b  
--
-- Tested rtn params: 
--    @a       SQL_VARIANT,
--    @b       SQL_VARIANT,
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
CREATE PROCEDURE [test].[hlpr_043_sp_assert_gtr_than_or_equal]
   @a       SQL_VARIANT,
   @b       SQL_VARIANT,
   @msg     NVARCHAR(200),
   @msg2    NVARCHAR(200),
   @msg3    NVARCHAR(200),
   @msg4    NVARCHAR(200),
   @msg5    NVARCHAR(200),
   @msg6    NVARCHAR(200),
   @msg7    NVARCHAR(200),
   @msg8    NVARCHAR(200),
   @msg9    NVARCHAR(200),
   @msg10   NVARCHAR(200),
   @msg11   NVARCHAR(200),
   @msg12   NVARCHAR(200),
   @msg13   NVARCHAR(200),
   @msg14   NVARCHAR(200),
   @msg15   NVARCHAR(200),
   @msg16   NVARCHAR(200),
   @msg17   NVARCHAR(200),
   @msg18   NVARCHAR(200),
   @msg19   NVARCHAR(200),
   @msg20   NVARCHAR(200),
   @ex_num  INT,
   @state   INT,
   @fn_     NVARCHAR(60),
   @exp_ex  BIT = 0,
   @subtest NVARCHAR(100)
AS
BEGIN
   DECLARE
      @fn                 NVARCHAR(35)   = N'hlpr_043_sp_assert_gtr_than_or_equal'
   EXEC sp_log 1, @fn, '01: starting, @subtest: ', @subtest;
---- SETUP:
   -- <TBD>
---- RUN tested rtn:
   EXEC sp_log 1, @fn, '04: running tested rtn '
   IF @exp_ex = 1
   BEGIN
      BEGIN TRY
         -- Expect an exception here
         EXEC  sp_assert_gtr_than_or_equal @a,@b,@msg,@msg2,@msg3,@msg4,@msg5,@msg6,@msg7,@msg8,@msg9,@msg10,@msg11,@msg12,@msg13,@msg14,@msg15,@msg16,@msg17,@msg18,@msg19,@msg20,@ex_num,@state,@fn_;
         EXEC sp_log 4, @fn, '05: oops! Expected an exception here';
         THROW 51000, ' Expected an exception but none were thrown', 1;
      END TRY
      BEGIN CATCH
         EXEC sp_log 2, @fn, '05: caught expected exception'
      END CATCH
   END -- IF @exp_ex = 1
   ELSE
   BEGIN
      -- Do not expect an exception here
      EXEC  sp_assert_gtr_than_or_equal @a,@b,@msg,@msg2,@msg3,@msg4,@msg5,@msg6,@msg7,@msg8,@msg9,@msg10,@msg11,@msg12,@msg13,@msg14,@msg15,@msg16,@msg17,@msg18,@msg19,@msg20,@ex_num,@state,@fn_;
   END -- ELSE -IF @exp_ex = 1
---- TEST:
   -- <TBD>
---- CLEANUP:
   -- <TBD>
   EXEC sp_log 1, @fn, '99: leaving'
END
/*
   EXEC tSQLt.RunAll;
   EXEC tSQLt.RunTest 'test.test_043_sp_assert_gtr_than_or_equal;
*/
GO

