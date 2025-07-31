SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ========================================================================================
-- Author:           Terry Watts
-- Create date:      11-Nov-2023
-- Description:      main test rtn for the sp_exprt_to_xl rtn being tested
-- Tested rtn desc:
--  Creates an Excel xls file as a TSV  
-- N.B.: It needs to be loaded by Excel to actual make a .xls formatted file, however  
-- Excel will open a CSV or TSV as an Excel file with a warning prompt  
--  
-- Process:  
--  Validate parameters  
--      Mandatory parameters  
--          table name  
--          folder  
--  
--  set paramter defaults as needed  
--      file name       <table>.xlsx  
--      sheet_name:     <table>  
--      view:           <table>View  
--      timestamp:      <current time and date> Fprmat YYMMDD-HHmm  
--
-- Tested rtn params: 
--    @tbl_nm      NVARCHAR(50),
--    @folder      NVARCHAR(260),
--    @wrkbk_nm    NVARCHAR(260),
--    @sht_nm      NVARCHAR(50),
--    @vw_nm       NVARCHAR(50),
--    @filter      NVARCHAR(MAX),
--    @crt_tmstmp  BIT,
--    @max_rows    INT
-- ========================================================================================
CREATE PROCEDURE [test].[test_039_sp_exprt_to_xl]
AS
BEGIN
   DECLARE
      @fn                 NVARCHAR(35)   = N'test_039_sp_exprt_to_xl'
   EXEC ut.test.sp_tst_mn_st @fn
   ---- Run the test Helper rtn to run the tested rtn and do some checks
   EXEC test.hlpr_039_sp_exprt_to_xl
       @tst_num   = 'T001'
      ,@tbl_spec  = ''
      ,@folder    = ''
      ,@wrkbk_nm  = ''
      ,@sht_nm    = ''
      ,@vw_nm     = ''
      ,@filter    = ''
      ,@crt_tmstmp= 0
      ,@max_rows  = 0
      ,@exp_ex_num= 50102
      ,@exp_ex_msg= 'table must be specified'
  ;
   EXEC ut.test.sp_tst_mn_cls;
END
/*
EXEC tSQLt.Run 'test.test_039_sp_exprt_to_xl';
EXEC tSQLt.RunAll;
*/
GO

