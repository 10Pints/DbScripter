SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ====================================================
-- Procedure:   sp_SetFixupRowId
-- Description: sets the row id during staging2 fixup
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- ALTER date: 06-JAN-2025
-- ====================================================
CREATE PROCEDURE [dbo].[SetCtxFixupRepCls] @SrchCls NVARCHAR(500)
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE @key NVARCHAR(50) = dbo.fnGetCtxFixupRepClsKey()
   ;

   EXEC sp_set_session_context @key, @SrchCls;

END
/*
EXEC SetCtxFixupRepCls 'Coffee Berries';
PRINT dbo.fnGetCtxFixupRepCls();
*/

GO
