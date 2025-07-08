SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 18-OCT-2024
-- Description: 
-- =============================================
CREATE   FUNCTION [dbo].[fnSplitKeys]
(
   @keys VARCHAR(4000)
  ,@sep1 VARCHAR(1)
)
RETURNS
@t TABLE
(
    val VARCHAR(4000)
   ,ordinal INT
)
AS
BEGIN
   INSERT INTO @t 
   SELECT value, ordinal
   FROM string_split(@keys, @sep1, 1)
   WHERE value <> '';
   RETURN;
END
/*
SELECT * FROM  dbo.fnSplitKeys('crops:LIKE Mungbeans', ',', NULL);
*/


GO
