SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===================================================================
-- Author:      Terry Watts
-- Create Date: 05-FEB-2024
-- Description: Asserts that the given table does not have any rows
-- ===================================================================
CREATE PROCEDURE [dbo].[sp_assert_tbl_not_pop]
    @table           VARCHAR(60)
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
   ,@display_msgs    BIT            = 0
   ,@exp_cnt         INT            = NULL
   ,@ex_num          INT            = 56687
   ,@ex_msg          VARCHAR(500)   = NULL
   ,@fn_             VARCHAR(35)    = N'*'
   ,@log_level       INT            = 0
   ,@display_row_cnt BIT            = 1
AS
BEGIN
   DECLARE
    @fn        VARCHAR(35)    = N'sp_assert_tbl_not_pop'
   EXEC sp_assert_tbl_pop
       @table
      ,@msg0  = 'sp_assert_tbl_not_po'
      ,@msg1  = @msg0 
      ,@msg2  = @msg1 
      ,@msg3  = @msg2 
      ,@msg4  = @msg3 
      ,@msg5  = @msg4 
      ,@msg6  = @msg5 
      ,@msg7  = @msg6 
      ,@msg8  = @msg7 
      ,@msg9  = @msg8 
      ,@msg10 = @msg9 
      ,@msg11 = @msg10
      ,@msg12 = @msg11
      ,@msg13 = @msg12
      ,@msg14 = @msg13
      ,@msg15 = @msg14
      ,@msg16 = @msg15
      ,@msg17 = @msg16
      ,@msg18 = @msg17
--      ,@msg19 = @msg18
      ,@exp_cnt =0
      ,@log_level=@log_level
      ,@display_row_cnt=@display_row_cnt;
END
/*
EXEC tSQLt.Run 'test.test_004_sp_chk_tbl_not_pop';
TRUNCATE TABLE AppLog;
EXEC test_sp_chk_tbl_not_pop 'AppLog'; -- ok no rows
INSERT iNTO AppLog ()
*/
GO

