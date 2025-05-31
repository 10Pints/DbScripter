SET ANSI_NULLS OFF

SET QUOTED_IDENTIFIER OFF

GO
ALTER FUNCTION [dbo].[Regex_Match_Count_Opt](@input [nvarchar](max), @pattern [nvarchar](max), @options [int])
RETURNS [int] WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [RegEx].[Regex].[Regex_Match_Count_Opt]

GO
