SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ================================================================================================
-- Author:      Terry Watts
-- Create date: 05-APR-2024
-- Description: returns:
--    if @ty_nm is a text array type then returns the full type from a data type + max_len fields
--    else returns @ty_nm on its own.
--
--    This is useful when using sys rtns like sys.columns
--
-- Test: test.test_089_fnGetFullTypeName
-- ================================================================================================
ALTER FUNCTION [dbo].[fnGetFullTypeName]
(
    @ty_nm  NVARCHAR(20)
   ,@len    INT
)
RETURNS NVARCHAR(50)
AS
BEGIN
   RETURN iif(@ty_nm in ('NVARCHAR','VARCHAR'), CONCAT(@ty_nm, '(', iif(@len=-1, 'MAX', FORMAT(@len, '####')), ')'), @ty_nm);
END
/*
  PRINT dbo.fnGetFullTypeName('NVARCHAR', -1);
  PRINT dbo.fnGetFullTypeName('NVARCHAR', 20);
  PRINT dbo.fnGetFullTypeName('VARCHAR', 4000);
  PRINT dbo.fnGetFullTypeName('INT', 30);
*/

GO
