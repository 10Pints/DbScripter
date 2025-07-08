SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 04-DEC-2024
-- Description: takes a string like
-- 'a1:5248,b2:15964,c345:32528,d67:9929'
-- and makes a map of the key value pairs it contains
-- returning it as a table.
-- ==============================================================================
CREATE   FUNCTION [dbo].[fnSplitKeyValuePairs]
(
   @s    VARCHAR(4000)
  ,@sep1 VARCHAR(1) -- separator used between the kv pairs
  ,@sep2 VARCHAR(1) -- separates the key from the value in each kv pair
)
RETURNS
@t TABLE
(
    ordinal INT
   ,[key]   VARCHAR(4000)
   ,value   VARCHAR(4000)
)
AS
BEGIN
   WITH cte
   AS
   (
      SELECT ordinal, TRIM(value) AS value
      FROM string_split(@s, @sep1,1)
      WHERE dbo.fnLen(TRIM(value)) >0
   )
   INSERT INTO @t(ordinal, [key], value)
   (
      SELECT ordinal, SUBSTRING([value], 1,CHARINDEX(@sep2, value)-1) AS [key], SUBSTRING([value], CHARINDEX(@sep2, value)+1, 900) AS [value]
      FROM cte
   );

   RETURN;
END
/*
SELECT * FROM  dbo.fnSplitKeys('a1:5248,b2:15964,c345:32528,d67:9929', ','', ',');
*/


GO
