SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==========================================================================================================
-- Author:      Terry Watts
-- Create date: 22-JUN-2023
-- Description: uses 1 row of the ImportCorrections table to fixup
--              the Pesticide register table from the fixup table.
--
-- Process: reads the command and from that determines which
-- process rtn to call and calls it.
--
-- CALLED BY:sp_FixupImportRegister
--
-- CALLS:
--   Command handlers:
--       sp_updateAndSetNote
--       sp_Singularise
--       sp_update
--       SQL handler (inline)
--
-- RETURNS:
--              severity   result
--       if OK  0          rows updates
--       stop   1          do it was false - but continue
--       error -1          error so stop, @result_msg will have the error msg
--
-- PRECONDITIONS:
--    none
--
-- RESPONSIBILITOES:
-- RESP 01. remove {} from the search_clause parameter
-- RESP 02. remove {} from the replace_clause parameter
-- RESP 03. remove "  from the search_clause parameter
-- RESP 04. remove "  from the replace_clause parameter
-- RESP 05. remove {} from the not_clause parameter
-- RESP 06. remove "  from the not_clause parameter
--
-- POSTCONDITIONS:
-- Returns rc: 0 if ok
--             1 if ok but warning
--            -1 if error  - so record and stop
-- POST 01: command must be valid 1 of {SQL, sp_update, stop}
-- POST 02: @result_msg must be set and not 'NOT SET' else exception 87000 '@result_msg not set'
-- POST 03: if @must_update set then if no rows returned then EXCEPTION 87001, 'expected rows to be returned but none were', 1;

-- CHANGES
-- 230819: removing the expected count get and check
-- 231106: RC 0,1 are considered success codes, 0 is update, 1 is skip or doit =0
-- 240129: added preprocessing to remove wrapping {} and "" from @search_clause, @replace_clause,@not_clause
-- 240324: improved validation
-- ==========================================================================================================
ALTER PROCEDURE [dbo].[sp_fixup_s2_using_corrections_file_row]
    @id              INT
   ,@command         NVARCHAR(100)
   ,@search_clause   NVARCHAR(4000)
   ,@replace_clause  NVARCHAR(4000)
   ,@not_clause      NVARCHAR(4000)
   ,@note_clause     NVARCHAR(4000)
   ,@doit            BIT
   ,@must_update     BIT
   ,@case_sensitive  BIT
   ,@crops           NVARCHAR(4000)
   ,@chk             NVARCHAR(150)
   ,@result_msg      NVARCHAR(150)  OUTPUT
   ,@row_count       INT            OUTPUT
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
    @fn              NVARCHAR(30)  = N'FIXUP_S2_USING FILE ROW'
   ,@error_msg       NVARCHAR(4000)
   ,@cnt_sql         NVARCHAR(MAX)
   ,@exists_sql      NVARCHAR(MAX)
   ,@fixup_id        INT
   ,@id_key          NVARCHAR(30) = N'FIXUP_ROW_ID'
   ,@search_cls_key  NVARCHAR(30) = N'SEARCH_CLAUSE'
   ,@replace_cls_key NVARCHAR(30) = N'REPLACE_CLAUSE'
   ,@line            NVARCHAR(200)= '---------------------------------------------------------------------------'
   ,@msg             NVARCHAR(MAX)
   ,@ndx             INT =  0
   ,@nl              NVARCHAR(2) = NCHAR(10)+NCHAR(13)
   ,@rc              INT = -1
   ,@str             NVARCHAR(30)
   ,@where_clause    NVARCHAR(MAX)


   EXEC sp_log 2, @fn, '00: starting: parameters:
