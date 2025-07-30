SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================================================================
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
-- Preconditions
-- PRE 02: if schema is not specifed in @qrn and there are more than 1 rtn with the rtn nm
--          but differnt schema then raise div by zero exception
-- Postconditions:
-- Post 01: if schema is not specifed then get it from the sys rtns PROVIDED ONLY ONE rtn named the @rtn_nm
-- 
-- Changes:
-- 231117: handle [ ] wrappers
-- 240403: handle errors like null @qual_rtn_nm softly as per rules above
-- 241207: changed schema from test to dbo
-- 241227: default schema is now the schema found in the sys rtns for the given rtn in @qrn
--         will throw a div by zero error if PRE 02 violated
-- ==============================================================================================================
CREATE FUNCTION [dbo].[fnSplitQualifiedName]
(
   @qrn VARCHAR(150) -- qualified routine name
)
RETURNS @t TABLE
(
    schema_nm  VARCHAR(50)
   ,rtn_nm     VARCHAR(100)
)
AS
BEGIN
   DECLARE
    @n          INT
   ,@schema_nm  VARCHAR(50)
   ,@rtn_nm     VARCHAR(100)
   -- Remove [ ] wrappers
   SET @qrn = dbo.fnDeSquareBracket(@qrn);
   IF @qrn IS NOT NULL AND @qrn <> ''
   BEGIN
      SET @n = CHARINDEX('.',@qrn);
      -- if rtn nm not qualified then assume schema = dbo
      SET @schema_nm = iif(@n=0, 'dbo',SUBSTRING( @qrn, 1   , @n-1));
      SET @rtn_nm    = iif(@n=0,  @qrn,SUBSTRING( @qrn, @n+1, dbo.fnLen(@qrn)-@n))
      -- PRE 02: if schema is not specifed in @qrn and there are more than 1 rtn with the rtn nm
      --          but differnt schema then raise div by zero exception
      IF( CHARINDEX('.', @qrn) = 0)
      BEGIN
         DECLARE @cnt INT;
         SELECT @cnt = COUNT(*) FROM dbo.SysRtns_vw WHERE rtn_nm = @qrn;
         -- Raise div by zero exception
         IF @cnt > 1 SET @cnt = @cnt/0;
      END
   END
   INSERT INTO @t (schema_nm, rtn_nm)
   VALUES( @schema_nm,@rtn_nm);
   RETURN;
END
/*
SELECT * FROM fnSplitQualifiedName('test.fnGetRtnNmBits')
SELECT * FROM fnSplitQualifiedName('a.b')
SELECT * FROM fnSplitQualifiedName('a.b.c')
SELECT * FROM fnSplitQualifiedName('a')
SELECT * FROM fnSplitQualifiedName(null)
SELECT * FROM fnSplitQualifiedName('')
EXEC test.sp__crt_tst_rtns '[dbo].[fnSplitQualifiedName]';
*/
GO

