SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================
-- Author:      Terry Watts
-- Create date: 16-Dec-2023
-- Description: encapsulates the helper header comment
-- 05 Create the test rtn Header:  ->fnCrtHlprCodeTstHdr
--
-- PRECONDITIONS: test.RtnFetails pop'd
-- ======================================================
CREATE FUNCTION [test].[fnCrtCodeDropRtn](@is_hlpr BIT)
RETURNS 
@t TABLE 
(
    id INT IDENTITY(1,1) NOT NULL
   ,line NVARCHAR(500)
)
AS
BEGIN
   DECLARE 
       @ad_stp       BIT            = 0    -- used in testing to identify a step with a unique name (not an incremental int id)
      ,@rtn_ty       NCHAR(1)
      ,@hlpr_rtn_nm  NVARCHAR(100)
      ,@tst_rtn_nm   NVARCHAR(100)
   SELECT
       @ad_stp       = ad_stp
      ,@rtn_ty       = rtn_ty
      ,@hlpr_rtn_nm  = hlpr_rtn_nm
      ,@tst_rtn_nm   = tst_rtn_nm
    FROM test.RtnDetails;
   INSERT INTO @t( line) VALUES
   (
      CONCAT
      (
       'DROP PROCEDURE IF EXISTS test.[', iif(@is_hlpr=1, @hlpr_rtn_nm, @tst_rtn_nm), ']'
       ,IIF(@ad_stp=1, ' -- fnCrtCodeDropRtn','')
      )
   );
   RETURN;
END
/*
   SELECT * FROM test.fnCrtCodeTstHdr('dbo.fnSysRtnCfg', 1)
   SELECT * FROM test.fnCrtCodeTstHdr('test.sp_crt_tst_hlpr_script', 0)
   SELECT * FROM test.fnCrtCodeTstHdr('test.sp_crt_tst_hlpr_script', 1)
   SELECT * FROM test.RtnDetails;
*/
GO

