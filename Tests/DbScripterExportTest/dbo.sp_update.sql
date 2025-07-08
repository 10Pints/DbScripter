SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =================================================================================
-- Author:      Terry Watts
-- Create date: 07-NOV-2024
-- Description: general update rtn
-- updates the given field in the given table. 
--
-- @fixup_cnt: returns the number of rows updated by this rtn it is not culmulative
--
-- Tests:
--    Test_017_sp_update
--    test_018_fnCrtUpdateSql
--
-- Called By:
--    sp_update_s2
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
CREATE PROCEDURE [dbo].[sp_update]
    @table_nm        NVARCHAR(60)
   ,@field_nm        NVARCHAR(60)
   ,@search_clause   NVARCHAR(500)
   ,@filter_field_nm NVARCHAR(60)  -- = NULL
   ,@filter_op       NVARCHAR(6)    -- One of {'LIKE', 'EQUALS', 'IN'}
   ,@filter_clause   NVARCHAR(400)  --= NULL
   ,@not_clause      NVARCHAR(400)  --= NULL
   ,@exact_match     BIT            --= 0 -- if set 1 then match the full field
   ,@cs              BIT
   ,@replace_clause  NVARCHAR(500)
   ,@field2_nm       NVARCHAR(60)
   ,@field2_op       NVARCHAR(8)    -- 0 replace(default), 1 add
   ,@field2_clause   NVARCHAR(500)
   ,@extras          NVARCHAR(2000) = NULL-- sql clause to add one or more extra field values e,g 'comments=''some comment'' '
   ,@fixup_cnt       INT            = NULL OUT
   ,@select_sql      NVARCHAR(4000) = NULL OUT -- can be stored on the corrections table, or for testing
   ,@update_sql      NVARCHAR(4000) = NULL OUT -- can be stored on the corrections table, or for testing
   ,@execute         BIT             = 1     -- if clr then just return the sqls dont actually update
AS
BEGIN
   SET NOCOUNT OFF;

   DECLARE
    @fn              VARCHAR(35)   = 'sp_update'
   ,@nl              NCHAR(2)       = NCHAR(13)+NCHAR(10)
   ,@error_msg       VARCHAR(4000)
   ,@log_level       INT = dbo.fnGetLogLevel()

   SET @fixup_cnt = 0;

   If @log_level < 1
      EXEC sp_log 0, @fn, '000: starting
table_nm       :[',@table_nm       , '] 
field_nm       :[',@field_nm       , ']
search_clause  :[',@search_clause  , ']
filter_field_nm:[',@filter_field_nm, ']
filter_op      :[',@filter_op      , ']
filter_clause  :[',@filter_clause  , ']
not_clause     :[',@not_clause     , ']
exact_match    :[',@exact_match    , ']
cs             :[',@cs             , ']
replace_clause :[',@replace_clause , ']
field2_nm      :[',@field2_nm      , ']
field2_op      :[',@field2_op      , ']
field2_clause  :[',@field2_clause  , ']
extras         :[',@extras         , ']
execute        :[',@execute        , ']
';

   EXEC sp_fnCrtUpdateSql
    @table_nm       = @table_nm
   ,@field_nm       = @field_nm
   ,@search_clause  = @search_clause
   ,@filter_field_nm= @filter_field_nm
   ,@filter_op      = @filter_op
   ,@filter_clause  = @filter_clause
   ,@not_clause     = @not_clause
   ,@exact_match    = @exact_match
   ,@cs             = @cs
   ,@replace_clause = @replace_clause
   ,@field2_nm      = @field2_nm
   ,@field2_op      = @field2_op
   ,@field2_clause  = @field2_clause
   ,@extras         = @extras
   ,@select_sql     = @select_sql OUT
   ,@update_sql     = @update_sql OUT

   BEGIN TRY
      EXEC sp_log 0, @fn,'010: executing update sql'

      IF @execute = 1
         EXEC (@update_sql);
      ELSE
         EXEC sp_log 2, @fn,'030: NOT EXECUTING UPDATE sql (@execute=0)';

      SET @fixup_cnt = @@rowcount;
      EXEC sp_log 1, @fn, '040:executed sql, updated ', @fixup_cnt, ' rows',@row_count = @fixup_cnt;
   END TRY
   BEGIN CATCH
      -- if exception came from EXEC (@update_sql); ERROR_PROC and ERROR_LINE() dont work properly
      SET @error_msg = CONCAT('(099): raised exception# ', ERROR_NUMBER(),': ', ERROR_MESSAGE());
      DECLARE @line VARCHAR(4000) = REPLICATE('+', dbo.fnLen(@error_msg) + 46);
      PRINT CONCAT(@nl, @line);
      EXEC sp_log 4, @fn, @error_msg;

      EXEC sp_log 0, @fn, '520: params
table_nm       :[',@table_nm       , '] 
field_nm       :[',@field_nm       , ']
search_clause  :[',@search_clause  , ']
filter_field_nm:[',@filter_field_nm, ']
filter_op      :[',@filter_op      , ']
filter_clause  :[',@filter_clause  , ']
not_clause     :[',@not_clause     , ']
exact_match    :[',@exact_match    , ']
cs             :[',@cs             , ']
replace_clause :[',@replace_clause , ']
field2_nm      :[',@field2_nm      , ']
field2_op      :[',@field2_op      , ']
field2_clause  :[',@field2_clause  , ']
extras         :[',@extras         , ']
execute        :[',@execute        , ']
';
      PRINT CONCAT(@line, @nl);
      THROW 70000, @error_msg, 1;
   END CATCH

   EXEC sp_log 0, @fn, '999: leaving, @fixup_cnt: ',@fixup_cnt;
END
/*
DECLARE @delta INT = 0
EXEC sp_update_s2 'entry_mode', 'Contact/selective','contact,selective';
*/

GO
