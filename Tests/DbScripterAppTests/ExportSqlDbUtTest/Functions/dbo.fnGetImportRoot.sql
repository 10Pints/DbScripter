SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================================
-- Author:       Terry Watts
-- Create date:  02-AUG-2023
-- Description:  Gets the Import root flder from the session context [Import Root]
-- ======================================================================================================
CREATE FUNCTION [dbo].[fnGetImportRoot]()
RETURNS NVARCHAR(1000)
AS
BEGIN
   RETURN  dbo.fnGetSessionContextAsString(dbo.fnGetKeyImportRoot());
END
/*
EXEC sp_set_session_context_import_root 'D:\Dev\Farming\Data'
PRINT CONCAT('[',dbo.fnGetImportRoot(),']');
PRINT CONCAT('[',dbo.fnGetKeyImportRoot(),']');
*/
GO

