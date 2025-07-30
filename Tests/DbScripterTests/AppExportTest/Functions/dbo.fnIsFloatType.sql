SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================
-- Author:      Terry Watts
-- Create date: 04-JAN-2021
-- Description: determines if a sql_variant is an
-- approximate type: {float, real or numeric}
-- test: [test].[t 025 fnIsFloat]
-- ================================================
CREATE FUNCTION [dbo].[fnIsFloatType](@ty VARCHAR(20))
RETURNS BIT
AS
BEGIN
   RETURN iif(@ty IN ('float','real','numeric'), 1, 0);
END
GO

