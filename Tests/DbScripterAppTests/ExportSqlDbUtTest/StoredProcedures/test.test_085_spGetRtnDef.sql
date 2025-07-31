SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      19-Dec-2023
-- Description:      main test rtn for the test.spGetRtnDef rtn being tested
-- Tested rtn desc:
--
-- Tested rtn params:
--    @rtn_name  NVARCHAR(120)
--[@tSQLt:SkipTest]('Temporarily disabled while refactoring')
--========================================================================================
CREATE PROCEDURE [test].[test_085_spGetRtnDef]
AS
BEGIN
   DECLARE
      @fn                 NVARCHAR(35)   = N'test_085_spGetRtnDef'
   EXEC sp_log 2, @fn,'01: starting'
---- SETUP
   -- <TBD>
   ------------------------------------------
   -- Green tests: ones that should work ok
   ------------------------------------------
   ---- Run the test Helper rtn to run the tested rtn and do some checks
   --EXEC test.hlpr_085_spGetRtnDef @test_num='TG001',@rtn_name='', @exp_ex_num=NULL, @exp_ex_msg=NULL;
   ------------------------------------------
   -- Red tests: ones that should fail
   ------------------------------------------
   -- EXEC test.hlpr_085_spGetRtnDef @test_num='TR001',@rtn_name='', @exp_ex_num=-1, @exp_ex_msg=NULL;
   -- EXEC test.hlpr_085_spGetRtnDef @test_num='TR002',@rtn_name='', @exp_ex_num=51356 <todo: replace this with the expected exception number>, @exp_ex_msg=NULL;
   -- EXEC test.hlpr_085_spGetRtnDef @test_num='TR003',@rtn_name='', @exp_ex_num=51356 <todo: replace this with the expected exception number>, @exp_ex_msg='blah <todo: replace this with the expected exception msg>;
   EXEC sp_log 2, @fn, '99: leaving, All subtests PASSED'
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.rtn';
*/
GO

