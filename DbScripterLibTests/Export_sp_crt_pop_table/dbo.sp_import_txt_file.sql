SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================================================================================
-- Author:      Terry Watts
-- Create date: 20-OCT-2024
-- Description: Imports a txt file into @table
-- Returns the count of rows imported
-- Design: EA?
-- Responsibilities:
-- R00: delete the log files beefore importing if they exist
-- R01: Import the table from the tsv file
-- R02: Remove double quotes
-- R03: Trim leading/trailing whitespace
-- R04: Remove in-field line feeds
-- R05: check the list of @non_null_flds fields do not have any nulls - if @non_null_flds supplied
--
-- Tests: test_037_sp_import_txt_file
--
-- Preconditions:
-- PRE01: File must be specified: chkd
-- PRE02: Filpath must exist : chkd
--
-- Postconditions:
-- POST01 ret: the count of rows imported
--
-- Changes:
-- 20-OCT-2024: increased @spreadsheet_file parameter len from 60 to 500 as the file path was being truncated
-- 31-OCT-2024: cleans each imported text field for double quotes and leading/trailing white space
-- 05-NOV-2024: optionally display imported table: sometimes we need to do more fixup before data is ready
--              so when this is the case then dont display the table here, but do post import fixup in the 
--              calling sp first and then display the table
-- 11-NOV-2024: added an optional view to control field mapping
-- 06-APR-2025  @table may be qualified with the schema - sort out bracketing
-- =============================================================================================================
CREATE PROCEDURE [dbo].[sp_import_txt_file]
    @table            VARCHAR(60)
   ,@file             VARCHAR(500)
   ,@folder           VARCHAR(600)  = NULL
   ,@field_terminator VARCHAR(4)    = NULL -- tab 0x09
   ,@row_terminator   VARCHAR(10)   = NULL -- '0x0d0a'
   ,@codepage         INT           = 65001 -- Claude: Note that if your text file has a BOM (Byte Order Mark), SQL Server should automatically detect it when using codepage 65001.
   ,@first_row        INT           = 2
   ,@last_row         INT           = NULL
   ,@clr_first        BIT           = 1
   ,@view             VARCHAR(120)  = NULL
   ,@format_file      VARCHAR(500)  = NULL
   ,@expect_rows      BIT           = 1
   ,@exp_row_cnt      INT           = NULL
   ,@non_null_flds    VARCHAR(1000) = NULL
   ,@display_table    BIT           = 0
AS
BEGIN
   DECLARE
    @fn                 VARCHAR(35)       = N'sp_import_txt_file'
   ,@cmd                NVARCHAR(MAX)
   ,@sql                VARCHAR(MAX)
   ,@CR                 CHAR(1)           = CHAR(13)
   ,@LF                 CHAR(2)           = CHAR(10)
   ,@NL                 CHAR(2)           = CHAR(13)+CHAR(10)
   ,@line_feed          CHAR(1)           = CHAR(10)
   ,@bkslsh             CHAR(1)           = CHAR(92)
   ,@tab                CHAR(1)           = CHAR(9)
   ,@max_len_fld        INT
   ,@del_file           VARCHAR(1000)
   ,@error_file         VARCHAR(1000)
   ,@ndx                INT = 1
   ,@end                INT
   ,@line               VARCHAR(128) = REPLICATE('-', 100)
   ,@file_path          VARCHAR(600)
   ,@row_cnt            INT
   ,@schema_nm          VARCHAR(28)
   ,@table_nm           VARCHAR(40)
   ,@table_nm_no_brkts  VARCHAR(40)
   ,@ex_num             INT
   ,@ex_msg             INT
   ;

   --SET @row_terminator_str = iif(@row_terminator='0x0d0a', '0x0d0a',@row_terminator);

   EXEC sp_log 1, @fn, '000: starting:
