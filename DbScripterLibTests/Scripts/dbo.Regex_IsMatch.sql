SET ANSI_NULLS OFF

SET QUOTED_IDENTIFIER OFF

GO

CREATE FUNCTION [dbo].[Regex_IsMatch](@input [nvarchar](max), @pattern [nvarchar](max))
RETURNS [bit] WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [RegEx].[Regex].[Regex_IsMatch]

GO
