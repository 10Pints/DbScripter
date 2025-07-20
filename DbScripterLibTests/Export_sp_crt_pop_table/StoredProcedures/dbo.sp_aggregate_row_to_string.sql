SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

--====================================================================================
-- Author:           Terry Watts in concert with ChapGPT
-- Create date:      10-Jul-2025
-- Rtn:              test.test_061_sp_aggregate_row_to_string
-- Description: main test routine for the dbo.sp_aggregate_row_to_string routine 
--====================================================================================
CREATE PROCEDURE [dbo].[sp_aggregate_row_to_string]
    @TableName   SYSNAME,
    @WhereClause NVARCHAR(MAX), -- e.g., 'ID = 1'
    @Sep         NVARCHAR(10) = ',',  -- separator between columns
    @Result      NVARCHAR(MAX) OUTPUT
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX) = '';
    DECLARE @colExpr NVARCHAR(MAX) = '';
    DECLARE @sepLiteral NVARCHAR(20) = QUOTENAME(@sep, ''''); -- e.g. ',' → "','"
    SET @sep = ISNULL(@Sep, ',');

    -- Cursor to loop over all columns
    DECLARE col_cursor CURSOR FOR
    SELECT name
    FROM sys.columns
    WHERE object_id = OBJECT_ID(@TableName);

    DECLARE @col SYSNAME;
    DECLARE @first BIT = 1;

    OPEN col_cursor;
    FETCH NEXT FROM col_cursor INTO @col;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @first = 1
        BEGIN
            SET @colExpr = CONCAT('ISNULL(CAST(', QUOTENAME(@col), ' AS NVARCHAR(MAX)), '''')');
            SET @first = 0;
        END
        ELSE
        BEGIN
            SET @colExpr = CONCAT(@colExpr, ' + ', @sepLiteral, ' + ISNULL(CAST(', QUOTENAME(@col), ' AS NVARCHAR(MAX)), '''')');
        END

        FETCH NEXT FROM col_cursor INTO @col;
    END

    CLOSE col_cursor;
    DEALLOCATE col_cursor;

    -- Build the final dynamic SQL
    SET @sql = '
        SELECT @ResultOut = ' + @colExpr + '
        FROM ' + QUOTENAME(@TableName) + '
        WHERE ' + @WhereClause;

    -- Execute it
    EXEC sp_executesql
        @sql,
        N'@ResultOut NVARCHAR(MAX) OUTPUT',
        @ResultOut = @Result OUTPUT;
END

/*
DECLARE @act_file_cols NVARCHAR(MAX);
EXEC sp_aggregate_row_to_string 'Enrollment','enrollment_id = 1',',', @act_file_cols OUTPUT;
PRINT @act_file_cols;

SELECT * FROM Enrollment WHERE enrollment_id = 1;
--> 12023-1908112

EXEC test.sp__crt_tst_rtns '[dbo].[sp_aggregate_row_to_string]';
*/

GO
