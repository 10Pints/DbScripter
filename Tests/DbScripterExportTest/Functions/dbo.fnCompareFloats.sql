SET ANSI_NULLS ON
GO
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
CREATE FUNCTION [dbo].[fnCompareFloats](@a FLOAT(24), @b FLOAT(24))
RETURNS INT
AS
BEGIN
   RETURN
      dbo.fnCompareFloats2(@a, @b, 0.00001);
END
/*
*/
GO

