SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =========================================================
-- Author:      Terry Watts
-- Create date: 05-JAN-2021
-- Description: function to compare values - includes an
--              approx equal check for floating point types
-- Returns 1 if equal, 0 otherwise
-- =========================================================
CREATE FUNCTION [dbo].[fnChkEquals]( @a SQL_VARIANT, @b SQL_VARIANT)
RETURNS BIT
AS
BEGIN
   DECLARE @res BIT
   -- NULL check
   IF @a IS NULL AND @b IS NULL
      RETURN 1;
   IF @a IS NULL AND @b IS NOT NULL
      RETURN 0;
   IF @a IS NOT NULL AND @b IS NULL
      RETURN 0;
   -- if both are floating point types, fnCompareFloats evaluates  fb comparison to accuracy +- epsilon
   -- any differnce less that epsilon is consider insignifacant so considers and b to =
   -- fnCompareFloats returns 1 if a>b, 0 if a==b, -1 if a<b
   IF (dbo.[fnIsFloat](@a) = 1) AND (dbo.[fnIsFloat](@b) = 1)
      RETURN iif(dbo.[fnCompareFloats](CONVERT(float, @a), CONVERT(float, @b)) = 0, 1, 0);
   -- if both are int types
   IF (dbo.fnIsIntType(@a) = 1) AND (dbo.fnIsIntType(@b) = 1)
   BEGIN
      DECLARE @aInt BIGINT = CONVERT(bigint, @a)
             ,@bInt BIGINT = CONVERT(bigint, @b)
      SET @res = iif(@aInt = @bInt, 1, 0);
      RETURN @res;
   END
   -- if both are string types
   IF (dbo.fnIsString(@a) = 1) AND (dbo.fnIsString(@b) = 1)
   BEGIN
      DECLARE @aStr NVARCHAR(4000) = CONVERT(NVARCHAR(4000), @a)
             ,@bStr NVARCHAR(4000) = CONVERT(NVARCHAR(4000), @b)
      SET @res = iif(@aStr = @bStr, 1, 0);
      RETURN @res;
   END
   -- if both are boolean types
   IF (dbo.fnIsBool(@a) = 1) AND (dbo.fnIsBool(@b) = 1)
   BEGIN
      DECLARE @aB BIT = CONVERT(BIT, @a)
             ,@bB BIT = CONVERT(BIT, @b)
      SET @res = iif(@a = @b, 1, 0);
      RETURN @res;
   END
   -- if both are datetime types
   IF (dbo.fnIsDateTime(@a) = 1) AND (dbo.fnIsDateTime(@b) = 1)
   BEGIN
      DECLARE @aDt DATETIME = CONVERT(DATETIME, @a)
             ,@bDt DATETIME = CONVERT(DATETIME, @b)
      SET @res = iif(@aDt = @bDt, 1, 0);
      RETURN @res;
   END
   -- if both are guid types
   IF (dbo.fnIsGuid(@a) = 1) AND (dbo.fnIsGuid(@b) = 1)
   BEGIN
      DECLARE @aGuid UNIQUEIDENTIFIER = CONVERT(UNIQUEIDENTIFIER, @a)
             ,@bGuid UNIQUEIDENTIFIER = CONVERT(UNIQUEIDENTIFIER, @b)
      SET @res = iif(@aGuid < @bGuid, 0, 1);
      RETURN @res;
   END
   -- ASSERTION: both parameters are not floating point
   IF ((@a = @b))
      RETURN 1;
   -- ASSERTION: if here then mismatch
   RETURN 0;
END
GO

