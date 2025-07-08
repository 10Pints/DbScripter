SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =========================================================
-- Author:      Terry Watts
-- Create date: 06-DEc-2024
-- Description: compares 2 SQL_VARIANTs
-- RULES:
-- R01: if a < b return 1, 0 otherwise
-- R02: if types are same then a normal comparison should be used
-- R03: NULL < NULL returns 0
-- R04: NULL < NON NULL returns 1
-- R05: NON NULL < NULL returns 0
-- R06: different types try to convert to strings and then compare
--
-- Postconditions
-- Post 01: if a < b return 1
-- Post 02: if types are same then a normal comparison should be used
-- Post 03: NULL < NULL returns 0
-- Post 04: NULL < NON NULL returns 1
-- Post 05: NON NULL < NULL returns 0
-- Post 06: different types try to convert to strings and then compare
-- =========================================================
CREATE FUNCTION [dbo].[fnIsLessThan]( @a SQL_VARIANT, @b SQL_VARIANT)
RETURNS BIT
AS
BEGIN
   DECLARE 
       @aTxt   VARCHAR(4000)
      ,@bTxt   VARCHAR(4000)
      ,@typeA  VARCHAR(50)
      ,@typeB  VARCHAR(50)
      ,@ret    BIT
      ,@res    INT

   ------------------------------------------------------
   -- Handle Null NULL
   ------------------------------------------------------
   IF @a IS NULL AND @b IS NULL RETURN 0;

   ------------------------------------------------------
   -- Handle Null not NULL scenarios
   ------------------------------------------------------
   IF @a IS NULL AND @b IS NOT NULL RETURN 1;
   IF @a IS NOT NULL AND @a IS NULL RETURN 0;

   ------------------------------------------------------
   -- ASSERTION: Both a and b are not NULL
   ------------------------------------------------------

   ------------------------------------------------------
   -- Handle different types
   ------------------------------------------------------
   SELECT @typeA = CONVERT(VARCHAR(500),SQL_VARIANT_PROPERTY(@a, 'BaseType'))
         ,@typeB = CONVERT(VARCHAR(500),SQL_VARIANT_PROPERTY(@b, 'BaseType'))
    ;

   IF @typeA <> @typeB
   BEGIN
      SELECT @aTxt = CONVERT(VARCHAR(500),@a)
            ,@bTxt = CONVERT(VARCHAR(500),@b);

      RETURN iif(@aTxt < @bTxt, 1, 0);
   END

   ------------------------------------------------------
   -- ASSERTION: Both a and b are the same type
   ------------------------------------------------------

   ------------------------------------------------------
   -- Handle types where the variant < operator
   -- does not return correct value
   ------------------------------------------------------

   ------------------------------------------------------
   -- Handle general case where variant < operator works
   ------------------------------------------------------

   RETURN iif(@a<@b, 1, 0);
END
/*
EXEC test.test_054_fnIsLT
EXEC tSQLt.Run 'test.test_054_fnIsLT';
EXEC tSQLt.RunAll;
PRINT DB_Name()

   DECLARE 
       @a      SQL_VARIANT = 2
      ,@b      SQL_VARIANT = '2'
      ,@aTxt   VARCHAR(4000) = CONVERT(VARCHAR(500),@a)
      ,@bTxt   VARCHAR(4000) = CONVERT(VARCHAR(500),@b)
      ;
   PRINT iif(@a<@b, 1, 0);

   DECLARE 
       @a      SQL_VARIANT =  2
      ,@b      SQL_VARIANT = 'abc'
      ,@aTxt   VARCHAR(4000)
      ,@bTxt   VARCHAR(4000)
      ;

   SELECT @aTxt = CONVERT(VARCHAR(500),@a)
         ,@bTxt = CONVERT(VARCHAR(500),@b)

   PRINT iif(@a<@b, 1, 0);
   PRINT iif(@b<@a, 1, 0);
   PRINT iif(@aTxt<@bTxt, 1, 0);
   PRINT iif(@bTxt<@aTxt, 1, 0);
   PRINT CONCAT('[',@aTxt, ']');
   PRINT CONCAT('[',@bTxt, ']');
*/

GO
