SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================================
-- Author:       Terry Watts
-- Create date:  02-AUG-2023
-- Description:  SETS the session context  [Import Root]
-- ======================================================================================================
CREATE   PROCEDURE [dbo].[sp_set_session_context_import_root]
   @val VARCHAR(450)
AS
BEGIN
   DECLARE @key NVARCHAR(60) = dbo.fnGetKeyImportRoot();
   EXEC sp_set_session_context @key, @val;
END
/*
EXEC tSQLt.Run 'test.test_100_fnGetSessionContextImportRoot';
*/
GO

