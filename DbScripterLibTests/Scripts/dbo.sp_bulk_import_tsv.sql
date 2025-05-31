SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ================================================================
-- Author:      Terry Watts
-- Create date: 25-FEB-2024
-- Description: imports a tsv file using a view
--
-- POSTCONDITIONS:
-- POST 01: if @clr_first is set then the table must be specified or EXCEPTION 62250, 'able must be specified if @clr_first is set'
--
-- Changes:
-- 07-MAR-2024  returns the count of imported rows in the @row_cnt out param
-- ================================================================
ALTER PROCEDURE [dbo].[sp_bulk_import_tsv]
    @tsv_file     NVARCHAR(MAX)
   ,@view         NVARCHAR(120)
   ,@table        NVARCHAR(60)   = NULL --POST 01: if @clr_first is set then the table must be specified or EXCEPTION 62250, 'able must be specified if @clr_first is set'
   ,@clr_first    BIT            = 1 -- if 1 then delete the table contents first
   ,@row_cnt      INT            = NULL OUT     -- optional count of imported rows
   ,@expect_rows  BIT            = 1 -- assert rows were imported if this flag is set
AS
BEGIN
   DECLARE
       @fn     NVARCHAR(35)   = N'BLK_IMPRT_TSV'
      ,@cmd    NVARCHAR(MAX)

   EXEC sp_log 1, @fn, '000: starting, 
@tsv_file: [',@tsv_file,']
@view:     [',@view,']
@table:    [',@table,']
@clr_first [',clr_first,']
';

   IF @clr_first = 1
   BEGIN
      EXEC sp_log 1, @fn, '005: deleting table [',@table,'] rows';
      -- POST 01: if @clr_first is set then the table must be specified or EXCEPTION 62250, 'table must be specified if @clr_first is set'
      IF dbo.fnTableExists(@table) = 0
      BEGIN
         EXEC Ut.dbo.sp_assert_not_null_or_empty @table;
         EXEC sp_log 4, @fn, '006: table [',@table,'] does not exist';
         THROW 62250, 'table must exist if @clr_first is set',1;
      END

      SET @cmd = CONCAT('DELETE FROM [', @table,']');
      PRINT @cmd;
      EXEC( @cmd)
   END

   EXEC sp_log 1, @fn, '010: deleting bulk import logs';
   SET @cmd = CONCAT('EXEC xp_cmdshell ''DEL D:\Logs\', @view,'.log.Error.Txt'', NO_OUTPUT;');
   EXEC sp_log 1, @fn, @cmd;
   EXEC sp_executesql @cmd;

   SET @cmd = CONCAT('EXEC xp_cmdshell ''DEL D:\Logs\', @view,'.log''          , NO_OUTPUT;');
   EXEC sp_log 1, @fn, @cmd;
   EXEC sp_executesql @cmd;

   SET @cmd = CONCAT(
      'BULK INSERT [',@view,'] FROM ''', @tsv_file, '''
      WITH
      (
         FIRSTROW        = 2
        ,ERRORFILE       = ''D:\Logs\',@view,'Import.log''
        ,FIELDTERMINATOR = ''\t''
        ,ROWTERMINATOR   = ''\n''
      );
   ');

   EXEC sp_log 1, @fn, '015: importig tsv file';
   EXEC sp_log 1, @fn, @cmd;
   EXEC sp_executesql @cmd;
   SET @row_cnt = @@ROWCOUNT;

   IF @expect_rows = 1
      EXEC ut.dbo.sp_assert_not_equal 0, @row_cnt, 'no rows were imported'

   EXEC sp_log 1, @fn, '99: leaving, OK, imported ',@row_cnt,' rows from file: ',@tsv_file;
END


GO
