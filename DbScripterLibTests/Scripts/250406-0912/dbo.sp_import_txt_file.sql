SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================================================================================
-- Author:      Terry Watts
-- Create date: 20-OCT-2024
-- Description: Imports a tab separated txt file into @table
--
-- Responsibilities:
-- R00: delete the log files beefore importing if they exist
-- R01: Import the table from the tsv file
-- R02: Remove double quotes
-- R03: Trim leading/trailing whitespace
-- R04: Remove in-field line feeds
-- R05: check the list of @non_null_flds fields do not have any nulls - if @non_null_flds supplied
--
-- Changes:
-- 20-OCT-2024: increased @spreadsheet_file parameter len from 60 to 500 as the file path was being truncated
-- 31-OCT-2024: cleans each imported text field for double quotes and leading/trailing white space
-- 05-NOV-2024: optionally display imported table: sometimes we need to do more fixup before data is ready
--              so when this is the case then dont display the table here, but do post import fixup in the 
--              calling sp first and then display the table
-- 11-NOV-2024: added an optional view to control field mapping
-- =============================================================================================================
ALTER PROCEDURE [dbo].[sp_import_txt_file]
    @table            VARCHAR(60)
   ,@file             VARCHAR(500)
   ,@folder           VARCHAR(600)  = NULL
   ,@field_terminator VARCHAR(2)    = NULL -- N'\t'
   ,@row_terminator   NCHAR(4)      = NULL -- N'\r\n'
   ,@codepage         INT           = 1252 -- 1252 for utf-8-bom or 65001 for 8-bom especiall if Â character appears in imported text
   ,@first_row        INT           = 2
   ,@last_row         INT           = NULL
   ,@clr_first        BIT           = 1
   ,@view             VARCHAR(120)  = NULL
   ,@format_file      VARCHAR(500)  = NULL
   ,@expect_rows      BIT           = 1
   ,@exp_row_cnt      INT           = NULL
   ,@non_null_flds    VARCHAR(1000) = NULL
   ,@display_table    BIT           = 0
   ,@row_cnt          INT           = NULL OUT
AS
BEGIN
   DECLARE
    @fn           VARCHAR(35)       = N'sp_import_txt_file'
   ,@cmd          NVARCHAR(MAX)
   ,@sql          VARCHAR(MAX)
   ,@nl           CHAR(2)           = CHAR(13)+CHAR(10)
   ,@line_feed    CHAR(1)           = CHAR(10)
   ,@bkslsh       CHAR(1)           = CHAR(92)
   ,@tab          CHAR(1)           = CHAR(9)
   ,@max_len_fld  INT
   ,@del_file     VARCHAR(1000)
   ,@error_file   VARCHAR(1000)
   ,@ndx          INT = 1
   ,@end          INT
   ,@line         VARCHAR(128) = REPLICATE('-', 100)
   ,@ex_num       INT
   ,@ex_msg       INT
   ;

   EXEC sp_log 1, @fn, '000: starting:
