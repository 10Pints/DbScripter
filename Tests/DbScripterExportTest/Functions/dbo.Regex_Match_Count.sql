SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[Regex_Match_Count](@input [nvarchar](max), @pattern [nvarchar](max))
RETURNS [int] WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [RegEx].[Regex].[Regex_Match_Count]
GO

