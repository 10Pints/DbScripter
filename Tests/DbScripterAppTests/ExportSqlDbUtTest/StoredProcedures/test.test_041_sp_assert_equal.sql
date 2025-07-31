SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      15-Nov-2023
-- Description:      main test rtn for the sp_assert_equal rtn being tested
-- Tested rtn desc:
--  1 line check null or mismatch and throw message  
--              ASSUMES data types are the same  
--
-- Tested rtn params: 
--    @a         SQL_VARIANT,
--    @b         SQL_VARIANT,
--    @msg       NVARCHAR(200),
--    @msg2      NVARCHAR(200),
--    @msg3      NVARCHAR(200),
--    @msg4      NVARCHAR(200),
--    @msg5      NVARCHAR(200),
--    @msg6      NVARCHAR(200),
--    @msg7      NVARCHAR(200),
--    @msg8      NVARCHAR(200),
--    @msg9      NVARCHAR(200),
--    @msg10     NVARCHAR(200),
--    @msg11     NVARCHAR(200),
--    @msg12     NVARCHAR(200),
--    @msg13     NVARCHAR(200),
--    @msg14     NVARCHAR(200),
--    @msg15     NVARCHAR(200),
--    @msg16     NVARCHAR(200),
--    @msg17     NVARCHAR(200),
--    @msg18     NVARCHAR(200),
--    @msg19     NVARCHAR(200),
--    @msg20     NVARCHAR(200),
--    @ex_num    INT,
--    @state     INT,
--    @fn_       NVARCHAR(60),
--    @print_ok  BIT,
--    @tst_nm    NVARCHAR(200)
--========================================================================================
CREATE PROCEDURE [test].[test_041_sp_assert_equal]
AS
BEGIN
   DECLARE
      @fn                 NVARCHAR(35)   = N'test_041_sp_assert_equal'
   EXEC sp_log 1, @fn,'01: starting'
---- SETUP
   -- <TBD>
   ------------------------------------------
   -- Green tests: ones that should work ok
   ------------------------------------------
   ---- Run the test Helper rtn to run the tested rtn and do some checks
   EXEC test.hlpr_041_sp_assert_equal @tst_num='TG001', @exp_ex=0, @a=5  ,@b=5  ,@msg='',@msg2='',@msg3='',@msg4='',@msg5='',@msg6='',@msg7=''
   ,@msg8='',@msg9='',@msg10='',@msg11='',@msg12='',@msg13='',@msg14='',@msg15='',@msg16='',@msg17='',@msg18='',@msg19='',@msg20='',@ex_num=0
   ,@state=0,@fn_='',@print_ok=0,@tst_nm='';
   EXEC test.hlpr_041_sp_assert_equal  @tst_num='TG002', @exp_ex=0,@a='a',@b='a',@msg='',@msg2='',@msg3='',@msg4='',@msg5='',@msg6='',@msg7=''
   ,@msg8='',@msg9='',@msg10='',@msg11='',@msg12='',@msg13='',@msg14='',@msg15='',@msg16='',@msg17='',@msg18='',@msg19='',@msg20='',@ex_num=0
   ,@state=0,@fn_='',@print_ok=0,@tst_nm='';
   ------------------------------------------
   -- Red tests: ones that should fail
   ------------------------------------------
   --EXEC test.hlpr_041_sp_assert_equal @a='',@b='',@msg='',@msg2='',@msg3='',@msg4='',@msg5='',@msg6='',@msg7='',@msg8='',@msg9='',@msg10='',@msg11='',@msg12='',@msg13='',@msg14='',@msg15='',@msg16='',@msg17='',@msg18='',@msg19='',@msg20='',@ex_num=0,@state=0,@fn_='',@sf=0,@print_ok=0,@tst_nm='',@exp_ex=1, @subtest='TR001';
   EXEC sp_log 1, @fn,'99: leaving'
END
/*
EXEC tSQLt.Run 'test.test_041_sp_assert_equal';
*/
GO

