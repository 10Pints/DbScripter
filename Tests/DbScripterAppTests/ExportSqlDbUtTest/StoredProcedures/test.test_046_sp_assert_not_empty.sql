SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      15-Nov-2023
-- Description:      main test rtn for the sp_assert_not_empty rtn being tested
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
CREATE PROCEDURE [test].[test_046_sp_assert_not_empty]
AS
BEGIN
   DECLARE
      @fn                 NVARCHAR(35)   = N'test_046_sp_assert_not_empty'
   EXEC ut.test.sp_tst_mn_st @fn;
   ---- Run the test Helper rtn to run the tested rtn and do some checks
   EXEC test.hlpr_046_sp_assert_not_empty 
   'TG001 - OK not empty'
   ,@val=' ',@msg='',@msg2='',@msg3='',@msg4='',@msg5='',@msg6='',@msg7='',@msg8='',@msg9='',@msg10='',@msg11=''
   ,@msg12='',@msg13='',@msg14='',@msg15='',@msg16='',@msg17='',@msg18='',@msg19='',@msg20='',@ex_num=0,@state=0
   ,@exp_ex_num=NULL
   ,@exp_ex_msg=NULL
   ;
   ------------------------------------------
   -- Red tests: ones that should fail
   ------------------------------------------
   EXEC test.hlpr_046_sp_assert_not_empty 
   'TG002 empty should assert'
   ,@val='',@msg='',@msg2='',@msg3='',@msg4='',@msg5='',@msg6='',@msg7='',@msg8='',@msg9='',@msg10='',@msg11=''
   ,@msg12='',@msg13='',@msg14='',@msg15='',@msg16='',@msg17='',@msg18='',@msg19='',@msg20='',@ex_num=61234,@state=0
   ,@exp_ex_num=61234
   ,@exp_ex_msg='ASSERTION FAILED: value should not be empty'
   ;
   EXEC test.hlpr_046_sp_assert_not_empty 
   'TG003 NULL should not assert'
   ,@val=NULL,@msg='',@msg2='',@msg3='',@msg4='',@msg5='',@msg6='',@msg7='',@msg8='',@msg9='',@msg10='',@msg11=''
   ,@msg12='',@msg13='',@msg14='',@msg15='',@msg16='',@msg17='',@msg18='',@msg19='',@msg20='',@ex_num=61234,@state=0;
   EXEC test.hlpr_046_sp_assert_not_empty 
   'TG004 empty should assert with msg'
   ,@val='',@msg='m1',@msg2='m2',@msg3='',@msg4='',@msg5='',@msg6='',@msg7='',@msg8='',@msg9='',@msg10='',@msg11=''
   ,@msg12='',@msg13='',@msg14='',@msg15='',@msg16='',@msg17='',@msg18='',@msg19='m19',@msg20='m20',@ex_num=61234,@state=0
   ,@exp_ex_num=61234
   ,@exp_ex_msg='ASSERTION FAILED: value should not be empty m1m2m19m20';
   EXEC ut.test.sp_tst_mn_cls;
END
/*
EXEC tSQLt.Run 'test.test_046_sp_assert_not_empty';
EXEC dbo.sp_assert_not_empty ' '
*/
GO

