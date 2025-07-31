SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================
-- Author:      Terry Watts
-- Create date: 27-MAY-2020
-- Description: Tests the fnGetNthSubstring function
-- =====================================================
CREATE PROCEDURE [test].[test_029_fnGetRtnDetails]
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(60)  = N'test_029_fnChkRtnExists'
   SET NOCOUNT ON
   EXEC dbo.sp_set_log_level 1;
   EXEC test.sp_tst_mn_st @fn;
   EXEC sp_log 1, @fn,'010: starting';
   BEGIN TRY
      WHILE 1 = 1
      BEGIN
         -- These rtns should exist:
         EXEC sp_log 1, @fn,'015: calling hlpr_029_fnGetRtnDetails: T01';
         EXEC test.hlpr_029_fnGetRtnDetails
             @tst_num      = N'T01 P exists'
            ,@qrn          = 'sp_assert_file_exists'
            ,@exp_schema_nm= 'dbo'
            ,@exp_rtn_nm   = 'sp_assert_file_exists'
            ,@exp_rtn_ty   = 'P'
            ,@exp_ty_code  = 'P'
            ,@exp_is_clr   = 0
            ;
         EXEC sp_log 1, @fn,'020: calling hlpr_029_fnGetRtnDetails: T02';
         EXEC test.hlpr_029_fnGetRtnDetails
             @tst_num      = N'T02: test.sp_crt_tst_mn P exists'
            ,@qrn          = 'test.sp_crt_tst_mn'
            ,@exp_schema_nm= NULL
            ,@exp_rtn_nm   = 'sp_crt_tst_mn'
            ,@exp_rtn_ty   = 'P'
            ,@exp_ty_code  = 'P'
            ,@exp_is_clr   = 0
            ;
         EXEC sp_log 1, @fn,'020: calling hlpr_029_fnGetRtnDetails: T03';
         EXEC test.hlpr_029_fnGetRtnDetails
             @tst_num      = N'T03: dbo.fnGetRtnDef TF exists'
            ,@qrn          = 'dbo.fnGetRtnDef'
            ,@exp_schema_nm= NULL
            ,@exp_rtn_nm   = 'fnGetRtnDef'
            ,@exp_rtn_ty   = 'F'
            ,@exp_ty_code  = 'TF'
            ,@exp_is_clr   = 0
            ;
         EXEC sp_log 1, @fn,'025: calling hlpr_029_fnGetRtnDetails: T04';
         EXEC test.hlpr_029_fnGetRtnDetails
             @tst_num      = N'T04: test.fnGetCrntTstClsFn FN exists'
            ,@qrn          = 'test.fnGetCrntTstClsFn'
            ,@exp_schema_nm= NULL
            ,@exp_rtn_nm   = 'fnGetCrntTstClsFn'
            ,@exp_rtn_ty   = 'F'
            ,@exp_ty_code  = 'FN'
            ,@exp_is_clr   = 0
            ;
         ---------------------------------------------------------
         -- These rtns should not exist:
         ---------------------------------------------------------
         EXEC sp_log 1, @fn,'030: calling hlpr_029_fnGetRtnDetails: T05';
         EXEC test.hlpr_029_fnGetRtnDetails
             @tst_num      = N'T05: non existant p'
            ,@qrn          = 'test.sp_non_existant'
            ,@expect_null  = 1
            ;
         EXEC sp_log 1, @fn,'035: calling hlpr_029_fnGetRtnDetails: T06';
         EXEC test.hlpr_029_fnGetRtnDetails
             @tst_num      = N'T06: non existant F'
            ,@qrn          = 'test.fnNonExistantFn'
            ,@expect_null  = 1
            ;
         EXEC sp_log 1, @fn,'040: completed tests';
         BREAK;  -- Do once loop
      END -- WHILE
      EXEC test.sp_tst_mn_cls
      EXEC sp_log 1, @fn,'050:';
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn,'060: caught exception';
      EXEC test.sp_tst_mn_hndl_ex;
   END CATCH
  EXEC sp_log 1, @fn,'999:';
END
/*
EXEC tSQLt.Run 'test.test_029_fnGetRtnDetails'
EXEC tSQLt.RunAll
*/
GO

