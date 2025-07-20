SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==================================================
-- Author:      Terry Watts
-- Create date: 24-MAR-2025
-- Description: returns Last Index of a str in a str
-- or 0 if not found
-- ==================================================
CREATE FUNCTION [dbo].[fnFindLastIndexOf](@searchFor VARCHAR(100),@searchIn VARCHAR(500))
RETURNS INT
AS
BEGIN
   IF LEN(@searchfor) > LEN(@searchin)
      RETURN 0;

   DECLARE @r VARCHAR(500), @rsp VARCHAR(100)
   SELECT @r   = REVERSE(@searchin)
   SELECT @rsp = REVERSE(@searchfor)
   RETURN len(@searchin) - charindex(@rsp, @r) - len(@searchfor)+1;
END

GO
