SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =====================================================
-- Author:      Terry Watts
-- Create date: 24-DEC-2024
-- Description: gets the log to file ctx
--
-- Changes:
-- =====================================================
ALTER FUNCTION [dbo].[fnGetCtxLogToFile]()
  RETURNS BIT
AS
BEGIN 
   RETURN dbo.fnGetSessionContextAsBit(N'Log to file');
END;
/*
EXEC spSetCtxLogToFile 1;
PRINT CONCAT('[', dbo.fnGetSessionContextAsBit(), ']');
*/

GO
