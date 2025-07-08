SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ====================================================================
-- Author:      Terry Watts
-- Create date: 01-FEB-2021
-- Description: determines if a sql_variant is of type BIT
-- ====================================================================
CREATE   FUNCTION [dbo].[fnIsBool](@v SQL_VARIANT)
RETURNS BIT
AS
BEGIN
   RETURN dbo.fnIsBoolType( CONVERT(VARCHAR(500), SQL_VARIANT_PROPERTY(@v, 'BaseType')));
END


GO
