SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

ALTER FUNCTION [dbo].[fnGetX](
   @id int)
RETURNS TABLE
AS RETURN
(
   SELECT chars.C, ASCII(chars.C)  phi FROM staging2 
   CROSS APPLY dbo.fnGetChars (phi) as chars
   where stg2_id = @id
)

GO
