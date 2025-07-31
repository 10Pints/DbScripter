SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2020
-- Description: 1 off Setup routine for
-- test 000_fnGetNthSubstring sp_chk_tst_setup_rtns
-- sets test dat afor the tests
-- ==================================================
CREATE PROCEDURE [test].[TSU1_031_fnContainsWhitespace]
      @log       BIT            = 0
AS
BEGIN
   DECLARE
       @fn              NVARCHAR(30) = N'test 031 fnContainsWhitespace'
      ,@wsp_test_data_1 NVARCHAR(60) = CONCAT(N'asd', NCHAR(9), N'zyz')
      ,@wsp_test_data_2 NVARCHAR(60) = CONCAT(NCHAR(9), N'zyz')
      ,@wsp_test_data_3 NVARCHAR(60) = CONCAT(N'asd', NCHAR(9))
      ,@wsp_test_data_4 NVARCHAR(60) = CONCAT(N'asd', NCHAR(9), N'zyz')
   EXEC UT.test.sp_tst_mn_st @fn,@log;
   DROP TABLE IF EXISTS test.TSU1_031_table;
   CREATE TABLE test.TSU1_031_table
   (
       test_num   NVARCHAR(4)
      ,inp        NVARCHAR(100)
      ,[exp]      INT
      CONSTRAINT [PK_TSU1_031_table] PRIMARY KEY CLUSTERED (test_num ASC)
   );
   -- whitespace is:
   --  NCHAR(9),  NCHAR(10), NCHAR(11), NCHAR(12)
   -- ,NCHAR(13), NCHAR(14), NCHAR(32), NCHAR(160)
   INSERT INTO test.TSU1_031_table(test_num, inp, [exp])
   VALUES 
       (N'T001', CONCAT(NCHAR(9), N'zyz'), 1)
      ,(N'T002', CONCAT(NCHAR(9), N'zyz'), 1)
      ,(N'T003', CONCAT(N'asd', NCHAR(9)), 1)
      ,(N'T004', CONCAT(N'asd', NCHAR(10), N'zyz'), 1)
      ,(N'T005', CONCAT(NCHAR(10), N'zyz'), 1)
      ,(N'T006', CONCAT(N'asd', NCHAR(10)), 1)
      ,(N'T007', CONCAT(N'asd', NCHAR(11), N'zyz'), 1)
      ,(N'T008', CONCAT(NCHAR(11), N'zyz'), 1)
      ,(N'T009', CONCAT(N'asd', NCHAR(11)), 1)
      ,(N'T010', CONCAT(N'asd', NCHAR(12), N'zyz'), 1)
      ,(N'T011', CONCAT(NCHAR(12), N'zyz'), 1)
      ,(N'T012', CONCAT(N'asd', NCHAR(12)), 1)
      ,(N'T013', CONCAT(N'asd', NCHAR(13), N'zyz'), 1)
      ,(N'T014', CONCAT(NCHAR(13), N'zyz'), 1)
      ,(N'T015', CONCAT(N'asd', NCHAR(13)), 1)
      ,(N'T016', CONCAT(N'asd', NCHAR(14), N'zyz'), 1)
      ,(N'T017', CONCAT(NCHAR(14), N'zyz'), 1)
      ,(N'T018', CONCAT(N'asd', NCHAR(14)), 1)
      ,(N'T019', CONCAT(N'asd', NCHAR(160), N'zyz'), 1)
      ,(N'T020', CONCAT(NCHAR(160), N'zyz'), 1)
      ,(N'T021', CONCAT(N'asd', NCHAR(160)), 1)
      ,(N'T022', CONCAT(N'asd', NCHAR(160), N'zyz'), 1)
   ;
END
/*
EXEC tSQLt.RunAll
EXEC tSQLt.Run 'test.test_031_fnContainsWhitespace';
*/
GO

