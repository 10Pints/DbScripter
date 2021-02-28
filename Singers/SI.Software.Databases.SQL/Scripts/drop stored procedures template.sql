-- drop stored procedures template.sql v1.0.0.0
-- this routine drops the user procedures for any database

SET NOCOUNT ON
DECLARE @UserStoredProcedure    VARCHAR(100)
DECLARE @Command                VARCHAR(100)

DECLARE UserStoredProcedureCursor CURSOR SCROLL STATIC READ_ONLY FOR
SELECT
    SPECIFIC_NAME
FROM
    INFORMATION_SCHEMA.ROUTINES
WHERE 
    ROUTINE_TYPE = 'PROCEDURE' AND SPECIFIC_SCHEMA='dbo'

OPEN UserStoredProcedureCursor

FETCH NEXT FROM UserStoredProcedureCursor
INTO @UserStoredProcedure
WHILE (@@FETCH_STATUS = 0) BEGIN
       SET @Command = 'DROP PROCEDURE ' + @UserStoredProcedure

         -- display; visual check
         SELECT @Command

       -- when you are ready to execute, uncomment below
       EXEC (@Command)

       FETCH NEXT FROM UserStoredProcedureCursor
       INTO @UserStoredProcedure
END


 CLOSE UserStoredProcedureCursor
 DEALLOCATE UserStoredProcedureCursor

 SET NOCOUNT OFF