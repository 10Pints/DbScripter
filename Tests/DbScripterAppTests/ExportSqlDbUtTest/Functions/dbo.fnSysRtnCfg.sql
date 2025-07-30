SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================================
-- Author:      Terry Watts
-- Create date: 01-JUN-2020
-- Description: returns a list of matching routines from the current database
--              Can use wild cards in parameters, NULL parameter means ALL
-- ===========================================================================
CREATE FUNCTION [dbo].[fnSysRtnCfg]
(
    @schema    NVARCHAR(20) = NULL
   ,@name      NVARCHAR(60) = NULL
   ,@ty_code   NVARCHAR(60) = NULL
)
RETURNS @t TABLE
(
    id         INT IDENTITY(1,1) NOT NULL
   ,schema_nm  NVARCHAR(20)
   ,rtn_nm     NVARCHAR(60)
   ,ty_nm      NVARCHAR(50)
   ,ty_code    NVARCHAR(70)
   ,created    DATE
   ,modified   DATE
)
BEGIN
   DECLARE 
      @test_num           NVARCHAR(60)
   if @schema IS NULL
      SET @schema = '%'
   if @name IS NULL
      SET @name = '%'
   if @ty_code IS NULL
      SET @ty_code = '%'
   INSERT INTO @t( schema_nm, rtn_nm, ty_nm, ty_code, created, modified)
   SELECT TOP 1000 schema_nm, rtn_nm, ty_nm, ty_code, created, modified
   FROM [dbo].[SysRtns_vw] 
   WHERE
          [schema_nm] LIKE @schema
      AND [rtn_nm]    LIKE @name
      AND ty_code     LIKE @ty_code
   ORDER BY schema_nm, ty_code, rtn_nm;
RETURN;
END
/*
   EXEC sp_sys_rtn_vw 'dbo', NULL, 'P%'
   Select top 2000 * FROM dbo.fnSysRtnCfg('dbo', '%', 'P%');
   SELECT TOP 50 * FROM SysRtns_vw
*/
GO

