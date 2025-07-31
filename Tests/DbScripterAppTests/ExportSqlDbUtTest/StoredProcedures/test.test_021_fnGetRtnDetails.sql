SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 17-JAN-2020
-- Description: Tests the fnGetRoutineDetails routine
-- =============================================
CREATE PROCEDURE [test].[test_021_fnGetRtnDetails]
AS
BEGIN
   EXEC ut.test.sp_tst_mn_st N'test 021 fnGetRoutineDetails'
--   BEGIN TRY
      WHILE 1 = 1
      BEGIN
      EXEC test.hlpr_021_fnGetRtnDetails
          @test_num     = '001'
         ,@schema_nm    = 'dbo'
         ,@rtn_nm       = 'sp_get_line_num'
         ,@exp_schema_nm= 'dbo'
         ,@exp_rtn_nm   = 'sp_get_line_num'
         ,@exp_ty_code  = 'P'
         ,@exp_ty_nm    = 'SQL_STORED_PROCEDURE'
         BREAK;  -- Do once loop
      END -- WHILE 1 = 1
      EXEC ut.test.sp_tst_mn_cls;
--   END TRY
--   BEGIN CATCH
--      EXEC ut.test.sp_tst_mn_hndl_ex;
--      THROW;
--   END CATCH
END
/*
EXEC tSQLt.RunAll
EXEC tSQLt.Run 'test.test_021_fnGetRtnDetails'
*/
GO

