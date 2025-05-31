SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==========================================================================================================
-- Author:      Terry Watts
-- Create date: 22-JUN-2023
-- Rtn:         dbo.sp_S2_fixup_row
--
-- Description: uses 1 row of the ImportCorrections table to fixup Staging2.
--
-- Process: reads the command and from that determines which
-- process rtn to call and calls it.
--
-- CALLED BY:sp_FixupImportRegister
--
-- RETURNS:
--              severity   result
--       if OK  0          rows updates
--       stop   1          do it was false - but continue
--       error -1          error so stop, @result_msg will have the error msg
--
-- PRECONDITIONS:
-- PRE 01: Stop already handled by client code
--
-- RESPONSIBILITIES:
-- R01. corrects Staging2 using the supplied parameters
-- R02. updates the ImportCorrections row id=@id with the results {row count, result msg}
-- R03. remove {} from the search_clause parameter
-- R04. remove {} from the replace_clause parameter
-- R05. remove "  from the search_clause parameter
-- R06. remove "  from the replace_clause parameter
-- R07. remove {} from the not_clause parameter
-- R08. remove "  from the not_clause parameter
--
-- POSTCONDITIONS:
-- Returns rc: 0 if ok
--             1 if ok but warning
--             2 if error  - so record and stop
-- POST 01: command must be valid 1 of {SQL, sp_update, stop}
-- POST 02: @result_msg must be set and not 'NOT SET' else exception 87000 '@result_msg not set'
-- POST 03: if @must_update set then if no rows returned then EXCEPTION 87001, 'expected rows to be returned but none were', 1;
--
-- xls order:
-- id, command, table, field, search_clause, filter_field, filter_clause, not_clause
--, replace_clause, field2_nm, field2_val, must_update, comments, exact_match
--
-- Tests:
-- test_038_sp_S2_fixup
--
-- CHANGES
-- 230819: removing the expected count get and check
-- 231106: RC 0,1 are considered success codes, 0 is update, 1 is skip or doit =0
-- 240129: added preprocessing to remove wrapping {} and "" from @search_clause, @replace_clause,@not_clause
-- 240324: improved validation
-- 241221: added comments, but only for the current list of tables that have a comments field
-- ==========================================================================================================
ALTER PROCEDURE [dbo].[sp_fixup_S2_row]
    @id              INT
   ,@command         VARCHAR(100)
   ,@table_nm        NVARCHAR(60)
   ,@field_nm        NVARCHAR(50)
   ,@search_clause   NVARCHAR(4000)
   ,@filter_field_nm NVARCHAR(1000)
   ,@filter_op       NVARCHAR(8)
   ,@filter_clause   NVARCHAR(500)
   ,@not_clause      NVARCHAR(1000)
   ,@exact_match     BIT
   ,@cs              BIT
   ,@replace_clause  NVARCHAR(1000)
   ,@field2_nm       NVARCHAR(60)
   ,@field2_op       NVARCHAR(8)  -- 0 replace(default), 1 add
   ,@field2_clause   NVARCHAR(400)
   ,@must_update     BIT
   ,@comments        NVARCHAR(1000)
   ,@row_id          INT
   ,@stg_file        NVARCHAR(100)
   ,@fixup_cnt       INT           OUTPUT
   ,@result_msg      VARCHAR(150)  OUTPUT
   ,@select_sql      NVARCHAR(MAX) OUTPUT
   ,@update_sql      NVARCHAR(MAX) OUTPUT
   ,@execute         BIT           = 1     -- if clr then just return the sqls dont actually update
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
    @fn              VARCHAR(30)  = N'sp_fixup_S2_row'
   ,@error_msg       VARCHAR(4000)
   ,@cnt_sql         NVARCHAR(MAX)
   ,@exists_sql      NVARCHAR(MAX)
   ,@fixup_id        INT
   ,@fixup_id_key    NVARCHAR(30) = N'FIXUP_ROW_ID'
   ,@fixup_cnt_delta INT
   ,@search_cls_key  NVARCHAR(30) = N'SEARCH_CLAUSE'
   ,@replace_cls_key NVARCHAR(30) = N'REPLACE_CLAUSE'
   ,@msg             VARCHAR(MAX)
   ,@ndx             INT          =  0
   ,@nl              VARCHAR(2)  = NCHAR(10)+NCHAR(13)
   ,@rc              INT          = -1
   ,@str             VARCHAR(30)
   ,@where_clause    VARCHAR(MAX) = NULL
   ,@comments_clause VARCHAR(1000)
   ;

   EXEC sp_log 0, @fn, '000: starting: id: ', @id, ' must_update: ', @must_update;

   SET @result_msg = 'NOT SET';
   EXEC SetCtxFixupRowId   @id;
   EXEC SetCtxFixupStgId   @row_id;
   EXEC SetCtxFixupFile    @stg_file;
   EXEC SetCtxFixupSrchCls @search_clause;
   EXEC SetCtxFixupRepCls  @replace_clause;

   -- 241221: added comments, but only for the current list of tables that have a comments field
   IF @table_nm IN ('staging3','s2_tst_bak','s1_tst_221018','s1_tst_221018_bak','ImportCorrections'
,'staging2','ImportCorrectionsStaging_vw','s2_tst','ImportCorrectionsStaging')
      SET @comments_clause = CONCAT('comments=''', @comments, '''');

   BEGIN TRY
      WHILE 1=1
      BEGIN
         --EXEC dbo.sp_set_session_context @id_key, @id;
         --EXEC sp_set_ctx_cor_id @id;
         --EXEC dbo.sp_set_session_context @search_cls_key,  @search_clause
         --EXEC dbo.sp_set_session_context @replace_cls_key, @replace_clause

         -- 240129: added preprocessing to remove wrapping {} and "" from @search_clause, @replace_clause,@not_clause
         -- Preprocess params
         -- RESP 01. remove {} from the search_clause parameter
         SET @search_clause  = REPLACE( REPLACE(@search_clause , '{',''), '}','');
         -- RESP 03. remove "  from the search_clause parameter
         SET @search_clause  = REPLACE(@search_clause, '"','');
         -- RESP 02. remove {} from the replace_clause parameter
         SET @replace_clause = REPLACE( REPLACE(@replace_clause, '{',''), '}','');
         -- RESP 04. remove "  from the replace_clause parameter
         SET @replace_clause = REPLACE(@replace_clause, '"','');
         -- RESP 05. remove {} from the not_clause parameter
         SET @not_clause     = REPLACE( REPLACE(@not_clause, '{',''), '}','');
         -- RESP 06. remove "  from the not_clause parameter
         SET @not_clause     = REPLACE(@not_clause, '"','');

         SET @command = dbo.fnTrim(@command);

         ---------------------------------------------------------------------------------------------------------------------
         -- Validate args
         ---------------------------------------------------------------------------------------------------------------------
         EXEC sp_log 0, @fn, '010: validating args';

         -- POST 01: command must be valid 
         IF (@command IS NULL OR dbo.fnTrim(@command) = '')
         BEGIN
            SET @result_msg = CONCAT( 'row [', @id,'] command must be specified');
            EXEC sp_log 4, @fn, '020: ',@result_msg;
            SET @rc = 2; -- Error
            BREAK;
         END

         -- ASSERTION: stop handled (PRE CONDITIONS)

         -------------------------------------------
         -- Process
         -------------------------------------------

         IF (@command = 'sp_update')
         BEGIN
            EXEC sp_log 0, @fn, '030 handling command: sp_update';

            EXEC @rc = dbo.sp_update
                         @table_nm       = @table_nm
                        ,@field_nm       = @field_nm
                        ,@search_clause  = @search_clause
                        ,@filter_field_nm= @filter_field_nm
                        ,@filter_op      = @filter_op
                        ,@filter_clause  = @filter_clause -- comma separated 'in' list, wrap the entire list in single quotes
                        ,@not_clause     = @not_clause
                        ,@exact_match    = @exact_match
                        ,@cs             = @cs
                        ,@replace_clause = @replace_clause
                        ,@field2_nm      = @field2_nm
                        ,@field2_op      = @field2_op
                        ,@field2_clause  = @field2_clause
                        ,@extras         = @comments_clause
                        ,@fixup_cnt      = @fixup_cnt_delta  OUT
                        ,@select_sql     = @select_sql OUT -- can be stored on the corrections table, or for testing
                        ,@update_sql     = @update_sql OUT -- can be stored on the corrections table, or for testing
                        ,@execute        = @execute
                        ;

            SET @result_msg = 
            CASE
               WHEN @rc=0 THEN 'OK'
               WHEN @rc=1 THEN 'STOP'
               ELSE 'ERROR'
            END;

            BREAK;
         END

         IF (@command = 'sp_update_path')
         BEGIN
            EXEC sp_log 0, @fn, '040 handling command: sp_update_path';

            EXEC @rc = sp_update_S2_path
                @search_clause   = @search_clause
               ,@filter_field_nm = @filter_field_nm
               ,@filter_clause   = @filter_clause
               ,@filter_op       = @filter_op
               ,@not_clause      = @not_clause
               ,@exact_match     = @exact_match
               ,@cs              = @cs
               ,@replace_clause  = @replace_clause
               ,@note_clause     = @field2_clause
               ,@comments       = @comments
               ,@fixup_cnt       = @fixup_cnt_delta  OUT
               ,@select_sql      = @select_sql OUT
               ,@update_sql      = @update_sql OUT
               ,@execute         = @execute
               ;

            SET @result_msg = 
            CASE
               WHEN @rc=0 THEN 'OK'
               WHEN @rc=1 THEN 'STOP'
               ELSE 'ERROR'
            END;

            BREAK;
         END

         IF (@command = 'sp_update_s2')
         BEGIN
            EXEC sp_log 0, @fn, '050 handling command: sp_update_s2';

            EXEC @rc = sp_update_s2
                @field           = @field_nm
               ,@search_clause   = @search_clause
               ,@filter_field_nm = @filter_field_nm -- typically crops
               ,@filter_op       = @filter_op
               ,@filter_clause   = @filter_clause
               ,@not_clause      = @not_clause
               ,@exact_match     = @exact_match
               ,@cs              = @cs
               ,@replace_clause  = @replace_clause
               ,@note_clause     = @field2_clause
               ,@comments        = @comments
               ,@fixup_cnt       = @fixup_cnt_delta  OUT
               ,@select_sql      = @select_sql OUT
               ,@update_sql      = @update_sql OUT
               ,@execute         = @execute
               ;

-- Rtn: dbo.sp_S2_fixup_row

            SET @result_msg = 
            CASE
               WHEN @rc=0 THEN 'OK'
               WHEN @rc=1 THEN 'STOP'
               ELSE 'ERROR'
            END;

            BREAK;
         END

         IF @command = 'SQL' -- sql contains the sql
         BEGIN
            SET @update_sql = @search_clause;
            EXEC sp_log 1, @fn, '060 sql:
',@update_sql;

            -- Record the update sql
            --UPDATE ImportCorrections SET update_sql = @update_sql WHERE id = @id;

            EXEC @rc = sp_executesql @update_sql;
            SET @fixup_cnt_delta = @@ROWCOUNT;

            EXEC sp_log 0, @fn, '070 SQL command ran, checking rc code';
            IF @rc = 0
            BEGIN
               SET @result_msg = 'OK';
            END
            ELSE
            BEGIN
               SET @result_msg = CONCAT('080: sp_executesql @sql returned error code ', @rc);
               BREAK;
            END

            -------------------------------------------
            -- ASSERTION EXEC @sql ran ok maybe no rows
            -------------------------------------------

            EXEC sp_log 0, @fn, '090 SQL command ran ok (@rc chk passed)';
            BREAK;
         END -- end IF @command = 'SQL'

        IF (@command = 'reg_ex')
         BEGIN
            EXEC sp_log 0, @fn, '030 handling command: reg_ex';

            EXEC @rc = dbo.sp_update_reg_ex
                         @table_nm       = @table_nm
                        ,@field_nm       = @field_nm
                        ,@search_clause  = @search_clause
                        ,@replace_clause = @replace_clause
--                        ,@filter_field_nm= @field_nm
                        ,@filter_op      = @filter_op
                        ,@filter_clause  = @filter_clause -- comma separated 'in' list, wrap the entire list in single quotes
                        ,@not_clause     = @not_clause
--                        ,@exact_match    = @exact_match
--                        ,@cs             = @cs
                        ,@field2_nm      = @field2_nm
                        ,@field2_op      = @field2_op
                        ,@field2_clause  = @field2_clause
                        ,@extras         = @comments_clause
                        ,@fixup_cnt      = @fixup_cnt_delta  OUT
                        ,@select_sql     = @select_sql OUT -- can be stored on the corrections table, or for testing
                        ,@update_sql     = @update_sql OUT -- can be stored on the corrections table, or for testing
                        ,@execute        = @execute
                        ;

            SET @result_msg = 
            CASE
               WHEN @rc=0 THEN 'OK'
               WHEN @rc=1 THEN 'STOP'
               ELSE 'ERROR'
            END;

            BREAK;
         END

         -------------------------------------------
         -- ASSERTION If here then unhandled cmd
         -------------------------------------------

         SET @result_msg = CONCAT( 'ERROR unrecognised command: [', @command, '] id: ', @id, ' ',@result_msg);
         EXEC sp_log 4, @fn, '100 ', @result_msg;
         SET @rc = 2;
         BREAK;
      END -- end while 1=1

      EXEC sp_log 1, @fn, '110: fixup_cnt: ',@fixup_cnt_delta, ' must_update: ', @must_update, ' result_msg: ', @result_msg;

      UPDATE ImportCorrections
      SET
          select_sql = @select_sql
         ,update_sql = @update_sql
         ,update_cnt = @fixup_cnt_delta
         ,result_msg = @result_msg
      WHERE id = @id;

         -------------------------------------------
      -- Record the results
          -------------------------------------------
      SET @fixup_cnt = @fixup_cnt + @fixup_cnt_delta;

     IF(@fixup_cnt_delta=0 AND @must_update=1 AND @execute=1)
      BEGIN
         SET @result_msg = CONCAT(' Error in row_id[',@id,'] file: [', @stg_file, '] row ', @row_id,': no rows were updated. but must update chk specified ');
         EXEC sp_log 4, @fn, '120 ', @result_msg;
         THROW 56656, @result_msg, 1;
         SET @rc = 2;
      END

      ---------------------------------------------------------------------------------------------------------------------
      -- Process complete
      ---------------------------------------------------------------------------------------------------------------------
      EXEC sp_log 0, @fn, '130: Process complete';
   END TRY
   BEGIN CATCH
      DECLARE @ex_msg VARCHAR(500) = CONCAT('ERROR: row: ', @id, ', caught exception ',ERROR_MESSAGE());
      EXEC .sp_log_exception @fn, '510: import row id:', @id, ' ', @ex_msg;

      -- Log the results in the ImportCorrections table
      UPDATE ImportCorrections
      SET
          select_sql = @select_sql
         ,update_sql = @update_sql
         ,update_cnt = @fixup_cnt
         ,result_msg = @ex_msg
      WHERE id = @id;

      THROW;
   END CATCH

   EXEC sp_log 0, @fn, '999: leaving';
   RETURN @rc;
END
/*
EXEC test.sp__crt_tst_rtns '[dbo].[sp_S2_fixup_row]', 8
*/


GO
