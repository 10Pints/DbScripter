SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry watts
-- Create date: 18-MAY-2020
-- Description: lists routine definitions in rows 
-- overcoming the 4000 char limit of dbo.SysRoutinesView
-- or any method based on INFORMATION_SCHEMA.ROUTINES
--
-- Usage SELECT def FROM dbo.[fnGrepSchema]('test', '%name%', '%content filter%') 
-- =============================================
CREATE FUNCTION [dbo].[fnGrepSchema]
(
    @schema_filter  NVARCHAR(20)
   ,@name_filter    NVARCHAR(50)
   ,@content_filter NVARCHAR(500)
)
RETURNS @T TABLE
(
    rtn_name   NVARCHAR(100)
   ,schema_nm  NVARCHAR(40)
   ,ty_nm      NVARCHAR(50)
   ,seq        INT
   ,[len]      INT
   ,created    DATE
   ,def        NVARCHAR(4000)
)
AS
BEGIN
   IF @schema_filter IS NULL SET @schema_filter='dbo';
   IF @content_filter IS NULL
   BEGIN
      INSERT INTO @t (rtn_name, schema_nm, ty_nm, seq, [len] ,created, def) 
      SELECT          rtn_nm, schema_nm, ty_nm, seq, [len], created, def
      FROM SysRtns2_vw
      WHERE schema_nm LIKE @schema_filter AND rtn_nm LIKE @name_filter
      ORDER BY rtn_nm, seq;
   END
   ELSE
   BEGIN
      INSERT INTO @t (rtn_name, schema_nm, ty_nm, seq, [len] ,created, def) 
      SELECT          rtn_nm,   schema_nm, ty_nm, seq, [len], created, def
      FROM SysRtns2_vw
      WHERE schema_nm LIKE @schema_filter AND rtn_nm LIKE @name_filter AND def like @content_filter
      ORDER BY rtn_nm, seq;
   END
   RETURN;
END
/*
  SELECT def FROM dbo.fnGrepSchema('dbo', 'fnGrepSchema', NULL) 
*/
GO

