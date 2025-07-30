SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ====================================================================================
-- Author:      Terry Watts
-- Create date: 16-APR-2024
--
-- Description: creates the test helper signature line for the hlpr script like:
-- ALTER PROCEDURE test.hlpr_106_fnGetParams
--    @qrn       VARCHAR(120)
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
   ,line  VARCHAR(1000)
)
AS
BEGIN
   DECLARE
    @qrn          VARCHAR(120)
   ,@schema_nm    VARCHAR(50)
   ,@rtn_nm       VARCHAR(60)
   ,@rtn_ty       NCHAR(1)
   ,@trn          VARCHAR(90)
   ,@tst_rtn_nm   VARCHAR(50)
   ,@hlpr_rtn_nm  VARCHAR(50)
   ,@ad_stp       BIT
   ,@cora         NCHAR(1)
   ,@tab          VARCHAR(3) = '   '
   SELECT
       @qrn       = qrn
      ,@schema_nm = schema_nm
      ,@rtn_nm     = rtn_nm
      ,@trn        = trn
      ,@tst_rtn_nm = tst_rtn_nm
      ,@hlpr_rtn_nm= hlpr_rtn_nm
      ,@ad_stp     = ad_stp
      ,@cora       = cora
   FROM test.RtnDetails;
   SELECT @rtn_ty = rtn_ty
   FROM test.RtnDetails;
   INSERT INTO @t( line)
   VALUES
       (CONCAT(iif(@cora='C','CREATE','ALTER'),' PROCEDURE test.', @hlpr_rtn_nm, IIF(@ad_stp=1,' -- fnCrtHlprCodeHlprSig','')))
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

