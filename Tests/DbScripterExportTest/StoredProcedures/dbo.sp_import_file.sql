SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================================================================================================
-- Author:      Terry Watts
-- Create date: 25-FEB-2024
-- Description: imports a txt (csv or tsv) or xlsx file
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
-- RULE07: @is_new: if new table and is an excel file and @fields is null then the table is created with fields taken from the spreadsheet header.
--
-- Changes:
-- 240326: added an optional root dir which can be specified once by client code and the path constructed here
-- ================================================================================================================================================
CREATE PROCEDURE [dbo].[sp_import_file]
    @import_file  VARCHAR(1000)
   ,@import_root  VARCHAR(1000)  = NULL
   ,@table        VARCHAR(60)    = NULL
   ,@view         VARCHAR(60)    = NULL
   ,@range        VARCHAR(100)   = N'Sheet1$'   -- POST09 for XL: like 'Corrections_221008$A:P' OR 'Corrections_221008$'
   ,@field_sep    VARCHAR(1)     = NULL
   ,@fields       VARCHAR(4000)  = NULL         -- for XL: comma separated list
   ,@clr_first    BIT            = 1            -- if 1 then delete the table contents first
   ,@is_new       BIT            = 0            -- if 1 then create the table - this is a double check
   ,@first_row    INT            = NULL
   ,@last_row     INT            = NULL
   ,@expect_rows  BIT            = 1            -- optional @expect_rows to assert has imported rows
   ,@row_cnt      INT            = NULL OUT     -- optional count of imported rows
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
    @fn              VARCHAR(35)= N'sp_import_file'
   ,@bckslsh         VARCHAR(1) = NCHAR(92)
   ,@tab             VARCHAR(1) = NCHAR(9)
   ,@nl              VARCHAR(2) = NCHAR(13) + NCHAR(10)
   ,@ndx             INT
   ,@file_name       VARCHAR(128)
   ,@table_exists    BIT
   ,@is_xl_file      BIT
   ,@txt_file_ty     BIT -- 0:txt, 1: tsv
   ,@msg             VARCHAR(500)
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
first_row     [', @first_row,']
last_row      [', @last_row,']
';
   BEGIN TRY
      EXEC sp_log 1, @fn, '005: initial checks';
      EXEC sp_log 0, @fn, '010: checking POST01';
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
         SET @import_file = CONCAT(@import_root, @bckslsh, @import_file);
         EXEC sp_log 1, @fn, '010: ,
