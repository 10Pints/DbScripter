SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 17-JAN-2020
-- Description: Helper routine the dbo.fnGetRoutineDetails Tests
-- =============================================
CREATE PROCEDURE [test].[hlpr_021_fnGetRtnDetails]
       @test_num        NVARCHAR(10)
      ,@schema_nm       NVARCHAR(30)
      ,@rtn_nm          NVARCHAR(40)
      ,@exp_schema_nm   NVARCHAR(40) = NULL
      ,@exp_rtn_nm      NVARCHAR(60) = NULL
      ,@exp_ty_code     NVARCHAR(2)  = NULL
      ,@exp_ty_nm       NVARCHAR(60) = NULL
AS
BEGIN
   DECLARE
       @fn              NVARCHAR(35) = 'HLPR_021_FN_GET_RTN_DETS'
      ,@act             NVARCHAR(50)
      ,@msg             NVARCHAR(500)
      ,@NL              NVARCHAR(2)    = NCHAR(13) + NCHAR(10)
      ,@act_count       INT
      ,@act_schema_nm   NVARCHAR(40)
      ,@act_rtn_nm      NVARCHAR(60)
      ,@act_ty_code     NVARCHAR(2)
      ,@act_ty_nm       NVARCHAR(40)
      ,@rtnDetails      RtnDetailsType
      EXEC ut.test.sp_tst_hlpr_st @fn, @test_num;
      -- Call the tested routine
      EXEC sp_log 1, @fn, '02: running test ', @test_num;
      INSERT INTO @rtnDetails
      SELECT *
      FROM dbo.fnGetRtnDetails( @schema_nm, @rtn_nm);
      SET @act_count = (SELECT COUNT(*) FROM @rtnDetails);
      EXEC sp_log 1, @fn, '03: run test ', @test_num, ' @act_count: ', @act_count;
      SELECT
           @act_schema_nm = schema_nm
          ,@act_rtn_nm    = rtn_nm
          ,@act_ty_code   = rtn_ty_code
          ,@act_ty_nm     = rtn_ty_nm
      FROM @rtnDetails;
      EXEC sp_log 1, @fn, '05: displaying results';
      SELECT * FROM @rtnDetails;
      -- expect 1 row
      EXEC sp_log 1, @fn, '07: asserting 1 row returned';
      SET @msg = CONCAT('expected exactly 1 row returned from fnGetRtnDetails, actual row count: ', @act_count)
      EXEC tSQLt.AssertEquals 1, @act_count, @msg;
      IF @exp_schema_nm IS NOT NULL EXEC tSQLt.AssertEquals @exp_schema_nm, @act_schema_nm, '@act_schema_nm chk failed';
      IF @exp_rtn_nm    IS NOT NULL EXEC tSQLt.AssertEquals @exp_rtn_nm   , @act_rtn_nm   , '@act_rtn_nm    chk failed';
      IF @exp_ty_code   IS NOT NULL EXEC tSQLt.AssertEquals @exp_ty_code  , @act_ty_code  , '@act_ty_code   chk failed';
      IF @exp_ty_nm     IS NOT NULL EXEC tSQLt.AssertEquals @exp_ty_nm    , @act_ty_nm    , '@act_ty_nm     chk failed';
      EXEC test.sp_tst_incr_pass_cnt;
      EXEC ut.test.sp_tst_hlpr_try_end --@exp_ex_num, @exp_ex_msg--,@exp_ex_st;
      EXEC sp_log 1, @fn, '99: leaving, test ', @test_num, ' PASSED';
END
/*
EXEC tSQLt.RunAll
EXEC tSQLt.Run 'test.test_021_fnGetRtnDetails'
   DECLARE
       @fn           NVARCHAR(4)
      ,@act          NVARCHAR(50)
      ,@msg          NVARCHAR(500)
      ,@NL           NVARCHAR(2)    = NCHAR(13) + NCHAR(10)
      ,@act_count    INT
      ,@act_ty_code  NVARCHAR(2)
      ,@rtnDetails   RtnDetailsType
INSERT INTO @rtnDetails
   SELECT *
   FROM dbo.fnGetRtnDetails( 'dbo', 'sp_get_line_num');
-- schema_nm, rtn_nm, rtn_ty_code, rtn_ty_nm
SELECT * FROM @rtnDetails
*/
GO

