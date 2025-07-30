SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================
-- Author:      Terry Watts
-- Create date: 25-FEB-2024
-- Description: imports a tsv file using a view
--
-- POSTCONDITIONS:
-- POST 01: if @clr_first is set then the table must be specified or EXCEPTION 62250, 'table must be specified if @clr_first is set'
--
-- ================================================================
CREATE PROCEDURE [dbo].[sp_import_tsv]
    @tsv_file  NVARCHAR(MAX)
   ,@view      NVARCHAR(120)
   ,@table     NVARCHAR(60)   = NULL --POST 01: if @clr_first is set then the table must be specified or EXCEPTION 62250, 'able must be specified if @clr_first is set'
   ,@clr_first    BIT        = 1 -- if 1 then delete the table contents first
AS
BEGIN
   DECLARE
       @fn     NVARCHAR(35)   = N'BLK_IMPRT_TSV'
      ,@cmd    NVARCHAR(MAX)
   EXEC sp_log 1, @fn, '00: starting, 
@tsv_file: [',@tsv_file,']
@view:     [',@view,']
@table:    [',@table,']
@clr_first [',clr_first,']'
;
   IF @clr_first = 1
   BEGIN
      -- POST 01: if @clr_first is set then the table must be specified or EXCEPTION 62250, 'table must be specified if @clr_first is set'
      EXEC sp_assert_table_exists @table;
      SET @cmd = CONCAT('DELETE FROM [', @table,']');
      PRINT @cmd;
      EXEC( @cmd)
   END
   SET @cmd = CONCAT('EXEC xp_cmdshell ''DEL D:\Logs',NCHAR(92), @view,'.log.Error.Txt'', NO_OUTPUT;');
   EXEC sp_log 1, @fn, @cmd;
   EXEC sp_executesql @cmd;
   SET @cmd = CONCAT('EXEC xp_cmdshell ''DEL D:\Logs',NCHAR(92), @view,'.log''          , NO_OUTPUT;');
   EXEC sp_log 1, @fn, @cmd;
   EXEC sp_executesql @cmd;
   SET @cmd = CONCAT(
      'BULK INSERT [',@view,'] FROM ''', @tsv_file, '''
      WITH
      (
         FIRSTROW        = 2
        ,ERRORFILE       = ''D:\Logs',NCHAR(92),@view,'Import.log''
        ,FIELDTERMINATOR = ''\t''
        ,ROWTERMINATOR   = ''\n''
      );
   ');
   EXEC sp_log 1, @fn, @cmd;
   EXEC sp_executesql @cmd;
   RETURN @cmd;
END
/*
EXEC tSQLt.RunAll;
*/
GO

