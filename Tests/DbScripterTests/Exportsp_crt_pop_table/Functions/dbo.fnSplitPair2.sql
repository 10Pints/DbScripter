SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================================================================
-- Author:      Terry Watts
-- Create date: 11-APR-2025
--
-- Description: splits a composoite string of 2 parts separated by a separator 
-- into a row containing the first part (a), and the second part (b)
--
--
-- Postconditions:
-- Post 01: if @composit contains sep then returns a 1 row table wher col a = first part 
--             and b  contains the second part when @composit is split using @sep
-- Changes:
-- ==============================================================================================================
CREATE FUNCTION [dbo].[fnSplitPair2]
(
    @composit VARCHAR(1000) -- qualified routine name
   ,@sep CHAR(1)
)
RETURNS @t TABLE
(
    a  VARCHAR(1000)
   ,b  VARCHAR(1000)
)
AS
BEGIN
   DECLARE
    @n   INT
   ,@a   VARCHAR(50)
   ,@b   VARCHAR(100)
   IF @composit IS NOT NULL AND @composit <> '' AND @sep IS NOT NULL AND @sep <> ''
   BEGIN
      SET @n = CHARINDEX(@sep, @composit);
      IF @n = 0
      BEGIN
         INSERT INTO @t(a) VALUES( @composit);
         RETURN;
      END
      SET @a = SUBSTRING( @composit, 1   , @n-1);
      SET @b = SUBSTRING( @composit, @n+1, dbo.fnLen(@composit)-@n+1);
      INSERT INTO @t(a, b) VALUES( @a, @b);
   END
   --ELSE INSERT INTO @t(a) VALUES( 'IF @composit: false');
   RETURN;
END
/*
SELECT a, b FROM dbo.fnSplitPair2('a.b', '.');
EXEC tSQLt.Run 'test.test_024_fnSplitPair2';
SELECT * FROM fnSplitQualifiedName('test.fnGetRtnNmBits')
SELECT * FROM fnSplitQualifiedName('a.b')
SELECT * FROM fnSplitQualifiedName('a.b.c')
SELECT * FROM fnSplitQualifiedName('a')
SELECT * FROM fnSplitQualifiedName(null)
SELECT * FROM fnSplitQualifiedName('')
EXEC test.sp__crt_tst_rtns 'dbo].[fnSplitPair2';
*/
GO

