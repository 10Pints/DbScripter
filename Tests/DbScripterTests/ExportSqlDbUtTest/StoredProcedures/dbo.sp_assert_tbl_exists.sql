SET ANSI_NULLS ON
GO
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
   ,@exp_exists      BIT            = 1
   ,@msg0            VARCHAR(MAX)   = NULL
   ,@msg1            VARCHAR(MAX)   = NULL
   ,@msg2            VARCHAR(MAX)   = NULL
   ,@msg3            VARCHAR(MAX)   = NULL
   ,@msg4            VARCHAR(MAX)   = NULL
   ,@msg5            VARCHAR(MAX)   = NULL
   ,@msg6            VARCHAR(MAX)   = NULL
   ,@msg7            VARCHAR(MAX)   = NULL
   ,@msg8            VARCHAR(MAX)   = NULL
   ,@msg9            VARCHAR(MAX)   = NULL
   ,@msg10           VARCHAR(MAX)   = NULL
   ,@msg11           VARCHAR(MAX)   = NULL
   ,@msg12           VARCHAR(MAX)   = NULL
   ,@msg13           VARCHAR(MAX)   = NULL
   ,@msg14           VARCHAR(MAX)   = NULL
   ,@msg15           VARCHAR(MAX)   = NULL
   ,@msg16           VARCHAR(MAX)   = NULL
   ,@msg17           VARCHAR(MAX)   = NULL
   ,@msg18           VARCHAR(MAX)   = NULL
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
   BEGIN -- Failed test
      SET @msg = CONCAT('table [', @table_nm, iif(@exp_exists = 1, '] does not exist but should', 'exists but should not'));
      EXEC sp_raise_exception
          @ex_num = 50001
         ,@msg0   = @msg
         ,@msg1   = @msg0
         ,@msg2   = @msg1
         ,@msg3   = @msg2
         ,@msg4   = @msg3
         ,@msg5   = @msg4
         ,@msg6   = @msg5
         ,@msg7   = @msg6
         ,@msg8   = @msg7
         ,@msg9   = @msg8
         ,@msg10  = @msg9
         ,@msg11  = @msg10
         ,@msg12  = @msg11
         ,@msg13  = @msg12
         ,@msg14  = @msg13
         ,@msg15  = @msg14
         ,@msg16  = @msg15
         ,@msg17  = @msg16
         ,@msg18  = @msg17
         ,@msg19  = @msg18
         ,@fn     = @fn
         ;
   END
   RETURN 1;
END
/*
EXEC test.test_070_sp_assert_tbl_exists;
*/
GO

