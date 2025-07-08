SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===========================================================
-- Author:      Terry Watts
-- Create date: 16-AUG-2023
-- Description: Gets the chars and ASCII codes for the pathogens
--              at id in Staging2.
-- ===========================================================
CREATE FUNCTION [dbo].[fnGetPathogenChars](
   @id int)
RETURNS TABLE
AS RETURN
(
   SELECT chars.C, ASCII(chars.C) as [ascii] FROM staging2 
   CROSS APPLY dbo.fnGetChars (pathogens) as chars
   where id = @id
)
/*
SELECT * FROM dbo.[fnGetPathogenChars](3730)
*/

GO
