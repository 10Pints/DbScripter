SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 09-DEC-2019
-- Description: splits a string of items separated
-- by a character into a list (table)
-- the lines include a NL if one existed in source code
-- if max(st)=Len(txt) -> there was a trailing NL
-- (on the last row)
-- =============================================
CREATE FUNCTION [dbo].[fnSplit]
(
   @string     NVARCHAR(4000),
   @delimiter  NVARCHAR(2) = ','
)
RETURNS TABLE
AS
RETURN
(
   WITH Split(stpos,endpos)
   AS
   (
      SELECT
         1 AS stpos,       CHARINDEX(@Delimiter, @string) AS endpos
      UNION ALL
         SELECT endpos+1,  iif(CHARINDEX(@Delimiter, @string, endpos+1)> 0, CHARINDEX(@Delimiter, @string, endpos+1), len(@string)+1)
         FROM Split
     WHERE endpos < len(@string)
   )
   -- SELECT * FROM Split
   SELECT 
   'id'     = ROW_NUMBER() OVER (ORDER BY (SELECT 1)), 'st' = stpos, 'end' = endpos
   ,'Line'   = iif(stpos<> 0  AND [endpos] <> 0, SUBSTRING( @string, stpos, iif([endpos] = 0, len(@string), [endpos])-stpos), NULL)
   ,'has_nl' = iif(stpos = LEN(@string), 0, 1)
   FROM Split
   WHERE endpos IS NOT NULL AND endpos <> 0
)
GO