modified import_file:  [', @import_file,']';
      END
      ----------------------------------------------------------------------------------------------------------
   -- POST02: @import file must exist  OR exception 63241, 'import_file must exist'
      ----------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '025: checking POST02';
      IF dbo.fnFileExists(@import_file) <> 1
      BEGIN
         EXEC sp_log 1, @fn, '030: checking POST02'
         SET @msg = CONCAT('import file [',@import_file,'] must exist');
         EXEC sp_log 4, @fn, '040 ',@msg;
         THROW 63241, @msg, 1;
      END
      EXEC sp_log 1, @fn, '050';
      SET @is_xl_file = IIF( CHARINDEX('.xlsx', @import_file) > 0, 1, 0);
      ----------------------------------------------------------------------------------------------------------
      -- Handle defaults
      ----------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '060: handle defaults';
      IF @range     IS NULL SET @range =  N'Sheet1$';
      IF @clr_first IS NULL SET @clr_first = 1;
      IF @table IS NULL
      BEGIN
         EXEC sp_log 1, @fn, '070: @table not specified so getting table';
         IF @is_xl_file = 1
         BEGIN
            ----------------------------------------------------------------------------------------------------------
            -- POST06: @table: if xl import then @table must be specified or deducable from the sheet name or file name OR exception 63245
            ----------------------------------------------------------------------------------------------------------
            EXEC sp_log 1, @fn, '080: is an XL import, @range:[',@range,']';
            IF SUBSTRING(@range, 1, 7)<> 'Sheet1$'
            BEGIN
               SET @ndx   = CHARINDEX('$', @range);
               SET @table = SUBSTRING(@range, 1, @ndx-1);
               EXEC sp_log 1, @fn, '083: range is not Sheet1$, table: [',@table,']';
            END
            ELSE
            BEGIN
               IF @ndx = 1 SET @ndx = dbo.fnLen(@range);
               SET @table = dbo.fnGetFileNameFromPath(@import_file,0);
               EXEC sp_log 1, @fn, '083: range is Sheet1$, table: [',@table,']';
            END
         END
         ELSE
         BEGIN
             EXEC sp_log 1, @fn, '090: is text import';
           ----------------------------------------------------------------------------------------------------------
            -- POST07: @table: if a tsv then must specify table or the file name is the table
            ----------------------------------------------------------------------------------------------------------
            SET @table = dbo.fnGetFileNameFromPath(@import_file,0);
         END
         EXEC sp_log 1, @fn, '100: chk table exists';
         IF dbo.fnTableExists(@table)=0
         BEGIN
            EXEC sp_log 1, @fn, '110: deduced table name:[', @table,'] does not exist, setting @table NULL';
            SET @table = NULL;
         END
         EXEC sp_log 1, @fn, '120: deduced table name:[', @table,']';
      END
      EXEC sp_log 1, @fn, '130: table:[', @table,']';
      SET @table_exists = iif( @table IS NOT NULL AND dbo.fnTableExists(@table)<>0, 1, 0);
      ----------------------------------------------------------------------------------------------------------
      -- RULE03: @view:  if a tsv file then if the view is not specified then it is set as Import<table>_vw
      ----------------------------------------------------------------------------------------------------------
      IF @view IS NULL AND @table_exists = 1  AND @is_xl_file = 0 
      BEGIN
         SET @view = CONCAT('Import_',@table,'_vw');
         EXEC sp_log 1, @fn, '140: if a tsv file and the view is not specified then set view default value as Import_<table>_vw: [',@view,']'
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
      EXEC sp_log 1, @fn, '150: checking rule 5,11';
      IF @fields IS NULL
      BEGIN
         IF @is_xl_file = 1
         BEGIN
            EXEC sp_get_flds_frm_hdr_xl @import_file, @range=@range, @fields=@fields OUT;
            EXEC sp_log 1, @fn, '160: is xl file and the fields are not specified then defaulting @fields to: [',@fields,']'
         END
         ELSE
         BEGIN
            EXEC sp_log 1, @fn, '170: calling sp_get_flds_frm_hdr_txt';
            EXEC sp_get_flds_frm_hdr_txt
                @file            = @import_file
               ,@fields          = @fields OUT
               ,@display_tables   = 0
               ,@file_type        = @txt_file_ty OUT -- 0:txt, 1: tsv
               ;
            EXEC sp_log 1, @fn, '180: ret frm sp_get_flds_frm_hdr_txt';
            -- try by name
            IF @field_sep IS NULL
               SET @field_sep = iif(@txt_file_ty=0, 'txt','tsv');
         END
      END
      EXEC sp_log 1, @fn, '190';
      --------------------------------------------------------------------------------------------------------------------
   -- POST03: if @is_new is false then (table must exist OR exception 63242, 'table must exist if @is_new is false')
      --------------------------------------------------------------------------------------------------------------------
      IF @is_new = 0 AND @table_exists = 0
      BEGIN
         SET @msg = 'table must exist if @is_new is false';
         EXEC sp_log 4, @fn, '200 ',@msg;
         THROW 63244, @msg, 1;
      END
      EXEC sp_log 1, @fn, '210';
      -----------------------------------------------------------------------------------------------------------------
   -- POST04: if @is_new is true then (table does not exist  OR ex 63243, 'table must not exist if @is_new is true'))
      -----------------------------------------------------------------------------------------------------------------
      IF @is_new = 1 AND @table_exists = 1
      BEGIN
         SET @msg = 'table must not exist if @is_new is true';
         EXEC sp_log 4, @fn, '220 ',@msg;
         THROW 63243, @msg, 1;
      END
      --****************************************
      -- Import the file
      --****************************************
      EXEC sp_log 1, @fn, '230: Importing file';
      IF @is_xl_file = 1
      BEGIN
         ----------------------------------------------------------------------------------------------------------
         -- Import Excel file
         ----------------------------------------------------------------------------------------------------------
         -- Parameter Validation
         EXEC sp_log 1, @fn, '240: Importing Excel file, fixup the range:',@range,'|';
         -- Fixup the range
         SET @range = dbo.fnFixupXlRange(@range);
         EXEC sp_log 1, @fn, '250: Importing Excel file, fixed up the range:',@range,'|';
         ----------------------------------------------------------------------------------------------------------
         -- RULE05: @fields:if an Excel file then @fields is optional
         --          if not specified then it is taken from the excel header (first row)
         -- RULE07: @is_new: if new table and if an Excel file and @fields is null 
         --         then the table is created with fields taken from the spreadsheet header
         ----------------------------------------------------------------------------------------------------------
         --EXEC sp_log 1, @fn, '085: calling sp_get_fields_from_xl_hdr';
         --EXEC sp_get_fields_from_xl_hdr @import_file, @range, @fields OUT;
         --EXEC sp_log 1, @fn, '087: ret frm sp_get_fields_from_xl_hdr';
         IF @is_new = 1
         BEGIN
            ----------------------------------------------------------------------------------------------------------
            -- Importing Excel file to new table
            ----------------------------------------------------------------------------------------------------------
            EXEC sp_log 1, @fn, '260: Importing Excel file to new table';
            EXEC sp_import_XL_new @import_file, @range, @table, @fields, @row_cnt=@row_cnt OUT;
         END
         ELSE
         BEGIN
            ----------------------------------------------------------------------------------------------------------
            -- Importing Excel file to existing table @range,
            ----------------------------------------------------------------------------------------------------------
            EXEC sp_log 1, @fn, '270: Importing Excel file to existing table';
            EXEC sp_import_XL_existing @import_file,  @table, @clr_first, @fields, @end_row=@first_row/*,@last_row=@last_row*/, @row_cnt=@row_cnt OUT;
            EXEC sp_log 1, @fn, '280:';
         END
         EXEC sp_log 1, @fn, '290: Imported Excel file';
      END
      ELSE
      BEGIN
         ----------------------------------------------------------------------------------------------------------
         -- Importing txt file
         ----------------------------------------------------------------------------------------------------------
         EXEC sp_log 1, @fn, '300: Importing tsv file';
         ----------------------------------------------------------------------------------------------------------
         -- POST12: @is_new: if this is set then the table is created with fields based on the spreadsheet header
         ----------------------------------------------------------------------------------------------------------
         --EXEC sp_bulk_import_tsv @import_file, @view, @table, @clr_first, @first_row=@first_row,@last_row=@last_row, @row_cnt=@row_cnt OUT;
         EXEC sp_import_txt_file
             @table           = @table
            ,@file            = @import_file
            ,@field_terminator= @field_sep
            ,@row_terminator  = N'\r\n'
            ,@first_row       = @first_row
            ,@last_row        = @last_row
            ,@clr_first       = @clr_first
            ,@view            = @view
            ,@format_file     = NULL
            ,@expect_rows     = 1
            ,@exp_row_cnt     = NULL
            ,@non_null_flds   = NULL
            ,@display_table   = 0
            ,@row_cnt         = @row_cnt OUT
      END
      ----------------------------------------------------------------------------------------------------------
      -- Checking post conditions
      ----------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '310: Checking post conditions'
      IF @expect_rows = 1
         EXEC sp_assert_tbl_pop @table;
      ---------------------------------------------------------------------
      -- Completed processing OK
      ---------------------------------------------------------------------
      EXEC sp_log 1, @fn, '320: Completed processing OK'
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      EXEC sp_log 1, @fn, '520: parameters:
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
      EXEC sp_log 1, @fn, '530: state:
   @table_exists:  [', @table_exists,']
   @is_xl_file     [', @is_xl_file,']';
      THROW;
   END CATCH
   EXEC sp_log 1, @fn, '999: leaving OK, imported ',@row_cnt,' rows to the ',@table,'  table from ',@import_file;
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_085_sp_bulk_import';
EXEC test.test_085_sp_import_file;
*/
GO

