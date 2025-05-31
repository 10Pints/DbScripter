SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================================================================================================================================
-- Author:      Terry Watts
-- Create date: 16-OCT-2024
-- Description: performs part of the import correction fixup process
--
-- Parameters:
--   @txn_id        : tag to id issues in the log
--  ,@search_clause : used in the replace and where clauses. the where is wrapped with %%
--   and has a NOT like the replace clause to avoid scenario Melon->Mellons when app tp 'Melons'->'Melonss'
-- 
--  ,@replace_clause: used in the REPLACE statement verbatum
--  ,@not_clause    : optional can be used to filter out unwanted replacements
--  ,@where_clause  : optional - in not supplied will be created out of the other parameters and the NOT like the replace clause is always added
--  ,@crop_clause   : optional optional filter to restrict by the supplied crop using LIKE %crop%
--  ,@sql           : optional - if supplied this will used verbatim and overrides all other parameters
--                    it is used for special cases where the standard algorithm is not suitable
--  ,@exp_row_cnt   : mandatory - this is used to verify the update will update the expected number of rows
--                    if the update affects a different number of rows the the transaction is backed out and the db is in its original state
--
-- Details:
-- uses a transaction so that erroneous changes can be backed out so as not to corrupt the data in the event of the update affecting more or less rows than expected

-- db default is DB_NAME()
-- schema default is dbo
-- ======================================================================================================================================================================
ALTER   PROCEDURE [dbo].[sp_s2_import_correction]
    @txn_id          VARCHAR(60)   = ''
   ,@search_clause   VARCHAR(1000) = NULL
   ,@replace_clause  VARCHAR(1000) = NULL
   ,@not_clause      VARCHAR(1000) = NULL
   ,@where_clause    VARCHAR(1000) = NULL
   ,@crop_clause     VARCHAR(1000) = NULL
   ,@sql             VARCHAR(4000) = NULL
   ,@exp_row_cnt     INT
AS
BEGIN
   DECLARE
       @fn              VARCHAR(35)    = 's2_imp_cor'
      ,@act_row_cnt     INT
      ,@NL              NCHAR(2) = NCHAR(13)+NCHAR(10)
      ,@select_sql      VARCHAR(4000)
      ,@update_sql      VARCHAR(4000)
      ,@cnt_sql         VARCHAR(500)
      ,@msg             VARCHAR(500)
      ,@error           INT
      ,@message         VARCHAR(4000)
      ,@error_type      VARCHAR(100) = ''
      ,@xstate          INT

   PRINT CONCAT(@NL,'-------------------------------------------------------------------------------------------------',@NL);
   EXEC sp_log 2, @fn, '000: txn_id: ',@txn_id, ' starting:
