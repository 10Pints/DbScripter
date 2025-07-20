SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =====================================================================================
-- Author:      Terry Watts
-- Create date: 12-JUN-2025
-- Description: Create and populate a table from a data file
-- 
-- Design:      EA: Model.Use Case Model.Create and populate a table from a data file
-- Define the import data file path
-- Table name = file name
-- Reads the header for the column names
-- Create a table with table name, columns = field names, type = text
-- Create a staging table 
-- Create a format file using BCP and the table
-- Generate the import routine using the table and the format file
--
-- Parameters:
--    @file_path     VARCHAR(500) -- the import data file path
-- Tests:       test_068_sp_crt_pop_table
--
-- Preconditions:
-- PRE01: @file_path populated
--
-- Postconditions:
-- POST01:  main table has the same row cnt as the  staging
-- =====================================================================================
CREATE PROCEDURE [dbo].[sp_crt_pop_table]
    @file_path       VARCHAR(500) -- the import data file path
   ,@sep             VARCHAR(6)  = NULL
   ,@codepage        INT         = 65001
   ,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;

   DECLARE
       @fn           VARCHAR(35)   = N'sp_crt_pop_table'
      ,@fields       VARCHAR(8000)
      ,@file         VARCHAR(500)
      ,@folder       VARCHAR(500)= NULL
      ,@format_file  VARCHAR(500)= NULL
      ,@NL           CHAR = CHAR(13)
      ,@tab          CHAR = CHAR(9)
      ,@ndx          INT
      ,@table_nm     VARCHAR(50)
      ,@stg_table_nm VARCHAR(50)
      ,@row_cnt      INT
      ,@cmd          VARCHAR(8000)
      ,@sql          VARCHAR(8000)

   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting:
