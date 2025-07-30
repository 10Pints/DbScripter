SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================================
-- Author:       Terry Watts
-- Create date:  02-AUG-2023
-- Description:  SETS the session context  [Import Root]
-- ======================================================================================================
CREATE PROCEDURE [dbo].[sp_set_session_context_import_root]
   @val     SQL_VARIANT
AS
BEGIN
   DECLARE @key NVARCHAR(MAX) = dbo.fnGetKeyImportRoot();
   EXEC sp_set_session_context @key, @val;
END
/*
EXEC sp_set_session_context_import_root 'D:\Dev\Farming\Data'
PRINT CONCAT('[',dbo.fnGetImportRoot(),']');
PRINT CONCAT('[',dbo.fnGetKeyImportRoot(),']');
*/
GO

