SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================================================
-- Author:      Terry Watts
-- Create date: 16-APR-2024
-- Description: adds the expected parameters for a table function test
-- Preconditions:
--    test.rtnDetails and test.ParamDetails populated
--
-- Postconditions:
-- POST 01:
-- ==============================================================================================
CREATE FUNCTION [test].[fnCrtHlprSigExpParamsTf]()
RETURNS @t TABLE
(
    id    INT IDENTITY(1,1)
   ,line  NVARCHAR(500)
)
AS
BEGIN
   DECLARE
    @tab       NVARCHAR(3) = '   '
   ,@ad_stp    BIT
   ,@max_len   INT
   ,@rtn_nm    NVARCHAR(32)
   ,@schema_nm NVARCHAR(32)
   SELECT 
       @ad_stp    = ad_stp
      ,@rtn_nm    = rtn_nm
      ,@schema_nm = schema_nm
   FROM test.RtnDetails;
   IF @ad_stp = 1
      INSERT INTO @t( line)
      VALUES ('-- fnCrtHlprSigExpParamsTf');
   SELECT @max_len = MAX(dbo.fnLen(CONCAT('@exp_', col_nm, ' ', data_type))) + 1
   FROM dbo.fnGetOutputColumnsForTf(@schema_nm, @rtn_nm);
   INSERT INTO @t (line) 
   SELECT CONCAT(@tab, dbo.fnPadRight(CONCAT(',@exp_', col_nm, ' ', data_type), @max_len), ' = NULL')
   FROM dbo.fnGetOutputColumnsForTf(@schema_nm, @rtn_nm);
   RETURN;
END
/*
   SELECT * FROM test.fnCrtHlprSigExpParamsTf()
   SELECT * FROM test.fnCrtHlprSigExpParamsTf()
   EXEC tSQLt.Run 'test.test_086_sp_crt_tst_hlpr_script'
*/
GO

