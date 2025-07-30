SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================
-- Author:      Terry Watts
-- Create date: 16-JUN-2025
-- Description: checks if a word is a reserved word
--
-- Design:      Deepseek
-- Tests:       test.test_071_IsReservedWord
-- ==================================================================
CREATE FUNCTION [dbo].[IsReservedWord](@word NVARCHAR(128))
RETURNS BIT
AS
BEGIN
    DECLARE @isReserved BIT = 0;
    -- We do UPPER incase we're working in a SQL 
    SET @word = UPPER(LTRIM(RTRIM(@word)));
    SET @isReserved = 
      CASE 
         WHEN @word IN
(
  'ABS', 'ADD', 'ALL', 'ALTER', 'AND', 'ANY', 'AS', 'ASC', 'AUTHORIZATION'
, 'BACKUP', 'BEGIN', 'BETWEEN', 'BIY', 'BREAK', 'BROWSE', 'BULK', 'BY'
, 'CASCADE', 'CASE', 'CAST', 'CHAR', 'CHARINDEX', 'CHAR_LENGTH', 'CHECK', 'CHECKPOINT'
, 'CEILING', 'CLOSE', 'CLUSTERED'
, 'COALESCE', 'COLLATE', 'COL_LENGTH', 'COL_NAME', 'COLUMN', 'COMMIT', 'COMPUTE', 'CONSTRAINT'
, 'CONTAINS', 'CONTAINSTABLE', 'CONTINUE', 'CONVERT', 'CREATE'
, 'CROSS', 'CURRENT', 'CURRENT_DATE', 'CURRENT_TIME'
, 'CURRENT_TIMESTAMP', 'CURRENT_USER', 'CURSOR', 'DATABASE', 'DBCC'
, 'DEALLOCATE', 'DECLARE', 'DEFAULT', 'DELETE', 'DENY', 'DESC'
, 'DISK', 'DISTINCT', 'DISTRIBUTED', 'DOUBLE', 'DROP', 'DUMMY'
, 'DUMP', 'ELSE', 'END', 'ERRLVL', 'ESCAPE', 'EXCEPT', 'EXEC'
, 'EXECUTE', 'EXISTS', 'EXIT'
 , 'FETCH', 'FILE', 'FILLFACTOR', 'FLOAT', 'FOR'
, 'FOREIGN', 'FREETEXT', 'FREETEXTTABLE', 'FROM', 'FULL', 'FUNCTION'
, 'GOTO', 'GRANT', 'GROUP', 'HAVING', 'HOLDLOCK', 'IDENTITY'
, 'IDENTITY_INSERT', 'IDENTITYCOL', 'IF', 'IN', 'INDEX', 'INNER'
, 'INSERT', 'INT','INTERSECT', 'INTO', 'IS', 'JOIN', 'KEY', 'KILL', 'LEFT'
, 'LIKE', 'LINENO', 'LOAD', 'NATIONAL', 'NOCHECK', 'NONCLUSTERED'
, 'NOT', 'NULL', 'NULLIF', 'OF', 'OFF', 'OFFSETS', 'ON', 'OPEN'
, 'OPENDATASOURCE', 'OPENQUERY', 'OPENROWSET', 'OPENXML', 'OPTION'
, 'OR', 'ORDER', 'OUTER', 'OVER', 'PERCENT', 'PLAN', 'PRECISION'
, 'PRIMARY', 'PRINT', 'PROC', 'PROCEDURE', 'PUBLIC', 'RAISERROR'
, 'READ', 'READTEXT', 'RECONFIGURE', 'REFERENCES', 'REPLICATION'
, 'RESTORE', 'RESTRICT', 'RETURN', 'REVOKE', 'RIGHT', 'ROLLBACK'
, 'ROWCOUNT', 'ROWGUIDCOL', 'RULE', 'SAVE', 'SCHEMA', 'SELECT'
, 'SESSION_USER', 'SET', 'SETUSER', 'SHUTDOWN', 'SOME', 'STATISTICS'
, 'SYSTEM_USER', 'TABLE', 'TEXTSIZE', 'THEN', 'TO', 'TOP', 'TRANSACTION'
, 'TRIGGER', 'TRUNCATE', 'TSEQUAL', 'UNION', 'UNIQUE', 'UPDATE'
, 'UPDATETEXT', 'USE', 'USER', 'VALUES', 'VARYING', 'VIEW'
, 'WAITFOR', 'WHEN', 'WHERE', 'WHILE', 'WITH', 'WRITETEXT'
)
      THEN 1
      ELSE 0
   END
    RETURN @isReserved;
END
/*
EXEC test.test_071_IsReservedWord;
*/
GO

