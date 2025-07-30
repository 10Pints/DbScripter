SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===================================================
-- Author:      Terry Watts
-- Create date: 05-APR-2020
-- sp_tst_hlpr_st Description:
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
       @fn        NVARCHAR(35)
      ,@tst_num   NVARCHAR(50)
      ,@params    NVARCHAR(MAX) = NULL
AS
BEGIN
   DECLARE
       @fnThis    NVARCHAR(35)   = N'sp_tst_hlpr_st'
      ,@NL        NVARCHAR(2)    = NCHAR(13) + NCHAR(10)
      ,@line      NVARCHAR(100)  = REPLICATE(N'-', 100)
   PRINT @line;
   EXEC sp_log 1, @fn, '000: test ', @tst_num, ' starting', @params;
   EXEC test.sp_tst_set_crnt_tst_num            @tst_num;
   EXEC test.sp_tst_set_crnt_tst_err_st         0;
   EXEC test.sp_tst_set_crnt_failed_tst_num     NULL;
   EXEC test.sp_tst_set_crnt_failed_tst_sub_num NULL;
END
GO

