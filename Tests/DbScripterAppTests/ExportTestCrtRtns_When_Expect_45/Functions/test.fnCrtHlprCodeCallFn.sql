SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================================================
-- Author:      Terry Watts
-- Create date: 16-APR-2024
-- Description: creates the test helper code for a scalar fn
-- Preconditions:
--    test.rtnDetails and test.ParamDetails populated
--
-- POSTCONDITIONS:
-- POST 01:
-- ==============================================================================================
CREATE FUNCTION [test].[fnCrtHlprCodeCallFn]()
RETURNS @t TABLE 
(
    id    INT
   ,line  VARCHAR(500)
)
AS
BEGIN
   DECLARE
    @qrn          VARCHAR(100)
   ,@rtn_ty_code  NCHAR(2)
   ,@ad_stp       BIT
   ,@prm_cnt      INT
   ,@tab1         VARCHAR(3) = dbo.fnGetNTabs(1)
   ,@tab2         VARCHAR(6) = dbo.fnGetNTabs(2)
   ,@tab3         NCHAR(9)    = dbo.fnGetNTabs(3)
   ,@tab4         NCHAR(12)   = dbo.fnGetNTabs(4)
   ,@tab5         NCHAR(15)   = dbo.fnGetNTabs(5)
   ,@tab6         NCHAR(18)   = dbo.fnGetNTabs(6)
   SELECT
       @qrn    = qrn
      ,@ad_stp = ad_stp
      ,@prm_cnt= prm_cnt
   FROM test.RtnDetails;
   INSERT INTO @t (line) VALUES     (IIF(@ad_stp = 1 ,'-- fnCrtHlprCodeCallFn', ''));
   -------------------------------------------------------------------------
   -- Handle single parameter inline, but multiple parameters on separate lines
   -------------------------------------------------------------------------
   IF @prm_cnt = 1
   BEGIN
      -- Handle single parameter  inline
      INSERT INTO @t (line) SELECT
      (CONCAT(@tab4, 'SET @act_out_val = ', @qrn, '( @inp_,',param_nm,')'))
      FROM test.ParamDetails
      WHERE tst_ty='INP'
      ;
   END
   ELSE
   BEGIN
      -- Handle multiple parameters on separate lines
      INSERT INTO @t (line) VALUES
      (CONCAT(@tab4, 'SET @act_out_val = ', @qrn))
     ,(CONCAT(@tab4, '('))
   -- Add the parameters
   INSERT INTO @t (line) SELECT
      CONCAT( @tab5, STRING_AGG(CONCAT('@inp_',param_nm), ', '))
      FROM test.ParamDetails
      WHERE tst_ty='INP';
   INSERT INTO @t (line) VALUES
    (CONCAT(@tab4, ');'))
   ;
   END
      INSERT INTO @t (line) VALUES ('');
   RETURN;
END
/*
SELECT * FROM test.fnCrtHlprCodeCallFn();
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_??';
    @inp_input_str,  @inp_sep,  @inp_ndx
   SELECT * FROM test.RtnDetails
*/
GO

