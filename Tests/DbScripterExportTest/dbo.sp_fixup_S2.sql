SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =======================================================================================================================================================
-- Author:      Terry Watts
-- Create date: 22-JUN-2023
-- Rtn:         dbo.sp_S2_fixup
--
-- Description: Fixup the staging 2 table for LRAP import, using the
-- ImportCorrections table as the corrections src to get the values to change
--
-- CALLED BY    sp__main_import_pesticide_register
--
-- RESPONSIBILITIES:
-- R01: corrects Staging2 using the supplied parameters (delegated to sp_S2_fixup_row)
-- R02: updates the ImportCorrections row id=@id with the results {row count, result msg} (delegated to sp_S2_fixup_row)
-- R03: remove {} from the search_clause parameter (delegated to sp_S2_fixup_row)
-- R04: remove {} from the replace_clause parameter (delegated to sp_S2_fixup_row)
-- R05: remove "  from the search_clause parameter (delegated to sp_S2_fixup_row)
-- R06: remove "  from the replace_clause parameter (delegated to sp_S2_fixup_row)
-- R07: remove {} from the not_clause parameter (delegated to sp_S2_fixup_row)
-- R08: remove "  from the not_clause parameter (delegated to sp_S2_fixup_row)
-- R09: if the cor_file does not exist throw exception 53600, 'correction file must exist',1;
-- R10: if STOP signal detected return 1 and @result_msg = ''
-- R11: if ERROR durinig import return 2
-- R12: if search cls = replace then throw exception 53610, 'replace clause = search clause {row id}',1;
--
-- PRECONDITIONS:
--    ImportCorrections table populated
--
-- POSTCONDITIONS:
      -- POST 01: if STOP signal detected return 1
      -- POST 02: if ERROR                return 2
--
-- Parameters:  default
-- @start_row      1
-- @stop_row       100000
--
-- RETURNS:
--    0  :  OK
--    1  :  STOP signal detected
--   -2  :  Error
--
-- TESTS: test_038_sp_S2_fixup
--
-- xls order:
-- id, command, table, field, search_clause, filter_field, filter_clause, not_clause
--, replace_clause, field2_nm, field2_val, must_update, comments, exact_match
--
-- CHANGES
-- 230622: added Skip
-- 230625: added Do it to print the action SQL but not actually run the sql
-- 230629: added must_update to make sure something changed in the table
-- 230703: added user supllied skip to to overrride the spreadsheet skip
-- 230704: added comment lines
-- 230715: doit now supports STOP AFTER[ DOIT=[0,1]]
--         added user supplied skip to
-- 231014: renamed the fixupimport register sp for Staging to:  sp_fixup_s2_using_corrections_file
-- 231014: added postcondition chks for the non existence of 'Golden apple Snails' and 'Golden apple Snails (kuhol)'
-- 231014: added a @stop_after_row parameter to stop the import from the main commandline, changed the order of params
-- 231019: tidied up the logging not to be repetitive @skip_to_row, @stop_after_row, [import id], [@fixup_cnt] moved to header log
-- 231106: RC 0,1 are considered success codes, 0 is update, 1 is skip or doit =0
-- 240129: change of logic if doit undefined: sewt default = 1 (do it anyway)
-- 240211: moved must update failure logic to sp_update_if_exists
--         also added a chk to sp_update_if_exists when failed to update when @must_update set then chk rows would be selected using the srch_sql_clause
-- 240329: parameter @cor_file_path changed to @cor_file - now uses the root folder
-- 250103: added the action column to hold actions like SKIP,STOP so that when skipping we dont lose the command
-- 250106: at the end of the fixup run fixup commas (leading, trailing) and internal double commas
-- =======================================================================================================================================================
CREATE PROCEDURE [dbo].[sp_fixup_S2]
    @start_row          INT            = 1      -- only work on the first imp file
   ,@stop_row           INT            = 100000 -- only work on the first imp file
   ,@row_count          INT            OUTPUT
   ,@fixup_cnt          INT            OUTPUT
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
    @fn                 VARCHAR(35)   = 'sp_fixup_S2'
   ,@cnt                INT
   ,@action             VARCHAR(12)
   ,@command            VARCHAR(50)
   ,@comments           VARCHAR(1000)
   ,@cor_log_flg_key    VARCHAR(30)   = N'COR_LOG_FLG'
   ,@cs                 BIT
   ,@cursor             CURSOR
   ,@exact_match        BIT
   ,@field_nm           VARCHAR(60)
   ,@field2_nm          VARCHAR(60)
   ,@field2_op          VARCHAR(8)
   ,@field2_clause      VARCHAR(150)
   ,@file_fxp_cnt_new   INT            = 0
   ,@file_fxp_cnt_prev  INT            = 0
   ,@file_row_cnt       INT            = 0
   ,@filter_field_nm    VARCHAR(60)
   ,@filter_op          VARCHAR(8)
   ,@filter_clause      VARCHAR(150)
   ,@first_time         BIT            = 1
   ,@id                 INT            = 0
   ,@import_id          INT
   ,@len                INT
   ,@line               VARCHAR(150)   = REPLICATE('-', 40)
   ,@line2              VARCHAR(150)   = REPLICATE('*', 150)
   ,@msg                VARCHAR(2000)
   ,@must_update        BIT
   ,@ndx                INT            = 0
   ,@nl                 VARCHAR(2)     = NCHAR(13)+NCHAR(10)
   ,@not_clause         VARCHAR(MAX)
   ,@rc                 INT            = 0       -- Controls the cursor get loop
   ,@replace_clause     VARCHAR(MAX)
   ,@result_msg         VARCHAR(500)
   ,@row_id             INT
   ,@search_clause      VARCHAR(500)
   ,@select_sql         VARCHAR(MAX)
   ,@stg_file_new       VARCHAR(100)
   ,@stg_file_prev      VARCHAR(100)   = ''
   ,@stp_flg            BIT            = 0
   ,@table_nm           VARCHAR(60)
   ,@update_sql         VARCHAR(MAX)

   EXEC sp_log 2, @fn, '000: starting:
