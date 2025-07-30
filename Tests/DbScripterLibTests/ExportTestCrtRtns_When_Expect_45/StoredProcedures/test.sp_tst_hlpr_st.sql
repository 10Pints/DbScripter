SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===================================================
-- Author:      Terry Watts
-- Create date: 05-APR-2020
-- Description:
--  Encapsulates the test helper startup:
--  Prints a line to separate test output
--  Prints the EXEC sp_log 2, @fn, '01: starting msg
--  Sets the current test num context
--
--  Clears previous test state context:
--    crnt_tst_err_st         = 0
--    crnt_failed_tst_num     = NULL
--    crnt_failed_tst_sub_num = NULL
-- ===================================================
CREATE PROCEDURE [test].[sp_tst_hlpr_st]
    @sub_tst   VARCHAR(50) -- Like '010: Chk Rule 1' OR 'T010: Chk Rule 1'
   ,@params    VARCHAR(MAX) = NULL
AS
BEGIN
   DECLARE
    @fn        VARCHAR(35)   = N'sp_tst_hlpr_st'
   ,@fnHlrSt   VARCHAR(35)
   ,@NL        VARCHAR(2)    = NCHAR(13) + NCHAR(10)
   ,@line      VARCHAR(100)  = REPLICATE(N'=', 100)
   ,@prms_msg  VARCHAR(MAX)
   ,@tstRtn    VARCHAR(60)
   ,@subTstNum VARCHAR(10) --  = test.fnGetCrntTstNum2()
   ,@msg       VARCHAR(500)
   ,@ndx       INT
   ;
   SET @tstRtn = test.fnGetCrntTstFn();
   SET @ndx = iif(IsNumeric(SUBSTRING(@sub_tst, 1,1))=1, 1,2);
   SET @subTstNum = SUBSTRING(@sub_tst, @ndx, 3);
   EXEC test.sp_tst_set_crnt_tst_num2 @subTstNum;    -- Just the 3 digit test number
   SET @fnHlrSt = test.fnGetCrntTstHlprFn();
   SET @msg = CONCAT(@tstRtn,'.',@subTstNum);
   DELETE FROM AppLog;
   --------------------------------------------------
   -- Validate preconditions:
   --------------------------------------------------
   EXEC sp_assert_not_null_or_empty @sub_tst;
   --------------------------------------------------
   -- Process
   --------------------------------------------------
   SET @prms_msg = IIF(@params IS NOT NULL, CONCAT('params: ', @params), '');
   PRINT test.fnGetTstHdrFooterLine(1, 1, @msg, 'starting');
   EXEC sp_log 1, @fn,@fnHlrSt, '.', @tstRtn,'.',@subTstNum,': 000: starting', @nl, @params;
   EXEC test.sp_tst_set_crnt_sub_tst            @sub_tst;
   EXEC test.sp_tst_set_crnt_tst_err_st         0;
   EXEC test.sp_tst_set_crnt_failed_tst_num     NULL;
   EXEC test.sp_tst_set_crnt_failed_tst_sub_num NULL;
   --------------------------------------------------
   -- Process complete
   --------------------------------------------------
   EXEC sp_log 1, @fn,'999: leaving';
END
/*
*/
GO

