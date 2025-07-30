SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================
-- Description: returns the count crom a query or table
-- Author:      Terry Watts
-- Create date: 17-APR-2025
-- Design:      
-- Tests:       
-- ====================================================
CREATE PROCEDURE [dbo].[sp_GetCount] @sql NVARCHAR(4000)
AS
BEGIN
   DECLARE @cnt   INT
   ;
   SET NOCOUNT ON;
   IF CHARINDEX('SELECT COUNT', @sql) = 0
      SET @sql = CONCAT('SELECT @cnt = COUNT(*) FROM ',@sql);
   PRINT CONCAT('modified SQL: ', @sql);
   EXEC sp_executesql @sql, N'@cnt   INT OUT', @cnt OUT;
   PRINT CONCAT(@sql, ' count: ',@cnt);
   RETURN  @cnt;
END
/*
-------------------------------------------------
DECLARE @cnt   INT;
EXEC @cnt = sp_GetCount '[test].[TstDef]';
PRINT @cnt;
SELECT COUNT(*) FROM country
SELECT COUNT(*) FROM [test].[TstDef]
-------------------------------------------------
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<proc_nm>';
*/
GO

