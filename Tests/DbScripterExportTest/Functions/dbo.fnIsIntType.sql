SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ====================================================================
-- Author:      Terry Watts
-- Create date: 01-FEB-2021
-- Description: determines if a sql_variant is an
-- integral type: {int, smallint, tinyint, bigint, money, smallmoney}
-- test: [test].[t 025 fnIsFloat]
--
-- Changes:
-- 241128: added optional check for non negative ints
-- ====================================================================
CREATE   FUNCTION [dbo].[fnIsIntType]( @ty VARCHAR(20))
RETURNS BIT
AS
BEGIN
   RETURN iif(@ty IN ('BIT','INT','SMALLINT','TINYINT','BIGINT','MONEY','SMALLMONEY'), 1, 0);
END
/*
SELECT dbo.fnIsInt('0',0) as [fnIsInt('0', 0)], dbo.fnIsInt('05',0) as [fnIsInt(05,0)]
SELECT dbo.fnIsInt('0',1) as [fnIsInt('0',1)], dbo.fnIsInt('05',1) as [dbo.fnIsInt('05',1)]
*/
GO

