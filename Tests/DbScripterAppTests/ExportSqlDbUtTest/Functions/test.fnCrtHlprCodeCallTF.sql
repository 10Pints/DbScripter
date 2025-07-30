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
CREATE FUNCTION [test].[fnCrtHlprCodeCallTF]()
RETURNS @t TABLE 
(
    id    INT
   ,line  NVARCHAR(500)
)
AS
BEGIN
   DECLARE
    @tab1            NVARCHAR(3) = REPLICATE(' ', 3)
   ,@tab2            NVARCHAR(6) = REPLICATE(' ', 6)
   ,@tab3            NVARCHAR(9) = REPLICATE(' ', 9)
   ,@qrn             NVARCHAR(100)
   ,@ad_stp          BIT
   ,@st_inp_ordinal  INT
   SELECT
       @qrn    = qrn
      ,@ad_stp = ad_stp
   FROM test.RtnDetails;
   INSERT INTO @t (line) VALUES
    (CONCAT(@tab2,'DROP TABLE IF EXISTS test.results', IIF(@ad_stp = 1 ,' -- CALL-TF', '')))
   ,(CONCAT(@tab2,''))
   ,(CONCAT(@tab2,'SELECT * INTO test.Results FROM ', @qrn))
   ,(CONCAT(@tab2,'('))
   ;
   SELECT @st_inp_ordinal = MIN(ordinal)
   FROM test.ParamDetails 
   WHERE tst_ty='INP'
   ;
   -- Add params
   INSERT INTO @t (line) 
   SELECT CONCAT( @tab3, iif(ordinal = @st_inp_ordinal,' ',',') , '@inp_', param_nm)
   FROM test.ParamDetails
   WHERE tst_ty ='INP';
   -- close off fn ()
   INSERT INTO @t (line) VALUES
    (CONCAT(@tab2,')'))
   ,(CONCAT(@tab2,''))
   ;
   RETURN;
END
/*
---------------------------------------------------------------------
TRUNCATE TABLE AppLog
EXEC tSQLt.Run 'test.test_068_sp__crt_tst_rtns_TF';
---------------------------------------------------------------------
SELECT * FROM test.fnCrtHlprCodeCallTF();
SELECT * FROM test.ParamDetails;
*/
GO

