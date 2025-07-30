SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 09-MAr-2024
-- Description: convenient wrapper for fnListApplog
--
-- Parameters:    Mandatory,optional M/O
-- @import_file  [O] the import source file can be a tsv or xlsx file
-- @fnFilter     [O] -- DEFAULT = ALL
-- @msgFilter    [O] -- DEFAULT = ALL
-- @idFilter     [O] -- DEFAULT = ALL
-- @levelFilter  [O] -- DEFAULT = ALL
-- @asc          [O] -- DEFAULT = DESC, 1= ASC, 0=desc
--
-- Preconditions: none
--
-- Postconditions:
-- POST01:
--
-- ======================================================================================================
CREATE PROCEDURE [dbo].[sp_list_AppLog]
    @fnFilter     NVARCHAR(50)   = NULL  -- DEFAULT = ALL
   ,@msgFilter    NVARCHAR(128)  = NULL  -- DEFAULT = ALL
   ,@minIdFilter  INT            = NULL  -- DEFAULT = ALL
   ,@maxIdFilter  INT            = NULL  -- DEFAULT = ALL
   ,@levelFilter  INT            = NULL  -- DEFAULT = ALL
   ,@asc          BIT            = NULL  -- DEFAULT = ASC, 1= ASC, 0=desc
   ,@top          INT            = NULL
AS
BEGIN
   DECLARE
    @fn              NVARCHAR(30)  = N'FIXUP S1 MRL HLPR'
   ,@sql             NVARCHAR(MAX)
   ,@fnFilterClause  NVARCHAR(MAX)
   IF @asc IS NULL SET @asc = 1; -- DEFAULT = ASC
   SELECT @fnFilterClause = CONCAT('''', string_agg(ut.dbo.fnTrim(value), ''','''), '''') from string_split(@fnFilter, ',');
   SET @sql = CONCAT
   (
'SELECT '
, IIF(@top IS NOT NULL, CONCAT('Top ', @top), '')
,'          id
         ,[level]
         ,row_count
         ,fn
         ,[msg                                                                                                                            .]
         ,[msg2                                                                                                                           .]
         ,[msg3                                                                                                                           .]
         ,[msg4                                                                                                                           .]
      FROM applog_vw_', iif(@asc = 1, 'asc', 'desc')
      -- only add these clauses if there is at least on predicate
      -- add 'AND ' if there was a preceding predicate clause
      , IIF(    @fnFilter    IS NULL
            AND @msgFilter   IS NULL
            AND @minIdFilter IS NULL
            AND @maxIdFilter IS NULL
            AND @levelFilter IS NULL, '', CONCAT(NCHAR(13),'WHERE'))
      , iif(@fnFilter    IS NULL, '', CONCAT(NCHAR(13), ' fn IN (' , @fnFilterClause,')'))
      , iif(@msgFilter   IS NULL, '', CONCAT(NCHAR(13),iif(@fnFilter IS NULL, '', 'AND ')
            ,'CONCAT([msg                                                                                                                            .]
                    ,[msg2                                                                                                                           .]) LIKE @msgFilter'))
      , iif(@minIdFilter IS NULL, '', CONCAT(NCHAR(13),iif(@fnFilter IS NULL AND @msgFilter IS NULL, '', 'AND '),' id >= ', @minIdFilter))
      , iif(@maxIdFilter IS NULL, '', CONCAT(NCHAR(13),iif(@fnFilter IS NULL AND @msgFilter IS NULL AND @minIdFilter IS NULL , '', 'AND '),' id <= ', @maxIdFilter))
      , iif(@levelFilter IS NULL, '', CONCAT(NCHAR(13),iif(@fnFilter IS NULL AND @msgFilter IS NULL AND @minIdFilter IS NULL AND @maxIdFilter IS NULL, '', 'AND '), '[level] >= '     , @levelFilter))
      , CONCAT(NCHAR(13),'ORDER BY id ', iif(@asc='1', 'ASC', 'DESC'))
   );
   PRINT @sql;
   EXEC sp_executesql @sql, N'@fnFilter NVARCHAR(50), @msgFilter NVARCHAR(128), @minIdFilter INT, @maxIdFilter INT, @levelFilter INT'
   , @fnFilter, @msgFilter, @minIdFilter,@maxIdFilter, @levelFilter;
END
/*
EXEC tSQLt.Run 'test.test_086_sp_list_AppLog';
EXEC sp_list_AppLog                       -- LIST ALL desc
EXEC sp_list_AppLog 'MN_IMPORT', @asc=1   -- LIST the main import rtn, asc 
EXEC sp_list_AppLog 'MN_IMPORT,POP STG TBLS', @asc=1   -- LIST the main import rtn, asc 
EXEC sp_list_AppLog 'MN_IMPORT,POP STG TBLS', @idFilter = 2000, @asc=1   -- LIST the main import rtn, asc 
EXEC sp_list_AppLog 'MN_IMPORT,POP STG TBLS', @idFilter = 2000, @asc=1   -- LIST the main import rtn, asc 
EXEC sp_list_AppLog        -- LIST ALL 
*/
GO

