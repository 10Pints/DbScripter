SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 12-MAY-2024
-- Description:Creates the drop script for the given schema
-- =============================================
CREATE FUNCTION [dbo].[fnCrtDropScript](@schema_nm NVARCHAR(32))
RETURNS @t TABLE
(
    id         INT IDENTITY(1,1)
   ,cmd        NVARCHAR(500)
   ,schema_nm  NVARCHAR(32)
   ,rtn_nm     NVARCHAR(60)
   ,rtn_ty     NVARCHAR(32)
)
BEGIN
   INSERT INTO @t(cmd, schema_nm, rtn_nm, rtn_ty)
   SELECT cmd, schema_nm, rtn_nm, rtn_ty
   FROM crt_drop_script_vw
   WHERE schema_nm = @schema_nm
   ORDER BY schema_nm, rtn_ty, rtn_nm;
   RETURN;
END
/*
SELECT * FROM dbo.fnCrtDropScript('test');
SELECT * FROM dbo.crt_drop_script_vw;
*/
GO

