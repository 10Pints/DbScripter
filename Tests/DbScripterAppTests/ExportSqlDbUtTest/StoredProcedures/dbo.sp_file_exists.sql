SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 Terry Watts
-- Create date: 09-NOV-2023
-- Description: Folder exists
-- =============================================
CREATE PROCEDURE [dbo].[sp_file_exists] 
    @file_or_folder NVARCHAR(500)
   ,@file_exists   INT OUT
   ,@folder_exists INT OUT
AS
BEGIN
	SET NOCOUNT ON;
   DECLARE @import_tsv_file NVARCHAR(200) = 'D:\Dev\Repos\Farmingx\Datax\'
   ,@error_msg NVARCHAR(200)
   DROP TABLE IF EXISTS #tmp_tbl;
   CREATE TABLE #tmp_tbl
   (
    file_exists              BIT
   ,directory_exists         BIT
   ,parent_directory_exists  BIT
   );
   -- Chk if file exists
   INSERT INTO #tmp_tbl EXEC xp_fileexist @file_or_folder--, @file_exists OUT;
   SELECT * FROM #tmp_tbl;
   SET @file_exists = 
   CASE
      WHEN EXISTS (SELECT 1 FROM #tmp_tbl WHERE file_exists =1) THEN 1
      ELSE 0
   END;
   SET @folder_exists = 
   CASE
      WHEN EXISTS (SELECT 1 FROM #tmp_tbl WHERE directory_exists =1) THEN 1
      ELSE 0
   END;
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_038_sp_file_exists';
-----------------------------------------------------------------------------------------
DECLARE 
    @file_exists   INT
   ,@folder_exists INT
EXEC ut.dbo.sp_file_exists 'D:\Dev\Farming', @file_exists OUT, @folder_exists OUT
PRINT CONCAT('
file_exists  : ', @file_exists,'
folder_exists: ', @folder_exists
);
-----------------------------------------------------------------------------------------
*/
GO

