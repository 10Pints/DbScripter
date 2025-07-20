SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ====================================================================
-- Author:      Terry Watts
-- Create date: 08-DEC-2024
-- Description: determines if a sql_variant is an
-- integral type: {int, smallint, tinyint, bigint, money, smallmoney}
-- test: [test].[t 025 fnIsFloat]
--
-- Changes:
-- 241128: added optional check for non negative ints
-- ====================================================================
CREATE FUNCTION [dbo].[fnIsTxtInt]( @v VARCHAR(50), @must_be_positive BIT)
RETURNS BIT
AS
BEGIN
   DECLARE @val INT
   ,@ret BIT

   -- SETUP
   IF @must_be_positive IS NULL  SET @must_be_positive = 0;

   -- PROCESS
   SET @val = TRY_CONVERT(INT, @v);
   SET @ret = iif(@val IS NULL, 0, 1);

      IF @ret = 1 AND @must_be_positive = 1
      BEGIN
         SET @ret = iif(@val >=0, 1, 0);
      END

   RETURN @ret;
END

/*
   DECLARE
       @v_str  VARCHAR(4000)
      ,@ret    BIT = 0
      ,@val    INT

--   DECLARE @type SQL_VARIANT
--   DECLARE @ty   VARCHAR(500)
--   SELECT @type = SQL_VARIANT_PROPERTY(@v, 'BaseType');
--   SET @ty = CONVERT(VARCHAR(20), @type);
   SET @v_str = CONVERT(VARCHAR(4000), @v);

   WHILE(1=1)
   BEGIN
      IF dbo.fnLen(@v_str) = 0
         BREAK;

      IF @must_be_positive IS NULL  SET @must_be_positive = 0;
      SET @val = TRY_CONVERT(INT, @v);

      SET @ret = iif(@val IS NULL, 0, 1);

      IF @ret = 1 AND @must_be_positive = 1
      BEGIN
         --SET @val =  CONVERT(INT, @v);
         SET @ret = iif(@val >=0, 1, 0);
      END

      BREAK;
   END
   RETURN @ret;
END
*/
/*
PRINT CONVERT(INT, NULL);
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_044_fnIsInt';
*/



GO
