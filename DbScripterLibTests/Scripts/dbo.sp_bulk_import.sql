SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ================================================================================================================================================
-- Author:      Terry Watts
-- Create date: 25-FEB-2024
-- Description: imports a tsv or xlsx file
--
-- Parameters:    Mandatory,optional M/O
-- @import_file  [M] the import source file can be a tsv or xlsx file
--                   if an XL file then the normal format for the sheet is field names in the top row including an id for ease of debugging 
--                   data issues
-- @table        [O] the table to import the data to. 
--                if an XL file defaults to sheet name if not Sheet1$ otherwise file name less the extension
--                if a tsv defaults to file name less the extension
-- @view         [O] if a tsv this is the view used to control which columns are used n the Bulk insert command
--                   the default is NULL when the view name is constructed as import_<table name>_vw
-- @range        [O] for XL: like 'Corrections_221008$A:P' OR 'Corrections_221008$' default is 'Sheet1$'
-- @fields       [O] for XL: comma separated list
-- @clr_first    [O] if 1 then delete the table contents first           default is 1
-- @is_new       [O] if 1 then create the table - this is a double check default is 0
-- @expect_rows  [O] optional @expect_rows to assert has imported rows   default is 1
--
-- Preconditions: none
--
-- Postconditions:
-- POST01: @import file must not be null or ''             OR exception 63240, 'import_file must be specified'
-- POST02: @import file must exist                         OR exception 63241, 'import_file must exist'
-- POST03: if @is_new is false then (table must exist      OR exception 63242, 'table must exist if @is_new is false')
-- POST04: if @is_new is true  then (table must not exist  OR exception 63243, 'table must not exist if @is_new is true'))
-- 
-- RULES:
-- RULE01: @table:  if xl import then @table must be specified or deducable from the sheet name or file name OR exception 63245
-- RULE02: @table:  if a tsv then must specify table or the file name is the table 
-- RULE03: @view:   if a tsv file then if the view is not specified then it is set as Import<table>_vw
-- RULE04: @range:  if an Excel file then range defaults to 'Sheet1$'
-- RULE05: @fields: if an Excel file then @fields is optional
--                  if not specified then it is taken from the excel header (first row)
-- RULE06: @fields: if a tsv file then @fields is mandatory OR EXCEPTION 63245, 'if a tsv file then @fields is must be specified'
-- RULE07: @is_new: if new table and is an excel file and @fields is null then the table is created with fields taken from the spreadsheet header.
--
-- Changes:
-- 240326: added an optional root dir which can be specified once by client code and the path constructed here
-- ================================================================================================================================================
ALTER PROCEDURE [dbo].[sp_bulk_import]
    @import_file  NVARCHAR(1000)
   ,@import_root  NVARCHAR(1000) = NULL
   ,@table        NVARCHAR(60)   = NULL
   ,@view         NVARCHAR(60)   = NULL
   ,@range        NVARCHAR(100)  = N'Sheet1$'   -- POST09 for XL: like 'Corrections_221008$A:P' OR 'Corrections_221008$'
   ,@fields       NVARCHAR(4000) = NULL         -- for XL: comma separated list
   ,@clr_first    BIT            = 1            -- if 1 then delete the table contents first
   ,@is_new       BIT            = 0            -- if 1 then create the table - this is a double check
   ,@expect_rows  BIT            = 1            -- optional @expect_rows to assert has imported rows
   ,@row_cnt      INT            = NULL OUT     -- optional count of imported rows
AS
BEGIN
   SET NOCOUNT ON;

   DECLARE
       @fn           NVARCHAR(35)   = N'BLK_IMPRT'
      ,@ndx          INT
      ,@file_name    NVARCHAR(128)
      ,@table_exists BIT
      ,@is_xl_file   BIT
      ,@msg          NVARCHAR(500)

   PRINT '';
   EXEC sp_log 1, @fn, '000: starting';

   EXEC sp_log 1, @fn, '001: parameters,
