SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 19-AUG-2023
-- Description: returns the import_id integer
-- ==============================================================================
ALTER   FUNCTION [dbo].[fnGetSessionValueImportId] ()
RETURNS INT
AS
BEGIN
   RETURN dbo.fnGetSessionContextAsInt(dbo.fnGetSessionKeyImportId());
END
/*
EXEC sp_set_session_context_import_id 240530
PRINT CONCAT('import_id: [', dbo.fnGetSessionValueImportId(),']');
*/


GO
