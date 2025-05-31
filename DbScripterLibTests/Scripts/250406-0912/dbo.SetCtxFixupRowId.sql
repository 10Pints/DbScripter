SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ====================================================
-- Procedure:   sp_SetFixupRowId
-- Description: sets the row id during staging2 fixup
-- EXEC tSQLt.Run 'test.test_<nnn>_sp_SetFixupRowId';
-- Design:      
-- Tests:       Terry Watts
-- Author:      06-JAN-2025
-- Create date: 
-- ====================================================
ALTER PROCEDURE [dbo].[SetCtxFixupRowId] @row_id INT
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE @key NVARCHAR(50) = dbo.fnGetCtxFixupRowIdKey()
   ;

   EXEC sp_set_session_context @key, @row_id;

END
/*
EXEC SetCtxFixupRowId 1000;
PRINT dbo.fnGetCtxFixupRowId();
*/

GO
