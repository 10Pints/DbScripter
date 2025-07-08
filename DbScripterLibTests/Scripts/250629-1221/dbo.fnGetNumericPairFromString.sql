SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==================================================================
-- Author:      Terry Watts
-- Create date: 06-AUG-2023
-- Description: Gets teh first numeric pair from a string 
-- e.g: dbo.fnGetNumericPairFromString('234 thf 15-24 5') -< 15-24
-- ==================================================================
CREATE   FUNCTION [dbo].[fnGetNumericPairFromString] ( @s VARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS
BEGIN
   DECLARE @pr VARCHAR(50)
   SET @pr = (SELECT TOP 1 value FROM dbo.fnGetNumericPairsFromString(@s));
   RETURN @pr
END
/*
PRINT dbo.fnGetNumericPairFromString('some other text 14 days before harvest fpr potato. 7 days before 8-15 harvest for 2-16 onion')
*/


GO
