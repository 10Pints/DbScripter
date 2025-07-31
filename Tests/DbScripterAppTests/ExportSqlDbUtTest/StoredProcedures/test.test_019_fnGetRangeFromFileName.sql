SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================================================================================================================
-- Author:      Terry Watts
-- Create date: 15-MAR-2024
-- Description: tests the sp_get_get_hdr_flds routine
--
-- Tested routine:
--  returns a 1 row table holding the file path and the range from the @filePath_inc_rng parameter
-- 
-- Parameters:
-- @file_path  path to the data file including file name
--             if an excel can include the sheet and range default range is Sheet1 all. See POST 04
--
--
-- Postconditions:
--   POST01: returns 1 row [file_path, range]
-- ============================================================================================================================
CREATE PROCEDURE [test].[test_019_fnGetRangeFromFileName]
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn              NVARCHAR(35) = 'TEST_GET_GET_HDR_FLDS'
  EXEC sp_log 1, @fn,'00: starting:';
  EXEC test.hlpr_019_fnGetRangeFromFileName
    @tst_num         = 'Test 001: NULL'
   ,@filePath_inc_rng= NULL
   ,@exp_file_path   = NULL
   ,@exp_range       = NULL
   ;
  EXEC test.hlpr_019_fnGetRangeFromFileName
    @tst_num         = 'Test 002: EMPTY'
   ,@filePath_inc_rng= ''
   ,@exp_file_path   = NULL
   ,@exp_range       = NULL
  EXEC test.hlpr_019_fnGetRangeFromFileName
    @tst_num         = 'Test 003: no exist file'
   ,@filePath_inc_rng= 'non existent file'
   ,@exp_file_path   = NULL
   ,@exp_range       = NULL
   ;
  EXEC test.hlpr_019_fnGetRangeFromFileName
    @tst_num         = 'Test 004: Full Xl spec'
   ,@filePath_inc_rng= 'D:\Dev\Repos\Farming\Data\Jap chem list 2306.xlsx!November_1_2022$A:D'
   ,@exp_file_path   = 'D:\Dev\Repos\Farming\Data\Jap chem list 2306.xlsx'
   ,@exp_range       = 'November_1_2022$A:D'
   ;
  EXEC test.hlpr_019_fnGetRangeFromFileName
    @tst_num         = 'Test 005: XL with default range'
   ,@filePath_inc_rng= 'D:\Dev\Repos\Farming\Data\Jap chem list 2306.xlsx'
   ,@exp_file_path   = 'D:\Dev\Repos\Farming\Data\Jap chem list 2306.xlsx'
   ,@exp_range       = 'Sheet1$'
   ;
  EXEC sp_log 2, @fn,'99: leaving, All tests passed';
END
/*
   EXEC test.test_019_fnGetRangeFromFileName;
   SELECT * FROM dbo.fnGetRangeFromFileName(NULL);
*/
GO

