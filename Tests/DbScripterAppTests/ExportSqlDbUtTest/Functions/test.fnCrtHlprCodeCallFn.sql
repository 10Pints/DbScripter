SET ANSI_NULLS ON
GO
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
   ,line  NVARCHAR(500)
)
AS
BEGIN
   DECLARE
    @qrn          NVARCHAR(100)
   ,@rtn_ty_code  NCHAR(2)
   ,@ad_stp       BIT
   ,@tab2         NVARCHAR(9)  = REPLICATE('   ', 2)
   ,@tab3         NVARCHAR(9)  = REPLICATE('   ', 3)
   SELECT
      @qrn = qrn
   FROM test.RtnDetails;
   INSERT INTO @t (line) VALUES
     (IIF(@ad_stp = 1 ,'-- fnCrtHlprCodeCallFn', ''))
    ,(CONCAT(@tab2, 'SET @act_out_val = ', @qrn))
    ,(CONCAT(@tab2, '('))
   ;
   INSERT INTO @t (line) SELECT
      CONCAT( @tab3, STRING_AGG(CONCAT('@inp_',param_nm), ', '))
      FROM test.ParamDetails
      WHERE tst_ty='INP';
   INSERT INTO @t (line) VALUES
    (CONCAT(@tab2, ')'))
   ,('')
   ;
   RETURN;
END
/*
SELECT * FROM test.fnCrtHlprCodeCallFn();
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_??';
    @inp_input_str,  @inp_sep,  @inp_ndx
*/
GO

