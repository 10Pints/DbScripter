SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ====================================================================
-- Author:      Terry Watts
-- Create date: 01-FEB-2021
-- Description: determines if a sql_variant is of type BIT
-- ====================================================================
CREATE FUNCTION [dbo].[fnIsBoolType](@v SQL_VARIANT)
RETURNS BIT
AS
BEGIN
   RETURN iif( @v = 'bit', 1,0);
END


GO
