SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- ====================================================================================
-- Author:      Terry Watts
-- Create date: 16-APR-2024
--
-- Description: creates the close bloc for the main test rtn
--
-- Preconditions:
--    test.rtnDetails and test.ParamDetails populated
--
-- Test rtn: test.test_086_sp_crt_tst_hlpr_script
--
-- ====================================================================================
CREATE FUNCTION [test].[fnCrtMnCodeClose]()
RETURNS @t TABLE
(
    id    INT IDENTITY (1,1)
   ,line  VARCHAR(1000)
)
AS
BEGIN
   DECLARE
    @tst_rtn_nm   VARCHAR(50)
   ,@tab1         NCHAR(3) = '   '
   ,@ad_stp       BIT
   SELECT
      @tst_rtn_nm = tst_rtn_nm
      ,@ad_stp    = ad_stp
   FROM test.RtnDetails;
   INSERT INTO @t( line)
   VALUES
    ('')
   ,(CONCAT(@tab1,'EXEC sp_log 2, @fn, ''99: All subtests PASSED''', IIF(@ad_stp=1, ' -- CLS-1','')))
   ,(CONCAT(@tab1, 'EXEC test.sp_tst_mn_cls;'))
   ,('END')
   ,('/*')
   ,('EXEC tSQLt.RunAll;')
   ,(CONCAT('EXEC tSQLt.Run ''test.', @tst_rtn_nm,''';'))
   ,('*/')
   RETURN;
END
/*
SELECT * FROM test.fnCrtCodeMnTstSig()
*/
GO

