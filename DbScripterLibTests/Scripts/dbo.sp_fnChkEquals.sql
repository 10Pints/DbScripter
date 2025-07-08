SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

--IF OBJECT_ID('dbo.sp_fnChkEquals', 'SP') IS NULL 
--BEGIN
-- =========================================================
-- Author:      Terry Watts
-- Create date: 05-JAN-2021
-- Description: function to compare values - includes an
--              approx equal check for floating point types
-- Returns 1 if equal, 0 otherwise
-- =========================================================
CREATE   PROC [dbo].[sp_fnChkEquals]( @a SQL_VARIANT, @b SQL_VARIANT)
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

   EXEC sp_log 1, @fn ,'000 starting
a :[', @a_str  ,']
b :[', @a_str  ,'] -- INP';

   -- NULL check
   IF @a IS NULL AND @b IS NULL
   BEGIN
      EXEC sp_log 1, @fn ,'010: @a IS NULL AND @b IS NULL, returning 1'
      RETURN 1;
   END

   IF @a IS NULL AND @b IS NOT NULL
   BEGIN
      EXEC sp_log 1, @fn ,'020: @a IS NULL AND @b IS NOT NULL, returning 0'
      RETURN 0;
   END

   IF @a IS NOT NULL AND @b IS NULL
   BEGIN
      EXEC sp_log 1, @fn ,'030: @a IS NOT NULL AND @b IS NULL, returning 0'
      RETURN 0;
   END

   -- if both are floating point types, fnCompareFloats evaluates  fb comparison to accuracy +- epsilon
   -- any differnce less that epsilon is consider insignifacant so considers and b to =
   -- fnCompareFloats returns 1 if a>b, 0 if a==b, -1 if a<b
   IF (dbo.[fnIsFloatType](@a_ty) = 1) AND (dbo.[fnIsFloatType](@b_ty) = 1)
   BEGIN
      SET @res = iif(dbo.[fnCompareFloats](CONVERT(float, @a), CONVERT(float, @b)) = 0, 1, 0);
      EXEC sp_log 1, @fn ,'040: comparing floats, returning ', @res;
   END

   -- if both are int types
   IF (dbo.fnIsIntType(@a_ty) = 1) AND (dbo.fnIsIntType(@b_ty) = 1)
   BEGIN
      DECLARE @aInt BIGINT = CONVERT(bigint, @a)
             ,@bInt BIGINT = CONVERT(bigint, @b)

      SET @res = iif(@aInt = @bInt, 1, 0);
      EXEC sp_log 1, @fn ,'050: comparing ints, returning ', @res;
      RETURN @res;
   END

   -- if both are string types
   IF (dbo.fnIsTextType(@a_ty) = 1) AND (dbo.fnIsTextType(@b_ty) = 1)
   BEGIN
      SET @res = iif(@a_str = @b_str, 1, 0);
      EXEC sp_log 1, @fn ,'060: comparing strings, returning ', @res;
      RETURN @res;
   END

   -- if both are boolean types
   IF (dbo.fnIsBoolType(@a_ty) = 1) AND (dbo.fnIsBoolType(@b_ty) = 1)
   BEGIN
      DECLARE @aB BIT = CONVERT(BIT, @a)
             ,@bB BIT = CONVERT(BIT, @b)

      SET @res = iif(@a = @b, 1, 0);
      EXEC sp_log 1, @fn ,'070: comparing bools, returning ', @res;
      RETURN @res;
   END

   -- if both are datetime types
   IF (dbo.fnIsTimeType(@a_ty) = 1) AND (dbo.fnIsTimeType(@b_ty) = 1)
   BEGIN
      DECLARE @aDt DATETIME = CONVERT(DATETIME, @a)
             ,@bDt DATETIME = CONVERT(DATETIME, @b)

      SET @res = iif(@aDt = @bDt, 1, 0);
      EXEC sp_log 1, @fn ,'080: comparing DateTimes, returning ', @res;
      RETURN @res;
   END

   -- if both are guid types
   IF (dbo.fnIsGuidType(@a_ty) = 1) AND (dbo.fnIsGuidType(@b_ty) = 1)
   BEGIN
      DECLARE @aGuid UNIQUEIDENTIFIER = CONVERT(UNIQUEIDENTIFIER, @a)
             ,@bGuid UNIQUEIDENTIFIER = CONVERT(UNIQUEIDENTIFIER, @b)

      SET @res = iif(@aGuid < @bGuid, 0, 1);
      EXEC sp_log 1, @fn ,'090: comparing guids, , returning ', @res;
      RETURN @res;
   END

   ----------------------------------------------------
   -- Compare by type cat
   ----------------------------------------------------

   DECLARE
    @a_cat  VARCHAR(25)
   ,@b_cat  VARCHAR(25)

   SET @a_cat = [dbo].[fnGetTypeCat](@a_ty);
   SET @b_cat = [dbo].[fnGetTypeCat](@b_ty);
   EXEC sp_log 1, @fn ,'100: comparing by type cat, @a_cat: ', @a_cat, ' @b_cat: ', @b_cat;

   if(@a_cat = @b_cat)
   BEGIN
      EXEC sp_log 1, @fn ,'110: ty cats are same so do a cat comparison'

      IF @a_cat = 'Int'
      BEGIN
         SET @res = iif(CONVERT(BIGINT, @a) = CONVERT(BIGINT, @b), 1, 0);
         EXEC sp_log 1, @fn ,'120: type cat Int comparing using BIGINTs ', @res;
      END
      ELSE IF @a_cat = 'Float'
      BEGIN
         SET @res = iif(CONVERT(FLOAT(24), @a) = CONVERT(FLOAT(24), @b), 1, 0);
         EXEC sp_log 1, @fn ,'130: Float type cat comparing using Float 24 ', @res;
      END
      ELSE IF @a_cat = 'Text'
      BEGIN
         SET @res = iif(CONVERT(VARCHAR(8000), @a) = CONVERT(VARCHAR(8000), @b), 1, 0);
         EXEC sp_log 1, @fn ,'140: type cat Text comparing using VARCHAR(8000) ', @res;
      END
      ELSE IF @a_cat = 'Time'
      BEGIN
         SET @res = iif(CONVERT(DateTime2, @a) = CONVERT(DateTime2, @b), 1, 0);
         EXEC sp_log 1, @fn ,'150: type cat Int comparing using DateTime2 ', @res;
      END
      ELSE IF @a_cat = 'GUID'
      BEGIN
         SET @res = iif(CONVERT(uniqueidentifier, @a) = CONVERT(uniqueidentifier, @b), 1, 0);
         EXEC sp_log 1, @fn ,'160: type cat GUID comparing using unique_identifier ', @res;
      END

      RETURN @res;
   END

   ----------------------------------------------------------------------
   -- Can compare Floats with integral types -> convert both to big float
   ----------------------------------------------------------------------
   IF (@a_cat='Int' AND @b_cat='Float') OR (@a_cat='Float' AND @b_cat='Int')
   BEGIN
      SET @res = iif(CONVERT(FLOAT(24), @a) = CONVERT(FLOAT(24), @b), 1, 0);
      EXEC sp_log 1, @fn ,'140: type cat Int/Float comparing using FLOAT(24)', @res;
      RETURN @res;
   END

   ----------------------------------------------------
   -- Final option: compare by converting to text
   ----------------------------------------------------
   SET @res = iif(@a_str = @b_str, 1, 0)
   EXEC sp_log 1, @fn ,'160: comparing by converting to text using VARCHAR(8000) ', @res;
   RETURN @res;
END
/*
EXEC test.sp__crt_tst_rtns '[dbo].[fnChkEquals]';
*/


GO
