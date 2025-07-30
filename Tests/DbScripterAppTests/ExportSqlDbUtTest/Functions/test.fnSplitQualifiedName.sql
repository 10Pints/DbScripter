SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================================
-- Author:      Terry Watts
-- Create date: 12-NOV-2023
--
-- Description: splits a qualified rtn name 
-- into a row containing the schema_nm and the rtn_nm
-- removes square brackets
--
-- RULES:
-- @qrn  schema   rtn
-- a.b   a        b
-- a     dbo      a
-- NULL  null     null
-- ''    null     null
--
-- Changes:
-- 231117: handle [ ] wrappers
-- 240403: handle errors like null @qual_rtn_nm softly as per rules above
-- =======================================================================
CREATE FUNCTION [test].[fnSplitQualifiedName]
(
   @qrn NVARCHAR(150) -- qualified routine name
)
RETURNS @t TABLE
(
    schema_nm  NVARCHAR(50)
   ,rtn_nm     NVARCHAR(100)
)
AS
BEGIN
   DECLARE
    @n          INT
   ,@schema_nm  NVARCHAR(50)
   ,@rtn_nm     NVARCHAR(100)
   -- Remove [ ] wrappers
   SET @qrn = dbo.fnDeSquareBracket(@qrn);
   IF @qrn IS NOT NULL AND  @qrn <> ''
   BEGIN
      SET @n = CHARINDEX('.',@qrn);
      -- if rtn nm not qualified then assume schema = dbo
      SET @schema_nm = iif(@n=0, 'dbo',SUBSTRING( @qrn, 1   , @n-1));
      SET @rtn_nm    = iif(@n=0,  @qrn,SUBSTRING( @qrn, @n+1, Ut.dbo.fnLen(@qrn)-@n))
   END
   INSERT INTO @t (schema_nm, rtn_nm)
   VALUES( @schema_nm,@rtn_nm);
   RETURN;
END
/*
SELECT * FROM test.fnDequalifyName('test.fnGetRtnNmBits')
SELECT * FROM test.fnDequalifyName('a.b')
SELECT * FROM test.fnDequalifyName('a.b.c')
SELECT * FROM test.fnDequalifyName('a')
SELECT * FROM test.fnDequalifyName(null)
SELECT * FROM test.fnDequalifyName('')
EXEC 
*/
GO

