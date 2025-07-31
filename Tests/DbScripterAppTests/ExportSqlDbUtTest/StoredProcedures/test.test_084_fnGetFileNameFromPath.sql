SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================================================
-- Author:      Terry Watts
-- Create date: 07-MAR-2024
-- Description: Tests the fnGetFileNameFromPath rtn
--
-- Tested rtn description:
-- Gets the file name optionally with the extension from the supplied file path
--
-- =============================================================================================================
--[@tSQLt:SkipTest]('Temporarily disabled while refactoring')
CREATE PROCEDURE [test].[test_084_fnGetFileNameFromPath]
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
     @fn    NVARCHAR(35) = 'TST_084_FNGETFILENAMEFROMPATH'
    ,@act   NVARCHAR(200)
   EXEC sp_log 1, @fn, '00: starting';
   -- 0: SETUP: clear all staging tables, pop all tables with 1 row manually
   EXEC sp_log 1, @fn, '05: test 01: setup';
   EXEC sp_log 1, @fn, '10: test 01: calling tested rtn';
   EXEC test.hlpr_084_fnGetFileNameFromPath '001','D:\Dev\Repos\Farming\Data\Type.xlsx',0, 'Type';
   EXEC test.hlpr_084_fnGetFileNameFromPath '002','D:\Dev\Repos\Farming\Data\Type.xlsx',1, 'Type.xlsx';
   EXEC test.hlpr_084_fnGetFileNameFromPath '003','Type.xlsx'                          ,0, 'Type';
   EXEC test.hlpr_084_fnGetFileNameFromPath '004','Type.xlsx'                          ,1, 'Type.xlsx';
   EXEC test.hlpr_084_fnGetFileNameFromPath '005',NULL                                 ,0, NULL;
   EXEC test.hlpr_084_fnGetFileNameFromPath '006',NULL                                 ,1, NULL;
   EXEC test.hlpr_084_fnGetFileNameFromPath '007',''                                   ,0, '';
   EXEC test.hlpr_084_fnGetFileNameFromPath '008',''                                   ,1, '';
   EXEC test.hlpr_084_fnGetFileNameFromPath '009','Type'                               ,0, 'Type';
   EXEC test.hlpr_084_fnGetFileNameFromPath '010','Type'                               ,1, 'Type';
   EXEC test.hlpr_084_fnGetFileNameFromPath '011','.Type'                              ,0, '';
   EXEC test.hlpr_084_fnGetFileNameFromPath '012','.Type'                              ,1, '.Type';
   EXEC test.hlpr_084_fnGetFileNameFromPath '013','\Type.'                             ,0, 'Type';
   EXEC test.hlpr_084_fnGetFileNameFromPath '014','\Type.'                             ,1, 'Type.';
   EXEC test.hlpr_084_fnGetFileNameFromPath '015','D:\Dev\Repos\Farming\Data\Type.xlsx',1, 'Type.xlsx';
EXEC sp_log 1, @fn, '99: leaving all tests passed';
END
/*
EXEC tSQLt.Run 'test.test_084_fnGetFileNameFromPath';
*/
GO

