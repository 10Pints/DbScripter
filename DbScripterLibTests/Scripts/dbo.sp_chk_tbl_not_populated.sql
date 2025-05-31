SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===================================================================
-- Author:      Terry Watts
-- Create Date: 05-FEB-2024
-- Description: Checks that the given table does not have any rows
-- ===================================================================
ALTER PROCEDURE [dbo].[sp_chk_tbl_not_populated]
    @table        NVARCHAR(60)
AS
BEGIN
   EXEC sp_chk_tbl_populated @table, 0;
END
/*
EXEC tSQLt.Run test.test_sp_chk_tbl_not_populated';
TRUNCATE TABLE AppLog;
EXEC test_sp_chk_tbl_not_populated 'AppLog'; -- ok no rows
INSERT iNTO AppLog ()
*/

GO
