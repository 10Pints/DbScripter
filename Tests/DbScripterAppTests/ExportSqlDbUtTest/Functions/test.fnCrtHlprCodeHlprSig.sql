SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ====================================================================================
-- Author:      Terry Watts
-- Create date: 16-APR-2024
--
-- Description: creates the test helper signature line for the hlpr script like:
-- CREATE PROCEDURE test.hlpr_106_fnGetParams
--    @qrn       NVARCHAR(120)
--   ,@ordinal   INT
--
-- Preconditions:
--    test.rtnDetails and test.ParamDetails populated
--
-- Test rtn: test.test_086_sp_crt_tst_hlpr_script
--
-- ====================================================================================
CREATE FUNCTION [test].[fnCrtHlprCodeHlprSig]()
RETURNS @t TABLE
(
    id    INT IDENTITY (1,1)
   ,line  NVARCHAR(1000)
)
AS
BEGIN
   DECLARE
    @qrn          NVARCHAR(120)
   ,@schema_nm    NVARCHAR(50)
   ,@rtn_nm       NVARCHAR(60)
   ,@rtn_ty       NCHAR(1)
   ,@trn          NVARCHAR(90)
   ,@tst_rtn_nm   NVARCHAR(50)
   ,@hlpr_rtn_nm  NVARCHAR(50)
   ,@ad_stp       BIT
   ,@tab          NVARCHAR(3) = '   '
   SELECT
       @qrn       = qrn
      ,@schema_nm = schema_nm
      ,@rtn_nm     = rtn_nm
      ,@trn        = trn
      ,@tst_rtn_nm = tst_rtn_nm
      ,@hlpr_rtn_nm= hlpr_rtn_nm
      ,@ad_stp     = ad_stp
   FROM test.RtnDetails;
   SELECT @rtn_ty = rtn_ty
   FROM test.RtnDetails;
   INSERT INTO @t( line)
   VALUES
       (CONCAT('CREATE PROCEDURE test.', @hlpr_rtn_nm, IIF(@ad_stp=1,' -- fnCrtHlprCodeHlprSig','')))
   -- Add the rtn params
   INSERT INTO @t( line)
   SELECT line
   FROM test.fnCrtHlprSigParams();
   RETURN;
END
/*
EXEC tSQLt.Run 'test.test_086_sp_crt_tst_hlpr_script';
EXEC tSQLt.Run 'test.test_057_sp_crt_tst_hlpr';
EXEC tSQLt.RunAll;
EXEC test.sp_get_rtn_details 'dbo.fnEatWhitespace';
SELECT * FROM test.fnCrtHlprCodeHlprSig();
EXEC test.sp_get_rtn_details 'dbo.sp_get_excel_data';
SELECT * FROM test.fnCrtHlprCodeHlprSig();
SELECT * FROM test.fnEatWhitespace();
*/
GO

