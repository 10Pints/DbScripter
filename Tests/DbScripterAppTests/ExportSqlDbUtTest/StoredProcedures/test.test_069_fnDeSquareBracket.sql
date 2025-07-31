SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      24-Nov-2023
-- Description:      main test rtn for the dbo.fnDeSquareBracket rtn being tested
-- Tested rtn desc:
--  removes square brackets from string  
-- in any position in the string  
--  
-- PRECONDITIONS:  
--    none  
--  
-- POSTCONDITIONS:  
--    [ ] brackets removed  
--  
-- Tests:  
--
-- Tested rtn params: 
--    @s  NVARCHAR(4000),
--
-- returns NVARCHAR(4000)
--========================================================================================
CREATE PROCEDURE [test].[test_069_fnDeSquareBracket]
AS
BEGIN
   DECLARE
      @fn                 NVARCHAR(35)   = N'test_069_fnDeSquareBracket'
   EXEC sp_log 2, @fn,'01: starting'
---- SETUP
   -- <TBD>
   ------------------------------------------
   -- Green tests: ones that should work ok
   ------------------------------------------
   ---- Run the test Helper rtn to run the tested rtn and do some checks
   EXEC test.hlpr_069_fnDeSquareBracket @s='',@exp_ex=0, @subtest='TG001';
   ------------------------------------------
   -- Red tests: ones that should fail
   ------------------------------------------
   -- EXEC test.hlpr_069_fnDeSquareBracket ='',@s='',@exp_ex=1, @subtest='TR001';
   EXEC sp_log 2, @fn, '99: All subtests PASSED'
END
/*
EXEC tSQLt.Run 'test.test_069_fnDeSquareBracket';
*/
GO

