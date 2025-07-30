SET ANSI_NULLS ON
GO
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
CREATE FUNCTION [dbo].[fnGetRtnDetails]
(
    @qrn NVARCHAR(120)
)
RETURNS @t TABLE
(
    schema_nm     NVARCHAR(32)
   ,rtn_nm        NVARCHAR(60)
   ,rtn_ty        NCHAR(61)
   ,ty_code       NVARCHAR(25)
   ,is_clr        BIT
)
AS
BEGIN
   DECLARE
       @schema       NVARCHAR(20)
      ,@rtn_nm       NVARCHAR(4000)
      ,@ty_nm        NVARCHAR(20)
   SELECT
       @schema = schema_nm
      ,@rtn_nm = rtn_nm
   FROM test.fnSplitQualifiedName(@qrn);
   SELECT @ty_nm = ty_nm FROM dbo.sysRtns_vw WHERE schema_nm = @schema and rtn_nm = 'fn_CamelCase';
   INSERT INTO @t 
   (
       schema_nm
      ,rtn_nm   
      ,rtn_ty   
      ,ty_code  
      ,is_clr   
   )
   SELECT  
       schema_nm
      ,rtn_nm   
      ,rtn_ty   
      ,ty_code  
      ,is_clr   
   FROM dbo.sysRtns_vw WHERE schema_nm = @schema and rtn_nm = @rtn_nm;
   RETURN;
END
/*
PRINT 
EXEC tSQLt.Run 'test.test_029_fnChkRtnExists';
SELECT * FROM [dbo].[fnGetRtnDetails]('[dbo].[fnDeltaStats]');
SELECT * FROM [dbo].[fnGetRtnDetails]('[dbo].[fnIsCharType]');
SELECT * FROM [dbo].[fnGetRtnDetails]('sp_assert_rtn_exists');
*/
GO

