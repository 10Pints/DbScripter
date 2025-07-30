SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================================================
-- Author:      Terry Watts
-- Create date: 16-APR-2024
-- Description: creates the test helper code to call a stored procedure
-- Preconditions:
--    test.rtnDetails and test.ParamDetails populated
--
-- POSTCONDITIONS:
-- POST 01:
--
-- Called by: fnCrtHlprCodeCallBloc
--
-- Changes:
-- 241126: now that we have added @display tables as a parameter to test helper fns for P and TF
--          but not FN then the first rtn param ordinal position will b 3 if FNs else 4
-- ==============================================================================================
CREATE FUNCTION [test].[fnCrtHlprCodeCallProc]()
RETURNS @t TABLE
(
    id    INT IDENTITY(1,1) NOT NULL
   ,line  VARCHAR(500)
)
AS
BEGIN
   DECLARE
    @qrn          VARCHAR(100)
   ,@tab1         VARCHAR(3) = dbo.fnGetNTabs(1)
   ,@tab2         VARCHAR(6) = dbo.fnGetNTabs(2)
   ,@tab3         NCHAR(9)    = dbo.fnGetNTabs(3)
   ,@tab4         NCHAR(12)   = dbo.fnGetNTabs(4)
   ,@tab5         NCHAR(15)   = dbo.fnGetNTabs(5)
   ,@rtn_ty_code  NCHAR(2)
   ,@ad_stp       BIT
   ,@max_prm_len  INT
   ,@line         VARCHAR(60) = REPLICATE('-', 60)
   ,@first_exp_prm_ndx  INT
   ,@rtn_ty       VARCHAR(2)
   SELECT
       @qrn          = qrn
      ,@ad_stp       = ad_stp
      ,@max_prm_len  = max_prm_len
      ,@rtn_ty       = rtn_ty
   FROM test.RtnDetails;
   SET @first_exp_prm_ndx =
   (
      SELECT TOP 1 ordinal
      FROM test.ParamDetails
      WHERE is_output=1
      ORDER BY ordinal
   )
   INSERT INTO @t (line) VALUES  (CONCAT(@tab4, 'EXEC @act_RC = ', @qrn, iif( @ad_stp = 1, '-- fnCrtHlprCodeCallProc', '')));
   INSERT INTO @t (line)
      SELECT
         CONCAT
         (
             @tab5
            ,dbo.fnPadRight
             (
               CONCAT
               (
               -- 241116: display tables affects the first ordinal as it depends on rtn type
               -- P and TF have the extra display tables parameter, FNs do not
                   iif(ordinal >iif(@rtn_ty = 'FN',3, 3),',',' ')
               ,'@'
               ,param_nm
             )
             ,@max_prm_len+3)
             ,' = @', IIF(is_output=1, 'act', 'inp'), '_'
             ,param_nm
             ,iif(is_output=1, dbo.fnPadLeft(' OUTPUT', @max_prm_len-len(param_nm)+8), '')
          )
      FROM test.ParamDetails
      WHERE tst_ty='INP';
   INSERT INTO @t (line) VALUES
     (CONCAT(@tab5,';'))
   ;
   RETURN;
END
/*
SELECT * FROM test.fnCrtHlprCodeCallProc()
EXEC tSQLt.Run 'test.test_086_sp_crt_tst_hlpr_script';
EXEC tSQLt.RunAll;
EXEC test.sp_set_rtn_details 'test.sp_pop_param_details', 41, @display_tables = 1
*/
GO