@file_path:       [',@file_path,']
@sep:             [',@sep,']
@codepage:        [',@codepage,']
@display_tables:  [',@display_tables,']
';

      ---------------------------------------------------------------
      -- Setup
      ---------------------------------------------------------------

      IF @sep IS NULL OR @sep IN('',0x09,'0x09', '\t') SET @sep = @tab; -- default
      SET @ndx = dbo.fnFindLastIndexOf('\', @file_path);
      -- Table name = file name less the extension
      SET @file   = SUBSTRING(@file_path, @ndx+2, dbo.fnLen(@file_path)-@ndx);
      SET @folder = iif(@ndx = 0, NULL, SUBSTRING(@file_path, 1, @ndx));
      SELECT @table_nm = a FROM dbo.fnSplitPair2(@file, '.');

      EXEC sp_log 1, @fn, '010:
@ndx:     [', @ndx     , ']
@file:    [', @file    , ']
@table_nm:[', @table_nm, ']
@folder:  [', @folder  , ']
';
      -- Table name = file name  less the extension
      -- Import the header into a single column generic text table
      -- Reads the header for the column names
      -- Read the header for the column names
         EXEC sp_log 1, @fn, '020: importing the file header for the column names';
         EXEC @row_cnt = sp_import_txt_file
             @table           = 'GenericStaging'
            ,@file            = @file
            ,@folder          = @folder
            ,@first_row       = 1
            ,@last_row        = 1
            ,@field_terminator= @NL
            ,@view            = 'ImportGenericStaging_vw'
            ,@codepage        = @codepage
            ,@display_table   = 1
         ;

      -- Create the staging table,  columns = field names, type = text
      -- Create a staging table
      SET @stg_table_nm = CONCAT(@table_nm, 'Staging');
      EXEC sp_drop_table @stg_table_nm;

      -- Create a table with table name, columns = field names, type = text
      EXEC sp_log 1, @fn, '030: creating the staging table, cmd: ', @NL, @cmd;
      SELECT @fields = staging FROM GenericStaging;
      EXEC sp_log 1, @fn, '040: @fields: ', @fields, ' @stg_table_nm: ',@stg_table_nm;

      SET @cmd = dbo.fnCrtTblSql(@stg_table_nm, @fields); -- delimits the qualified @stg_table_nm if necessary
      EXEC sp_log 1, @fn, '050: executing @cmd: ', @cmd;
      EXEC (@cmd);
      -- Bracket table name as necessary
      -- Bracket field names as necessary
      -- Create a format file using BCP and the table
      --SET @cmd = dbo.fnCrtTblSql(@table_nm, @fields);
      --EXEC sp_log 1, @fn, '060: creating the main table, sql: ', @NL, @cmd;
      --EXEC (@cmd);

   -- Create and populate the table from data file : Create and populate a table from a data file_ActivityGraph
   -- Infer the field types from the staged data
   -- Merge the staging table to the main table

      -- Create a format file using BCP and the table
      SET @format_file = CONCAT(@folder, '\',@table_nm,'_fmt.xml');
      --SET @cmd = CONCAT('bcp ',DB_NAME(),'.dbo.',@table_nm,' format nul -c -x -f ',@format_file, ' -t, -T');
      SET @cmd = 
         CONCAT
         (
            'bcp '
           ,DB_NAME()
           ,'.dbo.',@table_nm
           ,' format nul -c -x -f ',@format_file
           ,iif(@sep=@tab, '', ' -t, '),' -T'
         );

      EXEC sp_log 1, @fn, '060: creating format file: ', @NL, @cmd;
      EXEC xp_cmdshell @cmd;

      -- Import the staging table data
      -- Import staging table using the table and the format file
      EXEC sp_log 1, @fn, '070: importing ', @file_path, ' to staging: ', @stg_table_nm;

      EXEC @row_cnt = sp_import_txt_file
          @table            = @stg_table_nm
         ,@file             = @file_path
         ,@folder           = NULL
         ,@field_terminator = @sep
         ,@codepage         = @codepage
         ,@first_row        = 2
         ,@format_file      = @format_file
         ,@display_table    = @display_tables
      ;

      -- Infer the field types from the staged data
      EXEC sp_log 1, @fn, '080: Infer the field types from the staged data';

      -- Infer field types: pops the FieldInfo table
      EXEC sp_infer_field_types @stg_table_nm;
      EXEC sp_log 1, @fn, '090: Drop the main  if it exists';

      -- Drop table if it exists
      EXEC sp_drop_table @table_nm;

      -- Create the main table with table name, columns = field names, type = inferred type
      EXEC sp_log 1, @fn, '100: Create the main table with table name, columns = field names, type = inferred type';

      SELECT @sql = 
      CONCAT
      (
      'CREATE TABLE ', @table_nm, '
(
'
,STRING_AGG(CONCAT('   ', lower(nm), ' ', ty), ',
'
),'
);'
      )
      FROM FieldInfo
      ;

      EXEC sp_log 1, @fn, '110: Creating the main table, sql:
', @sql;

      EXEC(@sql);

      -- Migrating the staging data to the main table
      SET @sql = CONCAT('INSERT INTO ', @table_nm,' SELECT * FROM ',@stg_table_nm,';')
      EXEC sp_log 1, @fn, '120: Migrating the staging data to the main table, @sql:
', @sql;

      EXEC(@sql);

      SELECT @table_nm as [main table];
      SET @sql = CONCAT('SELECT * FROM ',@table_nm,';')
      EXEC sp_log 1, @fn, '130: displaying the main table';
      EXEC(@sql);

      -- POST: chk main table has the correct row cnt
      EXEC sp_assert_tbl_pop @table_nm, @exp_cnt = @row_cnt;
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: Caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: completed processing imnported ',@row_cnt, ' rows';
   RETURN @row_cnt;
END
/*
EXEC test.test_068_sp_crt_pop_table;

EXEC tSQLt.Run 'test.test_068_sp_crt_pop_table';
EXEC sp_AppLog_display 'sp_crt_pop_table';

EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<proc_nm>';
EXEC test.sp__crt_tst_rtns 'dbo.sp_crt_pop_table'
*/

GO
