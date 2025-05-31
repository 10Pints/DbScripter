SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==================================================================================================================================
-- Author:   Terry Watts
-- Create date: 26-JUN-2023
-- Description: updates 1 clause with another in a given table and field
--   e.g: UPDATE dbo.temp SET pathogens= REPLACE(pathogens, 'Annual and
--   Perennial broadleaves', 'Annual broad leaved weeds,  Perennial broad leaved weeds')
--   WHERE pathogens like '%Annual and Perennial broadleaves%'
--
-- This does a check if search clause exists, then updates if so -
-- if the search clause exists then if the update fails to update anything it will throw error
--
-- PRECONDITIONS: none
--
-- POSTCONDITIONS:
-- Return codes:
--  0: success
-- -1: error and @result_msg populated
-- POST 01: if @must_update is set but no rows were updated then exception 87001, 'expected rows to be returned but none were'
--
-- Changes:
-- 230628: added and not clause
-- 230629: added do it
-- 230630: added must update
-- 230701: added skip, stop
-- 230705: removed automatic wrapping of search clause in %% - let user have more control
-- 230705: added case sensivity to the searches
-- 230819: removed the expected count get and check
-- 231015: simplified the update sql
-- 231016: changed parameter @fixup_cnt nm to @row_count for consistency
-- 231019: re-adding the chk sql option
-- 240211: moved must update failure logic here from sp_fixup_s2_using_corrections_file
--         also added a chk when failed to update when @must_update set then chk rows would be selected using the srch_sql_clause
-- ==================================================================================================================================
ALTER PROCEDURE [dbo].[sp_update_if_exists]
    @search_clause   NVARCHAR(500)
   ,@replace_clause  NVARCHAR(500)
   ,@not_clause      NVARCHAR(150)     = NULL
   ,@note_clause     NVARCHAR(250)     = NULL
   ,@field           NVARCHAR(60)      = NULL
   ,@table           NVARCHAR(60)      = NULL
   ,@doit            BIT               = 1
   ,@must_update     BIT               = 1
   ,@id              NVARCHAR(60)      = 0
   ,@case_sensitive  BIT               = 0
   ,@crops           NVARCHAR(150)
   ,@chk             BIT               = 0
   ,@result_msg      NVARCHAR(150)     = NULL OUTPUT
   ,@row_count       INT OUTPUT
AS
BEGIN
   DECLARE 
       @fn              NVARCHAR(20)  = N'UPDT IF EXISTS'
      ,@updt_sql        NVARCHAR(MAX)
      ,@chk_sql         NVARCHAR(MAX)
      ,@set_clause      NVARCHAR(MAX)
      ,@where_clause    NVARCHAR(MAX)
      ,@srch_sql_clause NVARCHAR(MAX)
      ,@msg             NVARCHAR(2000) = NULL
      ,@rc              INT            = 0
      ,@nl              NVARCHAR(2)    = NCHAR(13)
      ,@act_cnt         INT            = -1

   EXEC sp_log 0, @fn, '00: starting'
   SET NOCOUNT OFF;

   BEGIN TRY
      EXEC sp_log 0, @fn, '05:  calling sp_update_if_exists_set_defaults ...'
      EXEC sp_update_if_exists_set_defaults
          @search_clause  = @search_clause   OUTPUT
         ,@replace_clause = @replace_clause  OUTPUT
         ,@field          = @field           OUTPUT
         ,@table          = @table           OUTPUT
         ,@doit           = @doit            OUTPUT
         ,@must_update    = @must_update     OUTPUT
         ,@id             = @id              OUTPUT
         ,@result_msg     = @result_msg      OUTPUT
         ,@row_count      = @row_count       OUTPUT
         ,@case_sensitive = @case_sensitive  OUTPUT

      IF @doit <> 0
      BEGIN

         EXEC sp_log 0, @fn, '10:  calling sp_update_if_exists_crt_updt_sql '

         -- The return status is the status of the cnt query
         -- This now determines the exp_cnt
         EXEC dbo.sp_update_if_exists_crt_updt_sql
             @search_clause   = @search_clause
            ,@replace_clause  = @replace_clause
            ,@not_clause      = @not_clause
            ,@note_clause     = @note_clause
            ,@field           = @field
            ,@table           = @table
            ,@case_sensitive  = @case_sensitive
            ,@crops           = @crops
            ,@id              = @id
            ,@updt_sql        = @updt_sql        OUTPUT
            ,@srch_sql_clause = @srch_sql_clause OUTPUT

         EXEC @rc = sp_executesql @Query = @updt_sql
         SET @row_count = @@ROWCOUNT;
         EXEC sp_log 1, @fn, '30:  @updt_sql:
', @updt_sql, @row_count=@row_count;

         IF @rc<>0 
         BEGIN
            SET @msg = CONCAT('sp_executesql returned error: @rc', @rc);
            EXEC sp_log 4, @fn, '30: ', @msg;
            THROW 87001, @msg, 1;
            --RETURN @RC;
         END

         -- if do it and must update then must update at least 1 row, 
         -- OR if do it and @exp_cnt not equal act_cnt -> raise error
         IF @must_update=1 AND @row_count = 0
         BEGIN
            -- POST 01: if @must_update is set but no rows were updated then exception 87001, 'expected rows to be returned but none were'
            SET @msg = 'expected rows to be returned but none were';
            EXEC sp_log 4, @fn, @msg;
            THROW 87002, @msg,1;
         END

         --EXEC sp_log 1, @fn, '60: executed update query',@row_count = @row_count;

         IF @chk <> 0
         BEGIN
            EXEC sp_log 0, @fn, '65: checking update';
            -- we are looking for rows that contain the replace clause, but not the search clause
            SET @chk_sql = CONCAT(' SELECT COUNT(*) FROM STAGING WHERE pathogens like ''',@replace_clause,'%'')
 AND pathogens NOT LIKE ''%',@search_clause,'%''');

            EXEC sp_log 0, @fn, '70: chk sql: ',@nl, @chk_sql;
          
            EXEC sp_executesql @chk_sql, @Params  = N'@act_cnt INT OUTPUT', @act_cnt = @act_cnt OUTPUT;

            IF @act_cnt = -1
            BEGIN
               SET @result_msg =CONCAT(@fn, '75: update chk failed - sql did not execute:', @nl, @chk_sql);
               EXEC sp_log 4, @fn, @msg;
              return -1;
            END

            IF @act_cnt = 0 -- and we are checking ...
            BEGIN
               SET @result_msg = CONCAT('80: update chk failed - did not update any rows, sql: ', @nl, 'chk sql:', @nl, @chk_sql);
               EXEC sp_log 4, @fn, @msg;
               RETURN -1;
            END

            -- ASSERTION: if here the chk found at least 1 rule
             EXEC sp_log 1, @fn,  '85: Chk passed, found ', @act_cnt, ' updated rows';
         END
      END -- IF @doit <> 0
      ELSE 
      BEGIN
         EXEC sp_log 0, @fn, '90: @doit = false so not updating';
      END

      EXEC sp_log 0, @fn, '95: completed processing OK'
   END TRY
   BEGIN CATCH
      SET @act_cnt = Ut.dbo.fnLen(@updt_sql);
      SET @result_msg = CONCAT(' row: ', @id,', len(updt_sql): ', @act_cnt);
      EXEC Ut.dbo.sp_log_exception @fn, @result_msg;
      EXEC sp_log 4, @fn, '150:', @updt_sql;
      THROW;
   END CATCH

   SET @result_msg = 'OK';
   EXEC sp_log 1, @fn, '99: leaving, RC: ', @rc, @row_count = @row_count;
   RETURN @rc;
END
/*
SELECT CONCAT('[', pathogens, ']') FROM staging2 where pathogens like '%Golden apple Snails%'

UPDATE Staging2
SET
     [pathogens]   = Replace(pathogens, 'Golden apple Snails (kuhol)', 'Golden apple snail'  COLLATE Latin1_General_CI_AI)
    ,cor_id        = 417
    ,search_clause = '%Golden apple Snails (kuhol)%'
    ,replace_clause= 'Golden apple snail'
    ,not_clause    = ''
WHERE [pathogens] LIKE '%Golden apple Snails (kuhol)%' COLLATE Latin1_General_CI_AI -- 99 rows updated

UPDATE Staging2
SET
     [pathogens]   = Replace(pathogens, 'Golden apple Snails', 'Golden apple snail'  COLLATE Latin1_General_CI_AI)
    ,cor_id = 418
    ,search_clause = '%Golden apple Snails%'
    ,replace_clause= 'Golden apple snail'
    ,not_clause    = ''
WHERE [pathogens] LIKE '%Golden apple Snails%' COLLATE Latin1_General_CI_AI -- 181 rows updated
*/

GO
