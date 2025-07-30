SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 12-MAY-2024
-- Description:Creates the drop script for the given schema
-- =============================================
CREATE PROCEDURE [dbo].[sp_crt_drop_script]
    @schema_nm NVARCHAR(32)
   ,@rtn_ty    NVARCHAR(32) = NULL
AS
BEGIN
   SET NOCOUNT ON;
   SELECT * FROM dbo.fnCrtDropScript(@schema_nm)
   WHERE rtn_ty = @rtn_ty OR @rtn_ty IS NULL
END
/*
EXEC dbo.sp_crt_drop_script 'test', 'function';
*/
GO

