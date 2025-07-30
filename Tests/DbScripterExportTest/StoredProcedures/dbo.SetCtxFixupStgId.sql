SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ====================================================
-- Procedure:   sp_SetFixupRowId
-- Description: sets the row id during staging2 fixup
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 06-JAN-2025
-- ====================================================
CREATE PROCEDURE [dbo].[SetCtxFixupStgId] @row_id INT
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE @key NVARCHAR(50) = dbo.fnGetCtxFixupStgIdKey()
   ;
   EXEC sp_set_session_context @key, @row_id;
END
/*
EXEC SetCtxFixupStgId 999;
PRINT dbo.fnGetCtxFixupStgId();
*/
GO

