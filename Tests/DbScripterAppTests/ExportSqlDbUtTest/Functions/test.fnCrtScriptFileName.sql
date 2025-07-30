SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =========================================================================
-- Author:      Terry Watts
-- Create date: 23-Jul-2024
-- Description: creates the script file name based on 
--    rtn_nm, server name and DB name
--
--- Changes:
-- =========================================================================
CREATE FUNCTION [test].[fnCrtScriptFileName](@rtn_nm NVARCHAR(60))
RETURNS  NVARCHAR(MAX)
AS
BEGIN
   DECLARE @ret NVARCHAR(MAX)
   SELECT @ret = CONCAT(@@SERVERNAME, '.', DB_NAME(), '.', @rtn_nm,'.sql');
RETURN @ret;
END
/*
PRINT test.fnCrtScriptFileName('MyRtn','D:\tmp');
*/
GO

