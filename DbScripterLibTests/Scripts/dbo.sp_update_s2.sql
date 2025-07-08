SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

--========================================================================
-- Author:      Terry Watts
-- Create date: 06-NOV-2024
-- Description: general S2 update fixup rtn
--    fixes up any filed in staging 2
--
-- Exception handling: logs error and rethrows exception
-- 
-- Responsibilities:
-- R01: updates Staging2 using the supplied parameters
--
-- Tests:
--    027_sp_update_s2

-- xls order:
-- id, command, table, field, search_clause
--, filter_field, filter_clause, not_clause
--, replace_clause, field2_nm, field2_val
--, must_update, comments, exact_match
--
-- CHANGES:
-- 241205: updated @filter_op prm to one of {'LIKE', 'EQUALS', 'IN'}
--========================================================================
CREATE PROCEDURE [dbo].[sp_update_s2]
    @field           NVARCHAR(80)
   ,@search_clause   NVARCHAR(500)
   ,@filter_field_nm NVARCHAR(60)
   ,@filter_op       NVARCHAR(6)     -- One of 'LIKE' 'EQUALS' 'IN'
   ,@filter_clause   NVARCHAR(400)   -- comma separated list use ' ' - do not wrap items like 'Fred',Bill'
   ,@not_clause      NVARCHAR(400)
   ,@exact_match     BIT
   ,@cs              BIT
   ,@replace_clause  NVARCHAR(500)
   ,@note_clause     NVARCHAR(500)   --- appends to notes
   ,@comments        NVARCHAR(500)
   ,@fixup_cnt       INT            = NULL  OUT
   ,@select_sql      NVARCHAR(4000) = NULL  OUT
   ,@update_sql      NVARCHAR(4000) = NULL  OUT
   ,@execute         BIT            = 1     -- if clr then just return the sqls dont actually update
AS
BEGIN
   SET NOCOUNT OFF;
   DECLARE
       @fn        VARCHAR(35)   = 'sp_update_s2'
      ,@extras    NVARCHAR(2000) -- sql clause to add extra field values e,g 'comments=''some comment'' '
      ,@error_msg VARCHAR(2000)
      ,@nl        NCHAR(2) = NCHAR(13) + NCHAR(10)
   ;

   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting, setting defaults';

      IF @comments IS NOT NULL
         SET @extras = CONCAT('comments =''',@comments, '''');

      IF @execute is null
         SET @execute = 1;

      EXEC sp_update
       @table_nm        = 'staging2'
      ,@field_nm        = @field
      ,@search_clause   = @search_clause
      ,@filter_field_nm = @filter_field_nm
      ,@filter_op       = @filter_op
      ,@filter_clause   = @filter_clause
      ,@not_clause      = @not_clause
      ,@exact_match     = @exact_match
      ,@cs              = @cs
      ,@replace_clause  = @replace_clause
      ,@field2_nm       = 'notes'
      ,@field2_clause   = @note_clause
      ,@field2_op       = 'Add'
      ,@extras          = @extras
      ,@fixup_cnt       = @fixup_cnt  OUT
      ,@select_sql      = @select_sql OUT
      ,@update_sql      = @update_sql OUT
      ,@execute         = @execute
     ;

   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, @fixup_cnt: ', @fixup_cnt;
END
/*
EXEC tSQLt.Run 'test.test_027_sp_update_s2';
*/

GO
