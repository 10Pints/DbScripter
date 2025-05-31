SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==========================================================================================================
-- Author:      Terry Watts
-- Create date: 28-FEB-2024
-- Description: Handles the import of the TableType table
-- It does the following:
-- 1: delete the log files
-- 2: clear the ActionStaging table
-- 3: import the the @imprt_tsv_file into the Action table
-- 4: do any fixup
-- 5: Check postconditions: ActionStaging has rows
--
-- ALGORITHM:
-- Parameter validation
-- Delete the log files if they exist
-- Clear the TableType table
-- Import the file
-- Do any fixup
-- Check postconditions
--
-- PRECONDITIONS:
--    TableType table dependants have been cleared
--
-- POSTCONDITIONS:
-- POST01: TableType must have rows
--
-- Called by: ?? sp_import_static_data
--
-- TESTS:
--
-- CHANGES:
-- ==========================================================================================================
ALTER PROCEDURE [dbo].[sp_import_TableType]
    @import_file     NVARCHAR(500)
   ,@range           NVARCHAR(100)  = N'TableType$A:B'  -- for XL: like 'Table$' OR 'Table$A:B'
AS
BEGIN
   DECLARE
        @fn          NVARCHAR(35)  = N'IMPRT_TBL_TY'

   EXEC sp_log 2, @fn, '01 starting
@import_file:[',@import_file,']
@range      :[',@range      ,']'
;

   EXEC sp_bulk_import 
       @import_file   = @import_file
      ,@table         = 'TableType'
      ,@view          = NULL
      ,@range         = @range
      ,@fields        = 'id,name'
      ,@clr_first     = 1
      ,@is_new        = 0;
END
/*
EXEC sp_import_TableType 'D:\Dev\Repos\Farming\Data\TableDef.xlsx','TableType$A:B';
SELECT * FROM TableType;
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_sp_import_TableType';
*/

GO
