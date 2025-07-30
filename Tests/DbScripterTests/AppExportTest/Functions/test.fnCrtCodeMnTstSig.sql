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
CREATE FUNCTION [test].[fnCrtCodeMnTstSig]()
RETURNS @t TABLE
(
    id    INT IDENTITY (1,1)
   ,line  VARCHAR(1000)
)
AS
BEGIN
   DECLARE
    @tst_rtn_nm   VARCHAR(50)
   ,@cora         NCHAR(1)
   SELECT
      @tst_rtn_nm = tst_rtn_nm
     ,@cora       = cora
   FROM test.RtnDetails;
   INSERT INTO @t( line)
   VALUES
       (CONCAT(iif(@cora='C', 'CREATE', 'ALTER'), ' PROCEDURE test.', @tst_rtn_nm));
   RETURN;
END
/*
SELECT * FROM test.fnCrtCodeMnTstSig()
*/
GO

