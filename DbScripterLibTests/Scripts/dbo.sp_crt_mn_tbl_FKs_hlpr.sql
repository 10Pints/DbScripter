SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===========================================================
-- Author:		  Terry Watts
-- Create date:  05-NOV-2023
-- Description:  Helper tp create foreign keys
-- ===========================================================
ALTER PROCEDURE [dbo].[sp_crt_mn_tbl_FKs_hlpr]
       @fk_nm  NVARCHAR(100)
      ,@fk_tbl NVARCHAR(100)
      ,@fk_fld NVARCHAR(60)
      ,@pk_tbl NVARCHAR(100)
      ,@pk_fld NVARCHAR(60)
AS
BEGIN
	SET NOCOUNT ON;
   DECLARE 
       @fn        NVARCHAR(30)   = 'CRT_MN_TBL_FKS_HLPR'
      ,@sql       NVARCHAR(MAX)
      ,@rc        INT
      ,@error_msg NVARCHAR(500)

   SET @sql = CONCAT(
'ALTER TABLE [',@fk_tbl,'] WITH CHECK ADD CONSTRAINT ',@fk_nm, ' FOREIGN KEY([',@fk_fld,']) REFERENCES [',@pk_tbl,']([',@pk_fld,']);'); 

   EXEC sp_log 1, @fn, @sql;
   EXEC @rc=sp_executesql @sql;

   IF @rc<> 0
   BEGIN
      SET @error_msg = CONCAT(@fn, '50: failed to create FK, ', @error_msg);
      EXEC sp_log 4, @fn, @error_msg;
      ;THROW 587412, @error_msg, 1;
   END

   SET @sql = CONCAT('ALTER TABLE [',@fk_tbl,'] CHECK CONSTRAINT ',@fk_nm, ';');
   EXEC @rc=sp_executesql @sql;

   IF @rc<> 0
   BEGIN
      --DECLARE @error_msg NVARCHAR(500) = ut.dbo.fnGetErrorMsg();
      SET @error_msg = CONCAT(@fn, '51: ',@fk_nm, ' check failed ', ut.dbo.fnGetErrorMsg());
      EXEC sp_log 4, @fn, @error_msg;
      ;THROW 587413, @error_msg, 1;
   END

END

GO
