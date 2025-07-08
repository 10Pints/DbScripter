SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =================================================================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2025
-- Description: update rtn using regex
-- updates the given field in the given table
--
-- @fixup_cnt: returns the number of rows updated by this rtn it is not culmulative
--
-- Tests:
--
-- Called By:
--    sp_fixup_S2_row
--
-- xls order:
-- id, command, table, field, search_clause
--, filter_field, filter_clause, not_clause
--, replace_clause, field2_nm, field2_val
--, must_update, comments, exact_match
--
-- CHANGES:
-- 241205: updated @filter_op prm to one of {'LIKE', 'EQUALS', 'IN'}
-- =================================================================================
CREATE PROCEDURE [dbo].[sp_update_reg_ex]
    @table_nm        NVARCHAR(60)
   ,@field_nm        NVARCHAR(60)
   ,@search_clause   NVARCHAR(500)
   ,@replace_clause  NVARCHAR(500)
--   ,@filter_field_nm NVARCHAR(60)   = NULL
   ,@filter_op       NVARCHAR(6)    = NULL-- One of {'LIKE', 'EQUALS', 'IN'} default: LIKE
   ,@filter_clause   NVARCHAR(400)  = NULL
   ,@not_clause      NVARCHAR(400)  = NULL
   ,@field2_nm       NVARCHAR(60)   = NULL
   ,@field2_op       NVARCHAR(8)    = NULL -- 0 replace(default), 1 add
   ,@field2_clause   NVARCHAR(500)  = NULL
   ,@extras          NVARCHAR(2000) = NULL-- sql clause to add one or more extra field values e,g 'comments=''some comment'' '
   ,@fixup_cnt       INT            = NULL OUT
   ,@select_sql      NVARCHAR(4000) = NULL OUT -- can be stored on the corrections table, or for testing
   ,@update_sql      NVARCHAR(4000) = NULL OUT -- can be stored on the corrections table, or for testing
   ,@execute         BIT            = 1     -- if clr then just return the sqls dont actually update
AS
BEGIN
   SET NOCOUNT OFF;

   DECLARE
    @fn              VARCHAR(35)   = 'sp_update_reg_ex'
   ,@nl              NCHAR(2)       = NCHAR(13)+NCHAR(10)
   ,@error_msg       VARCHAR(2000)
   ,@log_level       INT = dbo.fnGetLogLevel()
   ,@line            VARCHAR(200) = REPLICATE('-', 200)

   IF @filter_op IS NULL SET @filter_op = 'LIKE'

   SET @fixup_cnt = 0;

   If @log_level < 1
      EXEC sp_log 0, @fn, '000: starting';
      /*
table_nm       :[',@table_nm       , '] 
field_nm       :[',@field_nm       , ']
search_clause  :[',@search_clause  , ']
filter_field_nm:[',@filter_field_nm, ']
filter_op      :[',@filter_op      , ']
filter_clause  :[',@filter_clause  , ']
not_clause     :[',@not_clause     , ']
replace_clause :[',@replace_clause , ']
field2_nm      :[',@field2_nm      , ']
field2_op      :[',@field2_op      , ']
field2_clause  :[',@field2_clause  , ']
extras         :[',@extras         , ']
execute        :[',@execute        , ']
';
*/

   BEGIN TRY
      EXEC sp_log 0, @fn,'010: executing update sql   '

      -- Wrap each item in single quotes if the @filter_op is IN
      IF( @filter_op = 'IN')
         SELECT @filter_clause = dbo.fnQuoteItems(@filter_clause);

      SET @select_sql = CONCAT
(
'SELECT
[',@field_nm,'], dbo.RegEx_Match([',@field_nm,'], ''', @search_clause,''') AS search_cls', @nl
,'FROM [', @table_nm, ']', @nl
,'WHERE', @nl
,'[',@field_nm,'] '
,iif(@filter_op = 'LIKE', 'LIKE ''%', iif(@filter_op = '=', 'IN', ' IN ('))
--,' '
, @filter_clause
,iif( @filter_op = 'LIKE', '%''', iif(@filter_op='IN', ')', '')),@nl
--,'AND dbo.RegEx_Match([',@field_nm,'], ''', @search_clause,''') IS NOT NULL AND dbo.RegEx_Match([',@field_nm,'], ''', @search_clause,''') <> ''''',@nl
--,'AND [',@field_nm,'] NOT LIKE ''%', @replace_clause,'%''', @nl
,';'
);

      PRINT CONCAT(@nl, @line);
      EXEC sp_log 1, @fn, '030: SELECT SQL:',@nl, @select_sql;
      PRINT CONCAT(@line, @nl);

      -- UPDATE Staging2 SET crops = dbo.RegEx_Replace(crops, 'Snap.*Bean[s]*', 'Green Beans') WHERE crops LIKE '%Green Bean%'
      SET @update_sql = CONCAT
(
'UPDATE [',@table_nm,']
SET [',@field_nm,']=dbo.RegEx_Replace([',@field_nm,'], ''', @search_clause, ''', ''', @replace_clause,''')', @nl
,'FROM [', @table_nm, ']', @nl
,'WHERE', @nl
,'[',@field_nm,'] '
,iif(@filter_op= 'LIKE', 'LIKE ''%', iif(@filter_op = '=', 'IN', ' IN ('))
, @filter_clause
,iif(@filter_op='IN', ')', iif(@filter_op='LIKE', '%''', '')),@nl
--,'AND dbo.RegEx_Match([',@field_nm,'], ''', @search_clause,''') IS NOT NULL AND dbo.RegEx_Match([',@field_nm,'], ''', @search_clause,''') <> ''''',@nl
--,'AND [', @field_nm, '] NOT LIKE ''%',@replace_clause,'%''',@nl
,';'
)
;
      EXEC sp_log 1, @fn, '030: UPDATE SQL:',@nl, @update_sql;

      IF @execute = 1
      BEGIN
         EXEC sp_log 2, @fn,'040: EXECUTING UPDATE sql';
         EXEC (@update_sql);
      END
      ELSE
         EXEC sp_log 2, @fn,'030: NOT EXECUTING UPDATE sql';

      SET @fixup_cnt = @@rowcount;
      EXEC sp_log 1, @fn, '040: executed sql, updated ', @fixup_cnt, ' rows',@row_count = @fixup_cnt;
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 0, @fn, '999: leaving, @fixup_cnt: ',@fixup_cnt;
END
/*
DECLARE
    @select_sql      NVARCHAR(4000) = NULL OUT -- can be stored on the corrections table, or for testing
   ,@update_sql      NVARCHAR(4000) = NULL OUT -- can be stored on the corrections table, or for testing

dbo.sp_update_reg_ex 'staging2', 'crops', '[ ]*Cruciferae[ ]*', 'Crucifers'

EXEC tSQLt.Run 'test.test_069_sp_update_reg_ex';
*/

GO
