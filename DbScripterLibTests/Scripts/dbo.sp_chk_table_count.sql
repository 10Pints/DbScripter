SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:       Terry Watts
-- Create date:  01-AUG-2022
-- Description:  Checks table counts
-- ======================================================================================================
ALTER PROCEDURE [dbo].[sp_chk_table_count]
    @table  NVARCHAR(60)
   ,@exp    INT
AS
BEGIN
   SET NOCOUNT ON
   DECLARE
       @fn        NVARCHAR(35) ='sp_chk_table_count'
      ,@act       INT
      ,@sql       NVARCHAR(MAX)
      ,@error_msg NVARCHAR(300)
      ,@ok_msg    NVARCHAR(300)

   SET @ok_msg = CONCAT('table: ', ut.dbo.fnPadRight(@table, 20),  ut.dbo.fnPadRight(' exp row count: ', 23-ut.dbo.fnLen(@exp)), @exp);
   SET @sql = CONCAT('SET @act = (SELECT COUNT(*) FROM [', @table, ']);');
   EXEC sp_executesql @sql, N'@sql NVARCHAR(MAX), @act INT OUT', @sql, @act OUT;

   IF  @exp <> @act
   BEGIN
      SET @error_msg = CONCAT('Warning exp/act row count mismatch for table: [', @table, '] exp row count: ', @exp, ' act row count: ', @act); 
      EXEC sp_log 3, @fn, @error_msg;
   END
END
/*
EXEC sp_chk_table_count 'Chemical', 325;
*/

GO
