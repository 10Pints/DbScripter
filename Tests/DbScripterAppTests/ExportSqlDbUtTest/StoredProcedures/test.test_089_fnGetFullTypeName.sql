SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      05-Apr-2024
-- Description:      test rtn for dbo.fnGetFullTypeName(@ty_nm, @len)
-- Tested rtn desc:
-- Description: returns:
--    if @ty_nm is a text array type then returns the full type from a data type + max_len fields
--    else returns @ty_nm on its own
--    as is returned from sys rtns like sys.columns
--
-- RULES:
--========================================================================================
CREATE PROCEDURE [test].[test_089_fnGetFullTypeName]
AS
BEGIN
   DECLARE
     @fn    NVARCHAR(35)   = N'test_089_fnGetFullTypeName'
    ,@act   NVARCHAR(50)
   EXEC sp_log 1, @fn, '01: starting'
---- RUN tests
   EXEC sp_log 1, @fn, '05: T001: NVARCHAR'
   SET @act = dbo.fnGetFullTypeName('NVARCHAR', 20); EXEC tSQLt.AssertEquals 'NVARCHAR(20)', @act;
   EXEC sp_log 1, @fn, '10: T002: VARCHAR'
   SET @act = dbo.fnGetFullTypeName('VARCHAR' , 30); EXEC tSQLt.AssertEquals 'VARCHAR(30)', @act;
   EXEC sp_log 1, @fn, '15: T003: INT'
   SET @act = dbo.fnGetFullTypeName('INT'     ,  8); EXEC tSQLt.AssertEquals 'INT', @act;
   EXEC sp_log 1, @fn, '20: T004: NULL, NULL'
   SET @act = dbo.fnGetFullTypeName(NULL, NULL);     EXEC tSQLt.AssertEquals NULL, @act;
   EXEC sp_log 1, @fn, '25: T005: empty, 20'
   SET @act = dbo.fnGetFullTypeName('', 20);         EXEC tSQLt.AssertEquals '', @act;
   EXEC sp_log 1, @fn, '30: Completed all sub tests - PASSED'
END
/*
EXEC tSQLt.Run 'test.test_089_fnGetFullTypeName';
*/
GO

