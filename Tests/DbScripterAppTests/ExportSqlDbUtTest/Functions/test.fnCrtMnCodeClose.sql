SET ANSI_NULLS ON
GO
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
   ,line  NVARCHAR(1000)
)
AS
BEGIN
   DECLARE
    @tst_rtn_nm   NVARCHAR(50)
   ,@tab          NCHAR(3) = '   '
   ,@ad_stp       BIT
   SELECT
      @tst_rtn_nm = tst_rtn_nm
      ,@ad_stp    = ad_stp
   FROM test.RtnDetails;
   INSERT INTO @t( line)
   VALUES
       ('')
      ,(CONCAT(@tab,'EXEC sp_log 2, @fn, ''99: All subtests PASSED''', IIF(@ad_stp=1, ' -- CLS-1','')))
      ,('END')
      ,('/*')
      ,(CONCAT('EXEC tSQLt.Run ''test.', @tst_rtn_nm,''';'))
      ,('*/')
   RETURN;
END
/*
SELECT * FROM test.fnCrtCodeMnTstSig()
*/
GO

