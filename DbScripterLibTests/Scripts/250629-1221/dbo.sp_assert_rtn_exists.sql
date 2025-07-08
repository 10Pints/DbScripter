SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===========================================================================================
-- Author:      Terry Watts
-- Create date: 09-MAY-2020
-- Description: This routine checks that the given routine exists
--
-- POST         throws exception if rotine does not exist
--
-- Changes:
-- 10-NOV-2023: changed parameter @fn to @calling_fn as @fn is used to log and also in tests
-- 24-APR-2024: added feature to check if exist or not exist
-- ===========================================================================================
CREATE PROCEDURE [dbo].[sp_assert_rtn_exists]
    @qrn          VARCHAR(120)
   ,@should_exist BIT            = 1
   ,@msg1         VARCHAR(200) = NULL
   ,@msg2         VARCHAR(200) = NULL
   ,@msg3         VARCHAR(200) = NULL
   ,@msg4         VARCHAR(200) = NULL
   ,@msg5         VARCHAR(200) = NULL
   ,@msg6         VARCHAR(200) = NULL
   ,@msg7         VARCHAR(200) = NULL
   ,@log_level    INT            = 0
AS
BEGIN
   DECLARE
       @fn     VARCHAR(35)   = 'sp_assert_rtn_exists'
      ,@schema VARCHAR(20)
      ,@rtn_nm VARCHAR(4000)

   EXEC sp_log @log_level, @fn,'000: starting';

   SELECT
       @schema = schema_nm
      ,@rtn_nm = rtn_nm
   FROM fnSplitQualifiedName(@qrn);

   IF EXISTS
   (
      SELECT 1 FROM dbo.sysRtns_vw s
      WHERE schema_nm = @schema and rtn_nm = @rtn_nm
   )
   BEGIN -- rtn does exists
     EXEC sp_log @log_level, @fn,'005: rtn ',@schema,'.',@rtn_nm, ' exists';
     EXEC sp_assert_equal 1, @should_exist, @qrn, ' 005: should exist - but does not'
             ,@msg1,@msg2,@msg3,@msg4,@msg5,@msg6,@msg7
            ,@ex_num=50001;
        ;
   END
   ELSE
   BEGIN -- rtn does not exist
     EXEC sp_log @log_level, @fn,'010: ',@schema,'.',@rtn_nm, ' does not exist';
     EXEC sp_assert_equal 0, @should_exist, @qrn, ' 010: should not exist - but does'
            ,@msg1,@msg2,@msg3,@msg4,@msg5,@msg6,@msg7
            ,@ex_num=50002;
   END
END
/*
   EXEC sp_chk_rtn_exists 'dbo.sp_assert_tbl_pop' 
   EXEC sp_chk_rtn_exists 'dbo.sp_assert_tbl_popx' 
*/

GO
