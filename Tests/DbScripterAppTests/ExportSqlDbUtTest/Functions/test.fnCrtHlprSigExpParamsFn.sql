SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================================================
-- Author:      Terry Watts
-- Create date: 16-APR-2024
-- Description: adds the expected parameters for a scalar function test
-- Preconditions:
--    test.ParamDetails populated
--
-- Postconditions:
-- POST 01:
-- ==============================================================================================
CREATE FUNCTION [test].[fnCrtHlprSigExpParamsFn]()
RETURNS @t TABLE 
(
    id    INT IDENTITY(1,1)
   ,line  NVARCHAR(500)
)
AS
BEGIN
-- 11-MAY-2024 currently nothing to do
   RETURN;
END
/*
EXEC tSQLt.Run 'test.test_086_sp_crt_tst_hlpr_script'
EXEC tSQLt.RunAll;
EXEC test.sp_get_rtn_details 'dbo.asFloat'
SELECT * FROM test.fnCrtHlprSigExpParamsFn)
SELECT * FROM test.RtnDetails
SELECT * FROM test.ParamDetails
SELECT * FROM test.ParamDetails
*/
GO

