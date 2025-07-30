SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry watts
-- Create date: 05-JUL-2020
-- Description: creates the test helper routine name
-- =============================================
CREATE FUNCTION [test].[fnCreateTestRtnName]
(
       @tstd_rtn_nm  VARCHAR(100)
      ,@tst_rtn_num  INT 
      ,@tst_rtn_ty   VARCHAR(1)-- M: main test, H = helper
)
RETURNS VARCHAR(50)
AS
BEGIN
   RETURN 
      CONCAT
      (
         CASE
            WHEN @tst_rtn_ty = 'M' THEN 'test'
            ELSE 'hlpr'
         END
         ,'_'
        ,CASE
            WHEN @tst_rtn_num IS NOT NULL THEN FORMAT(@tst_rtn_num, '000')
            ELSE ''
         END
         ,'_', @tstd_rtn_nm
      );
END
/*
PRINT test.fnCreateTestRtnName('fnLen',43, 'M');
*/
GO

