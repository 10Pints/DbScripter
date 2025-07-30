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
CREATE PROCEDURE [dbo].[SetCtxFixupSrchCls] @SrchCls NVARCHAR(500)
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE @key NVARCHAR(50) = dbo.fnGetCtxFixupSrchClsKey()
   ;
   EXEC sp_set_session_context @key, @SrchCls;
END
/*
EXEC SetCtxFixupSrchCls 'Coffee Berry';
PRINT dbo.fnGetCtxFixupSrchCls();
*/
GO

