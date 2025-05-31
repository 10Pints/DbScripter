SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==========================================================
-- Author:       Terry Watts
-- Create date:  19-AUG-2023
-- Description:  SETS the import_id session context
-- ==========================================================
ALTER   PROCEDURE [dbo].[sp_set_ctx_cor_id]
   @val  INT
AS
BEGIN
   DECLARE @key NVARCHAR(30) = dbo.fnGetSessionKeyCorId();
   EXEC sp_set_session_context @key, @val;
END
/*
EXEC sp_set_ctx_cor_id 300
PRINT CONCAT('import_id: [', dbo.fnGetSessionValueImportId(),']');
*/


GO
