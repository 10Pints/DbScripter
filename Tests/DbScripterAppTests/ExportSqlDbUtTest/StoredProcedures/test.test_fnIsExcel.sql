SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================================================
-- Author:      Terry Watts
-- Create date: 15-MAR-2024
-- Description: Tests the dbo.IsExcel() routine
--
-- Tested rtn desc: imports all the static data
-- Description: returns 1 if the the file name has an .xlsx extension, 0 otherwise
--    0 = case insensitive, 1 = case sensitive 
--
-- Tested rtn Preconditions: none
--
-- Tested rtn Postconditions:
--   POST01: returns 1 if the the file name has an .xlsx extension, 0 otherwise
-- ================================================================================================
CREATE PROCEDURE [test].[test_fnIsExcel]
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
    @fn     NVARCHAR(35) = 'test_fnIsExcel'
   ,@is_xl  BIT
   EXEC sp_log 1, @fn, '00: starting';
   --------------------------------------------------------------------------------------------
   -- 1. Run tests
   --------------------------------------------------------------------------------------------
   EXEC sp_log 1, @fn, '0200: running tests';
   EXEC test.hlpr_fnIsExcel 'T001: NULL' , NULL,      0;
   EXEC test.hlpr_fnIsExcel 'T002: EMPTY', '',        0;
   EXEC test.hlpr_fnIsExcel 'T003: NO' , 'fred.txt',  0;
   EXEC test.hlpr_fnIsExcel 'T004: NO' , 'fred.xls',  0;
   EXEC test.hlpr_fnIsExcel 'T005: YES', 'fred.xlsx', 1;
   EXEC test.hlpr_fnIsExcel 'T006: NO' , 'D:\Dev\Repos\Farming\Data\ImportCorrections 221018 230816-2000.txt',  0;
   EXEC test.hlpr_fnIsExcel 'T007: NO' , 'D:\Dev\Repos\Farming\Data\ImportCorrections 221018 230816-2000.doc',  0;
   EXEC test.hlpr_fnIsExcel 'T008: YES', 'D:\Dev\Repos\Farming\Data\ImportCorrections 221018 230816-2000.xlsx', 1;
   EXEC sp_log 1, @fn, '99: leaving all tests passed';
END
/*
EXEC tSQLt.Run 'test.test_fnIsExcel';
*/
GO

