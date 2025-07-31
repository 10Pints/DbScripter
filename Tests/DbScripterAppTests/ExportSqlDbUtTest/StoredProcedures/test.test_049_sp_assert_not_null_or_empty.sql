SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      15-Nov-2023
-- Description:      main test rtn for the sp_assert_not_null_or_empty rtn being tested
-- Tested rtn desc:
--  Raises exception if @a is null or empty  
--
-- Tested rtn params: 
--    @a         SQL_VARIANT,
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
--    @st_empty  INT,
--    @fn_       NVARCHAR(60),
--========================================================================================
----[@tSQLt:SkipTest]('Temporarily disabled while refactoring')
CREATE PROCEDURE [test].[test_049_sp_assert_not_null_or_empty]
AS
BEGIN
   DECLARE
      @fn                 NVARCHAR(35)   = N'test_049_sp_assert_not_null_or_empty'
   EXEC ut.test.sp_tst_mn_st @fn;
   ---- Run the test Helper rtn to run the tested rtn and do some checks
   EXEC test.hlpr_049_sp_assert_not_null_or_empty
       @tst_num='T001'
      ,@val=''
      ,@msg1='msg 1'
      ,@msg2=''
      ,@inp_ex_num = NULL
      ,@exp_ex_num = 50001
      ,@exp_ex_msg = 'ASSERTION FAILED: value should not be empty msg 1'
   ------------------------------------------
   -- Red tests: ones that should fail
   ------------------------------------------
   EXEC test.hlpr_049_sp_assert_not_null_or_empty 
       @tst_num='T002'
      ,@val =''
      ,@msg1=''
      ,@msg2=''
      ,@msg3=''
      ,@msg4=''
      ,@msg5=''
      ,@msg6=''
      ,@msg7=''
      ,@msg8='',@msg9='',@msg10=''
      ,@msg11='',@msg12='',@msg13='',@msg14='',@msg15='',@msg16='',@msg17='',@msg18='',@msg19='',@msg20=''
      ,@inp_ex_num = 56789
      ,@exp_ex_num = 56789
      ,@state=0
      ,@st_empty=0
   EXEC ut.test.sp_tst_mn_cls;
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_049_sp_assert_not_null_or_empty';
*/
GO

