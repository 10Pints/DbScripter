SET ANSI_NULLS ON
GO
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
-- Keys:
-- RN-TST
-- ==============================================================================================
CREATE FUNCTION [test].[fnCrtHlprCodeCallProc]()
RETURNS @t TABLE
(
    id    INT IDENTITY(1,1) NOT NULL
   ,line  NVARCHAR(500)
)
AS
BEGIN
   DECLARE
    @qrn          NVARCHAR(100)
   ,@tab          NCHAR(3)  = '   '
   ,@tab2         NCHAR(6)  = dbo.fnGetNTabs(2)
   ,@tab3         NCHAR(9)  = dbo.fnGetNTabs(3)
   ,@tab4         NCHAR(12) = dbo.fnGetNTabs(4)
   ,@rtn_ty_code  NCHAR(2)
   ,@ad_stp       BIT
   ,@max_prm_len  INT
   ,@line         NVARCHAR(60) = REPLICATE('-', 60)
   ,@first_exp_prm_ndx  INT
   SELECT
       @qrn          = qrn
      ,@ad_stp       = ad_stp
      ,@max_prm_len  = max_prm_len
   FROM test.RtnDetails;
   SET @first_exp_prm_ndx = 
   (
      SELECT TOP 1 ordinal
      FROM test.ParamDetails
      WHERE is_out_col=1
      ORDER BY ordinal
   )
   INSERT INTO @t (line) VALUES
     (CONCAT(@tab, 'WHILE 1 = 1', IIF(@ad_stp = 1 ,' -- fnCrtHlprCodeCallProc]', '')))
    ,(CONCAT(@tab, 'BEGIN'))
    ,(CONCAT(@tab2, 'BEGIN TRY'))
    ,(CONCAT(@tab3, 'DROP TABLE IF EXISTS test.results;'))
    ,(CONCAT(@tab3, 'CREATE TABLE test.results'))
    ,(CONCAT(@tab3, '('))
    ;
   INSERT INTO @t (line) 
   SELECT CONCAT(@tab4, iif(ordinal <> @first_exp_prm_ndx, ',', ' '), dbo.fnPadRight(param_nm, @max_prm_len), type_nm)
   FROM test.ParamDetails
   WHERE is_out_col=1;
   INSERT INTO @t (line) VALUES
    (CONCAT(@tab3, ')'))
    ,(CONCAT(@tab3, 'EXEC sp_log 1, @fn, ''010: Calling tested routine: ', @qrn, ''';'))
    ,(CONCAT(@tab3, ' --this may fail if there is dynamic SQL in the SP'))
    ,(CONCAT(@tab3, ' --the SELECT INTO EXEC will fail if there is dynamic SQL in the SP'))
    ,(CONCAT(@tab3, ' --in which case manually create the results table based on the sp output '))
    ,('')
    ,(CONCAT(@tab3, 'INSERT INTO test.Results EXEC ', @qrn));
   INSERT INTO @t (line)
      SELECT CONCAT(@tab4, dbo.fnPadRight(CONCAT(iif(ordinal >3, ',',' '), '@',param_nm), @max_prm_len+3), ' = @inp_', param_nm)
      FROM test.ParamDetails
      WHERE tst_ty='INP';
   INSERT INTO @t (line) VALUES
     (CONCAT(@tab3,';'))
    ,('')
    ,(CONCAT(@tab3,'IF @exp_ex_num IS NOT NULL OR @exp_ex_msg IS NOT NULL'))
    ,(CONCAT(@tab3,'BEGIN'))
    ,(CONCAT(@tab4,'EXEC sp_log 4, @fn, ''010: oops! Expected exception was not thrown'';'))
    ,(CONCAT(@tab4, 'THROW 51000, '' Expected exception was not thrown'', 1;'))
    ,(CONCAT(@tab3,'END'))
    ,(CONCAT(@tab2,'END TRY'))
    ,(CONCAT(@tab2,'BEGIN CATCH'))
    ,(CONCAT(@tab3, 'SET @act_ex_num = ERROR_NUMBER();'))
    ,(CONCAT(@tab3, 'SET @act_ex_msg = ERROR_MESSAGE();'))
    ,(CONCAT(@tab3, 'EXEC sp_log 1, @fn, ''015: caught exception'', @act_ex_num, @act_ex_msg;'))
    ,(CONCAT(@tab4, 'EXEC sp_log 1, @fn, ''020 check ex num , exp: '', @exp_ex_num, '' act: '', @act_ex_num;'))
    ,(CONCAT(@tab3, 'EXEC sp_log_exception @fn;'))
    ,('')
    ,(CONCAT(@tab3, 'IF @exp_ex_num IS NULL AND @exp_ex_msg IS NULL'))
    ,(CONCAT(@tab3, 'BEGIN'))
    ,(CONCAT(@tab4, 'EXEC sp_log 4, @fn, ''08: oops! Unexpected an exception here'';'))
    ,(CONCAT(@tab4, 'THROW 51000, '' caught unexpected exception'', 1;'))
    ,(CONCAT(@tab3, 'END'))
    ,('')
    ,(CONCAT(@tab3, @line))
    ,(CONCAT(@tab3, '-- ASSERTION: if here then expected exception'))
    ,(CONCAT(@tab3, @line))
    ,(CONCAT(@tab3, 'IF @exp_ex_num IS NOT NULL EXEC tSQLt.AssertEquals @exp_ex_num, @act_ex_num        ,''ex_num mismatch'';'))
    ,(CONCAT(@tab3, 'IF @exp_ex_msg IS NOT NULL EXEC tSQLt.AssertEquals @exp_ex_msg, @act_ex_msg        ,''ex_msg mismatch'';'))
    ,(CONCAT(@tab3, ''))
    ,(CONCAT(@tab3,'EXEC sp_log 2, @fn, ''030 test# '',@tst_num, '': exception test PASSED;'''))
    ,(CONCAT(@tab3, 'BREAK'))
    ,(CONCAT(@tab2, 'END CATCH'))
    ,('')
    ,(CONCAT(@tab2, '-- TEST:'))
    ,(CONCAT(@tab2,'EXEC sp_log 2, @fn, ''10: running tests...'';'));
    INSERT INTO  @t (line) 
    SELECT line FROM test.fnCrtHlprCodeChkExps();
    INSERT INTO  @t (line) VALUES
     (CONCAT(@tab2, '-- passed tests'))
    ,(CONCAT(@tab2, 'BREAK'))
    ,(CONCAT(@tab, 'END --WHILE'))
    ,('')
   ,(CONCAT(@tab, 'EXEC sp_log 2, @fn, ''17: all tests ran OK'''))
   ,(CONCAT(@tab, 'EXEC test.sp_tst_hlpr_hndl_success;'))
   ;
   RETURN;
END
/*
SELECT * FROM test.fnCrtHlprCodeCallProc()
EXEC tSQLt.Run 'test.test_086_sp_crt_tst_hlpr_script';
EXEC tSQLt.RunAll;
   -- add parameters @p=@inp_p
   INSERT INTO @t (line)
      SELECT CONCAT(@tab3,dbo.fnPadRight(param_nm, @max_prm_len), ' = @inp_', dbo.fnTrim2(param_nm,'@'))
      FROM test.ParamDetails;
*/
GO

