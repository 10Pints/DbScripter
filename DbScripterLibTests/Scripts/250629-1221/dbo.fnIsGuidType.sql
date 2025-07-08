SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ====================================================================
-- Author:      Terry Watts
-- Create date: 01-FEB-2021
-- Description: determines if a sql_variant is of type GUID
-- ====================================================================
CREATE   FUNCTION [dbo].[fnIsGuidType](@v SQL_VARIANT)
RETURNS BIT
AS
BEGIN
/*   DECLARE @type SQL_VARIANT
   DECLARE @ty   VARCHAR(500)
   SELECT @type = SQL_VARIANT_PROPERTY(@v, 'BaseType');
   SET @ty = CONVERT(VARCHAR(500), @type);

   RETURN
      CASE
         WHEN @ty = 'uniqueidentifier' THEN  1
         ELSE                                0
         END;
*/
   RETURN iif(CONVERT(VARCHAR(500), SQL_VARIANT_PROPERTY(@v, 'BaseType')) = 'uniqueidentifier', 1, 0);
END


GO
