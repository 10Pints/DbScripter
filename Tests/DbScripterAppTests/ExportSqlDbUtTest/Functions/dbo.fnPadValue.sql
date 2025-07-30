SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 18-JAN-2020
-- Description: Pads an int, float, or string value v
-- Expected:    input to be padded
--
-- Rules:
--  if null -   change to '' then pad
--  if ''       return padding only
--  if INT      return normal pad
--  if FLOAT    retrun pad of the int part + defimal places
--  otherwise   pad as normal
-- =============================================
CREATE FUNCTION [dbo].[fnPadValue]
(
       @v            NVARCHAR(20)
      ,@len          INT
      ,@pad_char     CHAR
)
RETURNS NVARCHAR(200)
BEGIN
   -- Declare the return variable here
   DECLARE 
       @n            INT
      ,@test_num_flt FLOAT
      ,@tmp          NVARCHAR(30)
   --  if null -   change to '' then pad
   IF @v IS NULL SET @v = ''
   --  if ''       return padding only
   IF LEN(@v) = 0
   RETURN dbo.fnPadLeft2(@v, @len, @pad_char)
   --  if INT      return normal pad
   --  if FLOAT    retrun pad of the int part + defimal places
   --  otherwise   pad as normal
   SET @n = dbo.fnAsInt(@v)
   -- If a pure int then pad the int part and append the decimal part
   IF @n IS NOT NULL
   RETURN dbo.fnPadLeft2( CONVERT(NVARCHAR(20), @n), @len, @pad_char)
   SET @test_num_flt = dbo.fnAsFloat(@v)
   -- If a pure float then pad the int part and append the decimal part
   IF @test_num_flt IS NOT NULL
   BEGIN
   SET @n = dbo.fnLen(@v)
   SET @tmp = SUBSTRING(@v, CHARINDEX('.', @v)+1, @n)
   SET @tmp = CONCAT(SUBSTRING(@v, 1, CHARINDEX('.', @v)), @tmp)
   SET @tmp = dbo.fnPadLeft2(@tmp, @len, @pad_char)
   RETURN @tmp
   END
   -- Else is a non numeric string so pad as is
   RETURN dbo.fnPadLeft2(@v, @len, @pad_char)
END
GO

