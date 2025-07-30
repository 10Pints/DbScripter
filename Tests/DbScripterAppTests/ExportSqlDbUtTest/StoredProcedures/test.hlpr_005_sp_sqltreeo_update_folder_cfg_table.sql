SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      26-Nov-2023
-- Description:      test helper rtn for the sp_sqltreeo_update_folder_cfg_table rtn being tested
-- Tested rtn desc:
--  refreshes the SQLTreeOConfig table  
-- USE when additions or changes to the dynamic sqltreeo folders  
--    refreshes (merges) the SQLTreeOConfig table from the SQLTreeO extended properties.  
--    Does a full merge add, update and delete  
--  
-- USE when additions or changes to the dynamic sqltreeo folders  
--  
-- ERROR CODES: none  
--
-- Tested rtn params: 
--    @disp     BIT
--========================================================================================
CREATE PROCEDURE [test].[hlpr_005_sp_sqltreeo_update_folder_cfg_table]
    @test_num  NVARCHAR(100)
   ,@disp      BIT
   ,@exp_ex    BIT = 0
AS
BEGIN
   DECLARE
    @fn        NVARCHAR(35)   = N'hlpr_005_sp_sqltreeo_update_folder_cfg_table'
   EXEC test.sp_tst_hlpr_st @fn, @test_num;
---- SETUP:
   -- <TBD>
---- RUN tested rtn:
   EXEC sp_log 1, @fn, '04: running tested rtn: EXEC dbo.sp_sqltreeo_update_folder_cfg_table @disp;';
   IF @exp_ex = 1
   BEGIN
      BEGIN TRY
         -- Expect an exception here
         EXEC sp_log 1, @fn, '05: Expect an exception here';
         EXEC dbo.sp_sqltreeo_update_folder_cfg_table @disp;
         EXEC sp_log 4, @fn, '06: oops! Expected an exception here';
         THROW 51000, ' Expected an exception but none were thrown', 1;
      END TRY
      BEGIN CATCH
         EXEC sp_log 1, @fn, '07: caught expected exception';
      END CATCH
   END -- IF @exp_ex = 1
   ELSE
   BEGIN
      -- Do not expect an exception here
         EXEC sp_log 1, @fn, '08: Calling tested rtn: do not expect an exception now';
         EXEC dbo.sp_sqltreeo_update_folder_cfg_table @disp;
         EXEC sp_log 1, @fn, '09: Returned from tested rtn: no exception thrown';
---- TEST:
      EXEC sp_log 1, @fn, '10: running tests...';
   END -- ELSE -IF @exp_ex = 1
   -- <TBD>
      EXEC sp_log 1, @fn, '11: all tests ran OK';
---- CLEANUP:
   -- <TBD>
   EXEC test.sp_tst_hlpr_hndl_success;
;
   EXEC sp_log 2, @fn, 'subtest ',@test_num, ': PASSED';
END
/*
   EXEC tSQLt.Run 'test.test_005_sp_sqltreeo_update_folder_cfg_table';
*/
GO

