SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================
-- Author:      Terry Watts
-- Create date: 23-JUN-2023
-- Description: Removes specific characters from 
--              the beginning of a string
-- 23-JUN-2023: Fix handle all wspc like spc, tab, \n \r CHAR(160)
-- ==================================================================
CREATE FUNCTION [dbo].[fnLTrim]
(
    @s NVARCHAR(MAX)
)
RETURNS  NVARCHAR(MAX)
AS
BEGIN
   DECLARE  
       @tcs    NVARCHAR(20)
   IF (@s IS NULL ) OR (dbo.fnLen(@s) = 0)
      RETURN @s;
   SET @tcs = CONCAT( NCHAR(9), NCHAR(10), NCHAR(13), NCHAR(32), NCHAR(160))
   WHILE CHARINDEX(SUBSTRING(@s, 1, 1), @tcs) > 0 AND dbo.fnLen(@s) > 0
      SET @s = SUBSTRING(@s, 2, dbo.fnLen(@s)-1);
   RETURN @s;
END
/*
PRINT CONCAT('[', ut.dbo.fnTrim(' '), ']')
PRINT CONCAT('[', ut.dbo.fnLTrim(' '), ']')
PRINT CONCAT('[', ut.dbo.fnLTrim2(' ', ' '), ']')
PRINT CONCAT('[', [dbo].[fnLTrim](CONCAT(0x20, 0x09, 0x0a, 0x0d, 0x20,'a', 0x20, 0x09, 0x0a, 0x0d, 0x20,' #cd# ')), ']');
*/
GO

