SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =========================================================================
-- Author:      Terry Watts
-- Create date: 01-JUN-2020
-- Description: returns a list of matching routines from the given database
-- =========================================================================
CREATE PROCEDURE [dbo].[sp_sys_rtn_vw]
    @schema    NVARCHAR(20)   = NULL
   ,@name      NVARCHAR(60)   = NULL
   ,@ty_code   NVARCHAR(20)   = NULL
   ,@top       INT            = NULL
   ,@sf        INT            = 1
AS
BEGIN
   DECLARE 
       @fn     NVARCHAR(20)   = N'UT.SYS_RTNS_VW'
      ,@NL     NVARCHAR(2)    = NCHAR(13) + NCHAR(10)
      ,@sql    NVARCHAR(MAX)
   SET @schema    = iif(@schema  IS NULL, '%', @schema);
   SET @name      = iif(@name    IS NULL, '%', @name);
   SET @ty_code   = iif(@ty_code IS NULL, '%', @ty_code);
   if @top IS NULL
      SET @top = 2000
   SET @sql = CONCAT('Select top ',@top,' * FROM dbo.fnSysRtnCfg(''', @schema,''', ''',@name,''', ''',@ty_code,''')');
   PRINT CONCAT(@NL, 'SQL:',@NL, @sql, @NL);
   EXECUTE sp_executesql @sql
END
GO

