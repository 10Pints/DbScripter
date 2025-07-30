SET ANSI_NULLS ON
GO
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
   ,line  NVARCHAR(500)
)
AS
BEGIN
   DECLARE
    @tab1               NVARCHAR(3) = '   '
   ,@tab2               NVARCHAR(6) = '      '
   ,@rtn_ty_code        NCHAR(2)
   ,@tst_proc_hlpr_nm   NVARCHAR(60)
   ,@detld_rtn_ty_code  NVARCHAR(2)
   ,@qrn                NVARCHAR(100)
   ,@sc_fn_ret_ty       NVARCHAR(50)
   ,@ad_stp             BIT = 0
   ,@tst_rtn_nm         NVARCHAR(60)
   SELECT
       @tst_rtn_nm = tst_rtn_nm
      ,@ad_stp     = ad_stp
   FROM test.RtnDetails;
   INSERT INTO @t (line) VALUES
    ('')
   ,(CONCAT(@tab2,'-- CLEANUP:', IIF(@ad_stp=1, ' -- fnCrtHlprCodeCloseBloc','')))
   ,(CONCAT(@tab2,'-- <TBD>'))
   ,('')
   ,(CONCAT(@tab2,'EXEC sp_log 1, @fn, ''990: all subtests PASSED'';'))
   ,(CONCAT(@tab1,'END TRY'))
   ,(CONCAT(@tab1,'BEGIN CATCH'))
   ,(CONCAT(@tab2,'EXEC sp_log_exception @fn;'))
   ,(CONCAT(@tab2,'THROW;'))
   ,(CONCAT(@tab1,'END CATCH'))
   ,('')
   ,(CONCAT(@tab1,'EXEC test.sp_tst_hlpr_hndl_success;'))
   ,('END')
   ,('/*')
   ,(CONCAT(@tab1,'EXEC tSQLt.Run ''test.', @tst_rtn_nm, ''';'))
   ,(CONCAT(@tab1,'EXEC tSQLt.RunAll;'))
   ,('*/')
   ;
   RETURN;
END
/*
EXEC tSQLt.Run 'test.test_086_sp_crt_tst_hlpr_script';
EXEC tSQLt.RunAll;
*/
GO

