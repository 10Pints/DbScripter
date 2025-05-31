SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ====================================================================
-- Author:      Terry Watts
-- Create date: 01-FEB-2021
-- Description: determines if a sql_variant is of type GUID
-- ====================================================================
ALTER FUNCTION [dbo].[fnIsGuid](@v SQL_VARIANT)
RETURNS BIT
AS
BEGIN
   DECLARE @type SQL_VARIANT
   DECLARE @ty   NVARCHAR(500)
   SELECT @type = SQL_VARIANT_PROPERTY(@v, 'BaseType');
   SET @ty = CONVERT(NVARCHAR(500), @type);

   RETURN
      CASE
         WHEN @ty = 'uniqueidentifier' THEN  1
         ELSE                                0
         END;
END

GO
