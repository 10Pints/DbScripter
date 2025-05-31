SET ANSI_NULLS OFF

SET QUOTED_IDENTIFIER OFF

GO
ALTER FUNCTION [dbo].[Regex_IsMatch_Opt](@input [nvarchar](max), @pattern [nvarchar](max), @options [int])
RETURNS [bit] WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [RegEx].[Regex].[Regex_IsMatch_Opt]

GO
