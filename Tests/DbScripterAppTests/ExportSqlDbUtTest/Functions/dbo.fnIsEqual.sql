SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =========================================================
-- Author:      Terry Watts
-- Create date: 15-FEB-2021
-- Description: function to compare values
-- =========================================================
CREATE FUNCTION [dbo].[fnIsEqual]( @a SQL_VARIANT, @b SQL_VARIANT)
RETURNS BIT
AS
BEGIN
   RETURN ~(dbo.fnIsLessThan(@a, @b) | dbo.fnIsLessThan(@b, @a));
END
/*
   Print CONCAT('dbo.fnIsLessThan(1.2, 1.3)     -- T01: ', dbo.fnIsLessThan(1.2, 1.3)    ,' exp: 1    ');
   Print CONCAT('dbo.fnIsEqual(1.2, 1.3)        -- T02: ', dbo.fnIsEqual(1.2, 1.3)       ,' exp: 0    ');
   Print CONCAT('dbo.fnChkEquals(1.2, 1.3)      -- T03: ', dbo.fnChkEquals(1.2, 1.3)     ,' exp: 0    ');
   Print CONCAT('dbo.fnIsEqual(''asdf'', 5)      -- T04: ', dbo.fnIsEqual('asdf', 5)     ,' exp: error');
   Print CONCAT('dbo.fnIsEqual(2,2)             -- T05: ', dbo.fnIsEqual(2,2)            ,' exp: 1    ');
   Print CONCAT('dbo.fnIsEqual(''asdf'',''asdf'')   -- T06: ', dbo.fnIsEqual('asdf','asdf'),' exp: 1    ');
   Print CONCAT('dbo.fnIsEqual(1.3, 1.2)        -- T07: ', dbo.fnIsEqual(1.3, 1.2)       ,' exp: 0    ');
   Print CONCAT('dbo.fnIsEqual(1.3, 1.3)        -- T08: ', dbo.fnIsEqual(1.3, 1.3)       ,' exp: 1    ');
   Print CONCAT('dbo.fnIsEqual(5, 4)            -- T09: ', dbo.fnIsEqual(5, 4)           ,' exp: 0    ');
   Print CONCAT('dbo.fnIsEqual(3, 3)            -- T10: ', dbo.fnIsEqual(3, 3)           ,' exp: 1    ');
   Print CONCAT('dbo.fnIsEqual(2, 3)            -- T11: ', dbo.fnIsEqual(2, 3)           ,' exp: 0    ');
*/
GO

