SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==================================================
-- Author:      Terry Watts
-- Create date: 24-MAR-2025
-- Description: returns Last Index of a str in a str
-- or 0 if not found
--
-- Tests: test.test_065_fnFindLastIndexOf
-- ==================================================
CREATE FUNCTION [dbo].[fnFindLastIndexOf]
(
    @searchFor VARCHAR(MAX)
   ,@searchIn  VARCHAR(MAX)
)
RETURNS INT
AS
BEGIN
   IF @searchFor IS NULL OR @searchIn IS NULL
      RETURN 0;

   IF dbo.fnLen(@searchFor) = 0 OR dbo.fnLen(@searchIn) = 0
      RETURN 0;

   IF LEN(@searchfor) > LEN(@searchin)
      RETURN 0;

   DECLARE
       @r   VARCHAR(500)
      ,@rsp VARCHAR(100)
      ,@pos INT

   SELECT @r   = REVERSE(@searchin);
   SELECT @rsp = REVERSE(@searchfor);
   SET @pos = CHARINDEX(@rsp, @r);

   IF(@pos = 0)
      return 0;

   RETURN len(@searchin) - @pos - dbo.fnLen(@searchfor)+2;
END
/*
EXEC tSQLt.Run 'test.test_065_fnFindLastIndexOf';

EXEC tSQLt.RunAll;
*/

GO
