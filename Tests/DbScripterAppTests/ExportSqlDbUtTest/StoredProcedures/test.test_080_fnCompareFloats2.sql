SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      27-Nov-2023
-- Description:      main test rtn for the dbo.fnCompareFloats2 rtn being tested
-- Tested rtn desc:
--  determines if 2 floats are approximately equal  
-- Returns    : 1 if a significantly gtr than b  
--              0 if a = b with the signifcance of epsilon   
--             -1 if a significantly less than b within +/- Epsilon, 0 otherwise  
-- DROP FUNCTION [dbo].[fnCompareFloats2]  
--
-- Tested rtn params: 
--    @a        FLOAT,
--    @b        FLOAT,
--    @epsilon  FLOAT,
--
-- returns INT
-- returns INT
-- returns INT
--========================================================================================
CREATE PROCEDURE [test].[test_080_fnCompareFloats2]
AS
BEGIN
   DECLARE
      @fn                 NVARCHAR(35)   = N'test_080_fnCompareFloats2'
   EXEC sp_log 2, @fn,'01: starting'
---- SETUP
   -- <TBD>
   ------------------------------------------
   -- Green tests: ones that should work ok
   ------------------------------------------
   ---- Run the test Helper rtn to run the tested rtn and do some checks
   --                                                                @exp_res, @subtest
   --                                  @a,  @b,  @epsilon,               @exp_ex
   EXEC test.hlpr_080_fnCompareFloats2 1.2,        1.3, 0.00001,     -1, 0,    'TG001 EXP -1 less than';
   EXEC test.hlpr_080_fnCompareFloats2 1.2,        1.2, 0.00001,      0, 0,    'TG002 EXP 0 equal';
   EXEC test.hlpr_080_fnCompareFloats2 1.3,        1.2, 0.00001,      1, 0,    'TG003 EXP 1 gtr than'; -- *
   EXEC test.hlpr_080_fnCompareFloats2 0.1,        0.1, 0.00001,      0, 0,    'TG004 EXP  equal';
   EXEC test.hlpr_080_fnCompareFloats2 0.10001,    0.1, 0.00001,      0, 0,    'TG005 EXP 0 equal';
   EXEC test.hlpr_080_fnCompareFloats2 0.1,        0.100009, 0.00001, 0, 0,    'TG006 in tolerance EXP 0 equal';
   EXEC test.hlpr_080_fnCompareFloats2 0.1,        0.10001 , 0.00001, 0, 0,    'TG007 EXP 0 equal';
   EXEC test.hlpr_080_fnCompareFloats2 0.1,        0.100011, 0.00001,-1, 0,    'T08 out of tolerance: EXP -1 less than';
   EXEC test.hlpr_080_fnCompareFloats2 0.100011,   0.1, 0.00001,      1, 0,    'TG009 EXP 1 gtr than';
   EXEC test.hlpr_080_fnCompareFloats2 1.2,        1.3, 0.00001,     -1, 0,    'TG010 EXP -1 less than';
   EXEC test.hlpr_080_fnCompareFloats2 1.2901,     1.3, 0.01,         0, 0,    'TG011 epsilon EXP 0 0.1 equal';
   ------------------------------------------
   -- Red tests: ones that should fail
   ------------------------------------------
   -- EXEC test.hlpr_080_fnCompareFloats2 =0,@a=,@b=,@epsilon=,@exp_ex=1, @subtest='TR001';
   EXEC sp_log 2, @fn, '99: All subtests PASSED'
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_080_fnCompareFloats2';
*/
GO

