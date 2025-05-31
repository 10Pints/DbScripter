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
-- ===========================================================================================
ALTER PROCEDURE [dbo].[sp_chk_rtn_exists]
       @qrn    NVARCHAR(120)
      ,@fn     NVARCHAR(35)   = 'sp_chk_rtn_exists'

AS
BEGIN
   DECLARE
       @schema NVARCHAR(20)
      ,@rtn_nm NVARCHAR(4000)

   SELECT
       @schema = schema_nm
      ,@rtn_nm = rtn_nm
   FROM ut.test.fnSplitQualifiedName(@qrn);

   IF EXISTS
   (
      SELECT 1 FROM dbo.sysRtns_vw s
      WHERE schema_nm = @schema and rtn_nm = @rtn_nm
   )
   BEGIN
     EXEC sp_log 1, @fn,' ',@schema,'.',@rtn_nm, ' exists: OK';
   END
   ELSE
   BEGIN
      DECLARE @error_msg NVARCHAR(500);
      SET @error_msg = CONCAT('routine [', @schema,'].[', @rtn_nm, '] does not exist');
      EXEC sp_log 4, @fn,' ERROR: ', @error_msg;
      EXEC sp_raise_exception 50001, @error_msg, @state=1, @fn=@fn;
   END
END
/*
   EXEC sp_chk_rtn_exists 'dbo.sp_chk_tbl_populated' 
   EXEC sp_chk_rtn_exists 'dbo.sp_chk_tbl_populatedx' 
*/

GO
