SET ANSI_NULLS OFF

SET QUOTED_IDENTIFIER OFF

GO
ALTER FUNCTION [dbo].[Regex_Options](@IgnoreCase [bit], @MultiLine [bit], @ExplicitCapture [bit], @Compiled [bit], @SingleLine [bit], @IgnorePatternWhitespace [bit], @RightToLeft [bit], @ECMAScript [bit], @CultureInvariant [bit])
RETURNS [int] WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [RegEx].[Regex].[Regex_Options]

GO
