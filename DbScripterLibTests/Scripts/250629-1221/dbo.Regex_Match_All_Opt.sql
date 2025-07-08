SET ANSI_NULLS OFF

SET QUOTED_IDENTIFIER OFF

GO

CREATE FUNCTION [dbo].[Regex_Match_All_Opt](@input [nvarchar](max), @pattern [nvarchar](max), @options [int])
RETURNS  TABLE (
	[index] [int] NULL,
	[length] [int] NULL,
	[list] [nvarchar](max) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [RegEx].[Regex].[Regex_Match_All_Opt]

GO
