SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =========================================================
-- Author:      Terry Watts
-- Create date: 06-DEc-2024
-- Description: function to compare values
--
-- DROP FUNCTION dbo.fnIsLessThan
-- CREATE ALTER
-- =========================================================
CREATE FUNCTION [dbo].[fnIsLT]( @a SQL_VARIANT, @b SQL_VARIANT)
RETURNS BIT
AS
BEGIN
   DECLARE 
       @aTxt   NVARCHAR(1000)
      ,@bTxt   NVARCHAR(1000)
      ,@typeA  NVARCHAR(1000)
      ,@typeB  NVARCHAR(1000)
      ,@ret    BIT
      ,@res    INT
   RETURN iif(@a<@b, 1, 0);
END
      /*
   -- Get the type
   SET @typeA = CONVERT(NVARCHAR(20), SQL_VARIANT_PROPERTY(@a, 'BaseType'));
   SET @typeB = CONVERT(NVARCHAR(20), SQL_VARIANT_PROPERTY(@b, 'BaseType'));
   -- NULL check: mismatch
   IF @a IS NULL AND @b IS NULL
      RETURN 1;
   -- mismatch
   IF @a IS NULL AND @b IS NOT NULL
      RETURN 0;
   -- mismatch
   IF @a IS NOT NULL AND @b IS NULL
      RETURN 0;
   -- ASSERTION: neither variable is null
      SET @aTxt = CONVERT(NVARCHAR(4000), @a);
      SET @bTxt = CONVERT(NVARCHAR(4000), @b);
   -- if both are floating point types
   IF (dbo.fnIsFloat(@a) = 1) AND (dbo.fnIsFloat(@b) = 1)
   BEGIN
      -- fnCompareFloats returns an INT 0 if a=b within tolerance,else 1 if a>b, else -1 (if a<b)
      SET @res = dbo.fnCompareFloats(CONVERT(float, @a), CONVERT(float, @b));
      SET @ret = 
         IIF(@res=0, 0, -- a=b so not less than so return FALSE, 0
         IIF
         (@res=1, 0,    -- a>b so not less than so return FALSE, 0
         1              -- else -1: a<b so return TRUE, 1
         ));
      RETURN @ret;
   END
   -- if both are string types
   IF (dbo.fnIsString(@a) = 1) AND (dbo.fnIsString(@b) = 1)
   BEGIN
      -- HANDLE as String
      SET @ret = iif(@aTxt < @bTxt, 1, 0);
      RETURN @ret;
   END
   -- if both are Date time types
   IF (dbo.fnIsDateTime(@a) = 1) AND (dbo.fnIsDateTime(@b) = 1)
   BEGIN
      -- HANDLE as String
      DECLARE @aDt DATETIME
             ,@bDt DATETIME
      SET @aDt = CONVERT(DATETIME, @a);
      SET @bDt = CONVERT(DATETIME, @b);
      SET @ret = iif(@aDt < @bDt, 1, 0);
      RETURN @ret;
   END
   -- Validate whats left
   -- For now if a type mismatch then throw an exception 
   IF @typeA <> @typeB
      SET @typeA = 1/0;
   -- ASSERTION: types are the same
   
   -- Handle INTS
   IF @typeA = 'INT' 
   BEGIN
      DECLARE 
          @aInt   INT = CONVERT(INT, @a)
         ,@bInt   INT = CONVERT(INT, @b)
      SET @ret = iif(@aInt<@bInt, 1, 0);
      RETURN @ret;
   END
   -- HANDLE FLOATs
   IF  @typeA IN ('FLOAT', 'NUMERIC')
   BEGIN
      DECLARE 
          @aFlt      FLOAT = CONVERT(FLOAT, @a)
         ,@bFlt      FLOAT = CONVERT(FLOAT, @b)
         ,@epsilon   FLOAT          =  1.0E-05
         ,@val       FLOAT
      SET @val = abs(@bFlt -@aFlt) -- - 1.0E-08; -- threshold of comparison for floats
      -- If in significant i.e the difference less than tolerance 
      -- then a is NOT < b but is equal
      IF @val < @epsilon
         RETURN 0;
      -- ASERTION: significantly different so
      -- return the comparison
      SET @ret = iif(@aFlt<@bFlt, 1, 0);
      RETURN @ret;
   END
   SET @ret = [dbo].[fnChkEquals]( @a, @b);
   IF @ret = 1
      RETURN 0;
   -- ASSERTION: not null or equal
   -- Use text comparison
   SET @ret = iif( @aTxt < @bTxt, 1, 0);
   RETURN @ret;
END
/*
   Print dbo.fnLessThan(N'asdf', 5);      -- error
   Print dbo.fnLessThan(2,2);             -- 0
   Print dbo.fnLessThan(N'asdf',N'asdf'); -- 0
   Print dbo.fnLessThan(1.2, 1.3);        -- 1
   Print dbo.fnLessThan(1.3, 1.2);        -- 0
   Print dbo.fnLessThan(1.3, 1.3);        -- 0
   Print dbo.fnLessThan(5, 4);            -- 0
   Print dbo.fnLessThan(3, 3);            -- 0
   Print dbo.fnLessThan(2, 3);            -- 1
*/
*/
GO

