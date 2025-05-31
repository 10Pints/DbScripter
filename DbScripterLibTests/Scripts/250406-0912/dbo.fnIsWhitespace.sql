SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===============================================================================================
-- Author:      Terry Watts
-- Create date: 13-JAN-2020
-- Description: determines if a character is whitespace
--
-- whitespace is: 
-- (NCHAR(9), NCHAR(10), NCHAR(11), NCHAR(12), NCHAR(13), NCHAR(14), NCHAR(32), NCHAR(160))
--
-- RETURNS: 1 if is whitspace, 0 otherwise
-- ===============================================================================================
ALTER   FUNCTION [dbo].[fnIsWhitespace]( @t NCHAR) 
RETURNS BIT
AS
BEGIN
   RETURN CASE WHEN  @t IN (NCHAR(9) , NCHAR(10), NCHAR(11), NCHAR(12)
                           ,NCHAR(13), NCHAR(14), NCHAR(32), NCHAR(160)) THEN 1 
               ELSE 0 END
END


GO
