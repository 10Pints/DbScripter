SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================
-- Author:      Terry Watts
-- Create date: 16-Apr-2024
-- Description: creates the helper close bloc
--
-- Preconditions: Test.RtnDetails and Test.ParamDetails pop'd
--
-- Postconditions:
-- =============================================================
CREATE FUNCTION [test].[fnCrtHlprCodeCloseBloc]()
RETURNS @t TABLE 
(
    id    INT
   ,line  VARCHAR(500)
)
AS
BEGIN
   DECLARE
    @tab1               VARCHAR(3) = '   '
   ,@tab2               VARCHAR(6) = '      '
   ,@rtn_ty_code        NCHAR(2)
   ,@tst_proc_hlpr_nm   VARCHAR(60)
   ,@detld_rtn_ty_code  VARCHAR(2)
   ,@qrn                VARCHAR(100)
   ,@sc_fn_ret_ty       VARCHAR(50)
   ,@ad_stp             BIT = 0
   ,@tst_rtn_nm         VARCHAR(60)
   SELECT
       @tst_rtn_nm = tst_rtn_nm
      ,@ad_stp     = ad_stp
   FROM test.RtnDetails;
   INSERT INTO @t (line)
   VALUES
    ('')
   ,(CONCAT(@tab2,'-- CLEANUP: ??', IIF(@ad_stp=1, ' -- fnCrtHlprCodeCloseBloc','')))
   ,('')
   ,(CONCAT(@tab2,'EXEC sp_log 1, @fn, ''990: all subtests PASSED'';'))
   ,(CONCAT(@tab1,'END TRY'))
   ,(CONCAT(@tab1,'BEGIN CATCH'))
   ,(CONCAT(@tab2,'EXEC test.sp_tst_hlpr_hndl_failure;'))
   ,(CONCAT(@tab2,'THROW;'))
   ,(CONCAT(@tab1,'END CATCH'))
   ,('')
   ,(CONCAT(@tab1,'EXEC test.sp_tst_hlpr_hndl_success;'))
   ,('END')
   ,('/*')
   ,('EXEC tSQLt.RunAll;')
   ,(CONCAT('EXEC tSQLt.Run ''test.', @tst_rtn_nm, ''';'))
   ,('*/')
   ;
   RETURN;
END
/*
EXEC tSQLt.Run 'test.test_086_sp_crt_tst_hlpr_script';
EXEC tSQLt.RunAll;
*/
GO

