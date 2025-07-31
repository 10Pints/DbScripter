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
CREATE PROCEDURE [test].[hlpr_fnIsExcel]
    @tst_num         NVARCHAR(50)
   ,@LRAP_data_file  NVARCHAR(500)
   ,@exp             BIT
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
    @fn              NVARCHAR(35) = 'HLPR_fnIsExcel'
   ,@act             BIT
   ,@line            NVARCHAR(80)='------------------------'
   PRINT CONCAT(NCHAR(13), NCHAR(10), @line, ' ', @tst_num, @line);
   EXEC sp_log 1, 'LRAP_data_file:[',@LRAP_data_file,  ']
exp:           [',@exp,             ']'
;
   --------------------------------------------------------------------------------------------
   -- 0. Setup
   --------------------------------------------------------------------------------------------
   --------------------------------------------------------------------------------------------
   -- 1. Run routine
   --------------------------------------------------------------------------------------------
   SET @act = dbo.fnIsExcel(@LRAP_data_file);
   --------------------------------------------------------------------------------------------
   -- 2. test
   --------------------------------------------------------------------------------------------
   EXEC tSQLt.AssertEquals @exp, @act, @tst_num;
   EXEC sp_log 1, @fn, '99: passed';
END
/*
EXEC tSQLt.Run 'test.test_fnIsExcel';
*/
GO

