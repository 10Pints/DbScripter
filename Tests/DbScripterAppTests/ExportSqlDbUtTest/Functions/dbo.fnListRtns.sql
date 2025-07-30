SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 12-MAY-2024
-- Description:Creates the drop script for the given schema
-- =============================================
CREATE FUNCTION [dbo].[fnListRtns]
(
    @schema_nm NVARCHAR(32)
   ,@rtn_ty    NVARCHAR(32)
)
RETURNS @t TABLE
(
    id         INT IDENTITY(1,1)
   ,schema_nm  NVARCHAR(32)
   ,rtn_nm     NVARCHAR(60)
   ,rtn_ty     NVARCHAR(32)
)
BEGIN
   INSERT INTO @t(schema_nm, rtn_nm, rtn_ty)
   SELECT
       schema_nm
      ,rtn_nm
      ,rtn_ty
   FROM list_rtns_vw
   WHERE
       (schema_nm = @schema_nm OR @schema_nm IS NULL)
   AND (rtn_ty    = @rtn_ty    OR @rtn_ty    IS NULL)
   ORDER BY schema_nm, rtn_ty, rtn_nm;
   RETURN;
END
/*
SELECT * FROM dbo.fnListRtns('test', NULL);
SELECT * FROM dbo.list_rtns_vw;
*/
GO

