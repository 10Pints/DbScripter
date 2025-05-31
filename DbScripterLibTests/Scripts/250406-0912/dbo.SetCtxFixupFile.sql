SET ANSI_NULLS ON

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
ALTER PROCEDURE [dbo].[SetCtxFixupFile] @file NVARCHAR(500)
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE @key NVARCHAR(50) = dbo.fnGetCtxFixupFileKey()
   ;

   EXEC sp_set_session_context @key, @file;

END
/*
EXEC SetCtxFixupFile 'D:\dev\abc.txt';
PRINT dbo.fnGetCtxFixupFile();
*/

GO
