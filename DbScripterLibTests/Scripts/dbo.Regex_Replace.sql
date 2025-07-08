SET ANSI_NULLS OFF

SET QUOTED_IDENTIFIER OFF

GO

CREATE FUNCTION [dbo].[Regex_Replace](@input [nvarchar](max), @pattern [nvarchar](max), @replacement [nvarchar](max))
RETURNS [nvarchar](max) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [RegEx].[Regex].[Regex_Replace]

GO
