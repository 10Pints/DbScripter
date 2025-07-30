SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 21-JUN-2020
-- Description: Creates a script to rename procedures
-- and references in a sql file
-- =============================================
CREATE PROCEDURE [dbo].[sp_rename_rtns]
       @file_pth  NVARCHAR(500)
      ,@schema    NVARCHAR(20)
      ,@nm_fltr   NVARCHAR(100)
      ,@tgt       NVARCHAR(500) = NULL
      ,@rep       NVARCHAR(500) = NULL
      ,@switches  NVARCHAR(50)  = NULL
AS
BEGIN
   DECLARE
       @sql       NVARCHAR(MAX)
   -- change the encoding to UTF-8
   --SELECT * FROM dbo.[fnSysRtnsVw]('test %', 'test', NULL)
   --SET @SQL = 
   SET @sql = CONCAT('SELECT CONCAT(''FART "', @file_pth, '" "', @tgt,'" "', @rep, '" -V -n ', @switches, ''') 
   AS cmd__________________________________________________________________________________________________________________________
   FROM dbo.[fnSysRtnsVw](''',@nm_fltr,''',''', @schema, ''',NULL)
   ORDER BY [name];
   ');
   PRINT @SQL;
END
GO

