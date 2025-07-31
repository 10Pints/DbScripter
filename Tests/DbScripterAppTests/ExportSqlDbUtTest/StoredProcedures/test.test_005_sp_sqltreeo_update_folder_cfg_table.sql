SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ====================================================================
-- Author:      Terry Watts
-- Create date: 14-JAN-2020
-- Description: Tests the sp_sqltreeo_update_folder_cfg_table routine
-- ====================================================================
CREATE PROCEDURE [test].[test_005_sp_sqltreeo_update_folder_cfg_table]
AS
BEGIN
   DECLARE
       @tested_fn    NVARCHAR(60)   = N'test 005 sp_sqltreeo_update_folder_cfg_table'
      ,@act_updated  INT
      ,@act_inserted INT
      ,@act_deleted  INT
      ,@cnt_act      INT
      ,@schema       NVARCHAR(20)
      ,@rtn_nm       NVARCHAR(60)
   BEGIN TRY
      SET NOCOUNT ON
      EXEC UT.test.sp_tst_mn_st N'test 005 sp_sqltreeo_update_folder_cfg_table', 0
      -- Logging switches
      EXEC sp_set_session_context N'AGSU'             , 1;
      SELECT @cnt_act = COUNT(*) FROM tempDB.sys.extended_properties;
      -- start fromm fresh
      TRUNCATE TABLE SQLTreeOConfig;
      WHILE 1 = 1
      BEGIN
         -- Call the helper routine
         -- there should be 0 updates, @cnt_act inserts, 0 deletes
         EXEC test.hlpr_005_sp_sqltreeo_update_folder_cfg_table 'T01', @disp = 0
         SELECT @act_updated  = updated
               ,@act_inserted = inserted
               ,@act_deleted  = deleted
         FROM SqlTreeoStatsTable;
         EXEC [test].[sp_tst_gen_chk] '01', 0 ,   @act_updated,  N'initial load should not have updated any rows'
       --EXEC [test].[sp_tst_gen_chk] '02', 123 , @act_inserted, N'initial load did not insert correct # of rows from extended_properties'
         EXEC [test].[sp_tst_gen_chk] '03', 0 ,   @act_deleted,  N'initial load should not have deleted any rows'
         -- Call the tested routine again now that the table has been populated
         -- and the state is exactly the same as the extended_properties 
         -- there should be 0 updates, 0 inserts, 0 deletes
         EXEC test.hlpr_005_sp_sqltreeo_update_folder_cfg_table 'T01', @disp = 0
         SELECT @act_updated  = updated
               ,@act_inserted = inserted
               ,@act_deleted  = deleted
         FROM SqlTreeoStatsTable;
         /*SELECT A.updated AS updated, b.inserted, c.deleted
         FROM 
          (SELECT count(*) AS updated  FROM SqlTreeoTempTable WHERE [action] = 'UPDATE') A
         ,(SELECT count(*) AS inserted FROM SqlTreeoTempTable WHERE [action] = 'INSERT') B
         ,(SELECT count(*) AS deleted  FROM SqlTreeoTempTable WHERE [action] = 'DELETE') C
         */
         EXEC test.sp_tst_gen_chk '04', 0 , @act_updated,  N'subsequent load should not have updated any rows'
         EXEC test.sp_tst_gen_chk '05', 0 , @act_inserted, N'subsequent load did not insert correct # of rows from extended_properties'
         EXEC test.sp_tst_gen_chk '06', 0 , @act_deleted,  N'subsequent load should not have deleted any rows'
         EXEC test.sp_tst_incr_pass_cnt;
         EXEC ut.test.sp_tst_mn_cls;
         BREAK;
         END -- WHILE 1 = 1
   END TRY
   BEGIN CATCH
      EXEC ut.test.sp_tst_mn_hndl_ex;
   END CATCH
END
/*
EXEC tSQLt.Run 'test.test_005_sp_sqltreeo_update_folder_cfg_table'
EXEC tSQLt.RunAll
EXEC test.sp_crt_tst_hlpr 'dbo.sp_sqltreeo_update_folder_cfg_table', 5
*/
GO

