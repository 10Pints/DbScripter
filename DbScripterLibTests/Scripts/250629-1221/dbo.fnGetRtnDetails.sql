SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ============================================================================================================================
-- Author:      Terry Watts
-- Create date: 09-MAY-2020
-- Description: checks if the routine exists
--
-- Preconditions
-- PRE 02: if schema is not specifed in @qrn and there are more than 1 rtn with the rtn nm
--          but differnt schema then raise div by zero exception - delegated to fnSplitQualifiedName
--
-- Postconditions:
-- Post 01: RETURNS if @q_rtn_name exists then [schema_nm, rtn_nm, rtn_ty, ty_code,] , 0 otherwise
--
-- Changes 240723: now returns a single row table as above
--
-- Tests: test.test_029_fnChkRtnExists
-- ============================================================================================================================
CREATE   FUNCTION [dbo].[fnGetRtnDetails]
(
    @qrn VARCHAR(120)
)
RETURNS @t TABLE
(
    qrn           VARCHAR(120)
   ,schema_nm     VARCHAR(32)
   ,rtn_nm        VARCHAR(60)
   ,rtn_ty        NCHAR(61)
   ,ty_code       VARCHAR(25)
   ,is_clr        BIT
)
AS
BEGIN
   DECLARE
       @schema       VARCHAR(20)
      ,@rtn_nm       VARCHAR(4000)
      ,@ty_nm        VARCHAR(20)
      ,@qrn2         VARCHAR(120)

   SELECT
       @schema = schema_nm
      ,@rtn_nm = rtn_nm
      ,@qrn2   = CONCAT(schema_nm, '.', rtn_nm)
   FROM fnSplitQualifiedName(@qrn);

   SELECT @ty_nm = ty_nm FROM dbo.sysRtns_vw WHERE schema_nm = @schema and rtn_nm = 'fn_CamelCase';

   INSERT INTO @t
   (
       qrn
      ,schema_nm
      ,rtn_nm
      ,rtn_ty
      ,ty_code
      ,is_clr
   )
   SELECT
       @qrn2
      ,schema_nm
      ,rtn_nm
      ,rtn_ty
      ,ty_code
      ,is_clr
   FROM dbo.sysRtns_vw WHERE schema_nm = @schema and rtn_nm = @rtn_nm;

   RETURN;
END
/*
EXEC tSQLt.Run 'test.test_029_fnChkRtnExists';
SELECT * FROM [dbo].[fnGetRtnDetails]('[dbo].[fnIsCharType]');
SELECT * FROM [dbo].[fnGetRtnDetails]('sp_assert_rtn_exists');
*/


GO
