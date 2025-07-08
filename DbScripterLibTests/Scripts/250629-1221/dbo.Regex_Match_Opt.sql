SET ANSI_NULLS OFF

SET QUOTED_IDENTIFIER OFF

GO

CREATE FUNCTION [dbo].[Regex_Match_Opt](@input [nvarchar](max), @pattern [nvarchar](max), @options [int])
RETURNS [nvarchar](max) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [RegEx].[Regex].[Regex_Match_Opt]

GO
