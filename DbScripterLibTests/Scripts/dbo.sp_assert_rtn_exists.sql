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
ALTER PROCEDURE [dbo].[sp_assert_rtn_exists]
    @qrn          NVARCHAR(120)
   ,@should_exist BIT            = 1
   ,@msg1         NVARCHAR(200) = NULL
   ,@msg2         NVARCHAR(200) = NULL
   ,@msg3         NVARCHAR(200) = NULL
   ,@msg4         NVARCHAR(200) = NULL
   ,@msg5         NVARCHAR(200) = NULL
   ,@msg6         NVARCHAR(200) = NULL
   ,@msg7         NVARCHAR(200) = NULL
AS
BEGIN
   DECLARE
       @fn     NVARCHAR(35)   = 'sp_assert_rtn_exists'
      ,@schema NVARCHAR(20)
      ,@rtn_nm NVARCHAR(4000)

   EXEC sp_log 1, @fn,'000: starting';

   SELECT
       @schema = schema_nm
      ,@rtn_nm = rtn_nm
   FROM test.fnSplitQualifiedName(@qrn);

   IF EXISTS
   (
      SELECT 1 FROM dbo.sysRtns_vw s
      WHERE schema_nm = @schema and rtn_nm = @rtn_nm
   )
   BEGIN -- rtn does exists
     EXEC sp_log 1, @fn,'005: rtn ',@schema,'.',@rtn_nm, ' exists';
     EXEC sp_assert_equal 1, @should_exist, @qrn, ' 005: should exist - but does not'
             ,@msg1,@msg2,@msg3,@msg4,@msg5,@msg6,@msg7
            ,@ex_num=50001;
        ;

   END
   ELSE
   BEGIN -- rtn does not exist
     EXEC sp_log 1, @fn,'010: ',@schema,'.',@rtn_nm, ' does not exist';
     EXEC sp_assert_equal 0, @should_exist, @qrn, ' 010: should not exist - but does'
            ,@msg1,@msg2,@msg3,@msg4,@msg5,@msg6,@msg7
            ,@ex_num=50002;
   END
END
/*
   EXEC sp_chk_rtn_exists 'dbo.sp_chk_tbl_populated' 
   EXEC sp_chk_rtn_exists 'dbo.sp_chk_tbl_populatedx' 
*/

GO
