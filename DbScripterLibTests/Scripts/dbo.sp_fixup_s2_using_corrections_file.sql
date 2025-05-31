SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =======================================================================================================================================================
-- Author:      Terry Watts
-- Create date: 22-JUN-2023
-- Description: Fixup the staging 2 table for import Register, using the
--              ImportCorrections table as the src to get the values to change
--              Does not handle the initial dequote, special characters
--              as there are problems with MS import of  special characters
--
-- CALLED BY    sp__main_import_pesticide_register
--
-- PRECONDITIONS:
--    ImportCorrections table populated
--
-- POSTCONDITIONS:
--    POST 01: @cor_file_path exists or exception 53600, 'correction file must exist',1;

-- RETURNS:
--    0  :  OK
--    1  :  STOP signal detected
--   -1  :  Error
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
-- =======================================================================================================================================================
ALTER PROCEDURE [dbo].[sp_fixup_s2_using_corrections_file]
    @start_row             INT            = 1
   ,@stop_row              INT            = 100000
   ,@cor_file              NVARCHAR(500) = NULL
   ,@cor_range             NVARCHAR(1000) = 'Sheet1$A:S'
   ,@fixup_cnt             INT            = NULL   OUTPUT

AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
    @fn                    NVARCHAR(30)  = N'FIXUP_S2_USING FILE'
   ,@alt_names             NVARCHAR(MAX)
   ,@cnt                   INT
   ,@case_sensitive        BIT
   ,@chk                   BIT
   ,@command               NVARCHAR(50)
   ,@common_name           NVARCHAR(MAX)
   ,@cor_file_path         NVARCHAR(500) = NULL
   ,@cor_log_flg_key       NVARCHAR(30) = N'COR_LOG_FLG'
   ,@crops                 NVARCHAR(MAX)
   ,@cursor                CURSOR
   ,@doit                  BIT
   ,@doit_s                NVARCHAR(100)
   ,@first_time            BIT            = 1
   ,@id                    INT = 0
   ,@import_id             INT
   ,@latin_name            NVARCHAR(MAX)
   ,@len                   INT
   ,@line                  NVARCHAR(80) = '---------------------------------'
   ,@local_name            NVARCHAR(MAX)
   ,@msg                   NVARCHAR(2000)
   ,@must_update           BIT
   ,@ndx                   INT            = 0
   ,@nl                    NVARCHAR(2)
   ,@not_clause            NVARCHAR(MAX)
   ,@note_clause           NVARCHAR(MAX)
   ,@rc                    INT            = 0
   ,@replace_clause        NVARCHAR(MAX)
   ,@result_msg            NVARCHAR(150)
   ,@row_count             INT            = 0
   ,@search_clause         NVARCHAR(MAX)
   ,@sql                   NVARCHAR(MAX)
   ,@stop_after_this_row   BIT            = 0
   ,@updated_field         NVARCHAR(60)
   ,@updated_table         NVARCHAR(60)

   EXEC sp_log 2, @fn, '000: starting:
start_row:    [', @start_row,    ']
stop_row:     [', @stop_row,     ']
cor_file:     [', @cor_file,']
cor_range:    [', @cor_range,    ']'
;

   EXEC sp_register_call @fn;
   SET @nl = NCHAR(13);

   BEGIN TRY

      -------------------------------------------------------
      -- Parameter Validation
      -------------------------------------------------------

      -------------------------------------------------------
      -- Process
      -------------------------------------------------------
      -- Go to the desired stage:
      -- Remove page header rows
      EXEC sp_log 0, @fn, '005: deleting CorrectionLog, ';

      DELETE FROM CorrectionLog;
      EXEC sp_log 0, @fn, '010: deleting header rows from the LRAP import';
      --DELETE FROM dbo.staging2 WHERE company LIKE '%NAME OF COMPANY%'; -- 22714 rows

      -- Remove the old import comments
      EXEC sp_log 0, @fn, '015: Remove old import comments';
      UPDATE staging2 SET Comment='';

      -------------------------------------------------------
      -- ASSERTION: ready to import
      -------------------------------------------------------

      -- Enable the S2 trigger
      ENABLE TRIGGER staging2.sp_Staging2_update_trigger ON Staging2;

      -- Turn on S2 update logging
      EXEC Ut.dbo.sp_set_session_context @cor_log_flg_key, 1;
      EXEC sp_log 0, @fn, '020: B4 main do loop';

      -------------------------------------------------------
      -- Main do loop
      -------------------------------------------------------
      WHILE 1 = 1
      BEGIN
         SET @cursor = CURSOR FOR
         SELECT id, [command],  search_clause, not_clause, replace_clause, case_sensitive, latin_name, common_name
                  ,local_name, alt_names, note_clause, crops, doit, must_update, chk
         FROM ImportCorrections order by id
         FOR UPDATE OF act_cnt,results;

         OPEN @cursor;
         EXEC sp_log 1, @fn, '025: before Row fetch loop, @@FETCH_STATUS: [', @@FETCH_STATUS, ']';

      -------------------------------------------------------
      -- Row fetch loop
      -------------------------------------------------------
         WHILE (@@FETCH_STATUS = 0) OR (@first_time = 1)
         BEGIN
            SET @first_time = 0
            SET @stop_after_this_row = 0;
