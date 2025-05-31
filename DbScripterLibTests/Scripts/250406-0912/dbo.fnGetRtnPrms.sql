SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================================================================================
-- Author:      Terry Watts
-- Create date: 11-DEC-2024
-- Description: lists the parameters for teh given routine
--
-- Params: @rtn_nm is not schema quaklified
-- ======================================================================================================================
ALTER   FUNCTION [dbo].[fnGetRtnPrms] (@qrn VARCHAR(100))
RETURNS @t table
(
    ordinal    INT
   ,schema_nm  VARCHAR(32)
   ,rtn_nm     VARCHAR(60)
   ,prm_nm     VARCHAR(32)
   ,ty_nm      VARCHAR(20)
   ,ty_nm_full VARCHAR(20)
   ,ty_len     INT
)
AS
BEGIN
DECLARE
    @schema_nm VARCHAR(32)
   ,@rtn_nm    VARCHAR(50)

   SELECT
    @schema_nm = schema_nm
   ,@rtn_nm    = rtn_nm
   FROM dbo.fnSplitQualifiedName(@qrn);

   INSERT INTO @t
      (ordinal, schema_nm, rtn_nm, prm_nm, ty_nm,ty_nm_full, ty_len)
   SELECT
       ordinal, schema_nm, rtn_nm, prm_nm, ty_nm,ty_nm_full, ty_len
   FROM SysRtnPrms_vw
   WHERE rtn_nm = @rtn_nm
   ;

RETURN
END
/*
SELECT * FROM dbo.fnGetRtnPrms('dbo.sp__main_import');
*/


GO