start_row:[', @start_row,']
stop_row: [', @stop_row ,']
';
-- stg_file: [',@stg_file  ,']

   BEGIN TRY
         -------------------------------------------------------
         -- Parameter Defaults
         -------------------------------------------------------
      IF @start_row IS NULL SET @start_row = 1;
      IF @stop_row  IS NULL SET @stop_row = 100000;

      -------------------------------------------------------
      -- Parameter Validation
      -------------------------------------------------------
      EXEC sp_log 1, @fn, '010: Parameter Validation';
      EXEC sp_assert_not_null @row_count, '@row_count param IS NULL', 1;
      EXEC sp_assert_not_null @fixup_cnt, '@fixup_cnt param';

      -------------------------------------------------------
      -- Setup
      -------------------------------------------------------
      EXEC sp_log 1, @fn, '020: deleting CorrectionLog, ';

      TRUNCATE TABLE CorrectionLog;--DELETE FROM CorrectionLog;
      IF @start_row = 1
      BEGIN
         EXEC sp_log 1, @fn, '030: clearing the update counts from the previous run';
         UPDATE ImportCorrections SET update_cnt = 0;
      END

      -- Remove the old import comments
      EXEC sp_log 1, @fn, '040: Remove old import comments';
      UPDATE staging2 SET comments='';

      -- Enable the S2 trigger
      ENABLE TRIGGER staging2.sp_Staging2_update_trigger ON Staging2;

      -- Turn on S2 update logging
      EXEC dbo.sp_set_session_context @cor_log_flg_key, 1;
      EXEC sp_log 0, @fn, '050: B4 main do loop';

      SET @cursor = CURSOR FOR
      SELECT id, [action],[command], table_nm, field_nm, search_clause, filter_field_nm, filter_op
      , filter_clause, not_clause, exact_match, cs, replace_clause, field2_nm, field2_op, field2_clause, must_update, comments, @row_id, stg_file
      FROM ImportCorrections order by id

      OPEN @cursor;
      EXEC sp_log 1, @fn, '060: before Row fetch loop, @@FETCH_STATUS: [', @@FETCH_STATUS, ']';
      FETCH NEXT FROM @cursor INTO @id, @action, @command, @table_nm, @field_nm, @search_clause, @filter_field_nm, @filter_op
         ,@filter_clause, @not_clause, @exact_match, @cs, @replace_clause, @field2_nm, @field2_op, @field2_clause, @must_update, @comments, @row_id, @stg_file_new;

      -------------------------------------------------------
      -- Main process loop
      -------------------------------------------------------
      WHILE (@@FETCH_STATUS = 0)-- Row fetch loop
      BEGIN
         WHILE (1=1) -- Do loop
         BEGIN
            EXEC sp_log 1, @fn, '070: top of Row fetch loop, cor id: ',@id;

            IF @stg_file_prev <> @stg_file_new
            BEGIN
               IF @file_row_cnt > 0
               BEGIN
                  -- Not first time
                  EXEC sp_log 1, @fn, '080: finished processing file recording summary results: ',@stg_file_prev, ' row_cnt: ', @file_row_cnt, ' file_fxp_cnt:', @file_fxp_cnt_prev;
                  UPDATE CorFiles
                  SET
                     row_cnt   = @file_row_cnt
                    ,fixup_cnt = @fixup_cnt
                  WHERE [file] = @stg_file_prev
               END

               -- Every time if @stg_file_prev <> @stg_file_new
               SET @stg_file_prev = @stg_file_new;
            END

            -- Ready for next time
            SET @file_fxp_cnt_prev = @file_fxp_cnt_new;

            IF @id < @start_row
            BEGIN
               EXEC sp_log 1, @fn, '090: skipping row: ', @id;
               BREAK; -- RC= 0  so CONTINUE i.e skip this row;
            END

            EXEC sp_log 1, @fn, @nl, @line, ' row ', @id, ' ', @line;
            SET @len = dbo.fnLen(@search_clause);
