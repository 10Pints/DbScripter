SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================================================
-- Author:      Terry Watts
-- Create date: 04-JAN-2021
-- Description: mockup sp for fn to aid debugging
--  determines if 2 floats are approximately equal
-- Returns    : 1 if a significantly gtr than b
--              0 if a = b with the signifcance of epsilon 
--             -1 if a significantly less than b within +/- Epsilon, 0 otherwise
-- DROP FUNCTION [dbo].[fnCompareFloats2]
-- ============================================================
CREATE PROC [dbo].[spfnCompareFloats2]
    @a         FLOAT
   ,@b         FLOAT
   ,@epsilon   FLOAT = 0.00001
AS
BEGIN
   DECLARE
       @fn     NVARCHAR(35)  = N'spfnCompareFloats2'
      ,@diff   FLOAT
      ,@res    INT
   EXEC sp_log 1, @fn, '01: starting 
@a      :[', @a, ']
@b      :[', @b, ']
@epsilon:[', @epsilon,']'
;
   SET @diff   = abs(@a - @b);
   EXEC sp_log 1, @fn, '02 diff: abs(@a - @b) = [',@diff,']';
   IF(@diff < @epsilon)
   BEGIN
      EXEC sp_log 1, @fn, '05 diff < @epsilon - so a is considered = to b therfore return false 0'
      RETURN 0  -- a = b within the tolerance of epsilon - return false 0
   END
   ELSE 
      EXEC sp_log 1, @fn, '10 diff >= @epsilon - so a is considered significantly different to b, either significantly larger or significantly smaller, lets find out'
   -- ASSERTION  a is signifcantly different to b
   -- 10-7 is the tolerance for floats
   SET @diff   = round(@a - @b, 7);
   EXEC sp_log 1, @fn, '02 diff rounded to 7 dp = [',@diff,']';
   SET @res = IIF( @diff>0.0, 1, -1);
   EXEC sp_log 1, @fn, '99: leaving 
@res:[', @res, ']';
   RETURN @res;
END
/*
EXEC dbo.spfnCompareFloats2 -1.00001,   -1.0000
*/
GO