id            :[', @id              , ']
command       :[', @command         , ']
search_clause :[', @search_clause   , ']
replace_clause:[', @replace_clause  , ']
not_clause    :[', @not_clause      , ']
note_clause   :[', @note_clause     , ']
doit          :[', @doit            , ']
must_update   :[', @must_update     , ']
case_sensitive:[', @case_sensitive  , ']
crops         :[', @crops           , ']
chk           :[', @chk             , ']'
;

   SET @result_msg = 'NOT SET';

   BEGIN TRY
      WHILE 1=1
      BEGIN
         EXEC ut.dbo.sp_set_session_context @id_key, @id;
         EXEC ut.dbo.sp_set_session_context @search_cls_key,  @search_clause
         EXEC ut.dbo.sp_set_session_context @replace_cls_key, @replace_clause

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

         ---------------------------------------------------------------------------------------------------------------------
         -- Validate args
         ---------------------------------------------------------------------------------------------------------------------
         -- POST 01: command must be valid 1 of {SQL, sp_update, stop} OR EXCEPTION 63574, 'command must be one of {SQL, sp_update, stop}',1;
         IF (@command IS NULL OR ut.dbo.fnTrim(@command) = '')
         BEGIN
            SET @result_msg = CONCAT( 'sp_FixupRow: search_clause or @sql or cmd must be specified row id: [', @id,']');
            EXEC sp_log 4, @fn, '10: command = stop: so stopping';
            SET @rc = -1; -- Error
            BREAK;
         END

         IF @command NOT IN ('SQL', 'sp_update', 'stop')--63574, 'command must be one of {SQL, sp_update, stop}',1;
         BEGIN
            SET @error_msg = CONCAT('invalid command:[',@command,']');
            EXEC sp_log 4, @fn, '15: ', @error_msg;
            THROW 63574, @error_msg, 1;
         END

         IF LOWER(@command) = 'stop' -- stop sht prcessing
         BEGIN
            SET @result_msg = 'sp_FixupRow: command = stop: so stopping';
            EXEC sp_log 4, @fn, '20: command = stop: so stopping';
            SET @rc = 1; -- OK
            BREAK;
         END

         ---------------------------------------------------------------------------------------------------------------------
         -- Process
         ---------------------------------------------------------------------------------------------------------------------
         IF (@command = 'sp_update')
         BEGIN
            EXEC sp_log 0, @fn, '25 handling command: sp_update';

            IF @doit = 1
            BEGIN
               -- POST 03: if @must_update set then if no rows returned then EXCEPTION 87001, 'expected rows to be returned but none were', 1;
               EXEC @rc = dbo.sp_update_if_exists
                       @search_clause  = @search_clause
                      ,@replace_clause = @replace_clause
                      ,@not_clause     = @not_clause
                      ,@note_clause    = @note_clause
                      ,@doit           = @doit
                      ,@must_update    = @must_update
                      ,@case_sensitive = @case_sensitive
                      ,@crops          = @crops
                      ,@id             = @id
                      ,@chk            = @chk
                      ,@result_msg     = @result_msg        OUTPUT
                      ,@row_count      = @row_count         OUTPUT;
            END
            ELSE
            BEGIN
               EXEC sp_log 4, @fn, '30 Not processing command as @doit is false';
               SET @rc = 1; -- OK
            END

            BREAK;
         END

         IF @command = 'SQL' -- sql contains the sql
         BEGIN
            EXEC sp_log 0, @fn, '30 handling command: SQL';

            EXEC @rc = dbo.sp_execute_sql_cmd
                  @doit            = 1
               , @table           = 'staging2'
               , @result_msg      = @result_msg OUTPUT
               , @row_count       = @row_count  OUTPUT
               , @sql             = @search_clause

            -- POST 03: if @must_update set then if no rows returned then EXCEPTION 87001, 'expected rows to be returned but none were', 1;
            IF @row_count = 0 AND @must_update = 1
            BEGIN
               EXEC sp_log 4, @fn, ' expected rows to be returned but none were',1;
               THROW 87001, 'expected rows to be returned but none were',1;
            END

            BREAK;
         END -- end IF @command = 'SQL'

         ----------------------------------------------------------------------------------------
         -- ASSERTION: if here then error
         ----------------------------------------------------------------------------------------
         SET @result_msg = CONCAT( 'ERROR unrecognised command: [', @command, '] id: ', @id, ' ',@result_msg);
         EXEC sp_log 4, @fn, '40: ', @result_msg;
         SET @rc=-1;
         THROW 53124, @msg, 1;
      END -- end while 1=1

      ---------------------------------------------------------------------------------------------------------------------
      -- Chk postconditions
      ---------------------------------------------------------------------------------------------------------------------

      IF @rc NOT IN (0, 1) -- 1 means doit=0
         EXEC sp_log 4, @fn, '45: invalid return code: ', @rc, @row_count = @row_count;

      -- POST02
      EXEC Ut.dbo.sp_assert_not_equal 'NOT SET', '@result_msg not set: ', @result_msg, @ex_num=87000, @fn=@fn;
      EXEC Ut.dbo.sp_assert_not_equal '',        '@result_msg not set: ', @result_msg, @ex_num=87000, @fn=@fn;

      ---------------------------------------------------------------------------------------------------------------------
      -- Process complete
      ---------------------------------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, 'Process complete';
   END TRY
   BEGIN CATCH
      EXEC .sp_log_exception @fn, 'XL row id:', @id;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '99: leaving';
   RETURN @rc;
END
/*
*/

GO
