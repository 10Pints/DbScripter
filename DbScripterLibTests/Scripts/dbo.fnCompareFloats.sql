SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =================================================================
-- Author:      Terry Watts
-- Create date: 04-JAN-2021
-- Description: determines if 2 floats are approximately equal
-- Returns    : 1 if a significantly gtr than b
--              0 if a = b with the signifcance of epsilon 
--             -1 if a significantly less than b within +/- Epsilon, 0 otherwise
-- =================================================================
ALTER FUNCTION [dbo].[fnCompareFloats](@a FLOAT, @b FLOAT)
RETURNS INT
AS
BEGIN
   RETURN
      dbo.fnCompareFloats2(@a, @b, 0.00001);
END
/*
*/

GO
