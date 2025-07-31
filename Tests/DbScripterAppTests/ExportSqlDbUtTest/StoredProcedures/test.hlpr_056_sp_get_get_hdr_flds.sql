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
CREATE PROCEDURE [test].[hlpr_056_sp_get_get_hdr_flds]
    @tst_num         NVARCHAR(50)
   ,@file_path       NVARCHAR(500)
   ,@exp_fields      NVARCHAR(4000) = NULL
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
    @fn              NVARCHAR(35) = 'HLPR_fnIsExcel'
   ,@line            NVARCHAR(80)='------------------------'
   ,@act_fields      NVARCHAR(4000)            -- comma separated
   PRINT CONCAT(NCHAR(13), NCHAR(10), @line, ' ', @tst_num, @line);
   EXEC sp_log 1, 'LRAP_data_file:[',@file_path,  ']
exp_fields:           [',@exp_fields,             ']'
;
   --------------------------------------------------------------------------------------------
   -- 0. Setup
   --------------------------------------------------------------------------------------------
   --------------------------------------------------------------------------------------------
   -- 1. Run routine
   --------------------------------------------------------------------------------------------
   EXEC sp_get_get_hdr_flds @file_path, @act_fields OUT;
   --------------------------------------------------------------------------------------------
   -- 2. test
   --------------------------------------------------------------------------------------------
   EXEC tSQLt.AssertEquals @exp_fields, @act_fields, @tst_num;
   EXEC sp_log 1, @fn, '99: passed';
END
/*
EXEC tSQLt.Run 'test.test_fnIsExcel';
*/
GO

