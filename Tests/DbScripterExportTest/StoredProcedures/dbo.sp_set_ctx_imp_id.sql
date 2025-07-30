SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ====================================================
-- Author:       Terry Watts
-- Create date:  19-AUG-2023
-- Description:  SETS the import correction id
-- ====================================================
CREATE   PROCEDURE [dbo].[sp_set_ctx_imp_id]
   @val     INT
AS
BEGIN
   DECLARE @key NVARCHAR(60)
   SET @key = dbo.fnGetSessionKeyImportId();
   EXEC sp_set_session_context @key, @val;
END
/*
EXEC sp_set_ctx_imp_id 35
PRINT CONCAT(dbo.fnGetSessionKeyImportId(), ': [', dbo.fnGetSessionValueImportId(),']');
*/
GO