table           :[',@table             ,']
file            :[',@file              ,']
folder          :[',@folder            ,']
row_terminator  :[',@row_terminator    ,']
field_terminator:[',@field_terminator  ,']
first_row       :[',@first_row         ,']
last_row        :[',@last_row          ,']
clr_first       :[',@clr_first         ,']
view            :[',@view              ,']
format_file     :[',@format_file       ,']
expect_rows     :[',@expect_rows       ,']
exp_row_cnt     :[',@exp_row_cnt       ,']
non_null_flds   :[',@non_null_flds     ,']
display_table   :[',@display_table     ,']'
;

   BEGIN TRY
      ---------------------------------------------------
      -- Set defaults
      ---------------------------------------------------
      IF @field_terminator IS NULL SET @field_terminator = @tab;
      IF @field_terminator IN (0x09, '0x09', '\t') SET @field_terminator = @tab;

      --IF @field_terminator NOT IN ( @tab,',',@CR, @LF, @NL)
      --   EXEC sp_raise_exception 53051, @fn, '005: error: field terminator must be one of comma, tab, NL';

      IF @row_terminator   IS NULL OR @row_terminator='' SET @row_terminator = @nl;

      ---------------------------------------------------
      -- Validate parameters
      ---------------------------------------------------
      EXEC sp_log 1, @fn, '010: Validate parameters';

      -- PRE01: File must be specified
      EXEC sp_assert_not_null_or_empty @file, 50001, 'File must be specified';
      ---------------------------------------------------
      -- Set defaults
      ---------------------------------------------------
      EXEC sp_log 1, @fn, '020: Set defaults';

      IF @codepage IS NULL SET @codepage = 1252;

      SET @file_path = iif( @folder IS NOT NULL,  CONCAT(@folder, @bkslsh, @file), @file);

      -- sort out double \\
      SET @file_path = REPLACE(@file_path, @bkslsh+@bkslsh, @bkslsh);

      -- ASSERTION 

      -- 06-APR-2025  @table may be qualified with the schema - sort out bracketing
      SET @ndx = CHARINDEX('.', @table);

      IF @ndx>0
      BEGIN
         SELECT
             @schema_nm = schema_nm
            ,@table_nm  = rtn_nm
         FROM dbo.fnSplitQualifiedName(@table);

         SET @table = CONCAT('[',@schema_nm,'].[',@table_nm, ']');
      END
      ELSE
      BEGIN
         SET @table = CONCAT('[',@table, ']');
      END

      SET @table_nm_no_brkts = REPLACE(REPLACE(@table, '[', ''),']', '');
      EXEC sp_log 1, @fn, '030: table:',@table, ' @table_nm_no_brkts: ', @table_nm_no_brkts;

      ---------------------------------------------------
      -- Validate inputs
      ---------------------------------------------------
      EXEC sp_log 1, @fn, '040: validating inputs, @file_path: [',@file_path,']';

      -- PRE02: Filpath must exist : chkd
      EXEC sp_assert_file_exists @file_path
      -------------------------------------------------------------
      -- ASSERTION: @table is now like [table] or [schema].[table]
      -------------------------------------------------------------

      IF @table IS NULL OR @table =''
         EXEC sp_raise_exception 53050, @fn, '050: error: table must be specified';

      IF @first_row IS NULL OR @first_row < 1
         SET @first_row = 2;

      IF @last_row IS NULL OR @last_row < 1
         SET @last_row = 1000000;

      -- View is optional - defaults to the table stru
      IF @view IS NULL
         SET @view = @table;

      IF @clr_first = 1
      BEGIN
         SET @cmd = CONCAT('TRUNCATE TABLE ', @table,';');
         EXEC sp_log 1, @fn, '060: clearing table first: EXEC SQL:',@NL, @cmd;

         EXEC (@cmd);
      END

      ----------------------------------------------------------------------------------
      -- R00: delete the log files before importing if they exist
      ----------------------------------------------------------------------------------

      SET @error_file = CONCAT('D:',NCHAR(92),'logs',NCHAR(92),@table_nm_no_brkts,'import.log');
      SET @del_file = @error_file;
      EXEC sp_log 1, @fn, '070: deleting log file ', @del_file;
      EXEC sp_delete_file @del_file;
      SET @del_file = CONCAT(@del_file, '.Error.Txt');
      EXEC sp_log 1, @fn, '080: deleting log file ',@del_file;
      EXEC sp_delete_file @del_file;

      ----------------------------------------------------------------------------------
      -- R01: Import the table from the tsv file
      ----------------------------------------------------------------------------------

      SET @cmd = 
         CONCAT('BULK INSERT ',@view,' FROM ''',@file_path,''' 
WITH
(
    DATAFILETYPE    = ''Char''
   ,FIRSTROW        = ',@first_row, @nl
);

      IF @last_row         IS NOT NULL 
      BEGIN
         EXEC sp_log 1, @fn, '090: @last_row is not null, =[',@last_row, ']';
         SET @cmd = CONCAT( @cmd, '   ,LASTROW        =   ', @last_row        , @nl);
      END

      IF @format_file      IS NOT NULL
      BEGIN
         EXEC sp_log 1, @fn, '100: @last_row is not null, =[',@last_row, ']';
         SET @cmd = CONCAT( @cmd, '   ,FORMATFILE     = ''', @format_file, '''', @nl);
      END

      IF @field_terminator IS NOT NULL
      BEGIN
         EXEC sp_log 1, @fn, '110: @field_terminator is not null, =[',@field_terminator, ']';
         If @field_terminator = 't' SET @field_terminator = '\t';
         SET @cmd = CONCAT( @cmd, '   ,FIELDTERMINATOR= ''', @field_terminator, '''', @nl);
      END

      if @row_terminator IS NOT NULL
      BEGIN
         EXEC sp_log 1, @fn, '120: @row_terminator is not null, =[',@row_terminator, ']';
         SET @cmd = CONCAT( @cmd, '   ,ROWTERMINATOR= ''', @row_terminator, '''', @nl);
      END

      SET @cmd = CONCAT( @cmd, '  ,ERRORFILE      = ''',@error_file,'''', @nl
         ,'  ,MAXERRORS      = 20', @nl
         ,'  ,CODEPAGE       = ',@codepage, @nl
         ,');'
      );

      PRINT CONCAT( @nl, @line);
      EXEC sp_log 1, @fn, '130: importing file: SQL: 
', @cmd;

      PRINT CONCAT( @line, @nl);

      EXEC (@cmd);
      SET @row_cnt = @@ROWCOUNT;

      EXEC sp_log 1, @fn, '140: imported ', @row_cnt, ' rows';

      ----------------------------------------------------------------------------------------------------
      -- 05-NOV-2024: optionally display imported table
      ----------------------------------------------------------------------------------------------------
      IF @display_table = 1
      BEGIN
         EXEC sp_log 1, @fn, '150: displaying table: ', @table;
         SET @cmd = CONCAT('SELECT * FROM ', @table,';');
         EXEC (@cmd);
      END

      IF @expect_rows = 1
      BEGIN
         EXEC sp_log 1, @fn, '160: checking resulting row count';
         EXEC sp_assert_tbl_pop @table;
      END

      IF  @exp_row_cnt IS NOT NULL
      BEGIN
         EXEC sp_log 1, @fn, '170: checking resulting row count';
         EXEC sp_assert_tbl_pop @table, @exp_cnt = @exp_row_cnt;
      END

      ----------------------------------------------------------------------------------------------------
      -- 31-OCT-2024: cleans each imported text field for double quotes and leading/trailing white space
      ----------------------------------------------------------------------------------------------------
      SET @cmd = CONCAT('SELECT @max_len_fld = MAX(dbo.fnLen(column_name)) FROM list_table_columns_vw WHERE table_name = ''', @table, ''' AND is_txt = 1;');
      EXEC sp_log 1, @fn, '180: getting max field len: @cmd:', @cmd;
      EXEC sp_executesql @cmd, N'@max_len_fld INT OUT', @max_len_fld OUT;
      EXEC sp_log 1, @fn, '190: @max_len_fld: '       , @max_len_fld;
      EXEC sp_log 1, @fn, '200: @table_nm_no_brkts: ' , @table_nm_no_brkts;
      EXEC sp_log 1, @fn, '210: @table            : ' , @table ;

      ----------------------------------------------------------------------------------
      -- R02: Remove double quotes
      -- R03: Trim leading/trailing whitespace
      -- R04: Remove line feeds
      ----------------------------------------------------------------------------------
      SET @sql = dbo.fnCrtRemoveDoubleQuotesSql( @table_nm_no_brkts, @max_len_fld);
      PRINT @sql;
      EXEC sp_log 1, @fn, '220: trim replacing double quotes, @sql:', @NL, @sql;
      EXEC (@sql);

     ----------------------------------------------------------------------------------------------------
      -- R05: check the list of @non_null_flds fields do not have any nulls - if @non_null_flds supplied
      ----------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '230: check mandatory fields for null values';
      EXEC sp_chk_flds_not_null @table_nm_no_brkts, @non_null_flds ;
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;--, ' launching notepad++ to display the error files';
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ',@row_cnt,' rows from: ', @file_path;
   -- POST01 ret: the count of rows imported
   RETURN @row_cnt;
END
/*
EXEC test.test_037_sp_import_txt_file;
EXEC tSQLt.Run 'test.test_037_sp_import_txt_file';
EXEC sp_AppLog_display

EXEC tSQLt.RunAll;
*/


GO