--            EXEC sp_log 1, @fn, '100: @must_update: ',@must_update;

            -- Standardise action and command
            SET @command= LOWER(dbo.fnTrim(@command));
            SET @action = LOWER(dbo.fnTrim(@action));

      -------------------------------------------------------
            -- Handle Skip and comment  rows
      -------------------------------------------------------
            IF @action LIKE '%skip%' OR  @action LIKE ';%' OR @action LIKE 'COMMENT%'
            BEGIN
               EXEC sp_log 1, @fn,'120: skipping comment row: ', @id;
               BREAK; -- RC= 0  so CONTINUE;
            END

            EXEC sp_log 1, @fn, '130: calling sp_S2_fixup_row
id:               [', @id              ,']
row_id            [', @row_id          ,']
stg_file          [', @stg_file_new    ,']
action:           [', @action          ,']
command:          [', @command         ,']
table_nm:         [', @table_nm        ,']
field_nm:         [', @field_nm        ,']
search_clause:    [', @search_clause   ,']
replace_clause    [', @replace_clause  ,']
filter_field_nm:  [', @filter_field_nm ,']
filter_op         [', @filter_op       ,']
filter_clause     [', @filter_clause   ,']
not_clause        [', @not_clause      ,']
exact_match       [', @exact_match     ,']
cs                [', @cs              ,']
field2_nm         [', @field2_nm       ,']
field2_op         [', @field2_op       ,']
field2_clause     [', @field2_clause   ,']
must_update       [', @must_update     ,']
comments          [', @comments        ,']
';

            -- R12: if search cls = replace then throw exception 53610, 'replace clause = search clause {row id}',1;
            -- 240110: Sql server ignores trailing spaces when comparing string values
            IF CONVERT(VARBINARY(500),@search_clause)=CONVERT(VARBINARY(500),@replace_clause)
            BEGIN
               EXEC sp_log 4, @fn, '075: replace clause = search clause @id: ', @id, ', @stg_file_new: ',@stg_file_new,'