search_clause: [',@search_clause , ']
replace_clause:[',@replace_clause, ']
where_clause:  [',@where_clause  , ']
crop_clause:   [',@crop_clause   , ']
sql:           [',@sql           , ']
exp_row_cnt:   [',@exp_row_cnt   , ']'
;

   SET XACT_ABORT ON;

      ---------------------------------------------------------------------------------------
      -- Validate the parameters: either sql or (@search_clause, @crop_clause) are specified
      ---------------------------------------------------------------------------------------

   EXEC sp_log 1, @fn, '010:  Validating parameters   ';
   IF @sql IS NULL
   BEGIN
      EXEC sp_assert_not_null_or_empty @search_clause, '@search_clause';
      EXEC sp_assert_not_null_or_empty @crop_clause  , '@crop_clause';
   END

      ---------------------------------------
      -- ASSERTION: Validated the parameters
      ---------------------------------------
   EXEC sp_log 1, @fn, '020:  Validated parameters: OK';
   EXEC sp_log 1, @fn, '030: processing update';

   BEGIN TRY
      WHILE 1=1
      BEGIN
         IF @sql IS NOT NULL
         BEGIN
            SET @error_type = 'Update';
            EXEC sp_log 1, @fn, '040: running sql command:';
            EXEC(@sql);
            SET @act_row_cnt = @@ROWCOUNT;
            EXEC sp_log 1, @fn, '050:  sql command ran OK, updated ',@act_row_cnt, ' rows';
            BREAK;
         END

      ------------------------------------------------
      -- ASSERTION @sql not supplied
      ------------------------------------------------
        EXEC sp_log 1, @fn, '060: running using non sql parameters';
      ------------------------------------------------
      -- Build the WHERE clause
      ------------------------------------------------
      -- add in the search filter AND a filter to stop us updating rows that match the replace clause
      -- This may back fire if the replace clause is a subset of the search clause
         IF @where_clause IS NULL SET @where_clause= CONCAT('pathogens LIKE ''%',@search_clause,'%'' AND pathogens NOT LIKE ''%',@replace_clause,'%''');

      -- Add in the not clause
         IF @not_clause IS NOT NULL
         SET @where_clause= CONCAT(@where_clause, ' AND pathogens NOT LIKE ''%',@not_clause, '%''');

      -- Add in the crop filter
         IF @crop_clause IS NOT NULL SET @where_clause= CONCAT(@where_clause, ' AND crops LIKE ''%',@crop_clause, '%''');

         ------------------------------------------------
         -- 10: Select the rows that will be updated
         ------------------------------------------------
         SET @select_sql = CONCAT('SELECT id, pathogens, crops FROM Staging2 WHERE ', @where_clause);
         EXEC sp_log 1, @fn, '070:  executing select_sql: ',@NL,  @select_sql;
         EXEC (@select_sql);

         SELECT @cnt_sql = CONCAT('SELECT @act_row_cnt = COUNT(*) FROM Staging2 WHERE ', @where_clause);
         EXEC sp_log 1, @fn, '080: executing the count select sql:',@NL, @cnt_sql;
         EXEC sp_executesql @cnt_sql, N'@act_row_cnt INT OUT', @act_row_cnt OUT;
         EXEC sp_log 1, @fn, '090: select act updated row count: ',@act_row_cnt;

         -------------------------------------------------------------------------
         -- Check the view count is as expected
         -------------------------------------------------------------------------
         EXEC sp_log 4, @fn, '100: checking view row count = expected row count';
         IF @act_row_cnt <> @exp_row_cnt
         BEGIN
            EXEC sp_log 4, @fn, '110: ERROR: EXPECTED to be able to find ',@exp_row_cnt,' rows to select for update, but actually found ', @act_row_cnt, ' rows so rolling back txn';
            --ROLLBACK TRANSACTION Trans1;
            SET @error_type = 'Find';
            BREAK;
         END

         ------------------------------------------------
         -- ASSERTION: the view count is as expected
         ------------------------------------------------
         EXEC sp_log 4, @fn, '120: view row count matched expected row count OK';

         ------------------------------------------------
         -- Do the update
         ------------------------------------------------
         EXEC sp_log 4, @fn, '130: running the update';
         SET @update_sql = CONCAT('UPDATE Staging2 SET Pathogens = REPLACE(pathogens, ''',@search_clause, ''',''',@replace_clause, ''') WHERE ',@where_clause, ';');
         EXEC sp_log 1, @fn, '140: @update_sql: ', @NL, @update_sql;

         BEGIN TRANSACTION Trans1
            BEGIN TRY
               EXEC (@update_sql);
               SET @act_row_cnt = @@ROWCOUNT;

               IF @act_row_cnt = @exp_row_cnt
               BEGIN
                  -- update exp/act count match
                  COMMIT TRANSACTION Trans1;
                  EXEC sp_log 1, @fn, '170: exp/act update row count matched OK, so committing txn';
               END
               ELSE
               BEGIN
                  ROLLBACK TRANSACTION Trans1;
                  -- update exp/act count mismatch
                  EXEC sp_log 1, @fn, '180: exp/act update row count mismatch, so rolling back txn';
               END
            END TRY
            BEGIN CATCH
               ROLLBACK TRANSACTION Trans1;

               SELECT 
                   @error   = ERROR_NUMBER()
                  ,@message = ERROR_MESSAGE()
                  ,@xstate  = XACT_STATE()
               ;

               EXEC sp_log 4, @fn, '500: caught exception: ', @error, ', ',@message;
               EXEC sp_log 4, @fn, 'caught exception, so rolling back txn';
               THROW;
            END CATCH
         EXEC sp_log 1, @fn, '150: updated ', @act_row_cnt, ' ROWS';

         ------------------------------------------------
         -- Check the update count is as expected
         ------------------------------------------------
         EXEC sp_log 4, @fn, '160: checking update row count: exp row count: ',@exp_row_cnt, ' = act row cnt: ', @act_row_cnt;

         ------------------------------------------------
         -- ASSERTION: the update count is as expected
         ------------------------------------------------
         BREAK; -- Always
      END
   END TRY
   BEGIN CATCH
      SELECT 
          @error   = ERROR_NUMBER()
         ,@message = ERROR_MESSAGE()
         ,@xstate  = XACT_STATE()
      ;

      EXEC sp_log 4, @fn, '500: caught exception: ', @error, ', ',@message;
      EXEC sp_log 4, @fn, 'caught exception, so rolling back txn';
      --ROLLBACK TRANSACTION Trans1;
--      RAISERROR ('sp_s2_import_correction: %d: %s', 16, 1, @error, @message) ;
      THROW;
   END CATCH

   -- Do this for all non exception cases

   ------------------------------------------------
   -- Check the update count is as expected
   ------------------------------------------------
   EXEC sp_log 1, @fn, '800: checking exp/act update row counts';

   IF @act_row_cnt <> @exp_row_cnt
   BEGIN
      SET @msg = CONCAT('Error: failed to ',@error_type, ' the expected number of rows, expected ', @exp_row_cnt, ' rows, but actual: ',@act_row_cnt,' rows');
      EXEC sp_log 4, @fn, '810: raisig exception: ', 65032, ', ',@message;
      THROW 65032, @msg, 1;
   END

   EXEC sp_log 4, @fn, '830:exp/act row counts matched';

   ------------------------------------------------
   -- ASSERTION: SUCCESS
   ------------------------------------------------
   EXEC sp_log 2, @fn, '999 leaving, OK';
   PRINT CONCAT(@NL,'-------------------------------------------------------------------------------------------------',@NL);
END
/*
EXEC sp_s2_import_correction @search_clause='Shootborer/fruitborer', @replace_clause='eggplant fruit shoot borer', @where_clause='pathogens LIKE ''%Shootborer/fruitborer%''', @exp_row_cnt=5;
SELECT COUNT(*) FROM Staging2 WHERE pathogens LIKE '%Shootborer/fruitborer%'
*/


GO
