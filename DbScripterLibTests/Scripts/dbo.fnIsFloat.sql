SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ================================================
-- Author:      Terry Watts
-- Create date: 04-JAN-2021
-- Description: determines if a sql_variant is an
-- approximate type: {float, real or numeric}
-- test: [test].[t 025 fnIsFloat]
-- ================================================
ALTER FUNCTION [dbo].[fnIsFloat](@v SQL_VARIANT)
RETURNS BIT
AS
BEGIN
   DECLARE @type SQL_VARIANT
   DECLARE @ty   NVARCHAR(500)
   SELECT @type = SQL_VARIANT_PROPERTY(@v, 'BaseType');
   SET @ty = CONVERT(NVARCHAR(500), @type)

   RETURN
      CASE 
         WHEN @ty = 'float'   THEN 1
         WHEN @ty = 'real'    THEN 1
         WHEN @ty = 'numeric' THEN 1
         ELSE                    0
         END;
END

GO
