SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================================================
-- Author:      Terry watts=
-- Create date: 13-NOV-2024
-- Description: fixes up the creation and modification dates
--              in the Eppo staging tables
--
-- RESPONSIBILITIES:
-- R01: Puts dates in the right format to implicitly import into tables
-- R02: if a group or name type table then filter out rows with unwanted languages
--
-- POSTCONDITIONS: (self checked)
-- POST01: dates are in the right format or (error msg logged and return error code 1) OR
-- POST02: if group or name table then  unwanted languages filtered out or returm error code 1
--         and error msg logged  OR
-- POST03: if successful return 0
-- ===========================================================================================
CREATE   PROCEDURE [dbo].[sp_eppo_fixup_stgng_dates]
   @table VARCHAR(60)
AS
BEGIN
   SET NOCOUNT OFF;
   DECLARE
       @fn  VARCHAR(35)   = 'sp_eppo_fixup_stgng_dates'
      ,@sql NVARCHAR(4000)
      ,@nl  VARCHAR(2)    = NCHAR(13) + NCHAR(10)
      ,@cnt INT
      ,@rc  INT = 1 -- default: error state
   ;
   EXEC sp_log 1, @fn,'000: starting, @@trancount: ', @@trancount, '  @table: [',@table,']';
   BEGIN TRY
      BEGIN TRANSACTION;
      WHILE 1 = 1
      BEGIN
         --------------------------------------------------------------------------------
         -- R01: Puts dates in the right format to implicitly import into tables
         --------------------------------------------------------------------------------
         SET @sql =
         CONCAT
         (
            'UPDATE [', @table, N'] SET', @nl
            ,' creation     = CONCAT(SUBSTRING(creation,7,4), ''-'', SUBSTRING(creation, 4, 2), ''-'', SUBSTRING(creation, 1, 2)) ',@nl
            ,',modification = iif(modification = '''', modification, CONCAT(SUBSTRING(modification,7,4), ''-'', SUBSTRING(modification, 4, 2), ''-'', SUBSTRING(modification, 1, 2)))
            WHERE TRY_CONVERT(DATE, creation) IS NULL OR TRY_CONVERT(DATE, modification) IS NULL;'
         );
         EXEC sp_log 1, @fn,'010: SQL;', @nl, @sql;
         EXEC(@sql);
         SET @cnt = @@ROWCOUNT;
         EXEC sp_log 1, @fn,'020: updated ', @cnt,' rows';
         SET @cnt = 0;
         SET @sql =
         CONCAT
         (
            'SELECT @cnt = COUNT(*) FROM [', @table,']', @nl
            ,'WHERE TRY_CONVERT(DATE, creation) IS NULL OR TRY_CONVERT(DATE, modification) IS NULL;'
         );
         EXEC sp_log 1, @fn,'030: about to run date conversion check SQL'; --, @nl, @sql;
         EXEC sp_executesql @sql, N'@cnt INT OUT', @cnt OUT;
         IF @cnt > 0
         BEGIN
            EXEC sp_log 4, @fn, '040: ',@cnt,' dates still exist with the wrong format in ', @table, ' after fixup, so rolling back the fixup txn';
            SET @sql =
            CONCAT
            (
               'SELECT * FROM [', @table,']', @nl
               ,'WHERE TRY_CONVERT(DATE, creation) IS NULL OR TRY_CONVERT(DATE, modification) IS NULL;'
            );
            EXEC(@sql);
            ROLLBACK TRANSACTION;
            BREAK;
         END
         ------------------------------------------------------
         -- ASSERTION first job (responsibility R01) completed
         ------------------------------------------------------
         -----------------------------------------------------------------------------------
         -- R02: if a group or name type table then filter out rows with unwanted languages
         -----------------------------------------------------------------------------------
         IF @table LIKE '%Group' OR @table LIKE '%Name'
         BEGIN
            EXEC sp_log 1, @fn, '050: filtering out rows with unwanted languages';
            SET @sql = CONCAT('DELETE FROM [',@table,'] WHERE lang not in (''en'', ''la'')) ');
            EXEC(@sql);
            ---------------------------
            -- ASSERTION @cnt IS  NULL
            ---------------------------
            SET @sql = CONCAT('SELECT @cnt=1 FROM [',@table,'] WHERE lang not in (''en'', ''la''))');
            EXEC sp_log 1, @fn,'060: about to run lang check SQL'; 
            EXEC sp_executesql @sql, N'@cnt INT OUT', @cnt OUT;
            IF @cnt IS NOT NULL
            BEGIN
               EXEC sp_log 4, @fn, '070: language other (en or la) still exists in ', @table, ' after fixup, so rolling back the fixup txn';
               ROLLBACK TRANSACTION;
               BREAK;
            END
         END -- R02
         --------------------------------------------------------
         -- ASSERTION second job (responsibility R02) completed
         -- so good to commit updates
         --------------------------------------------------------
         EXEC sp_log 1, @fn, '080: ', @table,' fixup successful';
         COMMIT TRANSACTION;
         SET @rc = 0; -- flag success
         BREAK;
      END -- while 1=1
      EXEC sp_log 1, @fn,'050: completed process';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn, ' 550: caught exception, @@trancount: ', @@trancount, ' @sql:', @nl, @sql;
      ROLLBACK TRANSACTION;
      THROW;
   END CATCH
   EXEC sp_log 2, @fn,'999: leaving, ret: ',@rc;
END
/*
EXEC sp_eppo_fixup_stgng_dates 'EPPO_GafGroupStaging';
EXEC tSQLt.Run 'test.test_023_sp_eppo_fixup_stgng_dates';
*/
GO