table           :[',@table             ,']
file            :[',@file              ,']
folder          :[',@folder            ,']
field_terminator:[',@field_terminator  ,']
first_row       :[',@first_row         ,']
last_row        :[',@last_row          ,']
clr_first       :[',@clr_first         ,']
view            :[',@view              ,']
format_file     :[',@format_file       ,']
row_terminator  :[',@row_terminator    ,']
expect_rows     :[',@expect_rows       ,']
exp_row_cnt     :[',@exp_row_cnt       ,']
non_null_flds   :[',@non_null_flds     ,']
display_table   :[',@display_table     ,']'
;

   BEGIN TRY
      ---------------------------------------------------
      -- Validating inputs
      ---------------------------------------------------
      IF @folder IS NOT NULL
         SET @file = CONCAT(@folder, @bkslsh, @file);

      IF @table IS NULL OR @table =''
         EXEC sp_raise_exception 53050, @fn, '010: error: table must be specified';

      EXEC sp_assert_not_null_or_empty @file, @fn, '020: error: file must be specified'
      IF @field_terminator IS NULL SET @field_terminator = @tab;
      IF @field_terminator NOT IN ( @tab,',','t') EXEC sp_raise_exception 53051, @fn, '030: error: field terminator must be either comma or tab';
      IF @row_terminator IS NULL OR @row_terminator='' SET @row_terminator = @nl;

      IF @first_row IS NULL OR @first_row < 1
         SET @first_row = 2;

      IF @last_row IS NULL OR @last_row < 1
         SET @last_row = 1000000;

      -- View is optional - defaults to the table stru
      IF @view IS NULL
         SET @view = @table;

      IF @clr_first = 1
      BEGIN
         SET @cmd = CONCAT('TRUNCATE TABLE [', @table,'];');
         EXEC sp_log 1, @fn, '040: clearing table fist: SQL: 
   ', @cmd;

         EXEC (@cmd);
      END

      ----------------------------------------------------------------------------------
      -- R00: delete the log files beefore importing if they exist
      ----------------------------------------------------------------------------------

      SET @error_file = CONCAT('D:',NCHAR(92),'logs',NCHAR(92),@table,'import.log');
      SET @del_file = @error_file;
      EXEC sp_log 1, @fn, '050: deleting log file ', @del_file;
      EXEC sp_delete_file @del_file;
      SET @del_file = CONCAT(@del_file, '.Error.Txt');
      EXEC sp_log 1, @fn, '030: deleting log file ',@del_file;
      EXEC sp_delete_file @del_file;

      ----------------------------------------------------------------------------------
      -- R01: Import the table from the tsv file
      ----------------------------------------------------------------------------------

      SET @cmd = 
         CONCAT('BULK INSERT [',@view,'] FROM ''',@file,''' 
   WITH
   (
       DATAFILETYPE    = ''Char''
      ,FIRSTROW        = ',@first_row, @nl
               );

   IF @last_row         IS NOT NULL 
   BEGIN
      EXEC sp_log 1, @fn, '060: @last_row is not null, =[',@last_row, ']';
      SET @cmd = CONCAT( @cmd, '   ,LASTROW        =   ', @last_row        , @nl);
   END

   IF @format_file      IS NOT NULL
   BEGIN
      EXEC sp_log 1, @fn, '070: @last_row is not null, =[',@last_row, ']';
      SET @cmd = CONCAT( @cmd, '   ,FORMATFILE     = ''', @format_file     , @nl);
   END

   if @field_terminator IS NOT NULL
   BEGIN
      EXEC sp_log 1, @fn, '080: @field_terminator is not null, =[',@field_terminator, ']';
      If @field_terminator = 't' SET @field_terminator = '\t';
      SET @cmd = CONCAT( @cmd, '   ,FIELDTERMINATOR= ''', @field_terminator, '''', @nl);
   END

   SET @cmd = CONCAT( @cmd, '  ,ERRORFILE      = ''',@error_file,'''', @nl
      ,'  ,MAXERRORS      = 100', @nl
      ,'  ,CODEPAGE       = ',@codepage, @nl
      ,');'
   );

      PRINT CONCAT( @nl, @line);
      EXEC sp_log 1, @fn, '090: importing file: SQL: 
   ', @cmd;

      PRINT CONCAT( @line, @nl);

      EXEC (@cmd);
      SET @row_cnt = @@ROWCOUNT;

      EXEC sp_log 1, @fn, '100: imported ', @row_cnt, ' rows';

      IF @expect_rows = 1 OR @exp_row_cnt IS NOT NULL
      BEGIN
         EXEC sp_log 1, @fn, '110: importing file: SQL';
         EXEC sp_assert_tbl_pop @table, @exp_cnt = @exp_row_cnt;
      END

      ----------------------------------------------------------------------------------------------------
      -- 31-OCT-2024: cleans each imported text field for double quotes and leading/trailing white space
      ----------------------------------------------------------------------------------------------------
      SET @cmd = CONCAT('SELECT @max_len_fld = MAX(dbo.fnLen(column_name)) FROM list_table_columns_vw WHERE table_name = ''', @table, ''' AND is_txt = 1;');
      EXEC sp_log 1, @fn, '120: getting max field len: @cmd:', @cmd;
      EXEC sp_executesql @cmd, N'@max_len_fld INT OUT', @max_len_fld OUT;
      EXEC sp_log 1, @fn, '130: @max_len_fld: ', @max_len_fld;

      ----------------------------------------------------------------------------------
      -- R02: Remove double quotes
      -- R03: Trim leading/trailing whitespace
      -- R04: Remove line feeds
      ----------------------------------------------------------------------------------

      WITH cte AS
      (
         SELECT dbo.fnPadRight(CONCAT('[', column_name, ']'), @max_len_fld+2) AS column_name,ROW_NUMBER() OVER (ORDER BY ORDINAL_POSITION) AS row_num, ordinal_position, DATA_TYPE, is_txt
         FROM list_table_columns_vw 
         WHERE table_name = @table AND is_txt = 1
      )
      ,cte2 AS
      (
         SELECT CONCAT('UPDATE [',@table,'] SET ') AS sql
         UNION ALL
         SELECT CONCAT( iif(row_num=1, ' ',','), column_name, ' = TRIM(REPLACE(REPLACE(',column_name, ', ''"'',''''), NCHAR(10), ''''))') 
         FROM cte
         UNION ALL
         SELECT CONCAT('FROM [',@table,'];')
      )
      SELECT @sql = string_agg(sql, @NL) FROM cte2;

      EXEC sp_log 1, @fn, '140: trim replacing double quotes, @sql:', @NL, @sql;
      --EXEC sp_log 4, @fn, '145: debug RETURN ******';RETURN;
      EXEC (@sql);
      --EXEC sp_log 4, @fn, '145: debug RETURN ******'; RETURN;

      ----------------------------------------------------------------------------------------------------
      -- 05-NOV-2024: optionally display imported table
      ----------------------------------------------------------------------------------------------------
      IF @display_table = 1
      BEGIN
         SET @cmd = CONCAT('SELECT * FROM [', @table,'];');
         EXEC (@cmd);
      END

     ----------------------------------------------------------------------------------------------------
      -- R05: check the list of @non_null_flds fields do not have any nulls - if @non_null_flds supplied
      ----------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '150: check mandatory fields for null values';

      EXEC sp_chk_flds_not_null
          @table
         ,@non_null_flds
         ;
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;--, ' launching notepad++ to display the error files';
      --SET @cmd = CONCAT('EXEC xp_cmdshell ''notepad++ ', @error_file, '''');
      --EXEC (@cmd);
      --SET @cmd = CONCAT('EXEC xp_cmdshell ''notepad++ ', @error_file, '.Error.txt''');
      --EXEC (@cmd);
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ',@row_cnt,' rows from: ',@file;
END
/*
EXEC tSQLt.Run 'test.test_024_sp_import_txt_file';
EXEC test.test_069_ImportPathWikiUrlTax;

EXEC sp_import_txt_file 'PathogenStaging','D:\Dev\Farming\Data\Pathogen.txt';
SELECT * FROM PathogenStaging;
*/

GO