search clause :[', @search_clause, ']
replace clause:[', @replace_clause, ']
';
               EXEC sp_raise_exception 53610, '075: replace clause = search clause @id: ', @id, ', @stg_file_new: ',@stg_file_new, @fn=@fn;
            END

            -- Handle stop
            IF @action = 'stop'
            BEGIN
               SET @result_msg =CONCAT( 'stop detected at row ', @id);
               EXEC sp_log 4, @fn, @line2
               EXEC sp_log 4, @fn, '140: ',@result_msg;
               EXEC sp_log 4, @fn, @line2

               UPDATE ImportCorrections
               SET
                   result_msg = @result_msg
                  ,update_cnt = @fixup_cnt
               WHERE id = @id
               ;

               SET @rc = 1 -- Signal stop
               BREAK
            END

            IF @action = 'skip'
            BEGIN
               SET @result_msg =CONCAT( 'skip detected at row ', @id);
               EXEC sp_log 4, @fn, @line2
               EXEC sp_log 4, @fn, '150: ',@result_msg;
               EXEC sp_log 4, @fn, @line2

               UPDATE ImportCorrections 
               SET
                   result_msg = @result_msg
                  ,update_cnt = @fixup_cnt
               WHERE id = @id
               ;

               --SET @file_fixup_cnt = 0; -- ready for next file
               SET @rc = 0;
               BREAK; -- RC= 0  so CONTINUE;
            END

            EXEC sp_log 0, @fn, '160: calling sp_S2_fixup_row';

            -- Get the return status from fixup row - return it if error
            EXEC @rc = sp_fixup_S2_row
                  @id             = @id
                  ,@command        = @command
                  ,@table_nm       = @table_nm
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
                  ,@must_update    = @must_update
                  ,@comments       = @comments
                  ,@row_id         = @row_id
                  ,@stg_file       = @stg_file_new
                  ,@fixup_cnt      = @file_fxp_cnt_new OUTPUT -- incremental
                  ,@result_msg     = @result_msg       OUTPUT
                  ,@select_sql     = @select_sql       OUTPUT
                  ,@update_sql     = @update_sql       OUTPUT

            IF  @row_count IS NULL THROW 56000, '@row_count is NULL', 1;
            SET @row_count = @row_count + 1;
            EXEC sp_log 0, @fn, '170: ret frm sp_S2_fixup_row, @rc: ',@rc, ', @row_count: ', @row_count, ', @fixup_cnt:', @fixup_cnt, @row_count = @row_count;

            IF @id >= @stop_row
            BEGIN
               EXEC sp_log 1, @fn, '180: reached stop row: ',@stop_row,' stopping'
               SET @rc = 1; -- signal stop
               BREAK; -- RC= 0  so CONTINUE;
            END

            IF @rc = 0 -- OK
            BEGIN
               SET @result_msg = 'OK';
               BREAK; -- RC= 0  so CONTINUE;
            END

            IF @rc = 1 -- STOP signal detected
            BEGIN
               EXEC sp_log 2, @fn, '190: STOP or last row encountered: ', @id, ' stopping after this row';
               BREAK; -- RC= 1 so STOP;
            END

            IF @rc = 2
            BEGIN
               SET @msg = CONCAT('ERROR: fixup LRAP import error ', @result_msg, ' row: ', @id, ' raising exception');
               EXEC sp_log 4, @fn, '200: ', @msg;
               THROW 50003, @msg, 1;
               --BREAK;
            END

            BREAK; -- ALWAYS
         END -- while 1=1

         IF @rc<> 0 -- STOP;
            BREAK;

         -- Get the next row if poss
         FETCH NEXT FROM @cursor INTO @id, @action, @command, @table_nm, @field_nm, @search_clause, @filter_field_nm, @filter_op
         ,@filter_clause, @not_clause, @exact_match, @cs, @replace_clause, @field2_nm, @field2_op, @field2_clause, @must_update, @comments, @row_id, @stg_file_new;
      END -- end outer while loop

      -- Need to do this for the last file imported (including the 1 file scenario)
      EXEC sp_log 1, @fn, '210: finished processing file recording summary results: ',@stg_file_prev, ' row_cnt: ', @file_row_cnt, ' file_fxp_cnt:', @file_fxp_cnt_prev;
      UPDATE CorFiles
      SET
          row_cnt   = @file_row_cnt
         ,fixup_cnt = @fixup_cnt
      WHERE [file]  = @stg_file_prev
      ;

      -- 250106: at the end of the fixup run fixup commas (leading, trailing) and internal double commas
      EXEC sp_log 1, @fn, '220: cleaning up redundant commas in pathogens after fixup';
      DECLARE @fixup_cnt2 INT;
      UPDATE Staging2 SET pathogens = TRIM(',' FROM pathogens) WHERE pathogens like ',%' OR  pathogens like '%,';
      SET @fixup_cnt2 = @@ROWCOUNT;
      UPDATE Staging2 SET pathogens = REPLACE(pathogens, ',,',',') WHERE pathogens like '%,,%';
      SET @fixup_cnt2 = @fixup_cnt2 + @@ROWCOUNT;

      -- Chk it worked
      IF EXISTs (SELECT 1 FROM Staging2 WHERE pathogens LIKE ',%') -- this can happen if removing first item in a list
         EXEC sp_raise_exception 53152, 'INVARIANT VIOLATION S2 pathogens has leading '',''', @fn=@fn

      IF EXISTs (SELECT 1 FROM Staging2 WHERE pathogens LIKE '%,,%') -- this can happen if removing a mid item in a list
         EXEC sp_raise_exception 53152, 'INVARIANT VIOLATION S2 pathogens contains '',,''', @fn=@fn

      EXEC sp_log 1, @fn, '230: cleaned up ',@fixup_cnt2,' redundant commas in pathogens after fixup';

      -------------------------------------------------------
      -- Process complete
      -------------------------------------------------------
      EXEC sp_log 1, @fn, '250: Process complete';
   END TRY
   BEGIN CATCH
      DECLARE 
          @ex_num  INT
         ,@ex_msg  VARCHAR(500)
         ,@ex_proc VARCHAR(80)
         ,@ex_line VARCHAR(20)
         ,@err_msg VARCHAR(500)

      SET @ex_msg  = ERROR_MESSAGE();
      SET @ex_num  = ERROR_NUMBER();
      SET @ex_proc = ERROR_PROCEDURE();
      SET @ex_line = CAST(ERROR_LINE() AS VARCHAR(20));
      SET @err_msg = CONCAT(' error in ', @ex_proc, '(',@ex_line, '): row: ', @id, ' exception: ', @ex_num, ' ',@ex_msg);
      EXEC dbo.sp_set_session_context @cor_log_flg_key, 0;
      EXEC sp_log_exception @fn, '500: @result_msg: ', @result_msg, @ex_num = @ex_num OUT, @ex_msg = @ex_msg OUT;

      -------------------------------------------------------
      -- Close abnormally
      -------------------------------------------------------
      -- Close the cursor
      IF CURSOR_STATUS('global','@cursor') = 1
      BEGIN
         EXEC sp_log 1, @fn, '510: Close abnormally: Close the cursor, disable trigger';
         CLOSE      @cursor;
         EXEC sp_log 1, @fn, '520: DEALLOCATING @cursor';
         DEALLOCATE @cursor;
         EXEC sp_log 1, @fn, '530: DEALLOCATed @cursor';
      END

      -- Update context
      EXEC sp_set_session_context N'fixup count', @fixup_cnt;
      EXEC dbo.sp_set_session_context @cor_log_flg_key, 0;

      -- Disable the trigger
      DISABLE TRIGGER staging2.sp_Staging2_update_trigger ON staging2;

      EXEC sp_log 1, @fn, '540: throw revised exception: ', @err_msg;
      IF @ex_num < 50000  SET @ex_num = @ex_num + 50000;

      THROW @ex_num, @err_msg, 1;
   END CATCH

   -------------------------------------------------------
   -- Close normally
   -------------------------------------------------------
   CLOSE      @cursor;
   DEALLOCATE @cursor;
   DISABLE TRIGGER staging2.sp_Staging2_update_trigger ON staging2;
   EXEC dbo.sp_set_session_context @cor_log_flg_key, 0;

   -------------------------------------------------------
   -- Report summary
   -------------------------------------------------------
   DECLARE 
       @file_cnt INT
   ;

   EXEC sp_log 2, @fn, '600: Report summary: ',@file_cnt,' files, #rows imported: ',@id,' #fixups: ',@fixup_cnt, ' @rc: ', @rc;
   SELECT @file_cnt = COUNT(*) FROM CorFiles;

   PRINT CONCAT(@NL, @NL, @Line2);
   EXEC sp_log 2, @fn, '610: Completed import of ',@file_cnt,' files, #rows imported: ',@id,' #fixups: ',@fixup_cnt, ' @rc: ', @rc;
   PRINT CONCAT(@Line2, @NL,@NL);

   EXEC sp_log 2, @fn, '999: leaving, @fixup_cnt: ',@fixup_cnt, ' @rc: ', @rc;
   RETURN @rc;
END
/*
------------------------------------------------
EXEC tSQLt.Run 'test.test_038_sp_S2_fixup';

EXEC tSQLt.RunAll;
------------------------------------------------
*/

GO
