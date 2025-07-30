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
CREATE PROCEDURE [test].[hlpr_019_fnGetRangeFromFileName]
    @tst_num            NVARCHAR(50)
   ,@filePath_inc_rng   NVARCHAR(500)
   ,@exp_file_path      NVARCHAR(4000) = NULL
   ,@exp_range          NVARCHAR(255)  = NULL
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
    @fn              NVARCHAR(35) = 'HLPR_fnGetRangeFromFileName'
   ,@line            NVARCHAR(80) ='------------------------'
   ,@act_row_cnt     INT
   ,@act_file_path   NVARCHAR(4000)            -- comma separated
   ,@act_range       NVARCHAR(4000)            -- comma separated
   PRINT CONCAT(NCHAR(13), NCHAR(10), @line, ' ', @tst_num, ' ', @line);
   EXEC sp_log 1, @fn, 'starting:
file_path_inc_rng:[',@filePath_inc_rng, ']
exp_file_path:    [',@exp_file_path,    ']
exp_range:        [',@exp_range,        ']'
;
   --------------------------------------------------------------------------------------------
   -- 0. Setup
   --------------------------------------------------------------------------------------------
   --------------------------------------------------------------------------------------------
   -- 1. Run routine
   --------------------------------------------------------------------------------------------
   EXEC sp_log 1, @fn, 'calling fnGetRangeFromFileName( ',@filePath_inc_rng,')';
   SELECT
       @act_file_path = file_path
      ,@act_range     = [range]
      FROM dbo.fnGetRangeFromFileName(@filePath_inc_rng);
   -- Check we got either 0 or 1 row returned from the table fn
   SET @act_row_cnt   = @@ROWCOUNT;
   EXEC sp_log 1, @fn, 'ret frm fnGetRangeFromFileName() 
act_row_cnt  :[', @act_row_cnt,   ']
act_file_path:[', @act_file_path, ']
act_range    :[', @act_range,     ']';
   --------------------------------------------------------------------------------------------
   -- 2. test
   --------------------------------------------------------------------------------------------
   EXEC sp_log 1, @fn, 'checking row_cnt: ',@act_row_cnt;
   EXEC tSQLt.AssertEquals 1, @act_row_cnt, @tst_num, ' act_row_cnt'
   EXEC sp_log 1, @fn, 'checking file_path:[',@act_file_path, ']';
   IF @exp_file_path IS NOT NULL EXEC tSQLt.AssertEquals @exp_file_path, @act_file_path, @tst_num, ' file_path';
   EXEC sp_log 1, @fn, 'checking range:[',@act_range,']';
   IF @exp_range     IS NOT NULL EXEC tSQLt.AssertEquals @exp_range, @act_range,         @tst_num, ' range';
   EXEC sp_log 1, @fn, '99: passed';
END
/*
EXEC tSQLt.Run 'test.test_019_fnGetRangeFromFileName';
*/
GO

