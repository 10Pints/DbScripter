SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ====================================================================
-- Author:      Terry Watts
-- Create date: 08-DEC-2024
-- Description: determines if a sql_variant is an
-- approximate numeric: {int, smallint, tinyint, bigint, money, smallmoney}
-- test: [test].[t 025 fnIsFloat]
-- ====================================================================
CREATE FUNCTION [dbo].[fnIsFloatType]( @v SQL_VARIANT)
RETURNS BIT
AS
BEGIN
   DECLARE @type SQL_VARIANT
   DECLARE @ty   NVARCHAR(500)
   SELECT  @type = SQL_VARIANT_PROPERTY(@v, 'BaseType');
   SET @ty = CONVERT(NVARCHAR(500), @type);
   RETURN
      CASE 
         WHEN @ty = 'float' THEN 1
         WHEN @ty = 'real'  THEN 1
         ELSE               0
         END;
END
GO

