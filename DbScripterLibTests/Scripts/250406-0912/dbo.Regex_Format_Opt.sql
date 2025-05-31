SET ANSI_NULLS OFF

SET QUOTED_IDENTIFIER OFF

GO
ALTER FUNCTION [dbo].[Regex_Format_Opt](@input [nvarchar](max), @pattern [nvarchar](max), @format [nvarchar](max), @options [int])
RETURNS [nvarchar](max) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [RegEx].[Regex].[Regex_Format_Opt]

GO
