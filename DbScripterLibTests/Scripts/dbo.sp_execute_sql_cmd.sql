SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===============================================================
-- Author:      Terry Watts
-- Create date: 06-JUL-2023
-- Description: Performs the SQL operation
--
-- PRECONDITIONS: none
--
-- POSTCONDITIONS:
-- 
--
-- CALLER:      sp_fixup_import_register_row
--
-- CHANGES
-- 230819: removing the expected count get and check
-- 230816: changed param name from @fixup_cnt to @row_count
-- ===============================================================
ALTER PROCEDURE [dbo].[sp_execute_sql_cmd]
     @doit            BIT 
   , @table           NVARCHAR(50)
   , @result_msg      NVARCHAR(500)  OUTPUT
   , @row_count       INT            OUTPUT
   , @sql             NVARCHAR(MAX)
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(20)  = N'EXEC_SQL_CMD'
      ,@msg          NVARCHAR(MAX)
      ,@where_clause NVARCHAR(MAX)
      ,@nl           NVARCHAR(2) = NCHAR(10)+NCHAR(13)
      ,@ndx          INT = 0
      ,@rc           INT = -1
      ,@stage        INT = 1;

   SET NOCOUNT OFF;
   EXEC sp_log 1, @fn, 'starting'

   BEGIN TRY
      WHILE 1=1
      BEGIN
         --SET @act_cnt = -1;
         -- Occasionally the cursor get witl wrap the sql in double quotes
         SET @sql = ut.dbo.fnTrim2(@sql, '"');

         -- Replace <TABLE> with staging2
         SET @sql = REPLACE(@sql, '<TABLE>', 'staging2');
         SET @ndx = CHARINDEX('WHERE', @sql);
         SET @where_clause = CONCAT(' ', substring( @sql, @ndx, ut.dbo.fnLen(@sql) - @ndx + 1)); 
         EXEC sp_log 0, @fn, 'SQL COMMAND sql         : [', @sql         , ']';
         EXEC sp_log 0, @fn, 'SQL COMMAND Where clause: [', @where_clause, ']';

         SET @stage =2
         EXEC sp_log 0, @fn, 'sp_execute_sql_cmd: stage 2: executing cnt sql';

         IF @doit = 1
         BEGIN
            SET @stage = 3;
            EXEC sp_log 0, @fn, 'stage 3: executing update sql';
            EXEC sp_log 0, @fn, 'UPDATE SQL             : [', @sql        , ']';
            EXEC @rc = sp_executesql @sql; -- Msg 103, Level 15, State 4, Line 156 The identifier that starts with 'update dbo.staging SET notes   = '(STEM and MAT spray application of mealy bugs)' , pathogens = REPLACE(pathogens, '(STEM and MA' is too long. Maximum length is 128.
            SET @row_count = @@ROWCOUNT;
   
            IF @rc = 0
            BEGIN
               EXEC sp_log 0, @fn, '@fixup_cnt: ', @row_count, ' rows';
                SET @result_msg = 'OK';
            END
            ELSE
               BEGIN  
                  SET @msg = ERROR_MESSAGE();
                  -- Return -1 to the calling program to indicate failure.  
                  SET @result_msg = CONCAT('sp_execute_sql_cmd UPDATE SQL failed, error: ', @msg);  
                  SET @rc = -1;  
                  BREAK;
               END  
            END
          
         ELSE -- IF @doit = 1
         BEGIN
            SET @result_msg = 'Not processing command (@doit=0)';
         END

         SET @stage = 4;
         EXEC sp_log 0, @fn, 'stage 4: executed both sqls OK';
         SET @result_msg = 'OK';
         BREAK;
      END -- WHILE 1
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, 'leaving, updated ', @row_count, ' rows,  @rc:', @rc;
   RETURN @rc;
END

GO
