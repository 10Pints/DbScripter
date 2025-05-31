SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ====================================================================
-- Author:      Terry Watts
-- Create date: 01-FEB-2021
-- Description: determines if a sql_variant is an
-- integral type: {int, smallint, tinyint, bigint, money, smallmoney}
-- test: [test].[t 025 fnIsFloat]
-- ====================================================================
ALTER FUNCTION [dbo].[fnIsInt]( @v SQL_VARIANT)
RETURNS BIT
AS
BEGIN
   DECLARE @type SQL_VARIANT
   DECLARE @ty   NVARCHAR(500)
   SELECT  @type = SQL_VARIANT_PROPERTY(@v, 'BaseType');
   SET @ty = CONVERT(NVARCHAR(500), @type);

   RETURN
      CASE 
         WHEN @ty = 'int'        THEN 1
         WHEN @ty = 'smallint'   THEN 1
         WHEN @ty = 'tinyint'    THEN 1
         WHEN @ty = 'bigint'     THEN 1
         WHEN @ty = 'money'      THEN 1
         WHEN @ty = 'smallmoney' THEN 1
         ELSE                    0
         END;
END

GO
