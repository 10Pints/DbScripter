SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================================================
-- Author:      Terry Watts
-- Create date: 18-Apr-2024
-- Description: creates the tested rtn call dependant on the rtn type code
--
-- Preconditions: Test.RtnDetails and Test.ParamDetails pop'd
--
-- Postconditions:
-- Returns: lines of detailed test
--
-- Method:
-- delegate to a specific rtn based on rtn type
--
-- Called by: sp_crt_tst_hlpr_script
--
-- ==============================================================================================
CREATE FUNCTION [test].[fnCrtHlprCodeCallBloc]()
RETURNS @t TABLE
(
    id    INT IDENTITY(1,1)
   ,line  VARCHAR(500)
)
AS
BEGIN
   DECLARE
    @tab1         VARCHAR(3)  = dbo.fnGetNTabs(1)
   ,@tab2         VARCHAR(6)  = dbo.fnGetNTabs(2)
   ,@tab3         CHAR(9)     = dbo.fnGetNTabs(3)
   ,@tab4         CHAR(12)    = dbo.fnGetNTabs(4)
   ,@tab5         NCHAR(15)   = dbo.fnGetNTabs(5)
   ,@line         VARCHAR(60) = REPLICATE('-', 60)
   ,@line_star    VARCHAR(100)= N' --' + REPLICATE('*', 60)
   ,@qrn          VARCHAR(100)
   ,@rtn_ty_code  VARCHAR(2)
   ,@ad_stp       BIT
   ,@nl           VARCHAR(2) = CHAR(13)+CHAR(10)
   SELECT
       @qrn         = qrn
      ,@rtn_ty_code = rtn_ty_code
      ,@ad_stp      = ad_stp
   FROM test.RtnDetails
   IF @ad_stp = 1 INSERT INTO @t (line) VALUES (CONCAT(@tab2,'-- fnCrtHlprCodeCallBloc rtn ty:', @rtn_ty_code));
   WHILE 1=1
   BEGIN
      -- Add the rtn type if debugging
 --     IF @ad_stp = 1 INSERT INTO @t (line) VALUES( CONCAT(@tab2, '-- @rtn_ty_code:', @rtn_ty_code));
      INSERT INTO @t (line) VALUES
        (CONCAT(@tab2, 'WHILE 1 = 1'))
       ,(CONCAT(@tab2, 'BEGIN'))
       ,(CONCAT(@tab3, 'BEGIN TRY'))
       ,(CONCAT(@tab4, 'EXEC sp_log 1, @fn, ''010: Calling the tested routine: ', @qrn, ''';'))
       ,(CONCAT(@tab4, @line))
      IF @rtn_ty_code = 'P'
      BEGIN
         INSERT INTO @t (line)
            SELECT line FROM test.fnCrtHlprCodeCallProc();
            -- 250403: get the act row count 
         INSERT INTO @t (line) VALUES
         (@nl)
        ,(CONCAT(@tab4,'SELECT @act_row_cnt = @@ROWCOUNT;'))
         BREAK;
      END
      IF @rtn_ty_code = 'FN'
      BEGIN
         INSERT INTO @t (line)
            SELECT line FROM test.fnCrtHlprCodeCallFn();
         BREAK;
      END
      IF @rtn_ty_code = 'TF'
      BEGIN
         INSERT INTO @t (line)
            SELECT line FROM test.fnCrtHlprCodeCallTF();
         BREAK;
      END
      -- If here then unrecognised @rtn_ty_code
      INSERT INTO @t (line) VALUES( CONCAT('-- Unrecognised @rtn_ty_code:', @rtn_ty_code));
      BREAK;
   END -- while
   INSERT INTO @t (line) VALUES
       (CONCAT(@tab4, @line))
      ,(CONCAT(@tab4, 'EXEC sp_log 1, @fn, ''020: returned from ', @qrn, ''';'))
      ,('')
      ,(CONCAT(@tab4,'IF @exp_ex_num IS NOT NULL OR @exp_ex_msg IS NOT NULL'))
      ,(CONCAT(@tab4,'BEGIN'))
      ,(CONCAT(@tab5,'EXEC sp_log 4, @fn, ''030: oops! Expected exception was not thrown'';'))
      ,(CONCAT(@tab5, 'THROW 51000, '' Expected exception was not thrown'', 1;'))
      ,(CONCAT(@tab4,'END'))
      ,(CONCAT(@tab3,'END TRY'))
      ,(CONCAT(@tab3,'BEGIN CATCH'))
      ,(CONCAT(@tab4, 'SET @act_ex_num = ERROR_NUMBER();'))
      ,(CONCAT(@tab4, 'SET @act_ex_msg = ERROR_MESSAGE();'))
      ,(CONCAT(@tab4, 'EXEC sp_log 1, @fn, ''040: caught  exception: '', @act_ex_num, '' '',      @act_ex_msg;'))
      ,(CONCAT(@tab4, 'EXEC sp_log 1, @fn, ''050: check ex num: exp: '', @exp_ex_num, '' act: '', @act_ex_num;'))
      ,('')
      ,(CONCAT(@tab4, 'IF @exp_ex_num IS NULL AND @exp_ex_msg IS NULL'))
      ,(CONCAT(@tab4, 'BEGIN'))
      ,(CONCAT(@tab5, 'EXEC sp_log 4, @fn, ''060: an unexpected exception was raised'';'))
      ,(CONCAT(@tab5, 'THROW;'))
      ,(CONCAT(@tab4, 'END'))
      ,('')
      ,(CONCAT(@tab4, @line))
      ,(CONCAT(@tab4, '-- ASSERTION: if here then expected exception'))
      ,(CONCAT(@tab4, @line))
      ,(CONCAT(@tab4, 'IF @exp_ex_num IS NOT NULL EXEC tSQLt.AssertEquals      @exp_ex_num, @act_ex_num, ''ex_num mismatch'';'))
      ,(CONCAT(@tab4, 'IF @exp_ex_msg IS NOT NULL EXEC tSQLt.AssertIsSubString @exp_ex_msg, @act_ex_msg, ''ex_msg mismatch'';'))
      ,(CONCAT(@tab4, ''))
      ,(CONCAT(@tab4,'EXEC sp_log 2, @fn, ''070 test# '',@tst_num, '': exception test PASSED;'''))
      ,(CONCAT(@tab4, 'BREAK'))
      ,(CONCAT(@tab3, 'END CATCH'))
      ,('')
      ,(CONCAT(@tab3, '-- TEST:'))
      ,(CONCAT(@tab3,'EXEC sp_log 2, @fn, ''080: running tests   '';'))
   ;
    INSERT INTO  @t (line) 
    SELECT line FROM test.fnCrtHlprCodeChkExps();
    INSERT INTO  @t (line) VALUES
     ('')
    ,(CONCAT(@tab3, @line))
    ,(CONCAT(@tab3, '-- Passed tests'))
    ,(CONCAT(@tab3, @line))
    ,(CONCAT(@tab3, 'BREAK'))
    ,(CONCAT(@tab2, 'END --WHILE'))
   ;
   RETURN;
END
/*
EXEC tSQLt.Run 'test.test_086_sp_crt_tst_hlpr_script';
EXEC tSQLt.RunAll
SELECT * FROM test.fnCrtHlprCodeCall('SP',1);
SELECT * FROM test.fnCrtHlprCodeCall('F',1);
SELECT * FROM test.fnCrtHlprCodeCall('TF',1);
SELECT * FROM test.RtnDetails;
EXEC test.sp__crt_tst_rtns 'dbo.sp_Import_Role', @trn=26, @ad_stp=1;
*/
GO

