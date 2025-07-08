SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =========================================================================
-- Author:      Terry Watts
-- Create date: 20-AUG-2023
-- 
-- Description: imports the TypeStaging table form either a tsv or XL file
-- clears the table first
--
-- Parameters:
-- @import_file path to a tsv or excel file
-- @range [optional] if xlsx - can specify the sheet and range
-- @row_cnt [optional OUT] returns the rowcount is not null
--
-- Preconditions:
--  PRE01: all typeStaging dependent tables are cleared
--
-- Postconditions:
--   POST01: typeStaging table clean populated or error
--    
-- Tests: test.sp_import_TypeStaging
--
-- Changes:
-- 231107: imports to type_staging table not type
-- 231107: removed FK removal - now see Preconditions
-- ========================================================
CREATE PROCEDURE [dbo].[sp_import_TypeStaging]
      @import_file   VARCHAR(500)
     ,@range         VARCHAR(100)  = 'Sheet1$A:B'
     ,@row_cnt       INT           = NULL   OUT
AS
BEGIN
   DECLARE @fn        VARCHAR(35)  = N'IMPRT_TypeStaging'

   EXEC sp_log 1, @fn,'000: starting
import_file:[', @import_file, ']
range      :[', @range      , ']
row_cnt    :[', @row_cnt    , ']';

   --EXEC sp_register_call @fn;

   ------------------------------------------------------
   -- Pop defaults if necessary
   ------------------------------------------------------
   IF @range IS NULL SET @range = 'Sheet1$A:B';

   ------------------------------------------------------
   -- Import
   ------------------------------------------------------
   EXEC sp_log 1, @fn,'010: calling sp_bulk_import';
   EXEC sp_import_file
       @import_file  = @import_file
      ,@table        = 'TypeStaging'
      ,@view         = Import_TypeStaging_vw
      ,@range        = @range
      ,@fields       = 'type_id, type_nm'
      ,@clr_first    = 1
      ,@is_new       = 0
      ,@expect_rows  = 1
      ,@row_cnt      = @row_cnt OUT
      ;

   ------------------------------------------------------
   -- Processing complete
   ------------------------------------------------------
   EXEC sp_log 1, @fn, '999: leaving OK';
   RETURN;
END
/*
EXEC tSQLt.Run 'test.test_sp_import_TypeStaging';
EXEC sp_import_typeStaging 'D:\Dev\Repos\Farming\Data\Type.xlsx';
SELECT * FROM TypeStaging;
*/


GO
