SET ANSI_NULLS ON

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
   DECLARE
    @fn     VARCHAR(35)   = N'sp_fnChkEquals'
   ,@res    BIT
   ,@a_str  VARCHAR(4000) = CONVERT(VARCHAR(400), @a)
   ,@b_str  VARCHAR(4000) = CONVERT(VARCHAR(400), @b)
   ,@a_ty   VARCHAR(25)   = CONVERT(VARCHAR(25), SQL_VARIANT_PROPERTY(@a, 'BaseType'))
   ,@b_ty   VARCHAR(25)   = CONVERT(VARCHAR(25), SQL_VARIANT_PROPERTY(@b, 'BaseType'))
   ;

   -- NULL check
   IF @a IS NULL AND @b IS NULL
   BEGIN
      RETURN 1;
   END

   IF @a IS NULL AND @b IS NOT NULL
   BEGIN
      RETURN 0;
   END

   IF @a IS NOT NULL AND @b IS NULL
   BEGIN
      RETURN 0;
   END

   -- if both are floating point types, fnCompareFloats evaluates  fb comparison to accuracy +- epsilon
   -- any differnce less that epsilon is consider insignifacant so considers and b to =
   -- fnCompareFloats returns 1 if a>b, 0 if a==b, -1 if a<b
   IF (dbo.[fnIsFloatType](@a_ty) = 1) AND (dbo.[fnIsFloatType](@b_ty) = 1)
   BEGIN
      RETURN iif(dbo.[fnCompareFloats](CONVERT(FLOAT(24), @a), CONVERT(FLOAT(24), @b)) = 0, 1, 0);
   END

   -- if both are int types
   IF (dbo.fnIsIntType(@a_ty) = 1) AND (dbo.fnIsIntType(@b_ty) = 1)
      RETURN iif(CONVERT(BIGINT, @a) = CONVERT(BIGINT, @b), 1, 0);

   -- if both are string types
   IF (dbo.fnIsTextType(@a_ty) = 1) AND (dbo.fnIsTextType(@b_ty) = 1)
      RETURN iif(@a_str = @b_str, 1, 0);

   -- if both are boolean types
   IF (dbo.fnIsBoolType(@a_ty) = 1) AND (dbo.fnIsBoolType(@b_ty) = 1)
      RETURN iif(CONVERT(BIT, @a) = CONVERT(BIT, @b), 1, 0);

   -- if both are datetime types
   IF (dbo.fnIsTimeType(@a_ty) = 1) AND (dbo.fnIsTimeType(@b_ty) = 1)
      RETURN iif( CONVERT(DATETIME, @a) = CONVERT(DATETIME, @b), 1, 0);

   -- if both are guid types
   IF (dbo.fnIsGuidType(@a_ty) = 1) AND (dbo.fnIsGuidType(@b_ty) = 1)
      RETURN iif(CONVERT(UNIQUEIDENTIFIER, @a) = CONVERT(UNIQUEIDENTIFIER, @b), 1, 0);

   ----------------------------------------------------
   -- Compare by type cat
   ----------------------------------------------------

   DECLARE
    @a_cat  VARCHAR(25)
   ,@b_cat  VARCHAR(25)

   SET @a_cat = [dbo].[fnGetTypeCat](@a_ty);
   SET @b_cat = [dbo].[fnGetTypeCat](@b_ty);

   if(@a_cat = @b_cat)
   BEGIN
      IF @a_cat = 'Int'
      BEGIN
         SET @res = iif(CONVERT(BIGINT, @a) = CONVERT(BIGINT, @b), 1, 0);
      END
      ELSE IF @a_cat = 'Float'
      BEGIN
         SET @res = iif(CONVERT(FLOAT(24), @a) = CONVERT(FLOAT(24), @b), 1, 0);
      END
      ELSE IF @a_cat = 'Text'
      BEGIN
         SET @res = iif(CONVERT(VARCHAR(8000), @a) = CONVERT(VARCHAR(8000), @b), 1, 0);
      END
      ELSE IF @a_cat = 'Time'
      BEGIN
         SET @res = iif(CONVERT(DATETIME2, @a) = CONVERT(DATETIME2, @b), 1, 0);
      END
      ELSE IF @a_cat = 'GUID'
      BEGIN
         SET @res = iif(CONVERT(UNIQUEIDENTIFIER, @a) = CONVERT(UNIQUEIDENTIFIER, @b), 1, 0);
      END

      RETURN @res;
   END

   ----------------------------------------------------------------------
   -- Can compare Floats with integral types -> convert both to big float
   ----------------------------------------------------------------------
   IF (@a_cat='Int' AND @b_cat='Float') OR (@a_cat='Float' AND @b_cat='Int')
   BEGIN
      RETURN iif(CONVERT(FLOAT(24), @a) = CONVERT(FLOAT(24), @b), 1, 0);
   END

   ----------------------------------------------------
   -- Final option: compare by converting to text
   ----------------------------------------------------
   SET @res = iif(@a_str = @b_str, 1, 0)
   RETURN @res;
END


GO
