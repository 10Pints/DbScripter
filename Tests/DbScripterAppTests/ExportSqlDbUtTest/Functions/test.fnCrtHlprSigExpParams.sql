SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================================
-- Author:      Terry Watts
-- Create date: 17-DEC-2023
-- Description: adds the expected params to the helper
--    depends on the tested rtn type
--
-- Preconditions:
--  rtn and params detail tables pop'd
-- Postconditions:
-- ===========================================================================
CREATE FUNCTION [test].[fnCrtHlprSigExpParams]()
RETURNS @t TABLE 
(
    id    INT IDENTITY(1,1)
   ,line  NVARCHAR(500)
)
AS
BEGIN
   DECLARE 
       @rtn_ty_code  NVARCHAR(2)
      SELECT
         @rtn_ty_code  = rtn_ty_code
      FROM test.RtnDetails;
   IF @rtn_ty_code = 'P'
   BEGIN
      INSERT INTO @t(line)
      SELECT line FROM test.fnCrtHlprSigExpParamsSp();
   END
   IF @rtn_ty_code = 'FN'
   BEGIN
      INSERT INTO @t(line)
      SELECT line FROM test.fnCrtHlprSigExpParamsFn();
   END
   IF @rtn_ty_code = 'TF'
   BEGIN
      INSERT INTO @t(line)
      SELECT line FROM test.fnCrtHlprSigExpParamsTf();
   END
   RETURN;
END
/*
SELECT * FROM test.fnCrtHlprSigExpParams();
SELECT * FROM test.RtnDetails
SELECT * FROM test.ParamDetails
EXEC tSQLt.Run 'test.test_086_sp_crt_tst_hlpr_script'
EXEC tSQLt.RunAll;
*/
GO

