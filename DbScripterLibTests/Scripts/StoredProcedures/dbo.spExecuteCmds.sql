SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =========================================================================
-- Procedure:   dbo.spExecuteCmds
-- Description: 
-- EXEC tSQLt.Run 'test.test_067_spExecuteCmds';
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 30-DEC-2024
--
-- Notes:
-- use like:  spExecuteCmds 'EXEC sp_assert_tbl_pop ''', [value], ''''
-- parameters:
-- @cmd the command to be run, it must include [value]
-- =========================================================================
CREATE PROCEDURE [dbo].[spExecuteCmds]
    @cmd   NVARCHAR(MAX) -- like 'EXEC sp_assert_tbl_pop ''', [value], ''''
   ,@items NVARCHAR(MAX) -- comma separated list of items to run teh sql against
   ,@end   INT OUT
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
      @fn   VARCHAR(35)    = 'spExecuteCmds'
     ,@ndx INT = 0
     ,@sql NVARCHAR(MAX)
     ,@msg NVARCHAR(MAX)

      EXEC sp_log 1, @fn ,'000: starting
@cmd  :[',@cmd  ,']
@items:[',@items,']
';

      IF OBJECT_ID('dbo.#CmdsTbl', 'U') IS NULL
      CREATE table #CmdsTbl
      (
        id INT identity(1,1)
       ,sql NVARCHAR(MAX)
      )
      ELSE TRUNCATE TABLE #CmdsTbl;

   SET @sql = 
   CONCAT
   (
'INSERT INTO #CmdsTbl(sql)
SELECT CONCAT(''',@cmd,' '', value,'';'')
FROM string_split(''', @items, ''','','');'
   );

   EXEC sp_log 1, @fn ,'010: @sql:
', @sql;

   EXEC (@sql);

   SELECT @end = COUNT(*) FROM #CmdsTbl;
   EXEC sp_log 1, @fn ,'020: start ndx: ', @ndx, ' count of rows (end): ', @end;
   SELECT * FROM #CmdsTbl;

   WHILE @ndx < = @end
   BEGIN
      SELECT
            @sql = [sql]
      FROM #CmdsTbl
      WHERE id = @ndx;

      EXEC sp_log 1, @fn, '090:[',@ndx,']: ', @sql;
      EXEC (@sql);
      SET @ndx = @ndx + 1
   END

   EXEC sp_log 1, @fn ,'999 leaving';
END
/*
EXEC sp_assert_all_data_tbls_pop 0;
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_067_spExecuteCmds';
EXEC spExecuteCmds
*/

GO
