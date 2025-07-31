SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      18-Nov-2023
-- Description:      main test rtn for the test.fnDequalifyName rtn being tested
-- Tested rtn desc:
--  splits a qualified rtn name
-- into a row containing the schema_nm and the rtn_nm
--
-- e.g.: ('dbo.fnSplit') -> 'dbo'
--
-- ASSERTED PRECONDITIONS:
-- PRE01: @qual_rtn_nm NOT NULL
-- PRE02: @qual_rtn_nm NOT empty
--
-- Changes:
-- 231117: handle [ ] wrappers
--
-- Tested rtn params:
--    @qual_rtn_nm  NVARCHAR
--========================================================================================
CREATE PROCEDURE [test].[test_002_fnSplitQualifiedName]
AS
BEGIN
   DECLARE
      @fn                 NVARCHAR(35)   = N'T002_fnSplitQualifiedName'
   EXEC test.sp_tst_mn_st @fn;
---- SETUP <TBD>
   ------------------------------------------
   -- Green tests: ones that should work ok
   ------------------------------------------
---- Run the test Helper rtn to run the tested rtn and do some checks
   EXEC test.hlpr_002_fnSplitQualifiedName @test_num='TG001', @qual_rtn_nm='test.sp_tst_hlpr_try_end',@exp_ex=0, @exp_schema_nm='test', @exp_rtn_nm='sp_tst_hlpr_try_end';
   EXEC test.hlpr_002_fnSplitQualifiedName @test_num='TG002', @qual_rtn_nm='dbo.fnFindOneOf'         ,@exp_ex=0, @exp_schema_nm='dbo' , @exp_rtn_nm='fnFindOneOf';
   ------------------------------------------
   -- Red tests: ones that should fail
   ------------------------------------------
   --EXEC test.hlpr_002_fnDequalifyName @qual_rtn_nm='',@exp_ex=1, @subtest='TR001';
   EXEC sp_log 2, @fn, 'All subtests PASSED'
END
/*
EXEC tSQLt.RunAll
EXEC tSQLt.Run 'test.test_002_fnSplitQualifiedName';
*/
GO

