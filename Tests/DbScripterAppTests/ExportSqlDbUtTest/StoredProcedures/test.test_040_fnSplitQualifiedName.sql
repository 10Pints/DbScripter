SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      12-Nov-2023
-- Description:      main test rtn for the GetRtnNmBits rtn being tested
-- Tested rtn desc:
--  splits a qualified rtn name   
-- into a row containing the schema_nm and the rtn_nm  
--  
-- e.g.: ('dbo.fnSplit') -> 'dbo'  
--  
--
-- Tested rtn params: 
--    @qual_rtn_nm  NVARCHAR(150)
--========================================================================================
CREATE PROCEDURE [test].[test_040_fnSplitQualifiedName]
AS
BEGIN
   DECLARE
      @fn                 NVARCHAR(35)   = N'test_040_fnSplitQualifiedName'
   EXEC sp_log 1, @fn,'01: starting'
---- SETUP
   -- <TBD>
   ------------------------------------------
   -- Red tests: ones that should fail
   ------------------------------------------
   EXEC test.hlpr_040_fnSplitQualifiedName @qual_rtn_nm=NULL,@exp_ex=1, @subtest='TR001';
   EXEC test.hlpr_040_fnSplitQualifiedName @qual_rtn_nm=''  ,@exp_ex=1, @subtest='TR002';
   -- chk boundary conditions: param size limits red
   ------------------------------------------
   -- Green tests: ones that should work ok
   ------------------------------------------
   EXEC test.hlpr_040_fnSplitQualifiedName @qual_rtn_nm='dbo.fnGetRtnNmBits',@exp_ex=0, @subtest='TG001',@exp_schema_nm='dbo',@exp_rtn_nm='fnGetRtnNmBits';
   -- chk boundary conditions: param size limits red
   EXEC sp_log 1, @fn,'99: leaving'
END
/*
EXEC tSQLt.Run 'test.test_040_fnSplitQualifiedName';
EXEC tSQLt.RunAll
*/
GO

