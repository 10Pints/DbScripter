SET ANSI_NULLS OFF

SET QUOTED_IDENTIFIER OFF

GO
ALTER FUNCTION [dbo].[Regex_Match](@input [nvarchar](max), @pattern [nvarchar](max))
RETURNS [nvarchar](max) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [RegEx].[Regex].[Regex_Match]

GO
