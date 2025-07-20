SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================================================
-- Author:      Terry Watts
-- Create Date: 14-JUN-2025
-- Description: assert the table exists
-- Parameters:
--    @table to check if existscan be qualified
--    @exp_exists if 1 asserts @table exists else asserts @table does not exist
-- Returns      1 if exists
-- =============================================================================
CREATE PROCEDURE [dbo].[sp_assert_tbl_exists]
    @table_nm        VARCHAR(100)
   ,@exp_exists      BIT         = 1
AS
BEGIN
   DECLARE
    @fn              VARCHAR(35)   = N'sp_assert_tbl_exists'
   ,@sql             NVARCHAR(MAX)
   ,@act_exists      BIT
   ,@schema_nm       VARCHAR(50)
   ,@msg             VARCHAR(100)
   ,@nm_has_spcs     BIT
   ;

   SET NOCOUNT ON;
   SET @act_exists =dbo.fnTableExists(@table_nm);
   SET @nm_has_spcs = CHARINDEX(' ', @table_nm);

   IF @act_exists = @exp_exists
   BEGIN
      SET @msg = CONCAT('table ', iif(@nm_has_spcs=1, '[', ''), @table_nm, iif(@nm_has_spcs=1, ']', ''), iif(@exp_exists = 1, ' exists ', 'does not exist'), ' as expected');
      EXEC sp_log 1, @fn, @msg;
   END
   ELSE
   BEGIN -- failed test
      SET @msg = CONCAT('table [', @table_nm, iif(@exp_exists = 1, '] does not exist but should', 'exists but should not'));
      EXEC sp_raise_exception 50001, @msg, @fn=@fn;
   END

   RETURN 1;
END
/*
EXEC test.test_070_sp_assert_tbl_exists;
*/

GO
