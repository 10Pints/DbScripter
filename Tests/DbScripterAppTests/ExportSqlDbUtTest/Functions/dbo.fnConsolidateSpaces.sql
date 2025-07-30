SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================
-- Author:      Terry Watts
-- Create date: 13-DEC-2023
-- Description: replaces multiple spaces with 1 space in a string
-- e.g.  '   just single    spaces   only' -> ' just single spaces only'
-- ======================================================================
CREATE FUNCTION [dbo].[fnConsolidateSpaces](@str NVARCHAR(4000))
RETURNS NVARCHAR(4000) AS
BEGIN 
    WHILE CHARINDEX(N'  ', @str) > 0 
        SET @str = REPLACE(@str, N'  ', N' ')
    RETURN @str;
END
/*
DECLARE @s NVARCHAR(400) = dbo.consolidate_spaces('   just single    spaces   only');
PRINT CONCAT('[',@s,']');
EXEC tSQLt.AssertEquals @s,' just single spaces only';
SET @s = dbo.consolidate_spaces(NULL);
EXEC tSQLt.AssertEquals @s, NULL;
SET @s = dbo.consolidate_spaces('');
EXEC tSQLt.AssertEquals @s, '';
SET @s = dbo.consolidate_spaces(' ');
EXEC tSQLt.AssertEquals @s, ' ';
SET @s = dbo.consolidate_spaces('  ');
EXEC tSQLt.AssertEquals @s, ' ';
*/
GO

