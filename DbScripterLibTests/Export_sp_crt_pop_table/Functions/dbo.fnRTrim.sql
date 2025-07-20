SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO




-- ==========================================================================
-- Author:      Terry Watts
-- Create date: 08-JAN-2020
-- Description: Removes specific characters from the right end of a string
-- 23-JUN-2023: Fix handle all wspc like spc, tab, \n \r CHAR(160)
-- ==========================================================================
CREATE FUNCTION [dbo].[fnRTrim]
(
   @s VARCHAR(MAX)
)
RETURNS  VARCHAR(MAX)
AS
BEGIN
   DECLARE  
       @tcs    VARCHAR(20)

   IF (@s IS NULL ) OR (LEN(@s) = 0)
      RETURN @s;

   SET @tcs = CONCAT( NCHAR(9), NCHAR(10), NCHAR(13), NCHAR(32), NCHAR(160))

   WHILE CHARINDEX(Right(@s, 1) , @tcs) > 0 AND dbo.fnLen(@s) > 0 -- SUBSTRING(@s,  dbo.fnLen(@s)-1, 1) or Right(@s, 1)
      SET @s = SUBSTRING(@s, 1, dbo.fnLen(@s)-1); -- SUBSTRING(@s, 1, dbo.fnLen(@s)-1) or Left(@s, dbo.fnLen(@s)-1)

   RETURN @s;
END




GO
