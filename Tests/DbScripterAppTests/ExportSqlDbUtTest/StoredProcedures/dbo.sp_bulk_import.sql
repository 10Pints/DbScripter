SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================================================================================
-- Author:      Terry Watts
-- Create date: 25-FEB-2024
-- Description: imports a tsv or xlsx file
--
-- Preconditions:
--
-- Postconditions
--  POST01: @import_file must exist                         OR exception 63240, 'import_file must exist'
--  POST02: if @is_new is false then (table must exist      OR exception 63241, 'table must exist if @is_new is false')
--  POST03: if @is_new is true  then (table does not exist  OR exception 63242, 'table must not exist if @is_new is true'))
--  POST04: if import file is a tsv file then @view must be specified OR exception 63244 'the view must be specified if thisis a tsv import'
--
-- Changes:
-- 27-FEB-2024: added the @clr_first flag parameter
-- 28-FEB-2024: added the @is_new flag parameter
-- 28-FEB-2024: removed postcondition: fields must be specifiec if XL and table exists
-- =============================================================================================================================================
CREATE PROCEDURE [dbo].[sp_bulk_import]
    @import_file NVARCHAR(60)
   ,@table       NVARCHAR(60)   = NULL
   ,@view        NVARCHAR(60)   = NULL
   ,@range       NVARCHAR(100)  = NULL  -- for XL: like 'Corrections_221008$A:P' OR 'Corrections_221008$'
   ,@fields      NVARCHAR(4000) = NULL  -- for XL: comma separated list
   ,@clr_first   BIT            = 1     -- if 1 then delete the table contets first
   ,@is_new      BIT            = 1     -- if 1 then create the table - this is a double check
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(35)   = N'BLK_IMPRT'
      ,@cmd          NVARCHAR(MAX)
      ,@table_exists BIT
      ,@is_xl_file   BIT
   EXEC sp_log 1, @fn, '00: starting, 
@import_file:  [', @import_file,']
@table:        [', @table,']
@view:         [', @view,']
@range:        [', @range,']
@fields:       [', @fields,']
@clr_first:    [', @clr_first,']';
   ----------------------------------------------------------------------------------------------------------
   -- Parameter Validation
   ----------------------------------------------------------------------------------------------------------
   SET @table_exists = iif( EXISTS (SELECT 1 FROM list_tables_vw WHERE table_name = @table), 1, 0);
   SET @is_xl_file = IIF( CHARINDEX('.xlsx', @import_file) > 0, 1, 0);
   EXEC sp_log 1, @fn, '05: 
@table_exists:  [', @table_exists,']
@is_xl_file     [', @is_xl_file,']'
   --  POST01: @import_file must exist                         OR exception 63240, 'import_file must exist'
   IF @import_file IS NULL OR @import_file ='' THROW 63240, 'import_file must exist', 1;
   --  POST02: if @is_new is false then (table must exist      OR exception 63241, 'table must exist if @is_new is false')
   IF @is_new = 0 AND @table_exists = 0 THROW 63241, 'table must exist if @is_new is false', 1;
   --  POST03: if @is_new is true  then (table does not exist  OR exception 63242, 'table must not exist if @is_new is true'))
   IF @is_new = 1 AND @table_exists = 1 THROW 63242, 'table must not exist if @is_new is true', 1;
   --  POST04: if import file is a tsv file then @view must be specified OR exception 63244 'the view must be specified if this is a tsv import'
   IF @is_xl_file = 0 AND @view IS NULL THROW 63244, 'the view must be specified if this is a tsv import', 1;
   ----------------------------------------------------------------------------------------------------------
   -- Importing file
   ----------------------------------------------------------------------------------------------------------
   EXEC sp_log 1, @fn, '10: Importing file';
   IF @is_xl_file = 1
   BEGIN
      ----------------------------------------------------------------------------------------------------------
      -- Importing Excel file
      ----------------------------------------------------------------------------------------------------------
      -- Parameter Validation
      EXEC sp_log 1, @fn, '15: Importing Excel file';
      EXEC sp_log 1, @fn, '20: Parameter Validation...';
      IF @range  IS NULL SET @range = N'Sheet1$';
      IF @fields IS NULL THROW 63241, 'if xl import then @fields must be specified ', 1;
      IF @table  IS NULL THROW 63242, 'if xl import then @table must be specified', 1;
      EXEC sp_log 1, @fn, '25: Parameter Validation ok';
      IF @is_new = 1
      BEGIN
         ----------------------------------------------------------------------------------------------------------
         -- Importing Excel file to new table
         ----------------------------------------------------------------------------------------------------------
         EXEC sp_log 1, @fn, '30: Importing new Excel file';
         EXEC ut.dbo.sp_import_XL_new @import_file, @range, @fields, @table;
      END
      ELSE
      BEGIN
         ----------------------------------------------------------------------------------------------------------
         -- Importing Excel file to existing table
         ----------------------------------------------------------------------------------------------------------
         EXEC sp_log 1, @fn, '35: Importing existing Excel file';
         EXEC ut.dbo.sp_import_XL_existing @import_file, @range, @fields, @table, @clr_first;
      END
      EXEC sp_log 1, @fn, '40: Imported Excel file';
   END
   ELSE
   BEGIN
      ----------------------------------------------------------------------------------------------------------
      -- Importing tsv file
      ----------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '60: Importing tsv file';
      IF @view IS NULL SET @view = CONCAT('Import',@table,'_vw');
      EXEC sp_import_tsv @import_file, @view, @table, @clr_first;
      EXEC sp_log 1, @fn, '70: Imported tsv file';
   END
   ---------------------------------------------------------------------
   -- Completed processing OK
   ---------------------------------------------------------------------
      EXEC sp_log 1, @fn, '99: leaving, OK';
END
/*
   EXEC tSQLt.RunAll;
*/
GO

