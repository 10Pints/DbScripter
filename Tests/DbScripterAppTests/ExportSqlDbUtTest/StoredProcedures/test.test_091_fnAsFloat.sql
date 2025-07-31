SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      05-Jan-2024
-- Description:      main test rtn for the AsFloat rtn being tested
-- Tested rtn desc:
-- converts and returns input to a float if possible 
--              or return null of not
--
-- NOTE: converts '' to 0
--
-- PRECONITIONS - none
--
-- POSTCONDITIONS
-- RETURNS
-- Float value of the input if possible or NULL if not
--
-- Tested rtn params:
--    @v SQL_VARIANT the value to be converted
--========================================================================================
----[@tSQLt:SkipTest]('Temporarily disabled while refactoring')
CREATE PROCEDURE [test].[test_091_fnAsFloat]
AS
BEGIN
   DECLARE
      @fn                 NVARCHAR(35)   = N'test_086_AsFloat'
   EXEC sp_log 2, @fn,'01: starting'
   EXEC test.hlpr_091_fnAsFloat @tst_num='TR001',@inp_value='123.45', @exp_value=123.45;
   EXEC test.hlpr_091_fnAsFloat @tst_num='TR002',@inp_value=NULL    , @exp_value=NULL;
   EXEC test.hlpr_091_fnAsFloat @tst_num='TR003',@inp_value=''      , @exp_value=0;
   EXEC test.hlpr_091_fnAsFloat @tst_num='TR004',@inp_value='-64.0' , @exp_value=-64.0;
   EXEC sp_log 2, @fn, '99: leaving, All subtests PASSED';
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_091_fnAsFloat';
*/
GO