import_file:  [', @import_file,']
table:        [', @table,']
view:         [', @view,']
range:        [', @range,']
fields:       [', @fields,']
clr_first:    [', @clr_first,']
is_new        [', @is_new,']
expect_rows   [', @expect_rows,']
';

   BEGIN TRY
      EXEC sp_log 1, @fn, '005: initial checks'
      EXEC sp_log 0, @fn, '010: checking POST01'
      ----------------------------------------------------------------------------------------------------------
      -- POST01: @import file must not be null or '' OR exception 63240, 'import_file must be specified'
      ----------------------------------------------------------------------------------------------------------
      IF @import_file IS NULL OR @import_file =''
      BEGIN
         SET @msg = 'import file must be specified';
         EXEC sp_log 4, @fn, '011 ',@msg;
         THROW 63240, @msg, 1;
      END

      IF @import_root IS NOT NULL
      BEGIN
         SET @import_file = CONCAT(@import_root, '\', @import_file);
         EXEC sp_log 1, @fn, '010: ,
modified import_file:  [', @import_file,']'
      END

      ----------------------------------------------------------------------------------------------------------
   -- POST02: @import file must exist  OR exception 63241, 'import_file must exist'
      ----------------------------------------------------------------------------------------------------------
      EXEC sp_log 0, @fn, '015: checking POST02'
      IF Ut.dbo.fnFileExists(@import_file) <> 1
      BEGIN
         EXEC sp_log 1, @fn, '015: checking POST02'
         SET @msg = CONCAT('import file [',@import_file,'] must exist');
         EXEC sp_log 4, @fn, '015 ',@msg;
         THROW 63241, @msg, 1;
      END

      SET @is_xl_file = IIF( CHARINDEX('.xlsx', @import_file) > 0, 1, 0);

      ----------------------------------------------------------------------------------------------------------
      -- Handle defaults
      ----------------------------------------------------------------------------------------------------------
      EXEC sp_log 0, @fn, '020: handle defaults'
      IF @range     IS NULL SET @range =  N'Sheet1$';
      IF @clr_first IS NULL SET @clr_first = 1;

      IF @table IS NULL 
      BEGIN
         EXEC sp_log 1, @fn, '025: setting table default value'
         IF @is_xl_file = 1
         BEGIN
            ----------------------------------------------------------------------------------------------------------
            -- POST06: @table: if xl import then @table must be specified or deducable from the sheet name or file name OR exception 63245
            ----------------------------------------------------------------------------------------------------------
            IF SUBSTRING(@range, 1, 7)<> 'Sheet1$'
            BEGIN
               SET @ndx   = CHARINDEX('$', @range);
               SET @table = SUBSTRING(@range, 1, @ndx-1);
            END
            ELSE
            BEGIN
               IF @ndx = 0 SET @ndx = Ut.dbo.fnLen(@range);
               SET @table = Ut.dbo.fnGetFileNameFromPath(@import_file,0);
            END
         END
         ELSE
         BEGIN
            ----------------------------------------------------------------------------------------------------------
            -- POST07: @table: if a tsv then must specify table or the file name is the table
            ----------------------------------------------------------------------------------------------------------
            SET @table = Ut.dbo.fnGetFileNameFromPath(@import_file,0);
         END

         IF dbo.fnTableExists(@table)=0
         BEGIN
            EXEC sp_log 1, @fn, '026: deduced table name:[', @table,'] does not exist';
            SET @table = NULL;
         END

         EXEC sp_log 1, @fn, '027: deduced table name:[', @table,']';
      END

      EXEC sp_log 0, @fn, '027: table:[', @table,']';
      SET @table_exists = iif( @table IS NOT NULL AND dbo.fnTableExists(@table)<>0, 1, 0);

      ----------------------------------------------------------------------------------------------------------
      -- RULE03: @view:  if a tsv file then if the view is not specified then it is set as Import<table>_vw
      ----------------------------------------------------------------------------------------------------------
      IF @view IS NULL AND @table_exists = 1  AND @is_xl_file = 0 
      BEGIN
         SET @view = CONCAT('Import_',@table,'_vw');
         EXEC sp_log 1, @fn, '030: if a tsv file and the view is not specified then set view default value as Import_<table>_vw: [',@view,']'
      END

      ----------------------------------------------------------------------------------------------------------
      -- Parameter Validation
      ----------------------------------------------------------------------------------------------------------

      ----------------------------------------------------------------------------------------------------------
      -- RULE05: @fields:if an Excel file then @fields is optional
      --          if not specified then it is taken from the excel header (first row)
      -- RULE07: @is_new: if new table and is an excel file and @fields is null then the table is created with
      --         fields taken from the spreadsheet header.

      ----------------------------------------------------------------------------------------------------------
      EXEC sp_log 0, @fn, '035: checking rule 5,11';
      IF @fields IS NULL AND @is_xl_file = 1
      BEGIN
         EXEC sp_get_fields_from_xl_hdr @import_file, @range, @fields OUT;
         EXEC sp_log 0, @fn, '040: if xl file and the fields are not specified then defaulting @fields to: [',@fields,']'
      END

      ------------------------------------------------------------------------------------------------------------------------------------------
      -- RULE06: @fields:if a tsv file then @fields is mandatory OR EXCEPTION 63245, 'if a tsv file then @fields is must be specified'
      ------------------------------------------------------------------------------------------------------------------------------------------
      EXEC sp_log 0, @fn, '045: checking RULE06';

      IF @fields IS NULL AND @is_xl_file = 0
      BEGIN
         SET @msg = 'if a tsv file then @fields must be specified';
         EXEC sp_log 4, @fn, '050 ',@msg;
         THROW 63245, @msg, 1;
      END

      --------------------------------------------------------------------------------------------------------------------
   -- POST03: if @is_new is false then (table must exist      OR exception 63242, 'table must exist if @is_new is false')
      --------------------------------------------------------------------------------------------------------------------
      IF @is_new = 0 AND @table_exists = 0
      BEGIN
         SET @msg = 'table must exist if @is_new is false';
         EXEC sp_log 4, @fn, '055 ',@msg;
         THROW 63244, @msg, 1;
      END

      ----------------------------------------------------------------------------------------------------------
   -- POST04: if @is_new is true  then (table does not exist  OR exception 63243, 'table must not exist if @is_new is true'))
      ----------------------------------------------------------------------------------------------------------
      IF @is_new = 1 AND @table_exists = 1
      BEGIN
         SET @msg = 'table must not exist if @is_new is true';
         EXEC sp_log 4, @fn, '060 ',@msg;
         THROW 63243, @msg, 1;
      END

      ----------------------------------------------------------------------------------------------------------
      -- Import the file
      ----------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '070: Importing file';
      IF @is_xl_file = 1
      BEGIN
         ----------------------------------------------------------------------------------------------------------
         -- Import Excel file
         ----------------------------------------------------------------------------------------------------------
         -- Parameter Validation
         EXEC sp_log 1, @fn, '075: Importing Excel file, fixup the range:[',@range,']';

         -- Fixup the range
         SET @range = ut.dbo.fnFixupXlRange(@range);
         EXEC sp_log 1, @fn, '080: Importing Excel file, fixuped the range:[',@range,']';

         ----------------------------------------------------------------------------------------------------------
         -- RULE05: @fields:if an Excel file then @fields is optional
         --          if not specified then it is taken from the excel header (first row)
         -- RULE07: @is_new: if new table and if an Excel file and @fields is null 
         --         then the table is created with fields taken from the spreadsheet header
         ----------------------------------------------------------------------------------------------------------
         EXEC sp_log 1, @fn, '085: calling sp_get_fields_from_xl_hdr';
         EXEC sp_get_fields_from_xl_hdr @import_file, @range, @fields OUT;
         EXEC sp_log 1, @fn, '087: ret frm sp_get_fields_from_xl_hdr';

         IF @is_new = 1
         BEGIN
            ----------------------------------------------------------------------------------------------------------
            -- Importing Excel file to new table
            ----------------------------------------------------------------------------------------------------------
            EXEC sp_log 1, @fn, '090: Importing Excel file to new table';
            EXEC sp_import_XL_new @import_file, @range, @table, @fields, @row_cnt=@row_cnt OUT;
         END
         ELSE
         BEGIN
            ----------------------------------------------------------------------------------------------------------
            -- Importing Excel file to existing table
            ----------------------------------------------------------------------------------------------------------
            EXEC sp_log 0, @fn, '095: Importing Excel file to existing table';
            EXEC sp_import_XL_existing @import_file, @range, @table, @clr_first, @fields, @row_cnt=@row_cnt OUT;
         END

         EXEC sp_log 0, @fn, '100: Imported Excel file';
      END
      ELSE
      BEGIN
         ----------------------------------------------------------------------------------------------------------
         -- Importing tsv file
         ----------------------------------------------------------------------------------------------------------
         EXEC sp_log 1, @fn, '105: Importing tsv file';

         ----------------------------------------------------------------------------------------------------------
         -- POST12: @is_new: if this is set then the table is created with fields based on the spreadsheet header
         ----------------------------------------------------------------------------------------------------------

         EXEC sp_bulk_import_tsv @import_file, @view, @table, @clr_first, @row_cnt=@row_cnt OUT;
      END

      ----------------------------------------------------------------------------------------------------------
      -- Checking post conditions
      ----------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '115: Checking post conditions'

      IF @expect_rows = 1
         EXEC sp_chk_tbl_populated @table;

      ---------------------------------------------------------------------
      -- Completed processing OK
      ---------------------------------------------------------------------
      EXEC sp_log 1, @fn, '120: Completed processing OK'
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;

      EXEC sp_log 1, @fn, '000: parameters:
import_file:  [', @import_file,']
import_root:  [', @import_root,']
table:        [', @table,']
view:         [', @view,']
range:        [', @range,']
fields:       [', @fields,']
clr_first:    [', @clr_first,']
is_new        [', @is_new,']
expect_rows   [', @expect_rows,']
';

      EXEC sp_log 1, @fn, '050: parameters
   @table_exists:  [', @table_exists,']
   @is_xl_file     [', @is_xl_file,']';

      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '99: leaving OK, imported ',@row_cnt,' rows to the ',@table,'  table from ',@import_file;
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_085_sp_bulk_import';
*/

GO
