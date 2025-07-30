SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 17-JAN-2020
-- Description: Helper routine the dbo.fnGetFunctionDetails Tests
--
-- Changes: 
-- 231129: removed try catch bloc
-- =============================================
CREATE PROCEDURE [test].[hlpr_016_fnGetRtnDetails]
       @test_num           NVARCHAR(10)
      ,@schema_nm          NVARCHAR(30)
      ,@rtn_nm             NVARCHAR(40)
      ,@exp_rtn_ty_code    NVARCHAR(2)    = NULL
AS
BEGIN
   DECLARE
       @fn              NVARCHAR(35) = 'hlpr_016_fnGetRtnDetails'
      ,@NL              NVARCHAR(2)    = NCHAR(13) + NCHAR(10)
      ,@act_count       INT
      ,@rtnDetailsType  RtnDetailsType
      ,@act_rtn_nm      NVARCHAR(40)
      ,@act_rtn_ty_code NVARCHAR(2)
      ,@act_schema_nm   NVARCHAR(30)
      ,@act_ex_msg      DATETIME
   EXEC sp_log 1, @fn, '01: starting'
   EXEC ut.test.sp_tst_hlpr_st @fn, @test_num;
   EXEC sp_log 1, @fn, '05: calling tested rtn: fnGetRtnDetails'
   -- Populate the IN/OUT params
   -- Run test specific setup
   -- Call the tested routine
   INSERT INTO @rtnDetailsType
   SELECT * 
   FROM ut.dbo.fnGetRtnDetails( @schema_nm, @rtn_nm);--, @not_like, @schema)
   -- Check only 1 row returned
   SELECT * FROM @rtnDetailsType;
   SELECT @act_count = COUNT(*) FROM @rtnDetailsType;
   EXEC tSQLt.AssertEquals 1, @act_count, 'fnGetRtnDetails did not return 1 row';
   EXEC sp_log 1, @fn, '10: testing returned dataset'
   SELECT 
       @act_schema_nm   = schema_nm
      ,@act_rtn_nm      = rtn_nm
      ,@act_rtn_ty_code = rtn_ty_code
   FROM @rtnDetailsType;
   EXEC tSQLt.AssertEquals @schema_nm, @act_schema_nm, 'sub test 001 @schema_nm, @act_schema_nm mismatch';
   EXEC tSQLt.AssertEquals @rtn_nm   , @act_rtn_nm   , 'sub test 001 @rtn_nm   , @act_rtn_nm mismatch';
   IF @exp_rtn_ty_code IS NOT NULL EXEC tSQLt.AssertEquals @exp_rtn_ty_code, @act_rtn_ty_code, 'sub test 002 @exp_rtn_ty_code, @act_rtn_ty_code mismatch'
   EXEC sp_log 1, @fn, '99: leaving OK;'
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_016_fnGetRtnDetails';
*/
GO

