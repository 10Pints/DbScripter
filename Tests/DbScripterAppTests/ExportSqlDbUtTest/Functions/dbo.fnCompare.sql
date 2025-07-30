SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================================
-- Author:      Terry Watts
-- Create date: 13-JAN-2020
-- Description: compares 2 strings character by character case sensitve
-- RETURNS  0 if MATCH
--          index of the first mismatch character
-- =====================================================================
CREATE FUNCTION [dbo].[fnCompare]
(
       @s1           VARCHAR(8000)
      ,@s2           VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
   DECLARE
       @i            INT = 0
      ,@len1         INT = dbo.fnLEN(@s1)
      ,@len2         INT = dbo.fnLEN(@s2)
      ,@len_min      INT
   SET @len_min = dbo.fnMin(@len1, @len2);
   IF (@s1 IS NULL) AND (@s2 IS NULL)
      RETURN 0;
   IF ((@s1 IS NULL) AND (@s2 IS NOT NULL)) OR ((@s1 IS NOT NULL) AND (@s2 IS NULL))
      RETURN 1;
   -- Do a character by character comparison of the common characters
   --  in each string before comparing the lengths to find first mismatch
   WHILE @i <= @len_min
   BEGIN
      IF ASCII( SUBSTRING(@s1, @i, 1)) <> ASCII( SUBSTRING(@s2, @i, 1))
         RETURN @i;
      SET @i = @i + 1;
   END
   -- Assertion character match on the common string - so return the min len
   IF @len1 <> @len2
      RETURN dbo.fnMin(@len1, @len2) + 1;
   RETURN 0;
END
GO

