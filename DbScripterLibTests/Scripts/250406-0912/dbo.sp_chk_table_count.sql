SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:       Terry Watts
-- Create date:  01-AUG-2022
-- Description:  Checks table counts
-- RETURNS       1 if match, 0 otherwise
-- ======================================================================================================
ALTER   PROCEDURE [dbo].[sp_chk_table_count]
    @table  VARCHAR(60)
   ,@exp    INT
AS
BEGIN
   SET NOCOUNT ON
   DECLARE
       @fn        VARCHAR(35) ='sp_chk_table_count'
      ,@act       INT
      ,@sql       NVARCHAR(MAX)
      ,@error_msg VARCHAR(300)
      ,@ok_msg    VARCHAR(300)
      ,@ret       INT = 1 -- optimisitic match

   SET @ok_msg = CONCAT('table: ', ut.dbo.fnPadRight(@table, 20),  ut.dbo.fnPadRight(' exp row count: ', 23-ut.dbo.fnLen(@exp)), @exp);
   SET @sql = CONCAT('SET @act = (SELECT COUNT(*) FROM [', @table, ']);');
   EXEC sp_executesql @sql, N'@sql VARCHAR(MAX), @act INT OUT', @sql, @act OUT;

   IF @exp <> @act
   BEGIN
      SET @error_msg = CONCAT('Warning exp/act row count mismatch for table: [', @table, '] exp row count: ', @exp, ' act row count: ', @act); 
      EXEC sp_log 3, @fn, @error_msg;
      SET @ret = 0
   END

   RETURN @ret;
END
/*
EXEC sp_chk_table_count 'Chemical', 325;
EXEC tSQLt.Run 'test.test_011_sp_import_UseStaging';
*/


GO
