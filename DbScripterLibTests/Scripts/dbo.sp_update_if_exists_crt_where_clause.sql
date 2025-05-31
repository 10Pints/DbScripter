SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================
-- Author:      Terry Watts
-- Create date: 10-JUL-2023
-- Description: Creates the where clause SQL
--
-- PRECONDITIONS - all inputs valid
-- @search_clause will be wrapped with % % 
--  do not make a search clause like '%abcd%'
--
-- POSTCONDITIONS and RET CODES:
-- PO1: @where_clause is populated Always returns 0: OK
--
-- Changes:
-- 240325: if not case sensistive dont use the collation clause:
--         if @collation_clause is null then it is not included
-- ==============================================================
ALTER PROCEDURE [dbo].[sp_update_if_exists_crt_where_clause]
    @search_clause      NVARCHAR(MAX)
   ,@not_clause         NVARCHAR(MAX)
   ,@crops              NVARCHAR(MAX)
   ,@field              NVARCHAR(60)   = 'pathogens'
   ,@table              NVARCHAR(60)   = 'Staging2'
   ,@collation_clause   NVARCHAR(30)
   ,@where_clause       NVARCHAR(MAX) OUTPUT
 AS
BEGIN
   SET @where_clause = CONCAT('WHERE [', @field, '] LIKE ''', @search_clause, '''');
   
   IF ((@not_clause IS NOT NULL) AND (@not_clause <> ''))
   BEGIN
      SET @where_clause = CONCAT(@where_clause,  ' AND [', @field, '] NOT LIKE ''%', @not_clause, '%''');
   END

   IF @collation_clause IS NOT NULL
      SET  @where_clause = CONCAT(@where_clause, ' ',@collation_clause);

   IF @crops IS NOT NULL AND @crops NOT LIKE ''
   BEGIN
      SET @where_clause = CONCAT(@where_clause,  ' AND crops IN (''',REPLACE(@crops, ''',''', ''''','''''),''')');
   END

   RETURN 0;
END

/*
----------------------------------------------
DECLARE  @where_clause NVARCHAR(MAX)

exec sp_update_if_exists_crt_where_clause
    @search_clause   = 'Blight'
   ,@not_clause      = NULL
   ,@crops           = 'Celery'
   ,@field           = 'pathogens'
   ,@table           = 'Staging2'
   ,@where_clause    = @where_clause OUTPUT

PRINT CONCAT('where_clause:[',@where_clause, ']');
----------------------------------------------
DECLARE @cnt_sql NVARCHAR(MAX), @updt_sql NVARCHAR(MAX), @exp_cnt INT

EXEC sp_update_if_exists_crt_updt_sql 
    @search_clause     = 'Corn borer'
   ,@replace_clause    = 'Asian corn borer'
   ,@not_clause        = 'Asian corn borer'
   ,@notes             =  NULL
   ,@field             = 'pathogens'
   ,@table             = 'staging2' 
   ,@case_sensitive    = 0
   ,@crops             = 'Celery'
   ,@cnt_sql           =  OUTPUT
   ,@updt_sql          =  OUTPUT
   ,@id                = 605
   ,@exp_cnt = NULL

PRINT CONCAT('cnt_sql:
',@cnt_sql, ']');
PRINT CONCAT('updt_sql:
',@updt_sql, ']');

--SELECT @exp_cnt = COUNT(*) FROM [staging2] WHERE [pathogens] LIKE '%Corn borer%' AND [pathogens] NOT LIKE '%Asian corn borer%' COLLATE Latin1_General_CI_AI;
EXEC sp_executesql @cnt_sql, N'@exp_cnt INT OUTPUT', @exp_cnt OUTPUT
PRINT CONCAT('@exp_cnt:',@exp_cnt, '
,@cnt_sql:', @cnt_sql, ']');
----------------------------------------------

SELECT COUNT(*) FROM [staging2] WHERE [pathogens] LIKE '%Corn borer%' COLLATE Latin1_General_CI_AI AND crops IN ('Corn') ;
*/

GO
