SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2020
-- Description: Tests the dbo.fnContainsWhitespace rtn
--    1: settings configuration getters,
--    2: setters
--    3: test.sp_tst_main_start
-- ==================================================================
CREATE PROCEDURE [test].[test_031_fnContainsWhitespace]
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(60)      = N'test 031 fnContainsWhitespace'
      ,@fn_num    NVARCHAR(3)       -- test number
      ,@hlpr_fn   NVARCHAR(60)      -- helper fn nm
      ,@tsu_fn    NVARCHAR(60)      -- tsu    fn nm
      ,@tsu1_fn   NVARCHAR(60)      -- tsu1   fn nm
      ,@act_res   BIT
      ,@len       INT
      ,@wsp_test_data_1 NVARCHAR(60) = CONCAT(N'asd', NCHAR(9), N'zyz')
      ,@wsp_test_data_2 NVARCHAR(60) = CONCAT(NCHAR(9), N'zyz')
      ,@wsp_test_data_3 NVARCHAR(60) = CONCAT(N'asd', NCHAR(9))
      ,@wsp_test_data_4 NVARCHAR(60) = CONCAT(N'asd', NCHAR(9), N'zyz')
      ,@test_num   NVARCHAR(4)
      ,@inp        NVARCHAR(100)
      ,@exp        INT
   SET NOCOUNT ON
   EXEC sp_log 1, @fn, '01: starting';
   EXEC test.TSU1_031_fnContainsWhitespace
   DECLARE crsr CURSOR FOR
      SELECT test_num, inp, [exp] FROM test.TSU1_031_table ORDER BY test_num;
   WHILE 1 = 1
   BEGIN
      EXEC sp_log 1, @fn, 'starting';
      OPEN crsr
      FETCH NEXT FROM crsr INTO @test_num, @inp, @exp;
      WHILE @@FETCH_STATUS = 0
      BEGIN
         EXEC test.hlpr_031_fnContainsWhitespace @test_num, @inp, @exp;
         FETCH NEXT FROM crsr INTO @test_num, @inp, @exp;
      END
      CLOSE crsr;
      DEALLOCATE crsr;
      -- Setup: Test 1: data setup by directly using setters
      -- whitespace is: 
      --  NCHAR(9), NCHAR(10), NCHAR(11), NCHAR(12), NCHAR(13), NCHAR(14), NCHAR(32), NCHAR(160)
/*
      EXEC test.hlpr_031_fnContainsWhitespace 'T001 NULL', NULL, 0;
      EXEC test.hlpr_031_fnContainsWhitespace 'T002 MT'  , ''  , 0;
      -- positive tests
      EXEC test.hlpr_031_fnContainsWhitespace 'T002 P '  , ''  , 0;
      EXEC test.hlpr_031_fnContainsWhitespace 'T002 P '  , ''  , 0;
      EXEC test.hlpr_031_fnContainsWhitespace 'T002 P '  , ''  , 0;
      EXEC test.hlpr_031_fnContainsWhitespace 'T002 P '  , ''  , 0;
      EXEC test.hlpr_031_fnContainsWhitespace 'T002 P '  , ''  , 0;
      EXEC test.hlpr_031_fnContainsWhitespace 'T002 P '  , ''  , 0;
      EXEC test.hlpr_031_fnContainsWhitespace 'T002 P '  , ''  , 0;
      EXEC test.hlpr_031_fnContainsWhitespace 'T002 P '  , ''  , 0;
*/
      BREAK;  -- Do once loop
   END -- WHILE
   PRINT 'All tests passed'
   EXEC sp_log 1, @fn, '99: leaving';
END
/*
EXEC tSQLt.RunAll
EXEC tSQLt.Run 'test.test_031_fnContainsWhitespace';
*/
GO

