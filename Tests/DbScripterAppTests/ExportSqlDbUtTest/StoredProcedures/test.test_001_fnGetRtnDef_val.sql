SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      19-Dec-2023
-- Description:      main test rtn for the dbo.fnGetRtnDef rtn being tested
-- Tested rtn desc:
--
-- Tested rtn params:
--    @rtn_name  NVARCHAR(120)
--========================================================================================
CREATE PROCEDURE [test].[test_001_fnGetRtnDef_val]
AS
BEGIN
   DECLARE
      @fn                 NVARCHAR(35)   = N'test_001_fnGetRtnDef_val'
   EXEC sp_log 2, @fn,'01: starting'
---- SETUP
   -- <TBD>
   ---- Run the test Helper rtn to run the tested rtn and do some checks
   EXEC test.hlpr_001_fnGetRtnDef_val
      @test_num      = 'TG001'
     ,@inp_qrn       = ''
     ,@tst_key       = 1
     ,@exp_schema_nm = NULL
     ,@exp_rtn_nm    = NULL
     ,@exp_objid     = NULL
     ,@exp_ex_num    = NULL
     ,@exp_ex_msg    = NULL
     ,@display_table = 1;
   EXEC sp_log 2, @fn, '99: leaving, All subtests PASSED'
END
/*
EXEC tSQLt.Run 'test.test_001_fnGetRtnDef_val';
EXEC tSQLt.RunAll;
*/
GO

