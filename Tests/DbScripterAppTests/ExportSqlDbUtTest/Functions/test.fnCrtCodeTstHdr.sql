SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================
-- Author:      Terry Watts
-- Create date: 16-Dec-2023
-- Description: encapsulates the helper header comment
-- 05 Create the test rtn Header->fnCrtHlprCodeTstHdr
--
-- PRECONDITIONS: test.RtnFetails pop'd
-- ======================================================
CREATE FUNCTION [test].[fnCrtCodeTstHdr]( @is_hlpr      BIT = 1)
RETURNS 
@t TABLE 
(
    id      INT IDENTITY(1,1) NOT NULL
   ,line    NVARCHAR(500)
)
AS
BEGIN
   DECLARE 
       @line         NVARCHAR(500)
      ,@qrn          NVARCHAR(500)
      ,@tst_rtn_nm   NVARCHAR(50)
      ,@dt           DATE = GetDate()
      ,@ad_stp       BIT            = 0    -- used in testing to identify a step with a unique name (not an incremental int id)
      ,@maxLineLen   INT
   SELECT
       @qrn = qrn
      ,@tst_rtn_nm = iif(@is_hlpr = 1, hlpr_rtn_nm, tst_rtn_nm)
      ,@ad_stp = ad_stp
    FROM test.RtnDetails;
   SELECT @maxLineLen = MAX(dbo.fnLen(dbo.fnTrim(line)))
   FROM test.fnGetRtnDesc('test.test_086_sp_crt_tst_hlpr_script');
   
   SET @line = CONCAT('--',REPLICATE('=', @maxLineLen));
   INSERT INTO @t( line) VALUES
    (CONCAT('USE ', DB_NAME(), IIF(@ad_stp=1, ' -- fnCrtCodeTstHdr', '')))
   ,('GO')
   ,('SET ANSI_NULLS ON')
   ,('GO')
   ,('SET QUOTED_IDENTIFIER ON')
   ,('GO')
   ;
      INSERT INTO @t( line) 
      SELECT line 
      FROM 
         test.fnCrtCodeDropRtn(@is_hlpr);
   INSERT INTO @t( line) VALUES
    ('GO')
   ,(@line)
   ,('-- Author:           Terry Watts')
   ,(CONCAT('-- Create date:      ', FORMAT(@dt, 'dd-MMM-yyyy')))
   ,(CONCAT('-- Description: ',iif(@is_hlpr=1,'test helper','main test routine'),' for the ',@qrn, ' routine ',iif(@is_hlpr=1,'tests ', '')))
   ,('--')
   ,('-- Tested rtn description:')
   INSERT INTO @t(line)
   SELECT line FROM test.fnGetRtnDesc(@qrn);
   INSERT INTO @t( line) VALUES (@line)
   -- Reset the comment line length to be long enough to cover the new lines from the tested rtn desc
   SELECT @maxLineLen = MAX(dbo.fnLen(dbo.fnTrim(line))) FROM @t;
   SET @line =  CONCAT('--', REPLICATE('=', @maxLineLen));
   UPDATE @t SET line = @line where line like '--===%'
   RETURN;
END
/*
EXEC tSQLt.Run 'test.test_086_sp_crt_tst_hlpr_script';
   SELECT line FROM test.fnCrtCodeTstHdr('test.test_086_sp_crt_tst_hlpr_script', 1)
   SELECT * FROM test.fnCrtCodeTstHdr('dbo.fnSysRtnCfg', 1)
   SELECT * FROM test.fnCrtCodeTstHdr('test.sp_crt_tst_hlpr_script', 0)
   SELECT * FROM test.fnCrtCodeTstHdr('test.sp_crt_tst_hlpr_script', 1)
*/
GO

