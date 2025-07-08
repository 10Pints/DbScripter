SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ============================================================================================================================
-- Author:      Terry Watts
-- Create date: 09-MAY-2020
-- Description: checks if the routine exists
--
-- POSTCONDITIONS:
-- POST 01: RETURNS if @q_rtn_name exists then [schema_nm, rtn_nm, rtn_ty, ty_code,] , 0 otherwise
-- 
-- Changes 240723: now returns a single row table as above
--
-- Tests: test.test_029_fnChkRtnExists
-- ============================================================================================================================
CREATE   FUNCTION [dbo].[fnChkRtnExists]
(
    @qrn VARCHAR(120)
)
RETURNS BIT
AS
BEGIN
   DECLARE
       @schema       VARCHAR(20)
      ,@rtn_nm       VARCHAR(4000)
   ;

   SELECT
       @schema = schema_nm
      ,@rtn_nm = rtn_nm
   FROM fnSplitQualifiedName(@qrn);

   RETURN iif( EXISTS (SELECT 1 FROM dbo.sysRtns_vw WHERE schema_nm = @schema and rtn_nm = @rtn_nm), 1, 0);
END
/*
PRINT 
EXEC tSQLt.Run 'test.test_029_fnChkRtnExists';

SELECT * FROM [dbo].[fnChkRtnExists]('[dbo].[fnClassCreator]');
SELECT * FROM [dbo].[fnChkRtnExists]('[dbo].[fnCompareFloats]');
SELECT * FROM [dbo].[fnChkRtnExists]('sp_close_log');
*/


GO
