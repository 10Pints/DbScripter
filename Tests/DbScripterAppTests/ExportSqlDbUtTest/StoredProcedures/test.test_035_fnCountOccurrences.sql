SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ====================================================================
-- Author:           Terry Watts
-- Create date:      14-JAN-2023
-- Description:      tests dbo.fnCountOccurrences()
-- Tested rtn desc:  fnCountOccurrences() counts the occurrences of a 
--                   1 string in another string
-- ====================================================================
CREATE PROCEDURE [test].[test_035_fnCountOccurrences]
AS
BEGIN
   EXEC test.hlpr_035_fnCountOccurrences 'T001: ', 'asd.cdef', '.', 1
   EXEC test.hlpr_035_fnCountOccurrences 'T002: ', 'asd.cdef.ghijkl', '.', 2
   EXEC test.hlpr_035_fnCountOccurrences 'T003: ', 'asd__cdef', '__', 1
   EXEC test.hlpr_035_fnCountOccurrences 'T004: ', 'asd__cdef__ghijkl__z', '__', 3
   EXEC test.hlpr_035_fnCountOccurrences 'T005: ', 'asd__cdef__ghijkl__', '__', 3
   -- Edge cases:
   -- Empty string and token tests
   EXEC test.hlpr_035_fnCountOccurrences 'T006: ', ''    , '__' , 0
   EXEC test.hlpr_035_fnCountOccurrences 'T007: ', 'qwe' , ''     , 0
   EXEC test.hlpr_035_fnCountOccurrences 'T008: ', ''    , ''     , 0
   -- NULL string and token tests
   EXEC test.hlpr_035_fnCountOccurrences 'T009: ', NULL , '__'  , 0
   EXEC test.hlpr_035_fnCountOccurrences 'T010: ', 'qwe', NULL    , 0
   EXEC test.hlpr_035_fnCountOccurrences 'T011: ', NULL, NULL     , 0
   -- Token searched for is bigger than the contianer string
   EXEC test.hlpr_035_fnCountOccurrences 'T013: ', 'abc', 'abcd'  , 0
   -- Case sensitivity - *** ilicit requirement here
   EXEC test.hlpr_035_fnCountOccurrences 'T014: ', 'abcdeBC', 'bc' , 2
   EXEC test.hlpr_035_fnCountOccurrences 'T015: ', 'BCcdeBCBC','BC', 3
   -- Finally when all tests completed OK:
   PRINT 'test_fnCountOccurrences: all tests pass'
END
/*
EXEC tSQLt.Run 'test.test_035_fnCountOccurrences'
*/
GO

