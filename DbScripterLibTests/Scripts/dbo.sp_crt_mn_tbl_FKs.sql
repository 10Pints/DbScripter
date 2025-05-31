SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===========================================================
-- Author:      Terry Watts
-- Create date: 25-AUG-2023
-- Description: Creates or drops the main table FKs
-- Paramaters:
--       @mode 1: create fkey, : drop fkey
-- ===========================================================
ALTER PROCEDURE [dbo].[sp_crt_mn_tbl_FKs]
   @mode BIT =1
AS
BEGIN
   SET NOCOUNT ON
   DECLARE
       @fn NVARCHAR(30) = 'CRT_MN_TBL_FKS'

   EXEC sp_log 2, @fn, '01: starting';
   --EXEC sp_register_call @fn;
   EXEC sp_crt_FKs @table_type='main', @mode=@mode;
   EXEC sp_log 2, @fn, '99: leaving OK';
END
/*
EXEC sp_crt_mn_tbl_FKs @mode=1 -- 1=create
EXEC sp_crt_mn_tbl_FKs @mode=0 -- 0=drop
EXEC sp_truncate_main_tables
SELECT * FROM fkeys_vw where fk_nm NOT LIKE 'staging' AND schema_nm <> 'tSQLt'
SELECT * FROM fkeys_vw where fk_nm NOT LIKE 'staging' AND schema_nm <> 'tSQLt'
SELECT * FROM fkeys_vw where fk_nm NOT LIKE 'staging' AND schema_nm <> 'tSQLt'
SELECT * FROM ForeignKeys;
*/

GO
