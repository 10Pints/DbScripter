SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 31-JAN-2020
-- Description: returns the minimum of 2 values, 
--              but if one is NULL or 0 then returns the other value
--              ** This is NOT the same logic as dbo.fnMin
-- =============================================
CREATE FUNCTION [dbo].[fnMinNotZero](@p1 INT, @p2 INT)
RETURNS INT
AS
BEGIN
   RETURN
      CASE 
         WHEN @p1 = 0 THEN @p2
         WHEN @p2 = 0 THEN @p1
         WHEN @p1 IS NULL THEN @p2
         WHEN @p2 IS NULL THEN @p1
         WHEN @p1 < @p2   THEN @p1 
         ELSE @p2 
      END 
END
GO

