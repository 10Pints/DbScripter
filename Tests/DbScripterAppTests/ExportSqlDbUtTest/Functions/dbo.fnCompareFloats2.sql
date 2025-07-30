SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================================================
-- Author:      Terry Watts
-- Create date: 04-JAN-2021
-- Description: determines if 2 floats are approximately equal
-- Returns    : 1 if a significantly gtr than b
--              0 if a = b with the signifcance of epsilon 
--             -1 if a significantly less than b within +/- Epsilon, 0 otherwise
-- DROP FUNCTION [dbo].[fnCompareFloats2]
-- ============================================================
CREATE FUNCTION [dbo].[fnCompareFloats2](@a FLOAT, @b FLOAT, @epsilon FLOAT = 0.00001)
RETURNS INT
AS
BEGIN
   DECLARE   @v      FLOAT
            ,@res    INT
   SET @v   = abs(@a - @b);
   IF(@v < @epsilon)
      RETURN 0;  -- a = b within the tolerance of epsilon
   -- ASSERTION  a is signifcantly different to b
   -- 10-7 is the tolerance for floats
   SET @v   = round(@a - @b, 7);
   SET @res = IIF( @v>0.0, 1, -1);
   RETURN @res;
END
/*
EXEC test.sp_crt_tst_rtns 'dbo].[fnCompareFloats2', 80
-- Test
-- cmp > tolerance
PRINT CONCAT('[dbo].[fnCompareFloats2](1.2, 1.3, 0.00001)          : ', [dbo].[fnCompareFloats2](1.2, 1.3, 0.00001),       ' T01: EXP -1')
PRINT CONCAT('[dbo].[fnCompareFloats2](1.2, 1.2, 0.00001)          : ', [dbo].[fnCompareFloats2](1.2, 1.2, 0.00001),       '  T02: EXP  0')
PRINT CONCAT('[dbo].[fnCompareFloats2](1.3, 1.2, 0.00001)          : ', [dbo].[fnCompareFloats2](1.3, 1.2, 0.00001),       '  T03: EXP  1')
PRINT CONCAT('[dbo].[fnCompareFloats2](0.1,      0.1 , 0.00001)    : ', [dbo].[fnCompareFloats2](0.1,       0.1, 0.00001), '  T04: EXP  0')
PRINT CONCAT('[dbo].[fnCompareFloats2](0.10001,  0.1 , 0.00001)    : ', [dbo].[fnCompareFloats2](0.10001,   0.1, 0.00001), '  T05: EXP  0')
PRINT CONCAT('[dbo].[fnCompareFloats2](0.1,  0.000009, 0.00001)    : ', [dbo].[fnCompareFloats2](0.1,  0.100009, 0.00001), '  T06 in tolerance: EXP  0')
PRINT CONCAT('[dbo].[fnCompareFloats2](0.1,  0.10001 , 0.00001)    : ', [dbo].[fnCompareFloats2](0.1,  0.10001 , 0.00001), '  T07 exact: EXP  0')
PRINT CONCAT('[dbo].[fnCompareFloats2](0.1,  0.000011, 0.00001)    : ', [dbo].[fnCompareFloats2](0.1,  0.100011, 0.00001), ' T08 out of tolerance: EXP -1')
PRINT CONCAT('[dbo].[fnCompareFloats2](0.100011, 0.1, 0.00001)     : ', [dbo].[fnCompareFloats2](0.100011, 0.1, 0.00001) , '  T09 out of tolerance: EXP  1')
*/
GO

