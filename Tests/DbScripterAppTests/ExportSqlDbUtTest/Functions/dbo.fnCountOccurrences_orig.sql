SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnCountOccurrences_orig] 
(
	 @string NVARCHAR(MAX)
   ,@token  NVARCHAR(MAX)
)
RETURNS int
AS
BEGIN
   RETURN COALESCE((DATALENGTH(@string)-DATALENGTH(REPLACE(@string, @token,N'')))/DATALENGTH(@token), 0);
END
GO

