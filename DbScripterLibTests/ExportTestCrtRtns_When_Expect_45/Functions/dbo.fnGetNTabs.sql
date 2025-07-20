SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ================================================================================================
-- Author:      Terry watts
-- Create date: 24-APR-2024
-- Description: returns:
--   a string of n tabs (3 spcs each)
--
-- Test: test.test_086_sp_crt_tst_hlpr_script
-- ================================================================================================
CREATE FUNCTION [dbo].[fnGetNTabs]( @n    INT)
RETURNS VARCHAR(50)
AS
BEGIN
   RETURN REPLICATE(' ', @n*3);
END
/*
EXEC tSQLt.Run 'test.test_086_sp_crt_tst_hlpr_script';

  PRINT CONCAT('[',dbo.fnGetNTabs(NULL),']');
  PRINT CONCAT('[',dbo.fnGetNTabs(-1),']');
  PRINT CONCAT('[',dbo.fnGetNTabs(0),']');
  PRINT CONCAT('[',dbo.fnGetNTabs(1),']');
  PRINT CONCAT('[',dbo.fnGetNTabs(3),']');
*/



GO