--          SELECT                        id, [command], search_clause,  not_clause,  replace_clause,  case_sensitive,  latin_name,  common_name,  local_name,  alt_names,  note_clause,  crops,  doit  ,  must_update,  chk,  result
            FETCH NEXT FROM @cursor INTO @id, @command, @search_clause, @not_clause, @replace_clause, @case_sensitive, @latin_name, @common_name, @local_name, @alt_names, @note_clause, @crops, @doit_s, @must_update, @chk;
            EXEC sp_log 1, @fn, '030: top of row fetch loop, id: ',@id, ' @@FETCH_STATUS : [', @@FETCH_STATUS, ']';

            IF @@FETCH_STATUS <> 0
            BEGIN
               EXEC sp_log 1, @fn, '035: processing Corrections Completed at row: ', @id;

               IF @id < 1
               BEGIN
                  -- MUST process at least 1 row
                  SET @msg = ' No Corrections rows were processed';
                  EXEC sp_log 4, @fn, '040', @msg;
                  SET @msg = CONCAT(@fn, @msg);
                  THROW 52417, @msg, 1;
               END

               BREAK;
            END

            IF @id < @start_row
            BEGIN
               EXEC sp_log 0, @fn, '045: skipping row: ', @id;
               CONTINUE;
            END

            PRINT CONCAT( CONCAT(NCHAR(13), NCHAR(10)), @line, 'row ', @id, @line);
            SET @len = Ut.dbo.fnLen(@search_clause);

            -- Standardise command and doit
            SET @command= LOWER(Ut.dbo.fnTrim(@command));
            SET @doit_s = LOWER(Ut.dbo.fnTrim(@doit_s));

            -- Skip comments
            IF (@doit_s LIKE '%skip%') OR (@command LIKE '%skip%') OR  (@search_clause LIKE ';%' OR @search_clause LIKE 'COMMENT%')
            BEGIN
               EXEC sp_log 0, @fn,'050: skipping comment row: ', @id;
               CONTINUE;
            END

            IF (@doit_s = 'stop' OR @command = 'stop' )
            BEGIN
               SET @result_msg = 'STOP';
               EXEC sp_log 1, @fn, '055: STOP ENCOUNTERED: sp_fixup_import_register: 3.5: stopping at row: ', @id;
               SET @rc = 1;
               EXEC sp_set_fixup_result @id, @row_count, @result_msg;
               BREAK
            END

            -- doit now supports STOP AFTER[ DOIT=[0,1]]
            IF (@doit_s like 'stop after%')
            BEGIN
               SET @stop_after_this_row = 1;
               EXEC sp_log 1, '060: STOP AFTER ENCOUNTERED: sp_fixup_import_register: 3.5: stopping after executing this row: ', @id, ' @doit_s:[', @doit_s, ']';
               SET @ndx =  CHARINDEX( 'DOIT=', @doit_s);
               IF @ndx>0
               BEGIN
                  SET @doit_s = SUBSTRING(@doit_s, @ndx+5, 1);
                  EXEC sp_log 1, @fn, '065: @doit_s:[', @doit_s;
               END
            END

            SET @doit = CONVERT( BIT, @doit_s);

            -- 240129: change of logic if doit undefined: set default = 1 (do it anyway)
            IF (@doit IS NULL) OR ((@doit <>0) AND (@doit <> 1))
            BEGIN
               SET @doit = 1;
            END

            EXEC sp_log 1, @fn, '070: calling sp_fixup_s2_using_corrections_file_row';

            EXEC @rc = sp_fixup_s2_using_corrections_file_row
                 @id             = @id
                ,@command        = @command
                ,@search_clause  = @search_clause
                ,@replace_clause = @replace_clause
                ,@not_clause     = @not_clause
                ,@note_clause    = @note_clause
                ,@doit           = @doit
                ,@must_update    = @must_update
                ,@case_sensitive = @case_sensitive
                ,@crops          = @crops
                ,@chk            = @chk
                ,@result_msg     = @result_msg    OUTPUT
                ,@row_count      = @row_count     OUTPUT

            EXEC sp_log 1, @fn, '075: ret frm sp_fixup_s2_using_corrections_file_row, @row_count:', @row_count, ' @fixup_cnt:', @fixup_cnt, @row_count = @row_count;
            SET @fixup_cnt = @fixup_cnt + @row_count;
            -- Update the corrections table
           -- EXEC sp_log 2, @fn, '18.1';
            EXEC sp_set_fixup_result @id, @row_count, @result_msg--, @cursor;

            IF @rc IN (0,1)
            BEGIN
               SET @result_msg = CONCAT('OK, ', @result_msg);
            END
            ELSE
            BEGIN
               SET @msg = CONCAT('ERROR: sp_fixup_import_register returned ', @rc);
               EXEC sp_log 4, @fn, '080: ', @msg;
               THROW 50003, @msg, 1;
            END

            IF ((@stop_row = 1) OR (@stop_row <= @id))
            BEGIN
               EXEC sp_log 2, @fn, '085: STOP AFTER ENCOUNTERED: ', @id, ' stopping after this row';
               SET @rc = 1;
               BREAK;
            END

            EXEC sp_log 1, @fn, '090: end of fetch row loop for this row';
         END --  end of WHILE (@@FETCH_STATUS = 0) OR (@first_time = 1)

         SET @rc=0; -- OK

         -------------------------------------------------------
         -- Process complete
         -------------------------------------------------------
         EXEC sp_log 1, @fn, '095: Process complete';
         BREAK;
      END -- While 1=1

      EXEC sp_log 1, @fn, '100: completed main do loop';

      -- If XL file then update the results status
      IF @cor_file IS NOT NULL
      BEGIN
      -------------------------------------------------------
      -- Close normally
      -------------------------------------------------------
         EXEC sp_log 1, @fn, '105: Process complete, close normally';

         -- Close the cursor
         EXEC sp_log 2, @fn, '110: Close the cursor, disable trigger';
         CLOSE      @cursor;
         DEALLOCATE @cursor;

         -- Disable the trigger
         DISABLE TRIGGER staging2.sp_Staging2_update_trigger ON staging2;
         EXEC sp_set_session_context N'fixup count',     @fixup_cnt;

         EXEC sp_log 1, @fn, '115: writing results back to cor file
            @cor_file =[',@cor_file ,']
           ,@cor_range=[',@cor_range,']';

         EXEC sp_write_results_to_cor_file
            @cor_file = @cor_file
           ,@cor_range= @cor_range;

         EXEC Ut.dbo.sp_set_session_context @cor_log_flg_key, 0;
      END
   END TRY
   BEGIN CATCH
      DECLARE 
          @ex_num INT
         ,@ex_msg NVARCHAR(500)

      EXEC sp_log_exception @fn, @msg01 = '@result_msg: ', @msg02 = @result_msg, @ex_num = @ex_num OUT, @ex_msg = @ex_msg OUT;

      BEGIN TRY
         -- Log the error in the cor table
         EXEC sp_log 1, @fn, '120: calling sp_set_fixup_result: @result_msg: ',@result_msg;
         EXEC sp_set_fixup_result @id, -1, @result_msg--, @cursor OUT;
      END TRY
      BEGIN CATCH
         EXEC Ut.dbo.sp_log_exception @fn, '130: error raised in sp_set_fixup_result '
         -- Continue
      END CATCH

      -------------------------------------------------------
      -- Close abnormally
      -------------------------------------------------------
      -- Close the cursor
      EXEC sp_log 1, @fn, '135: Close abnormally: Close the cursor, disable trigger';
      CLOSE      @cursor;
      DEALLOCATE @cursor;

      -- Update context
      EXEC sp_set_session_context N'fixup count', @fixup_cnt;
      EXEC Ut.dbo.sp_set_session_context @cor_log_flg_key, 0;

      -- Disable the trigger
      DISABLE TRIGGER staging2.sp_Staging2_update_trigger ON staging2;

   -- Update the cor file with the results
      IF @cor_file IS NOT NULL
      BEGIN
         EXEC sp_log 1, '140: writing results back to cor file
            @cor_file =[',@cor_file ,']
           ,@cor_range=[',@cor_range,']';

         EXEC sp_write_results_to_cor_file
            @cor_file = @cor_file
           ,@cor_range= @cor_range;
      END

         EXEC sp_log 1, @fn, '145: rethrow exception';
      ;THROW;
   END CATCH

   EXEC sp_log 2, @fn, '999: leaving, @fixup_cnt: ',@fixup_cnt, ' @rc: ', @rc;
   RETURN @rc
END
/*
EXEC sp_reset_CallRegister;
EXEC dbo.sp_fixup_s2_using_corrections_file;
SELECT id, must_update FROM ImportCorrectionsStaging WHERE ID > 1999
SELECT id, must_update FROM ImportCorrectionsStaging WHERE must_update >0

------------------------------------------------------------------------------------------
EXEC sp_write_results_to_cor_file 
 @cor_file = 'D:\Dev\Repos\Farming\Data\ImportCorrections 221018 240322-2000.xlsx'
,@cor_range= 'ImportCorrections$A:S';
------------------------------------------------------------------------------------------
*/

GO
