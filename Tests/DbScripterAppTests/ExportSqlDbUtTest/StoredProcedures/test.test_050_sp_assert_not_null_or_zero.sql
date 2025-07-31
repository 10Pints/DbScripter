SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      15-Nov-2023
-- Description:      main test rtn for the sp_assert_not_null_or_zero rtn being tested
-- Tested rtn desc:
--  Raises exception if @a is null or zero  
--              this is meant for ints or floats  
--
-- Tested rtn params: 
--    @a         INT,
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
--[@ tSQLt:NoTransaction]('test.testCleanUp')
CREATE PROCEDURE [test].[test_050_sp_assert_not_null_or_zero]
AS
BEGIN
   DECLARE
      @fn                 NVARCHAR(35)   = N'test_050_sp_assert_not_null_or_zero'
   EXEC test.sp_tst_mn_st @fn;
   EXEC sp_log 1, @fn, '005 calling hlpr';
   EXEC test.hlpr_050_sp_assert_not_null_or_zero @tst_num='T001'
   ,@val=0, @msg1='', @msg2='',@msg3='',@msg4='',@msg5='',@msg6='',@msg7='',@msg8='',@msg9='',@msg10='',@msg11=''
   ,@msg12='',@msg13='',@msg14='',@msg15='',@msg16='',@msg17='',@msg18='',@msg19='',@msg20='',@ex_num=0,@state=0,@st_empty=0
   ,@exp_ex_num=50000
--   ,@exp_ex_msg='bla'
;
   EXEC sp_log 1, @fn, '900 completed tests OK';
   EXEC test.sp_tst_mn_cls;
END
/*
EXEC tSQLt.Run 'test.test_050_sp_assert_not_null_or_zero';
EXEC tSQLt.RunAll;
*/
GO

