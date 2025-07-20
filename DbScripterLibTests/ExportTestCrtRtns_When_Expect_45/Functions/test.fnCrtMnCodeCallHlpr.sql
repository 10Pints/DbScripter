SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==============================================================================================
-- Author:      Terry Watts
-- Create date: 16-Apr-2024
-- Description: Add the EXEC test.<test helper proc> call and params
--
-- Preconditions: Test.RtnDetails and Test.ParamDetails pop'd
--
-- Postconditions:
-- Returns: @rtnDef
-- Post 01:
--
-- Called By: sp_crt_tst_mn_script
-- ==============================================================================================
CREATE FUNCTION [test].[fnCrtMnCodeCallHlpr]()
RETURNS @t TABLE
(
    id    INT
   ,line  VARCHAR(500)
)
AS
BEGIN
   DECLARE
    @tab1               VARCHAR(3) = '   '
   ,@trn                INT
   ,@tst_proc_hlpr_nm   VARCHAR(60)
   ,@rtn_nm             VARCHAR(60)
   ,@ad_stp             BIT = 0
   ;

   SELECT
       @tst_proc_hlpr_nm = hlpr_rtn_nm
      ,@ad_stp           = ad_stp
      ,@trn              = trn
      ,@rtn_nm           = rtn_nm
   FROM test.RtnDetails
   ;

   -----------------------------------------------------------------
   -- Add the EXEC test.<test helper proc> call
   -----------------------------------------------------------------
   INSERT INTO @t (line) VALUES (CONCAT(@tab1, 'EXEC test.',@tst_proc_hlpr_nm, iif(@ad_stp=1, '  -- fnCrtMnCodeCallHlpr','')));

   -----------------------------------------------------------------
   -- Add the helper parameters
   -----------------------------------------------------------------
    INSERT INTO @t (line)
    SELECT line FROM test.fnCrtMnCodeCallHlprPrms();
   RETURN;
END
/*
SELECT * FROM test.fnCrtMnCodeCallHlpr();
EXEC tSQLt.Run 'test.test_067_sp_crt_tst_mn';
SELECT * FROM test.RtnDetails
SELECT * FROM test.ParamDetails
*/



GO
