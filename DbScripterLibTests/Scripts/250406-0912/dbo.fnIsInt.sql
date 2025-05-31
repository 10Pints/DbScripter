SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ====================================================================
-- Author:      Terry Watts
-- Create date: 01-FEB-2021
-- Description: determines if a sql_variant is an
-- integral type: {int, smallint, tinyint, bigint, money, smallmoney}
-- test: [test].[t 025 fnIsFloat]
--
-- See also: fnIsTxtInt
-- Changes:
-- 241128: added optional check for non negative ints
-- ====================================================================
ALTER   FUNCTION [dbo].[fnIsInt]( @v SQL_VARIANT)
RETURNS BIT
AS
BEGIN
   RETURN dbo.fnIsIntType(CONVERT(VARCHAR(20), SQL_VARIANT_PROPERTY(@v, 'BaseType')));
END
/*
EXEC tSQLt.Run 'test.test_044_fnIsInt';
EXEC tSQLt.RunAll;
*/


GO
