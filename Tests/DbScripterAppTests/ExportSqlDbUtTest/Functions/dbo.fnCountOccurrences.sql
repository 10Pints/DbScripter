SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================
-- Author:      Terry Watts
-- Create date: 14-JAN-2023
-- Description: counts the occurrences of a token
--              in a string
--
-- POST 1: returns the count of @token in @string
-- POST 2: special case: null or empty tokens should return 0 count
-- ==================================================================
CREATE FUNCTION [dbo].[fnCountOccurrences]
(
    @string NVARCHAR(MAX)
   ,@token  NVARCHAR(MAX)
)
RETURNS INT
AS
BEGIN
   DECLARE @n INT
   -- special case: null or empty tokens should return 0 count
   IF DATALENGTH(@token) = 0 RETURN 0;
   SET @n = COALESCE((DATALENGTH(@string)-DATALENGTH(REPLACE(@string, @token,N'')))/DATALENGTH(@token), 0);
   -- Return the result of the function
   RETURN @n;
END
/*
EXEC tSQLt.Run 'test.test_035_fnCountOccurrences'
*/
GO

