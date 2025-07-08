SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===================================================================
-- Author:      Terry Watts
-- Create Date: 05-FEB-2024
-- Description: Asserts that the given table does not have any rows
-- ===================================================================
CREATE PROCEDURE [dbo].[sp_assert_tbl_not_pop]
    @table     VARCHAR(60)
   ,@log_level INT = 0
AS
BEGIN
   DECLARE
    @fn        VARCHAR(35)    = N'sp_assert_tbl_not_pop'

   EXEC sp_assert_tbl_pop @table, @exp_cnt =0, @log_level=@log_level;
END
/*
EXEC tSQLt.Run 'test.test_004_sp_chk_tbl_not_pop';
TRUNCATE TABLE AppLog;
EXEC test_sp_chk_tbl_not_pop 'AppLog'; -- ok no rows
INSERT iNTO AppLog ()
*/

GO
