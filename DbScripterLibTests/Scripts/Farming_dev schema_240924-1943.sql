USE [Farming_dev]
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ============================================================
-- Author:      Terry Watts
-- Create date: 04-JAN-2021
-- Description: determines if 2 floats are approximately equal
-- Returns    : 1 if a significantly gtr than b
--              0 if a = b with the signifcance of epsilon 
--             -1 if a significantly less than b within +/- Epsilon, 0 otherwise
-- DROP FUNCTION [dbo].[fnCompareFloats2]
-- ============================================================
ALTER FUNCTION [dbo].[fnCompareFloats2](@a FLOAT, @b FLOAT, @epsilon FLOAT = 0.00001)
RETURNS INT
AS
BEGIN
   DECLARE   @v      FLOAT
            ,@res    INT

   SET @v   = abs(@a - @b);

   IF(@v < @epsilon)
      RETURN 0;  -- a = b within the tolerance of epsilon

   -- ASSERTION  a is signifcantly different to b

   -- 10-7 is the tolerance for floats
   SET @v   = round(@a - @b, 7);
   SET @res = IIF( @v>0.0, 1, -1);
   RETURN @res;
END
/*
EXEC test.sp_crt_tst_rtns 'dbo].[fnCompareFloats2', 80
-- Test
-- cmp > tolerance
PRINT CONCAT('[dbo].[fnCompareFloats2](1.2, 1.3, 0.00001)          : ', [dbo].[fnCompareFloats2](1.2, 1.3, 0.00001),       ' T01: EXP -1')
PRINT CONCAT('[dbo].[fnCompareFloats2](1.2, 1.2, 0.00001)          : ', [dbo].[fnCompareFloats2](1.2, 1.2, 0.00001),       '  T02: EXP  0')
PRINT CONCAT('[dbo].[fnCompareFloats2](1.3, 1.2, 0.00001)          : ', [dbo].[fnCompareFloats2](1.3, 1.2, 0.00001),       '  T03: EXP  1')
PRINT CONCAT('[dbo].[fnCompareFloats2](0.1,      0.1 , 0.00001)    : ', [dbo].[fnCompareFloats2](0.1,       0.1, 0.00001), '  T04: EXP  0')
PRINT CONCAT('[dbo].[fnCompareFloats2](0.10001,  0.1 , 0.00001)    : ', [dbo].[fnCompareFloats2](0.10001,   0.1, 0.00001), '  T05: EXP  0')
PRINT CONCAT('[dbo].[fnCompareFloats2](0.1,  0.000009, 0.00001)    : ', [dbo].[fnCompareFloats2](0.1,  0.100009, 0.00001), '  T06 in tolerance: EXP  0')
PRINT CONCAT('[dbo].[fnCompareFloats2](0.1,  0.10001 , 0.00001)    : ', [dbo].[fnCompareFloats2](0.1,  0.10001 , 0.00001), '  T07 exact: EXP  0')
PRINT CONCAT('[dbo].[fnCompareFloats2](0.1,  0.000011, 0.00001)    : ', [dbo].[fnCompareFloats2](0.1,  0.100011, 0.00001), ' T08 out of tolerance: EXP -1')
PRINT CONCAT('[dbo].[fnCompareFloats2](0.100011, 0.1, 0.00001)     : ', [dbo].[fnCompareFloats2](0.100011, 0.1, 0.00001) , '  T09 out of tolerance: EXP  1')
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =================================================================
-- Author:      Terry Watts
-- Create date: 04-JAN-2021
-- Description: determines if 2 floats are approximately equal
-- Returns    : 1 if a significantly gtr than b
--              0 if a = b with the signifcance of epsilon 
--             -1 if a significantly less than b within +/- Epsilon, 0 otherwise
-- =================================================================
ALTER FUNCTION [dbo].[fnCompareFloats](@a FLOAT, @b FLOAT)
RETURNS INT
AS
BEGIN
   RETURN
      dbo.fnCompareFloats2(@a, @b, 0.00001);
END
/*
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ====================================================================
-- Author:      Terry Watts
-- Create date: 01-FEB-2021
-- Description: determines if a sql_variant is of type BIT
-- ====================================================================
ALTER FUNCTION [dbo].[fnIsBool](@v SQL_VARIANT)
RETURNS BIT
AS
BEGIN
   DECLARE @type SQL_VARIANT
   DECLARE @ty   NVARCHAR(500)
   SELECT @type = SQL_VARIANT_PROPERTY(@v, 'BaseType');
   SET @ty = CONVERT(NVARCHAR(500), @type);

   RETURN
      CASE 
         WHEN @ty = 'bit'             THEN  1
         ELSE                                0
         END;
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ====================================================================
-- Author:      Terry Watts
-- Create date: 01-FEB-2021
-- Description: determines if a sql_variant is an
-- integral type: {int, smallint, tinyint, bigint, money, smallmoney}
-- ====================================================================
ALTER FUNCTION [dbo].[fnIsDateTime](@v SQL_VARIANT)
RETURNS BIT
AS
BEGIN
   DECLARE @type SQL_VARIANT
   DECLARE @ty   NVARCHAR(500)
   SELECT @type = SQL_VARIANT_PROPERTY(@v, 'BaseType');
   SET @ty = CONVERT(NVARCHAR(500), @type);

   RETURN
      CASE 
         WHEN @ty = 'date'             THEN  1
         WHEN @ty = 'datetime'         THEN  1
         WHEN @ty = 'datetime2'        THEN  1
         WHEN @ty = 'datetimeoffset'   THEN  1
         WHEN @ty = 'smalldatetime'    THEN  1
         ELSE                                0
         END;
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ================================================
-- Author:      Terry Watts
-- Create date: 04-JAN-2021
-- Description: determines if a sql_variant is an
-- approximate type: {float, real or numeric}
-- test: [test].[t 025 fnIsFloat]
-- ================================================
ALTER FUNCTION [dbo].[fnIsFloat](@v SQL_VARIANT)
RETURNS BIT
AS
BEGIN
   DECLARE @type SQL_VARIANT
   DECLARE @ty   NVARCHAR(500)
   SELECT @type = SQL_VARIANT_PROPERTY(@v, 'BaseType');
   SET @ty = CONVERT(NVARCHAR(500), @type)

   RETURN
      CASE 
         WHEN @ty = 'float'   THEN 1
         WHEN @ty = 'real'    THEN 1
         WHEN @ty = 'numeric' THEN 1
         ELSE                    0
         END;
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ====================================================================
-- Author:      Terry Watts
-- Create date: 01-FEB-2021
-- Description: determines if a sql_variant is of type GUID
-- ====================================================================
ALTER FUNCTION [dbo].[fnIsGuid](@v SQL_VARIANT)
RETURNS BIT
AS
BEGIN
   DECLARE @type SQL_VARIANT
   DECLARE @ty   NVARCHAR(500)
   SELECT @type = SQL_VARIANT_PROPERTY(@v, 'BaseType');
   SET @ty = CONVERT(NVARCHAR(500), @type);

   RETURN
      CASE
         WHEN @ty = 'uniqueidentifier' THEN  1
         ELSE                                0
         END;
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ====================================================================
-- Author:      Terry Watts
-- Create date: 01-FEB-2021
-- Description: determines if a sql_variant is an
-- integral type: {int, smallint, tinyint, bigint, money, smallmoney}
-- test: [test].[t 025 fnIsFloat]
-- ====================================================================
ALTER FUNCTION [dbo].[fnIsInt]( @v SQL_VARIANT)
RETURNS BIT
AS
BEGIN
   DECLARE @type SQL_VARIANT
   DECLARE @ty   NVARCHAR(500)
   SELECT  @type = SQL_VARIANT_PROPERTY(@v, 'BaseType');
   SET @ty = CONVERT(NVARCHAR(500), @type);

   RETURN
      CASE 
         WHEN @ty = 'int'        THEN 1
         WHEN @ty = 'smallint'   THEN 1
         WHEN @ty = 'tinyint'    THEN 1
         WHEN @ty = 'bigint'     THEN 1
         WHEN @ty = 'money'      THEN 1
         WHEN @ty = 'smallmoney' THEN 1
         ELSE                    0
         END;
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ====================================================================
-- Author:      Terry Watts
-- Create date: 01-FEB-2021
-- Description: determines if a sql_variant is of type string
-- ====================================================================
ALTER FUNCTION [dbo].[fnIsString](@v SQL_VARIANT)
RETURNS BIT
AS
BEGIN
   DECLARE @type SQL_VARIANT
   DECLARE @ty   NVARCHAR(500)
   SELECT @type = SQL_VARIANT_PROPERTY(@v, 'BaseType');
   SET @ty = CONVERT(NVARCHAR(500), @type);

   RETURN
      CASE 
         WHEN @ty = 'char'       THEN  1
         WHEN @ty = 'nchar'      THEN  1
         WHEN @ty = 'nvarchar'   THEN  1
         WHEN @ty = 'varchar'    THEN  1
         ELSE                          0
         END;
END

GO
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
ALTER FUNCTION [dbo].[fnChkEquals]( @a SQL_VARIANT, @b SQL_VARIANT)
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
   IF (dbo.fnIsInt(@a) = 1) AND (dbo.fnIsInt(@b) = 1)
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
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===============================================================================================
-- Author:      Terry Watts
-- Create date: 13-JAN-2020
-- Description: determines if a character is whitespace
--
-- whitespace is: 
-- (NCHAR(9), NCHAR(10), NCHAR(11), NCHAR(12), NCHAR(13), NCHAR(14), NCHAR(32), NCHAR(160))
--
-- RETURNS: 1 if is whitspace, 0 otherwise
-- ===============================================================================================
ALTER FUNCTION [dbo].[fnIsWhitespace]( @t NCHAR) 
RETURNS BIT
AS
BEGIN
   RETURN CASE WHEN  @t IN (NCHAR(9) , NCHAR(10), NCHAR(11), NCHAR(12)
                           ,NCHAR(13), NCHAR(14), NCHAR(32), NCHAR(160)) THEN 1 
               ELSE 0 END
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===============================================================
-- Author:      Terry Watts
-- Create date: 08-JAN-2020
-- Description: fnLen deals with the trailing spaces bug in Len
-- ===============================================================
ALTER FUNCTION [dbo].[fnLen]( @v VARCHAR(8000))
RETURNS INT
AS
BEGIN
   RETURN Len(@v+'x')-1;
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==========================================================================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2021
-- Description: determines if the string contains whitespace
--
-- whitespace is: 
-- (NCHAR(9), NCHAR(10), NCHAR(11), NCHAR(12), NCHAR(13), NCHAR(14), NCHAR(32), NCHAR(160))
--
-- RETURNS: 1 if string contains whitspace, 0 otherwise
-- ==========================================================================================
ALTER FUNCTION [dbo].[fnContainsWhitespace]( @s NVARCHAR(4000))
RETURNS BIT
AS
BEGIN
   DECLARE
       @res       BIT = 0
      ,@i         INT = 1
      ,@len       INT = dbo.fnLen(@s)

   WHILE @i <= @len
   BEGIN
      IF dbo.fnIswhitespace(SUBSTRING(@s, @i, 1))=1
      BEGIN
         SET @res = 1;
         break;
      END

      SET @i = @i + 1;
   END

   RETURN @res;
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===============================================================
-- Author:		 Terry Watts
-- Create date: 08-JUL-2023
-- Description: Generates the SQL for sp_list_occurence_counts
--
-- CHANGES: 231006:fixed issue with field name convention change:
--   Staging 1 id field nme is 'stg1_id' Staging 2 id is' stg2_id'
-- ===============================================================
ALTER FUNCTION [dbo].[fnCrtSqlForListOccurences]
(
    @table           NVARCHAR(100)
   ,@field           NVARCHAR(100)
   ,@where_clause    NVARCHAR(MAX)
   ,@len             INT
)
RETURNS  NVARCHAR(MAX)
AS
BEGIN
   DECLARE 
      @nl            NVARCHAR(1) = NCHAR(0x0d)

   SET @len = @len + 5;  -- stop the ... on the column hiding the end of the value
   SET @where_clause = REPLACE(@where_clause, '#field#', @field);
	RETURN CONCAT( 
   'SELECT', @nl, 
'   S.[',@field,'] AS [',LEFT( @table + '.' + @field + Space(@len), @len),'.]
, Count(s.stg',iif(@table='staging1', '1','2'),'_id) AS [count]
FROM
(
   SELECT DISTINCT [', @field,']
   FROM [', @table,']
   WHERE ', @where_clause,'
) AS A
JOIN [', @table,'] as S on A.[', @field,'] = S.[', @field,']
GROUP BY S.[', @field,']
ORDER BY S.[', @field,'] ASC;'
);
END

/*
DECLARE @where_clause NVARCHAR(MAX)='([#field#] LIKE ''%(Direct-seeded) (Pre-germinated) rice%'' COLLATE Latin1_General_CI_AI )   AND crops like ''%onio%''';
PRINT dbo.fnCrtSqlForListOccurences('staging1', 'crops', @where_clause, 25);

GO
SELECT   S.[crops] AS [staging2.crops                .]
, Count(s.id) AS [count]
FROM
(
   SELECT DISTINCT [crops]
   FROM [staging2]
   WHERE ([crops] LIKE     '%(Direct-seeded) (Pre-germinated) rice%' COLLATE Latin1_General_CI_AI )   AND crops like '%onio%'
) AS A
JOIN [staging2] as S on A.[crops] = S.[crops]
GROUP BY S.[crops]
ORDER BY S.[crops] ASC;
*/

GO
GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
ALTER FUNCTION [dbo].[fnCrtSqlForListOccurencesOld]
(
    @table           NVARCHAR(100)
   ,@field           NVARCHAR(100)
   ,@where_clause    NVARCHAR(MAX)
)
RETURNS  NVARCHAR(MAX)
AS
BEGIN
   DECLARE 
      @nl            NVARCHAR(1) = NCHAR(0x0d)
     ,@len1           INT
     ,@len2           INT
     ,@len            INT

   SELECT @len1 =MAX(ut.dbo.fnLen([Pathogens]))
   FROM
   (
   SELECT DISTINCT [Pathogens]
      FROM Staging1
      WHERE [Pathogens] LIKE     '%As surfactant%'
   ) R;

   SELECT @len2 = MAX(ut.dbo.fnLen([Pathogens]))
   FROM
   (
   SELECT DISTINCT [Pathogens]
      FROM Staging1
      WHERE [Pathogens] LIKE     '%As surfactant%'
   ) R;

   SET @len = iif(@len1>@len2, @len1, @len2);

   SET @where_clause = REPLACE(@where_clause, '#field#', @field);
	RETURN CONCAT( 
   'SELECT', @nl, 
'   S.pathogens
, Count(s.id) AS [count]
FROM
(
   SELECT DISTINCT [', @field,']
   FROM [', @table,']
   WHERE ', @where_clause,'
) AS A
JOIN [', @table,'] as S on A.[', @field,'] = S.[', @field,']
GROUP BY S.[', @field,']
ORDER BY S.[', @field,'] ASC;
-- @len1:',@len1,' @len2:',@len2, ' @len:', @len
);
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =================================================
-- Author:      Terry Watts
-- Create date: 24-NOV-2023
--
-- Description: removes square brackets from string
-- in any position in the string
--
-- PRECONDITIONS:
--    none
--
-- POSTCONDITIONS:
--    [ ] brackets removed
--
-- Tests:
-- =============================================
ALTER FUNCTION [dbo].[fnDeSquareBracket](@s NVARCHAR(4000))
RETURNS NVARCHAR(4000)
AS
BEGIN
   RETURN REPLACE(REPLACE(@s, '[', ''), ']', '');
END
/*
   EXEC test.sp_crt_tst_rtns 'dbo.fnDeSquareBracket', 69
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===============================================================
-- Author:      Terry watts
-- Create date: 30-MAR-2020
-- Description: returns true if the file exists, false otherwise
-- ===============================================================
ALTER FUNCTION [dbo].[fnFileExists](@path varchar(512))
RETURNS BIT
AS
BEGIN
     DECLARE @result INT
     EXEC master.dbo.xp_fileexist @path, @result OUTPUT
     RETURN cast(@result as bit)
END;

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ========================================================================================
-- Author:      Terry Watts
-- Create date: 09-JUL-2023
-- Description: returns the collation string for case sensitive or insensitve searches
--    0 = case insensitive, 1 = case sensitive
-- ========================================================================================
ALTER FUNCTION [dbo].[fnGetCollation]( @case_sensitive BIT)
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN IIF(@case_sensitive = 1, 'COLLATE Latin1_General_CS_AI', 'COLLATE Latin1_General_CI_AI');
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 19-Sep-2024
--
-- Description: Gets the file extension from the supplied file path
--
-- Tests:
--
-- CHANGES:
-- 240919: made return null if no extension - not '' as is the case with split fn
-- ======================================================================================================
ALTER FUNCTION [dbo].[fnGetFileExtension](@path NVARCHAR(MAX))
RETURNS NVARCHAR(200)
AS
BEGIN
   DECLARE
    @t TABLE
    (
       id int IDENTITY(1,1) NOT NULL
      ,val NVARCHAR(200)
    );

   DECLARE
       @val NVARCHAR(4000)
      ,@ndx INT = -1

   INSERT INTO @t(val)
   SELECT value from string_split(@path,'.'); -- ASCII 92 = Backslash
   SET @val = (SELECT TOP 1 val FROM @t ORDER BY id DESC);

   IF dbo.fnLen(@val) = 0 SET @val = NULL;

   RETURN @val;
END
/*
-- For tests see ut.test.test_092_fnGetFileExtension
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:		 Terry Watts
-- Create date: 6-AUG-2023
-- Description: extracts numeric values 
-- but not nn-mm pairs
-- =============================================
ALTER FUNCTION [dbo].[fnGetNumbersFromString](	@s NVARCHAR(MAX))
RETURNS @t TABLE
(
   value NVARCHAR(MAX)
)
AS
BEGIN
   -- tokenise s 
  INSERT INTO @t SELECT value FROM string_split(@s, ' ')
  WHERE ISNUMERIC(value)=1
  RETURN;
END

 /*
 SELECT * FROM dbo.fnGetNumbersFromString('some other text 14 days before harvest fpr potato. 7 days before 8-15 harvest for onion')
 SELECT * FROM string_split('some other text 14 days before harvest fpr potato. 7 days before harvest for onion', ' ')
 WHERE ISNUMERIC(value)=1;
 
 SELECT id, dbo.fnGetFirstNumberFromString(phi), phi 
 FROM staging2
 WHERE phi like '%[0-9]-[0-9]%'
 
 SELECT * FROM dbo.fnGetNumbersFromString('Harvest is generally 4-7 days');
 SELECT * FROM dbo.fnGetNumbersFromString('Harvest is generally 45-72 days');
 SELECT * FROM dbo.fnGetNumbersFromString('Harvest is generally 450-721 days');
 SELECT value FROM dbo.fnGetNumbersFromString('Harvest is generally 4506-7213 days')
 WHERE value like '%[0-9]-[0-9]%';


 */
 /*
 UPDATE staging2 set phi_resolved = value
 FROM
 (
    SELECT phi, value from Staging2
    CROSS APPLY [dbo].[fnGetNumbersFromString](phi)
    WHERE value like '%[0-9]-[0-9]%'
 ) X JOIN staging2 s2 ON X.phi = s2.phi


 SELECT id, phi, phi_resolved from Staging2
 */

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:		 TerryWatts
-- Create date: 06-AUG-2023
-- Description: Get first number from string
-- =============================================
ALTER FUNCTION [dbo].[fnGetFirstNumberFromString](@s NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @ret INT;
	SET @ret = (SELECT TOP 1 value from dbo.fnGetNumbersFromString(@s) where ISNUMERIC(value)=1);
	RETURN @ret;

END
/*
PRINT dbo.fnGetFirstNumberFromString('some other text 14 days before harvest fpr potato. 7 days before harvest for onion');
PRINT dbo.fnGetFirstNumberFromString('One (1) days after each spraying');
SELECT distinct phi from staging2 where phi like '%(%'

SELECT * FROM dbo.fnGetNumbersFromString('Harvest is generally 4-7 days');

 SELECT id, dbo.fnGetFirstNumberFromString(phi), phi 
 FROM staging2
 WHERE phi like '%[0-9]-[0-9]%'

*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ================================================================================================
-- Author:      Terry Watts
-- Create date: 05-APR-2024
-- Description: returns:
--    if @ty_nm is a text array type then returns the full type from a data type + max_len fields
--    else returns @ty_nm on its own.
--
--    This is useful when using sys rtns like sys.columns
--
-- Test: test.test_089_fnGetFullTypeName
-- ================================================================================================
ALTER FUNCTION [dbo].[fnGetFullTypeName]
(
    @ty_nm  NVARCHAR(20)
   ,@len    INT
)
RETURNS NVARCHAR(50)
AS
BEGIN
   RETURN iif(@ty_nm in ('NVARCHAR','VARCHAR'), CONCAT(@ty_nm, '(', iif(@len=-1, 'MAX', FORMAT(@len, '####')), ')'), @ty_nm);
END
/*
  PRINT dbo.fnGetFullTypeName('NVARCHAR', -1);
  PRINT dbo.fnGetFullTypeName('NVARCHAR', 20);
  PRINT dbo.fnGetFullTypeName('VARCHAR', 4000);
  PRINT dbo.fnGetFullTypeName('INT', 30);
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =================================================
-- Author:		 Terry Watts
-- Create date: 08-JUL-2023
-- Description: Creates the SQL to
-- to list the rows in a table for the given id set
-- =================================================
ALTER FUNCTION [dbo].[fnGetIdsInTableForCriteriaSql]( 
    @table           NVARCHAR(100)
   ,@field           NVARCHAR(100)
   ,@where_clause    NVARCHAR(MAX)
   )
RETURNS NVARCHAR(MAX)
AS
BEGIN
RETURN CONCAT('SELECT TOP 500 A.[',@field,'] AS id   FROM
   (
      SELECT DISTINCT [', @field,']
      FROM  [',@table,']
      WHERE ',@where_clause,'
   ) AS A
   JOIN [',@table,'] S on A.[',@field,'] = S.[',@field,']
   ORDER BY A.[',@field,']'
);
END

/*
PRINT dbo.fnGetIdsInTableForCriteriaSql( 
    'Staging2'
   ,'stg2_id'
   ,'crops like ''%Mung%'''
   );

SELECT TOP 500 A.stg2_id AS id   FROM
   (
      SELECT DISTINCT [stg2_id]
      FROM  [Staging2]
      WHERE crops like '%Mung%'
   ) AS A
   JOIN [Staging2] S on A.[stg2_id] = S.[stg2_id]
   ORDER BY A.stg2_id

*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===================================================================
-- Author:		 Terry Watts
-- Create date: 08-JUL-2023
-- Description: Creates the SQL to list the UNION all ids
--   matching the where clause in the 2 tables
--
-- CHANGES:
--   231006: fixed issue with field name convention change:
--   Staging 1 id field nme is 'stg1_id' Staging 2 id is' stg2_id'
-- ===================================================================
ALTER FUNCTION [dbo].[fnGetIdsInTablesForCriteriaSql]
(
    @table1          NVARCHAR(100)
   ,@field1          NVARCHAR(100)
   ,@table2          NVARCHAR(100)
   ,@field2          NVARCHAR(100)
   ,@where_clause    NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	RETURN CONCAT
   (
   'SELECT @ids = STRING_AGG(CAST(id AS NVARCHAR(MAX)), '','')
   FROM
(   ', dbo.fnGetIdsInTableForCriteriaSql(@table1, @field1, @where_clause),'
   UNION
   ', dbo.fnGetIdsInTableForCriteriaSql(@table2, @field2, @where_clause),'
) X'
   )
END
/*
PRINT [dbo].[fnGetIdsInTablesForCriteriaSql]('Staging2', 'stg2_id','Staging1','stg1_id', 'crops like ''%Mung%''');
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 06-NOV-2023
-- Description: returns the format id for provided import name (@import_nm)
--                or -1 if not recognised
--                import_nm can be part of a larger string
--
-- Tests: test.test_fnGetImportFormatIdFromName
--
-- Changes:
-- =============================================================================
ALTER FUNCTION [dbo].[fnGetImportFormatIdFromName]( @path NVARCHAR(250))
RETURNS int
AS
BEGIN
   DECLARE @file_nm NVARCHAR(MAX)
   SET @file_nm = ut.dbo.fnGetFileNameFromPath(@path, 1);

   RETURN
      IIF(@file_nm LIKE '%221018%', 1,
      IIF(@file_nm LIKE '%230721%', 2,
      IIF(@file_nm LIKE '%231025%', 2,   -- 231025 is the same format as 230721 but the corrections are different
                                   -1))) --  -1 =(Fmt not found) will stop the operations
;
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.fnGetImportFormatIdFromName';
PRINT dbo.fnGetImportFormatIdFromName('asdf221008zyz'); -- should be  1
PRINT dbo.fnGetImportFormatIdFromName('230721zyz');     -- should be  2
PRINT dbo.fnGetImportFormatIdFromName('231025zyz');     -- should be  2
PRINT dbo.fnGetImportFormatIdFromName('230722zyz');     -- should be -1
PRINT dbo.fnGetImportFormatIdFromName('23072zyz');      -- should be -1
PRINT ut.dbo.fnGetFileNameFromPath(@path); 
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ============================================================================================================
-- Author:      Terry Watts
-- Create date: 21-AUG-2023
-- Description: returns the id for provided import name (@import_nm)
--                or -1 if not recognised
--                import_nm can be part of a larger string
--
-- Tests: test.test_fnGetImportIdFromName
--
-- Changes:
-- 231103: added a new import name 231025  Format: 2; same as 230721
-- 231103: just use the file name not the whole path to determine the type
-- 231106: made 231025 a new format. It is the same format as 230721 but the set of corrections are different
-- ===========================================================================================================
ALTER FUNCTION [dbo].[fnGetImportIdFromName]( @path NVARCHAR(250))
RETURNS int
AS
BEGIN
   DECLARE @file_nm NVARCHAR(MAX)
   SET @file_nm = ut.dbo.fnGetFileNameFromPath(@path, 0);

   RETURN
      IIF(@file_nm LIKE '%221018%', 1,
      IIF(@file_nm LIKE '%230721%', 2,
      IIF(@file_nm LIKE '%231025%', 3, -1))) --  -1 =(Fmt not found) will stop the operations
;
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_fnGetImportIdFromName';
PRINT dbo.fnGetImportIdFromName('asdf221008zyz'); -- should be  1
PRINT dbo.fnGetImportIdFromName('230721zyz');     -- should be  2
PRINT dbo.fnGetImportIdFromName('230722zyz');     -- should be -1
PRINT ut.dbo.fnGetFileNameFromPath(@path); 
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ============================================================================================================
-- Author:      Terry Watts
-- Create date: 29-MAR-2024
-- Description: returns the import root key
--
-- Tests:
--
-- Changes:
-- ===========================================================================================================
ALTER FUNCTION [dbo].[fnGetSessionKeyImportRoot]()
RETURNS NVARCHAR(500)
AS
BEGIN
   RETURN N'Import Root';
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.fnGetImportFormatIdFromName';
PRINT dbo.fnGetImportFormatIdFromName('asdf221008zyz'); -- should be  1
PRINT dbo.fnGetImportFormatIdFromName('230721zyz');     -- should be  2
PRINT dbo.fnGetImportFormatIdFromName('231025zyz');     -- should be  2
PRINT dbo.fnGetImportFormatIdFromName('230722zyz');     -- should be -1
PRINT dbo.fnGetImportFormatIdFromName('23072zyz');      -- should be -1
PRINT ut.dbo.fnGetFileNameFromPath(@path); 
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===========================================================================================================
-- Author:      Terry Watts
-- Create date: 29-MAR-2024
-- Description: returns the import root
--
-- Tests:
--
-- Changes:
-- ===========================================================================================================
ALTER FUNCTION [dbo].[fnGetImportRoot]()
RETURNS NVARCHAR(500)
AS
BEGIN
   RETURN ut.dbo.fnGetSessionContextAsString(dbo.fnGetSessionKeyImportRoot());
END
/*
EXEC tSQLt.RunAll;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 25-NOV-2023
-- Description: returns the log level key
-- =============================================
ALTER FUNCTION [dbo].[fnGetLogLevelKey] ()
RETURNS NVARCHAR(50)
AS
BEGIN
   RETURN N'LOG_LEVEL';
END
/*
EXEC test.sp_crt_tst_rtns 'dbo.fnGetLogLevelKey', 
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===============================================================
-- Author:      Terry Watts
-- Create date: 25-MAY-2020
-- Description: Get session context as int - default = -1
-- RETURNS      if    key/value present returns value as INT
--              if no key/value present returns NULL
--
-- See Also: fnGetSessionContextAsString, sp_set_session_context
--
-- CHANGES:
-- 14-JUL-2023: default = -1 (not found) was 0 before
-- 06-FEB-2024: simply returns value if key found else NULL
-- ===============================================================
ALTER FUNCTION [dbo].[fnGetSessionContextAsInt](@key NVARCHAR(100))
RETURNS INT
BEGIN
   RETURN CONVERT(INT,  SESSION_CONTEXT(@key));
END


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 25-NOV-2023
-- Description: returns the log level
-- =============================================
ALTER FUNCTION [dbo].[fnGetLogLevel]()
RETURNS INT
AS
BEGIN
   RETURN dbo.fnGetSessionContextAsInt(dbo.fnGetLogLevelKey());
END
/*
EXEC test.sp_crt_tst_rtns 'dbo.fnGetLogLevel', 80;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 15-JAN-2020
-- Description: returns standard NL char(s)
-- =============================================
ALTER FUNCTION [dbo].[fnGetNL]()
RETURNS NVARCHAR(2)
AS
BEGIN
   RETURN NCHAR(13)+NCHAR(10)
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ================================================================================================
-- Author:      Terry watts
-- Create date: 24-APR-2024
-- Description: returns:
--   a string of n tabs (3 spcs each)
--
-- Test: test.test_086_sp_crt_tst_hlpr_script
-- ================================================================================================
ALTER FUNCTION [dbo].[fnGetNTabs]( @n    INT)
RETURNS NVARCHAR(50)
AS
BEGIN
   RETURN REPLICATE(' ', @n*3);
END
/*
EXEC tSQLt.Run 'test.test_086_sp_crt_tst_hlpr_script';

  PRINT CONCAT('[',dbo.fnGetNTabs(NULL),']');
  PRINT CONCAT('[',dbo.fnGetNTabs(-1),']');
  PRINT CONCAT('[',dbo.fnGetNTabs(0),']');
  PRINT CONCAT('[',dbo.fnGetNTabs(1),']');
  PRINT CONCAT('[',dbo.fnGetNTabs(3),']');
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =================================================
-- Author:		 Terry Watts
-- Create date: 6-AUG-2023
-- Description: extracts numeric pairs like 35-101
-- =================================================
ALTER FUNCTION [dbo].[fnGetNumericPairsFromString](@s NVARCHAR(MAX))
RETURNS @t TABLE
(
   value NVARCHAR(MAX)
)
AS
BEGIN
   -- tokenise s 
  INSERT INTO @t SELECT value FROM string_split(@s, ' ')
  WHERE value LIKE '%[0-9]-[0-9]%'
  RETURN;
END

 /*
 SELECT * FROM dbo.[fnGetNumericPairsFromString]('some other text 14 days before harvest fpr potato. 7 days before 8-15 harvest for onion')
 SELECT * FROM string_split('some other text 14 days before harvest fpr potato. 7 days before harvest for onion', ' ')
 WHERE ISNUMERIC(value)=1;
 
 SELECT id, dbo.fnGetFirstNumberFromString(phi), phi 
 FROM staging2
 WHERE phi like '%[0-9]-[0-9]%'
 
 SELECT * FROM dbo.fnGetNumbersFromString('Harvest is generally 4-7 days');
 SELECT * FROM dbo.fnGetNumbersFromString('Harvest is generally 45-72 days');
 SELECT * FROM dbo.fnGetNumbersFromString('Harvest is generally 450-721 days');
 SELECT value FROM dbo.fnGetNumbersFromString('Harvest is generally 4506-7213 days')
 WHERE value like '%[0-9]-[0-9]%';


 */
 /*
 UPDATE staging2 set phi_resolved = value
 FROM
 (
    SELECT phi, value from Staging2
    CROSS APPLY [dbo].[fnGetNumbersFromString](phi)
    WHERE value like '%[0-9]-[0-9]%'
 ) X JOIN staging2 s2 ON X.phi = s2.phi


 SELECT id, phi, phi_resolved from Staging2
 */

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==================================================================
-- Author:		 Terry Watts
-- Create date: 06-AUG-2023
-- Description: Gets teh first numeric pair from a string 
-- e.g: dbo.fnGetNumericPairFromString('234 thf 15-24 5') -< 15-24
-- ==================================================================
ALTER FUNCTION [dbo].[fnGetNumericPairFromString] ( @s NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @pr NVARCHAR(50)
	SET @pr = (SELECT TOP 1 value FROM dbo.fnGetNumericPairsFromString(@s));
	RETURN @pr
END
/*
PRINT dbo.fnGetNumericPairFromString('some other text 14 days before harvest fpr potato. 7 days before 8-15 harvest for 2-16 onion')
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===============================================================
-- Author:      Terry Watts
-- Create date: 16-APR-2024
-- Description: Get session context as bit
-- RETURNS      if    key/value present returns value as BIT
--              if no key/value present returns NULL
--
-- See Also: fnGetSessionContextAsString, sp_set_session_context
-- ===============================================================
ALTER FUNCTION [dbo].[fnGetSessionContextAsBit](@key NVARCHAR(100))
RETURNS INT
BEGIN
   RETURN CONVERT(BIT,  SESSION_CONTEXT(@key));
END


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================================
-- Author:		 Terry Watts
-- Create date: 19-AUG-2023
-- Description: returns the cor_id key used in the Staging2 update trigger
--    to determine if need a new entry in the correction log
-- ==============================================================================
ALTER FUNCTION [dbo].[fnGetSessionKeyCorId] ()
RETURNS NVARCHAR(30)
AS
BEGIN
	RETURN N'cor_id';
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================================
-- Author:		 Terry Watts
-- Create date: 19-AUG-2023
-- Description: returns the import_id key
-- ==============================================================================
ALTER FUNCTION [dbo].[fnGetSessionKeyImportId] ()
RETURNS NVARCHAR(30)
AS
BEGIN
	RETURN N'IMPORT_ID';
END
/*
EXEC sp_set_session_context_import_id 240530
PRINT CONCAT('import_id: [', dbo.fnGetSessionValueImportId(),']');
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 19-AUG-2023
-- Description: returns the cor_id value used in the Staging2 update trigger
--    to determine if need a new entry in the correction log
-- ==============================================================================
ALTER FUNCTION [dbo].[fnGetSessionValueCorId]()
RETURNS NVARCHAR(30)
AS
BEGIN
   RETURN ut.dbo.fnGetSessionContextAsString(dbo.fnGetSessionKeyCorId());
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 19-AUG-2023
-- Description: returns the import_id integer
-- ==============================================================================
ALTER FUNCTION [dbo].[fnGetSessionValueImportId] ()
RETURNS INT
AS
BEGIN
   RETURN dbo.fnGetSessionContextAsInt(dbo.fnGetSessionKeyImportId());
END
/*
EXEC sp_set_session_context_import_id 240530
PRINT CONCAT('import_id: [', dbo.fnGetSessionValueImportId(),']');
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================
-- Author:      Terry Watts
-- Create date: 12-NOV-2023
-- Description: returns the type name from the type code
--e.g. sysobjects xtype code 
-- ======================================================
ALTER FUNCTION [dbo].[fnGetTyNmFrmTyCode]
(
   @ty_code NVARCHAR(2)
)
RETURNS NVARCHAR(30)
AS
BEGIN
   RETURN
   (
      CASE 
         WHEN @ty_code = 'AF' THEN 'CLR aggregate function'
         WHEN @ty_code = 'C'  THEN 'CHECK constraint'
         WHEN @ty_code = 'D'  THEN 'DEFAULT'
         WHEN @ty_code = 'EC' THEN 'Edge constraint'
         WHEN @ty_code = 'ET' THEN 'External tbl'
         WHEN @ty_code = 'F'  THEN 'Foreign key'
         WHEN @ty_code = 'FN' THEN 'Scalar function'
         WHEN @ty_code = 'FS' THEN 'CLR scalar function'
         WHEN @ty_code = 'FT' THEN 'CLR table function'
         WHEN @ty_code = 'IF' THEN 'Inline table function'
         WHEN @ty_code = 'IT' THEN 'Intrnl table'
         WHEN @ty_code = 'P'  THEN 'Procedure'
         WHEN @ty_code = 'PC' THEN 'CLR procedure'
         WHEN @ty_code = 'PG' THEN 'Plan guide'
         WHEN @ty_code = 'P'  THEN 'Procedure'
         WHEN @ty_code = 'PK' THEN 'Primary key'
         WHEN @ty_code = 'R'  THEN 'Rule'
         WHEN @ty_code = 'RF' THEN 'Repl fltr proc'
         WHEN @ty_code = 'S'  THEN 'Sys base table'
         WHEN @ty_code = 'SN' THEN 'Synonym'
         WHEN @ty_code = 'SO' THEN 'Sequence object'
         WHEN @ty_code = 'SQ' THEN 'Service queue'
         WHEN @ty_code = 'TA' THEN 'CLR DML trigger'
         WHEN @ty_code = 'TF' THEN 'Table function'
         WHEN @ty_code = 'TR' THEN 'SQL DML trigger'
         WHEN @ty_code = 'TT' THEN 'Table type'
         WHEN @ty_code = 'U'  THEN 'Table'
         WHEN @ty_code = 'UQ' THEN 'Unique Key'
         WHEN @ty_code = 'V'  THEN 'View'
         WHEN @ty_code = 'X'  THEN 'Extended procedure'
         ELSE '???'
      END
   );
END
/*
PRINT dbo.fnGetTyNmFrmTyCode('TF')
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =======================================================================
-- Author:      Terry Watts
-- Create date: 06-FEB-2020
-- Description: Returns true if a character type
--              Handles single and array types like INT and NVARCHAR(MAX)
-- =======================================================================
ALTER FUNCTION [dbo].[fnIsCharType]
(
   @type    NVARCHAR(15)
)
RETURNS BIT
AS
BEGIN
   DECLARE 
    @rc     BIT
   ,@n      INT

   -- Trim possible aray (num) like NVARCHAR(100)
   SET @n = CHARINDEX('(', @type);

   IF @n > 0
      SET @type = SUBSTRING( @type, 1, @n-1);

   SET @rc = CASE
      WHEN @type = 'CHAR'     THEN 1
      WHEN @type = 'NCHAR'    THEN 1
      WHEN @type = 'VARCHAR'  THEN 1
      WHEN @type = 'NVARCHAR' THEN 1

      ELSE 0
   END

   RETURN @rc;
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =========================================================
-- Author:      Terry Watts
-- Create date: 05-JAN-2021
-- Description: function to compare values
--
-- DROP FUNCTION dbo.fnIsLessThan
-- CREATE ALTER
-- =========================================================
ALTER FUNCTION [dbo].[fnIsLessThan]( @a SQL_VARIANT, @b SQL_VARIANT)
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

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ================================================================
-- Author:      Terry Watts
-- Create date: 23-JUN-2023
-- Description: Removes specific characters from 
--              the beginning of a string
-- 23-JUN-2023: Fix handle all wspc like spc, tab, \n \r CHAR(160)
-- ==================================================================
ALTER FUNCTION [dbo].[fnLTrim]
(
    @s NVARCHAR(MAX)
)
RETURNS  NVARCHAR(MAX)
AS
BEGIN
   DECLARE  
       @tcs    NVARCHAR(20)

   IF (@s IS NULL ) OR (dbo.fnLen(@s) = 0)
      RETURN @s;

   SET @tcs = CONCAT( NCHAR(9), NCHAR(10), NCHAR(13), NCHAR(32), NCHAR(160))

   WHILE CHARINDEX(SUBSTRING(@s, 1, 1), @tcs) > 0 AND dbo.fnLen(@s) > 0
      SET @s = SUBSTRING(@s, 2, dbo.fnLen(@s)-1);

   RETURN @s;
END
/*
PRINT CONCAT('[', ut.dbo.fnTrim(' '), ']')
PRINT CONCAT('[', ut.dbo.fnLTrim(' '), ']')
PRINT CONCAT('[', ut.dbo.fnLTrim2(' ', ' '), ']')
PRINT CONCAT('[', [dbo].[fnLTrim](CONCAT(0x20, 0x09, 0x0a, 0x0d, 0x20,'a', 0x20, 0x09, 0x0a, 0x0d, 0x20,' #cd# ')), ']');
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 16-DEC-2021
-- Description: Removes specific characters from 
--              the beginning end of a string
-- =============================================
ALTER FUNCTION [dbo].[fnLTrim2]
(
    @str NVARCHAR(MAX)
   ,@trim_chr NVARCHAR(1)
)
RETURNS  NVARCHAR(MAX)
AS
BEGIN
   DECLARE @len INT;

   IF @str IS NOT NULL AND @trim_chr IS NOT NULL
      WHILE Left(@str, 1) = @trim_chr
      BEGIN
         SET @len = dbo.fnLen(@str)-1;

         IF @len < 0
            BREAK;

         SET @str = Substring(@str, 2, dbo.fnLen(@str)-1);
      END

   RETURN @str
END

/*
PRINT CONCAT('1: [',  dbo.fnLTrim2('  ', ' '), ']');
PRINT CONCAT('2: [',  dbo.fnLTrim2(' ', ' '), ']');
PRINT CONCAT('3: [',  dbo.fnLTrim2('', ' '), ']');
PRINT CONCAT('4: [', Right('', 1), ']');
PRINT CONCAT('5: [', dbo.fnLTrim2(' s 5   ', ' '), ']');
PRINT CONCAT('6: [', dbo.fnLTrim2(' ', ' '), ']');
PRINT CONCAT('7: [', dbo.fnLTrim2('', ' '), ']');
PRINT CONCAT('8: [', dbo.fnLTrim2(NULL, ' '), ']');
PRINT CONCAT('9: [', dbo.fnLTrim2(' ', NULL), ']');
PRINT CONCAT('10:[', dbo.fnLTrim2('', NULL), ']');
IF dbo.fnLTrim2(NULL, NULL) IS NULL PRINT 'IS NULL';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
ALTER FUNCTION [dbo].[fnMax] (@p1 INT, @p2 INT)
RETURNS INT
AS
BEGIN
   RETURN CASE WHEN @p1 > @p2 THEN @p1 ELSE @p2 END 
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================    
-- Author:      Terry Watts
-- Create date: 23-JUN-2023
-- Description: Pads Right with specified padding character
-- =============================================    
ALTER FUNCTION [dbo].[fnPadRight2]
(
    @s      NVARCHAR(MAX)
   ,@width  INT
   ,@pad    NVARCHAR(1)
)
RETURNS NVARCHAR (1000)
AS
BEGIN
   DECLARE 
      @ret  NVARCHAR(1000)
     ,@len  INT

   IF @s IS null
      SET @s = '';

   SET @len = ut.dbo.fnLen(@s)
   RETURN LEFT( CONCAT( @s, REPLICATE( @pad, @width-@len)), @width)
END
/*
SELECT CONCAT('[', ut.dbo.fnPadRight2('a very long string indeed - its about time we had a beer', 25, '.'), ']  ');
SELECT CONCAT('[', ut.dbo.fnPadRight2('', 25, '.'), ']  ');
SELECT CONCAT('[', ut.dbo.fnPadRight2(NULL, 25, '.'), ']  ');
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================    
-- Author:  Terry Watts
-- Create date: 04-OCT-2019
-- Description: Pads Right
-- =============================================    
ALTER FUNCTION [dbo].[fnPadRight]( @s NVARCHAR(500), @width INT)
RETURNS NVARCHAR (1000)
AS
BEGIN
   RETURN dbo.fnPadRight2( @s, @width, ' ' )
END
/*
SELECT CONCAT(', ]', ut.dbo.fnPadRight([name], 25), ']  ', [type])
FROM [tg].[test].[fnCrtPrmMap]( '          @table_nm                  NVARCHAR(50)  
         ,@folder                    NVARCHAR(260)  
         ,@workbook_nm               NVARCHAR(260)   OUTPUT  
         ,@sheet_nm                  NVARCHAR(50)    OUTPUT  
         ,@view_nm                   NVARCHAR(50)    OUTPUT  
         ,@error_msg                 NVARCHAR(200)   OUTPUT  ')
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==========================================================
-- Author:		 Terry Watts>
-- Create date: 01-JUL-2023
-- Description: Replace alternatie for hanling wsp, comma
-- ==========================================================
ALTER FUNCTION [dbo].[fnReplace](@src NVARCHAR(MAX), @old NVARCHAR(MAX), @new NVARCHAR(MAX)) 
RETURNS NVARCHAR(MAX)
AS
BEGIN

DECLARE 
    @ndx INT
   ,@len INT

   IF(@src IS NULL)
      return @src;

   SET @len = Ut.dbo.fnLen(@old);
   SET @ndx = CHARINDEX(@old, @src);

   IF(@ndx = 0)
      return @src;

   WHILE @ndx > 0
   BEGIN
      SET @src = STUFF(@src, @ndx, @len, @new);
      SET @ndx = CHARINDEX(@old, @src);
   END

   RETURN @src;
END

/*
SELECT dbo.fnReplace('ab ,cde ,def, ghi,jk', ' ,', ',' );   
SELECT dbo.fnReplace('ab ,cde ,def, ghi,jk, lmnp', ', ', ',' );   
SELECT dbo.fnReplace('abcdefgh', 'def', 'xyz' );   -- abcxyzgh
SELECT dbo.fnReplace(null, 'cd', 'xyz' );          -- null
SELECT dbo.fnReplace('', 'cd', 'xyz' );            -- ''
SELECT dbo.fnReplace('as', '', 'xyz' );            -- 'as'
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==========================================================================
-- Author:      Terry Watts
-- Create date: 08-JAN-2020
-- Description: Removes specific characters from the right end of a string
-- 23-JUN-2023: Fix handle all wspc like spc, tab, \n \r CHAR(160)
-- ==========================================================================
ALTER FUNCTION [dbo].[fnRTrim]
(
   @s NVARCHAR(MAX)
)
RETURNS  NVARCHAR(MAX)
AS
BEGIN
   DECLARE  
       @tcs    NVARCHAR(20)

   IF (@s IS NULL ) OR (LEN(@s) = 0)
      RETURN @s;

   SET @tcs = CONCAT( NCHAR(9), NCHAR(10), NCHAR(13), NCHAR(32), NCHAR(160))

   WHILE CHARINDEX(Right(@s, 1) , @tcs) > 0 AND dbo.fnLen(@s) > 0 -- SUBSTRING(@s,  dbo.fnLen(@s)-1, 1) or Right(@s, 1)
      SET @s = SUBSTRING(@s, 1, dbo.fnLen(@s)-1); -- SUBSTRING(@s, 1, dbo.fnLen(@s)-1) or Left(@s, dbo.fnLen(@s)-1)

   RETURN @s;
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 16-DEC-2021
-- Description: Removes specific characters from the right end of a string
-- =============================================
ALTER FUNCTION [dbo].[fnRTrim2]
(
    @str NVARCHAR(MAX)
   ,@trim_chr NVARCHAR(1)
)
RETURNS  NVARCHAR(MAX)
AS
BEGIN
   IF @str IS NOT NULL AND @trim_chr IS NOT NULL
      WHILE Right(@str, 1)= @trim_chr AND dbo.fnLen(@str) > 0
         SET @str = Left(@str, dbo.fnLen(@str)-1);

   RETURN @str
END
/*
PRINT CONCAT('[',  dbo.fnRTrim2('  ', ' '), ']');
PRINT CONCAT('[',  dbo.fnRTrim2(' ', ' '), ']');
PRINT CONCAT('[',  dbo.fnRTrim2('', ' '), ']');
PRINT CONCAT('[', Right('', 1), ']');
PRINT CONCAT('[', dbo.fnRTrim2(' s 5   ', ' '), ']');
PRINT CONCAT('[', dbo.fnRTrim2(' ', ' '), ']');
PRINT CONCAT('[', dbo.fnRTrim2('', ' '), ']');
PRINT CONCAT('[', dbo.fnRTrim2(NULL, ' '), ']');
PRINT CONCAT('[', dbo.fnRTrim2(' ', NULL), ']
PRINT CONCAT('[', dbo.fnRTrim2('', NULL), ']');
IF dbo.fnRTrim2(NULL, NULL) IS NULL PRINT 'IS NULL';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===============================================================================
-- Author:		 Terry Watts
-- Create date: 05-JUL-2023
-- Description: trims whitespace and sets to NULL if trimmed clause is empty
--              Trims [] as well
-- ===============================================================================
ALTER FUNCTION [dbo].[fnScrubParameter] (@clause NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @ret NVARCHAR(MAX)

	-- Add the T-SQL statements to compute the return value here
	SET @ret = Ut.dbo.fnTrim(@clause); 
	SET @ret = Ut.dbo.fnTrim2(@clause, '['); 
	SET @ret = Ut.dbo.fnTrim2(@clause, ']'); 
	SET @ret = Ut.dbo.fnTrim(@clause); 
   IF Ut.dbo.fnLen(@ret) = 0 SET @ret = NULL;

   RETURN @ret;
END
/*
Print CONCAT('[',dbo.fnStanardiseAnds('AB & CDE and FG&HIJ &KLM&NOP'),']');
Print CONCAT('[',dbo.fnStanardiseAnds('')                        ,']');
Print CONCAT('[',dbo.fnStanardiseAnds(NULL)                      ,']');
Print CONCAT('[',dbo.fnStanardiseAnds('&')                      ,']');
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===============================================================================
-- Author:		 Terry Watts
-- Create date: 04-JUL-2023
-- Description: standardiseis (repalces) combinations of & and space to ' and'
-- ===============================================================================
ALTER FUNCTION [dbo].[fnStanardiseAnds] (@s NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @r NVARCHAR(MAX)

	-- Add the T-SQL statements to compute the return value here
	RETURN REPLACE(REPLACE(REPLACE(REPLACE(@s, '& ', '&'), '& ', '&'), ' &', '&' ), '&', ' and ');
END
/*
Print CONCAT('[',dbo.fnStanardiseAnds('AB & CDE and FG&HIJ &KLM&NOP'),']');
Print CONCAT('[',dbo.fnStanardiseAnds('')                        ,']');
Print CONCAT('[',dbo.fnStanardiseAnds(NULL)                      ,']');
Print CONCAT('[',dbo.fnStanardiseAnds('&')                      ,']');
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 08-FEB-2020
-- Description: returns true (1) if table exxists else false (0)
-- schema default is dbo
-- =============================================
ALTER FUNCTION [dbo].[fnTableExists](@table_spec NVARCHAR(60))
RETURNS BIT
AS
BEGIN
   DECLARE
       @schema                    NVARCHAR(10)
      ,@table_nm                  NVARCHAR(60)
      ,@n                         INT

   SET @n = CHARINDEX('.', @table_spec)
   SET @schema = CASE WHEN  @n > 0 THEN SUBSTRING( @table_spec, 1, @n-1) ELSE 'dbo' END
   SET @table_nm  = CASE WHEN  @n > 0 THEN SUBSTRING( @table_spec, @n+1, Len(@table_spec)- @n) ELSE @table_spec END

   RETURN 
      CASE 
         WHEN EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @table_nm AND TABLE_SCHEMA = @schema) 
         THEN 1 
         ELSE 0 
      END
END


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ================================================================
-- Author:      Terry Watts
-- Create date: 10-OCT-2019
-- Description: Trims leading and trailing whitesace including the 
--                normally untrimmable CHAR(160)
-- 23-JUN-2023: Fix handle all wspc like spc, tab, \n \r CHAR(160)
-- ================================================================
ALTER FUNCTION [dbo].[fnTrim]( @s NVARCHAR(4000)
)
RETURNS NVARCHAR(4000)
AS
BEGIN
  RETURN dbo.fnRTrim( dbo.fnLTrim(@s));
END
/*
PRINT CONCAT('[', dbo.fnTrim(CONCAT(0x20, 0x09, 0x0a, 0x0d, 0xA0, '  a  #cd# ', 0x20, 0x09, 0x0a, 0x0d, 0x0d,0xA0)), ']');
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 16-DEC-2021
-- Description: Removes specific characters from 
--              the beginning end of a string
-- =============================================
ALTER FUNCTION [dbo].[fnTrim2]
(
    @str NVARCHAR(MAX)
   ,@trim_chr NVARCHAR(1)
)
RETURNS  NVARCHAR(MAX)
AS
BEGIN
   RETURN dbo.fnRTrim2(dbo.fnLTrim2(@str, @trim_chr), @trim_chr);
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================================
-- Author:      Terry Watts
-- Create date: 06-AUG-2023
-- Description: returns a table of single characters and their ascii code - 1 character per row
-- Reference:   https://stackoverflow.com/questions/59407743/sql-query-to-print-each-character-of-a-string-sql-server
-- ======================================================================================================================
ALTER FUNCTION [dbo].[fnGetChars] (@String nvarchar(4000))
RETURNS table
AS RETURN
    WITH N AS(
        SELECT N
        FROM(VALUES(NULL),(NULL),(NULL),(NULL),(NULL),(NULL),(NULL),(NULL),(NULL),(NULL))N(N)),
    Tally AS(
        SELECT TOP (LEN(@String)) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS I
        FROM N N1, N N2, N N3, N N4)
    SELECT SUBSTRING(@String, T.I, 1) AS C, T.I
    FROM Tally T;

/*
SELECT * FROM dbo.fnGetChars('Corn ( sweet corn )');
SELECT c, ASCII(c) as code FROM Staging2
CROSS APPLY dbo.fnGetChars (crops) WHERE crops LIKE '%Direct-seeded%Pre-germinated%rice';

SELECT c, ASCII(c) as code FROM Staging2
CROSS APPLY dbo.fnGetChars (crops) WHERE crops LIKE '%Dry-seeded%Upland%rice%';
;
SET NOCOUNT OFF;
UPDATE staging2 SET crops = 'Rice' WHERE crops LIKE '%Direct-seeded%Pre-germinated%rice';
*/

GO
GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =========================================================================
-- Author:      Terry Watts
-- Create date: 22-MAR-2020
-- Description: Logs to output and to the AppLog table

-- Level: 0 DEBUG
--        1 INFO
--        2 NOTE
--        3 WARNING (CONTINUE)
--        4 ERROR   (STOP)
--
-- Changes:
-- 231014: Added support of table logging: add a row to table for each log 
--            Level and msg
-- 231016: Added fn and optional row count columns
-- 231017: @fn no longer needs the trailing ' :'
-- 231018: @fn, @row_count are stored as separate fields
-- 231115: added Level
-- 231116: always append to the AppLog table - bit print is conditional on level
-- 240309: Trimmed the  @fn paameter as it is left padded
-- 240314: Logic Change: now if less than min log level do not log or print msg
-- 231221: added hold, values:
--          0: print cache first then this msg on same line immediatly
--          1: cache msg for later - dont print it now 
--          2: dump cache first then print this msg on a new line immediatly
-- 240422: separate lines into a separate display line if msg contains \r\n
-- =================================================================================
ALTER PROCEDURE [dbo].[sp_log]
 @level  INT = 1
,@fn     NVARCHAR(100)=NULL
,@msg00  NVARCHAR(MAX)=NULL,@msg01  NVARCHAR(MAX)=NULL,@msg02  NVARCHAR(MAX)=NULL,@msg03  NVARCHAR(MAX)=NULL,@msg04  NVARCHAR(MAX)=NULL,@msg05  NVARCHAR(MAX)=NULL,@msg06  NVARCHAR(MAX)=NULL,@msg07  NVARCHAR(MAX)=NULL,@msg08  NVARCHAR(MAX)=NULL,@msg09  NVARCHAR(MAX)=NULL
,@msg10  NVARCHAR(MAX)=NULL,@msg11  NVARCHAR(MAX)=NULL,@msg12  NVARCHAR(MAX)=NULL,@msg13  NVARCHAR(MAX)=NULL,@msg14  NVARCHAR(MAX)=NULL,@msg15  NVARCHAR(MAX)=NULL,@msg16  NVARCHAR(MAX)=NULL,@msg17  NVARCHAR(MAX)=NULL,@msg18  NVARCHAR(MAX)=NULL,@msg19  NVARCHAR(MAX)=NULL
,@msg20  NVARCHAR(MAX)=NULL,@msg21  NVARCHAR(MAX)=NULL,@msg22  NVARCHAR(MAX)=NULL,@msg23  NVARCHAR(MAX)=NULL,@msg24  NVARCHAR(MAX)=NULL,@msg25  NVARCHAR(MAX)=NULL,@msg26  NVARCHAR(MAX)=NULL,@msg27  NVARCHAR(MAX)=NULL,@msg28  NVARCHAR(MAX)=NULL,@msg29  NVARCHAR(MAX)=NULL
,@msg30  NVARCHAR(MAX)=NULL,@msg31  NVARCHAR(MAX)=NULL,@msg32  NVARCHAR(MAX)=NULL,@msg33  NVARCHAR(MAX)=NULL,@msg34  NVARCHAR(MAX)=NULL,@msg35  NVARCHAR(MAX)=NULL,@msg36  NVARCHAR(MAX)=NULL,@msg37  NVARCHAR(MAX)=NULL,@msg38  NVARCHAR(MAX)=NULL,@msg39  NVARCHAR(MAX)=NULL
,@msg40  NVARCHAR(MAX)=NULL,@msg41  NVARCHAR(MAX)=NULL,@msg42  NVARCHAR(MAX)=NULL,@msg43  NVARCHAR(MAX)=NULL,@msg44  NVARCHAR(MAX)=NULL,@msg45  NVARCHAR(MAX)=NULL,@msg46  NVARCHAR(MAX)=NULL,@msg47  NVARCHAR(MAX)=NULL,@msg48  NVARCHAR(MAX)=NULL,@msg49  NVARCHAR(MAX)=NULL
,@msg50  NVARCHAR(MAX)=NULL,@msg51  NVARCHAR(MAX)=NULL,@msg52  NVARCHAR(MAX)=NULL,@msg53  NVARCHAR(MAX)=NULL,@msg54  NVARCHAR(MAX)=NULL,@msg55  NVARCHAR(MAX)=NULL,@msg56  NVARCHAR(MAX)=NULL,@msg57  NVARCHAR(MAX)=NULL,@msg58  NVARCHAR(MAX)=NULL,@msg59  NVARCHAR(MAX)=NULL
,@msg60  NVARCHAR(MAX)=NULL,@msg61  NVARCHAR(MAX)=NULL,@msg62  NVARCHAR(MAX)=NULL,@msg63  NVARCHAR(MAX)=NULL,@msg64  NVARCHAR(MAX)=NULL,@msg65  NVARCHAR(MAX)=NULL,@msg66  NVARCHAR(MAX)=NULL,@msg67  NVARCHAR(MAX)=NULL,@msg68  NVARCHAR(MAX)=NULL,@msg69  NVARCHAR(MAX)=NULL
,@msg70  NVARCHAR(MAX)=NULL,@msg71  NVARCHAR(MAX)=NULL,@msg72  NVARCHAR(MAX)=NULL,@msg73  NVARCHAR(MAX)=NULL,@msg74  NVARCHAR(MAX)=NULL,@msg75  NVARCHAR(MAX)=NULL,@msg76  NVARCHAR(MAX)=NULL,@msg77  NVARCHAR(MAX)=NULL,@msg78  NVARCHAR(MAX)=NULL,@msg79  NVARCHAR(MAX)=NULL
,@msg80  NVARCHAR(MAX)=NULL,@msg81  NVARCHAR(MAX)=NULL,@msg82  NVARCHAR(MAX)=NULL,@msg83  NVARCHAR(MAX)=NULL,@msg84  NVARCHAR(MAX)=NULL,@msg85  NVARCHAR(MAX)=NULL,@msg86  NVARCHAR(MAX)=NULL,@msg87  NVARCHAR(MAX)=NULL,@msg88  NVARCHAR(MAX)=NULL,@msg89  NVARCHAR(MAX)=NULL
,@msg90  NVARCHAR(MAX)=NULL,@msg91  NVARCHAR(MAX)=NULL,@msg92  NVARCHAR(MAX)=NULL,@msg93  NVARCHAR(MAX)=NULL,@msg94  NVARCHAR(MAX)=NULL,@msg95  NVARCHAR(MAX)=NULL,@msg96  NVARCHAR(MAX)=NULL,@msg97  NVARCHAR(MAX)=NULL,@msg98  NVARCHAR(MAX)=NULL,@msg99  NVARCHAR(MAX)=NULL
,@msg100 NVARCHAR(MAX)=NULL,@msg101 NVARCHAR(MAX)=NULL,@msg102 NVARCHAR(MAX)=NULL,@msg103 NVARCHAR(MAX)=NULL,@msg104 NVARCHAR(MAX)=NULL,@msg105 NVARCHAR(MAX)=NULL,@msg106 NVARCHAR(MAX)=NULL,@msg107 NVARCHAR(MAX)=NULL,@msg108 NVARCHAR(MAX)=NULL,@msg109 NVARCHAR(MAX)=NULL
,@msg110 NVARCHAR(MAX)=NULL,@msg111 NVARCHAR(MAX)=NULL,@msg112 NVARCHAR(MAX)=NULL,@msg113 NVARCHAR(MAX)=NULL,@msg114 NVARCHAR(MAX)=NULL,@msg115 NVARCHAR(MAX)=NULL,@msg116 NVARCHAR(MAX)=NULL,@msg117 NVARCHAR(MAX)=NULL,@msg118 NVARCHAR(MAX)=NULL,@msg119 NVARCHAR(MAX)=NULL
,@msg120 NVARCHAR(MAX)=NULL,@msg121 NVARCHAR(MAX)=NULL,@msg122 NVARCHAR(MAX)=NULL,@msg123 NVARCHAR(MAX)=NULL,@msg124 NVARCHAR(MAX)=NULL,@msg125 NVARCHAR(MAX)=NULL,@msg126 NVARCHAR(MAX)=NULL,@msg127 NVARCHAR(MAX)=NULL,@msg128 NVARCHAR(MAX)=NULL,@msg129 NVARCHAR(MAX)=NULL
,@msg130 NVARCHAR(MAX)=NULL,@msg131 NVARCHAR(MAX)=NULL,@msg132 NVARCHAR(MAX)=NULL,@msg133 NVARCHAR(MAX)=NULL,@msg134 NVARCHAR(MAX)=NULL,@msg135 NVARCHAR(MAX)=NULL,@msg136 NVARCHAR(MAX)=NULL,@msg137 NVARCHAR(MAX)=NULL,@msg138 NVARCHAR(MAX)=NULL,@msg139 NVARCHAR(MAX)=NULL
,@msg140 NVARCHAR(MAX)=NULL,@msg141 NVARCHAR(MAX)=NULL,@msg142 NVARCHAR(MAX)=NULL,@msg143 NVARCHAR(MAX)=NULL,@msg144 NVARCHAR(MAX)=NULL,@msg145 NVARCHAR(MAX)=NULL,@msg146 NVARCHAR(MAX)=NULL,@msg147 NVARCHAR(MAX)=NULL,@msg148 NVARCHAR(MAX)=NULL,@msg149 NVARCHAR(MAX)=NULL
,@msg150 NVARCHAR(MAX)=NULL,@msg151 NVARCHAR(MAX)=NULL,@msg152 NVARCHAR(MAX)=NULL,@msg153 NVARCHAR(MAX)=NULL,@msg154 NVARCHAR(MAX)=NULL,@msg155 NVARCHAR(MAX)=NULL,@msg156 NVARCHAR(MAX)=NULL,@msg157 NVARCHAR(MAX)=NULL,@msg158 NVARCHAR(MAX)=NULL,@msg159 NVARCHAR(MAX)=NULL
,@msg160 NVARCHAR(MAX)=NULL,@msg161 NVARCHAR(MAX)=NULL,@msg162 NVARCHAR(MAX)=NULL,@msg163 NVARCHAR(MAX)=NULL,@msg164 NVARCHAR(MAX)=NULL,@msg165 NVARCHAR(MAX)=NULL,@msg166 NVARCHAR(MAX)=NULL,@msg167 NVARCHAR(MAX)=NULL,@msg168 NVARCHAR(MAX)=NULL,@msg169 NVARCHAR(MAX)=NULL
,@msg170 NVARCHAR(MAX)=NULL,@msg171 NVARCHAR(MAX)=NULL,@msg172 NVARCHAR(MAX)=NULL,@msg173 NVARCHAR(MAX)=NULL,@msg174 NVARCHAR(MAX)=NULL,@msg175 NVARCHAR(MAX)=NULL,@msg176 NVARCHAR(MAX)=NULL,@msg177 NVARCHAR(MAX)=NULL,@msg178 NVARCHAR(MAX)=NULL,@msg179 NVARCHAR(MAX)=NULL
,@msg180 NVARCHAR(MAX)=NULL,@msg181 NVARCHAR(MAX)=NULL,@msg182 NVARCHAR(MAX)=NULL,@msg183 NVARCHAR(MAX)=NULL,@msg184 NVARCHAR(MAX)=NULL,@msg185 NVARCHAR(MAX)=NULL,@msg186 NVARCHAR(MAX)=NULL,@msg187 NVARCHAR(MAX)=NULL,@msg188 NVARCHAR(MAX)=NULL,@msg189 NVARCHAR(MAX)=NULL
,@msg190 NVARCHAR(MAX)=NULL,@msg191 NVARCHAR(MAX)=NULL,@msg192 NVARCHAR(MAX)=NULL,@msg193 NVARCHAR(MAX)=NULL,@msg194 NVARCHAR(MAX)=NULL,@msg195 NVARCHAR(MAX)=NULL,@msg196 NVARCHAR(MAX)=NULL,@msg197 NVARCHAR(MAX)=NULL,@msg198 NVARCHAR(MAX)=NULL,@msg199 NVARCHAR(MAX)=NULL
,@msg200 NVARCHAR(MAX)=NULL,@msg201 NVARCHAR(MAX)=NULL,@msg202 NVARCHAR(MAX)=NULL,@msg203 NVARCHAR(MAX)=NULL,@msg204 NVARCHAR(MAX)=NULL,@msg205 NVARCHAR(MAX)=NULL,@msg206 NVARCHAR(MAX)=NULL,@msg207 NVARCHAR(MAX)=NULL,@msg208 NVARCHAR(MAX)=NULL,@msg209 NVARCHAR(MAX)=NULL
,@msg210 NVARCHAR(MAX)=NULL,@msg211 NVARCHAR(MAX)=NULL,@msg212 NVARCHAR(MAX)=NULL,@msg213 NVARCHAR(MAX)=NULL,@msg214 NVARCHAR(MAX)=NULL,@msg215 NVARCHAR(MAX)=NULL,@msg216 NVARCHAR(MAX)=NULL,@msg217 NVARCHAR(MAX)=NULL,@msg218 NVARCHAR(MAX)=NULL,@msg219 NVARCHAR(MAX)=NULL
,@msg220 NVARCHAR(MAX)=NULL,@msg221 NVARCHAR(MAX)=NULL,@msg222 NVARCHAR(MAX)=NULL,@msg223 NVARCHAR(MAX)=NULL,@msg224 NVARCHAR(MAX)=NULL,@msg225 NVARCHAR(MAX)=NULL,@msg226 NVARCHAR(MAX)=NULL,@msg227 NVARCHAR(MAX)=NULL,@msg228 NVARCHAR(MAX)=NULL,@msg229 NVARCHAR(MAX)=NULL
,@msg230 NVARCHAR(MAX)=NULL,@msg231 NVARCHAR(MAX)=NULL,@msg232 NVARCHAR(MAX)=NULL,@msg233 NVARCHAR(MAX)=NULL,@msg234 NVARCHAR(MAX)=NULL,@msg235 NVARCHAR(MAX)=NULL,@msg236 NVARCHAR(MAX)=NULL,@msg237 NVARCHAR(MAX)=NULL,@msg238 NVARCHAR(MAX)=NULL,@msg239 NVARCHAR(MAX)=NULL
,@msg240 NVARCHAR(MAX)=NULL,@msg241 NVARCHAR(MAX)=NULL,@msg242 NVARCHAR(MAX)=NULL,@msg243 NVARCHAR(MAX)=NULL,@msg244 NVARCHAR(MAX)=NULL,@msg245 NVARCHAR(MAX)=NULL,@msg246 NVARCHAR(MAX)=NULL,@msg247 NVARCHAR(MAX)=NULL,@msg248 NVARCHAR(MAX)=NULL,@msg249 NVARCHAR(MAX)=NULL
,@row_count INT = NULL
AS
BEGIN
   DECLARE
       @min_log_level   INT
      ,@lvl_msg         NVARCHAR(MAX)
      ,@log_msg         NVARCHAR(4000)
      ,@row_count_str   NVARCHAR(30) = NULL

   SET NOCOUNT ON
   SET @min_log_level = COALESCE(ut.dbo.fnGetSessionContextAsInt(N'LOG_LEVEL'), 1); -- Default: INFO

   SET @lvl_msg = 
   CASE
      WHEN @level = 0 THEN 'DEBUG  '
      WHEN @level = 1 THEN 'INFO   '
      WHEN @level = 2 THEN 'NOTE   '
      WHEN @level = 3 THEN 'WARNING'
      WHEN @level = 4 THEN 'ERROR  '
      ELSE '????'
   END;

   SET @fn= ut.dbo.fnPadRight(@fn, 31);

   IF @row_count IS NOT NULL SET @row_count_str = CONCAT(' rowcount: ', @row_count)

   SET @log_msg = CONCAT
   (
       @msg00 ,@msg01 ,@msg02 ,@msg03, @msg04, @msg05, @msg06 ,@msg07 ,@msg08 ,@msg09 
      ,@msg10 ,@msg11 ,@msg12 ,@msg13, @msg14, @msg15, @msg16 ,@msg18 ,@msg18 ,@msg19
      ,@msg20 ,@msg21 ,@msg22 ,@msg23, @msg24, @msg25, @msg26 ,@msg27 ,@msg28 ,@msg29
      ,@msg30 ,@msg31 ,@msg32 ,@msg33, @msg34, @msg35, @msg36 ,@msg37 ,@msg38 ,@msg39
      ,@msg40 ,@msg41 ,@msg42 ,@msg43, @msg44, @msg45, @msg46 ,@msg47 ,@msg48 ,@msg49
      ,@msg50 ,@msg51 ,@msg52 ,@msg53, @msg54, @msg55, @msg56 ,@msg57 ,@msg58 ,@msg59
      ,@msg60 ,@msg61 ,@msg62 ,@msg63, @msg64, @msg65, @msg66 ,@msg67 ,@msg68 ,@msg69
      ,@msg70 ,@msg71 ,@msg72 ,@msg73, @msg74, @msg75, @msg76 ,@msg77 ,@msg78 ,@msg79
      ,@msg80 ,@msg81 ,@msg82 ,@msg83, @msg84, @msg85, @msg86 ,@msg87 ,@msg88 ,@msg89
      ,@msg90 ,@msg91 ,@msg92 ,@msg93, @msg94, @msg95, @msg96 ,@msg97 ,@msg98 ,@msg99
      ,@msg100,@msg101,@msg102,@msg103,@msg104,@msg105,@msg106,@msg107,@msg108,@msg109 
      ,@msg110,@msg111,@msg112,@msg113,@msg114,@msg115,@msg116,@msg117,@msg118,@msg119 
      ,@msg120,@msg121,@msg122,@msg123,@msg124,@msg125,@msg126,@msg127,@msg128,@msg129 
      ,@msg130,@msg131,@msg132,@msg133,@msg134,@msg135,@msg136,@msg137,@msg138,@msg139 
      ,@msg140,@msg141,@msg142,@msg143,@msg144,@msg145,@msg146,@msg147,@msg148,@msg149 
      ,@msg150,@msg151,@msg152,@msg153,@msg154,@msg155,@msg156,@msg157,@msg158,@msg159 
      ,@msg160,@msg161,@msg162,@msg163,@msg164,@msg165,@msg166,@msg167,@msg168,@msg169 
      ,@msg170,@msg171,@msg172,@msg173,@msg174,@msg175,@msg176,@msg177,@msg178,@msg179 
      ,@msg180,@msg181,@msg182,@msg183,@msg184,@msg185,@msg186,@msg187,@msg188,@msg189 
      ,@msg190,@msg191,@msg192,@msg193,@msg194,@msg195,@msg196,@msg197,@msg198,@msg199 
      ,@msg200,@msg201,@msg202,@msg203,@msg204,@msg205,@msg206,@msg207,@msg208,@msg209 
      ,@msg210,@msg211,@msg212,@msg213,@msg214,@msg215,@msg216,@msg217,@msg218,@msg219 
      ,@msg220,@msg221,@msg222,@msg223,@msg224,@msg225,@msg226,@msg227,@msg228,@msg229 
      ,@msg230,@msg231,@msg232,@msg233,@msg234,@msg235,@msg236,@msg237,@msg238,@msg239 
      ,@msg240,@msg241,@msg242,@msg243,@msg244,@msg245,@msg246,@msg247,@msg248,@msg249 
      ,@row_count_str
   );

   -- Always log to log table
   INSERT INTO AppLog (fn, msg, [level], row_count) VALUES (ut.dbo.fnTrim(@fn), @log_msg, @level, @row_count);

   -- Only display if required
   IF @level >=@min_log_level
   BEGIN

         PRINT CONCAT(@lvl_msg, ' ',@fn, ': ', @log_msg);
      --END
   END -- IF @level >=@min_log_level
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:       Terry Watts
-- Create date:  21-DEC-2023
-- Description:  Dumps the held log 
--               call this in the event of an exception
-- ======================================================================================================
ALTER PROCEDURE [dbo].[sp_clr_log_cache]
AS
BEGIN
   DECLARE @was_hold BIT = COALESCE(CONVERT(BIT, SESSION_CONTEXT(N'HOLD LOG')), 0)
   IF @was_hold = 1 EXEC sp_log 2, 'dump_log', '';
END
/*

*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==================================================================
-- Author:      Terry Watts
-- Create date: 28-MAR-2020
-- Description: standard error handling:
--              get the exception message, log messages
--              clear the log cache first
--    NB: this does not throw
--
-- CHANGES
--    231221: added clear the log cache first
--    240315: added ex num, ex msg as optional out parmeters
-- ==================================================================
ALTER PROCEDURE [dbo].[sp_log_exception]
       @fn        NVARCHAR(35)
      ,@msg01     NVARCHAR(4000) = NULL
      ,@msg02     NVARCHAR(1000) = NULL
      ,@msg03     NVARCHAR(1000) = NULL
      ,@msg04     NVARCHAR(1000) = NULL
      ,@msg05     NVARCHAR(1000) = NULL
      ,@msg06     NVARCHAR(1000) = NULL
      ,@msg07     NVARCHAR(1000) = NULL
      ,@msg08     NVARCHAR(1000) = NULL
      ,@msg09     NVARCHAR(1000) = NULL
      ,@msg10     NVARCHAR(1000) = NULL
      ,@msg11     NVARCHAR(1000) = NULL
      ,@msg12     NVARCHAR(1000) = NULL
      ,@msg13     NVARCHAR(1000) = NULL
      ,@msg14     NVARCHAR(1000) = NULL
      ,@msg15     NVARCHAR(1000) = NULL
      ,@msg16     NVARCHAR(1000) = NULL
      ,@msg17     NVARCHAR(1000) = NULL
      ,@msg18     NVARCHAR(1000) = NULL
      ,@msg19     NVARCHAR(1000) = NULL
      ,@ex_num    INT            = NULL OUT
      ,@ex_msg    NVARCHAR(500)  = NULL OUT
AS
BEGIN
   DECLARE 
       @NL       NVARCHAR(2)    =  NCHAR(13) + NCHAR(10)
      ,@msg      NVARCHAR(500)

   SET @ex_num = ERROR_NUMBER();
   SET @ex_msg = ut.dbo.fnTrim(ERROR_MESSAGE());

   EXEC dbo.sp_clr_log_cache;

   SET @msg = 
      CONCAT
      (
          @msg01
         ,iif(@msg02 IS NOT NULL, CONCAT(' ', @msg02 ), '')
         ,iif(@msg03 IS NOT NULL, CONCAT(' ', @msg03 ), '')
         ,iif(@msg04 IS NOT NULL, CONCAT(' ', @msg04 ), '')
         ,iif(@msg05 IS NOT NULL, CONCAT(' ', @msg05 ), '')
         ,iif(@msg06 IS NOT NULL, CONCAT(' ', @msg06 ), '')
         ,iif(@msg07 IS NOT NULL, CONCAT(' ', @msg07 ), '')
         ,iif(@msg08 IS NOT NULL, CONCAT(' ', @msg08 ), '')
         ,iif(@msg09 IS NOT NULL, CONCAT(' ', @msg09 ), '')
         ,iif(@msg10 IS NOT NULL, CONCAT(' ', @msg10 ), '')
         ,iif(@msg11 IS NOT NULL, CONCAT(' ', @msg11 ), '')
         ,iif(@msg12 IS NOT NULL, CONCAT(' ', @msg12 ), '')
         ,iif(@msg13 IS NOT NULL, CONCAT(' ', @msg13 ), '')
         ,iif(@msg14 IS NOT NULL, CONCAT(' ', @msg14 ), '')
         ,iif(@msg15 IS NOT NULL, CONCAT(' ', @msg15 ), '')
         ,iif(@msg16 IS NOT NULL, CONCAT(' ', @msg16 ), '')
         ,iif(@msg17 IS NOT NULL, CONCAT(' ', @msg17 ), '')
         ,iif(@msg18 IS NOT NULL, CONCAT(' ', @msg18 ), '')
         ,iif(@msg19 IS NOT NULL, CONCAT(' ', @msg19 ), '')
         ,@NL
         ,@NL
      );

   EXEC sp_log 4, @fn, 'caught exception: ', @ex_num, ': ', @ex_msg, @msg;
END
/*
EXEC [dbo].[sp_log_exception] @fn='fn'
      ,@msg01 = 'msg01'
      ,@msg02 = 'msg02'
      ,@msg03 = 'msg03'
      ,@msg04 = 'msg04'
      ,@msg05 = 'msg05'
      ,@msg06 = 'msg06'
      ,@msg07 = 'msg07'
      ,@msg08 = 'msg08'
      ,@msg09 = 'msg09'
      ,@msg10 = 'msg10'
      ,@msg11 = 'msg11'
      ,@msg12 = 'msg12'
      ,@msg13 = 'msg13'
      ,@msg14 = 'msg14'
      ,@msg15 = 'msg15'
      ,@msg16 = 'msg16'
      ,@msg17 = 'msg17'
      ,@msg18 = 'msg18'
      ,@msg19 = 'msg19'
*/

GO
GO
GO
GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===========================================================
-- Author:		 Terry Watts
-- Create date: 16-AUG-2023
-- Description: Gets the chars and ASCII codes for the pathogens
--              at id in Staging2.
-- ===========================================================
ALTER FUNCTION [dbo].[fnGetPathogenChars](
   @id int)
RETURNS TABLE
AS RETURN
(
   SELECT chars.C, ASCII(chars.C) as [ascii] FROM staging2 
   CROSS APPLY dbo.fnGetChars (pathogens) as chars
   where stg2_id = @id
)
/*
SELECT * FROM dbo.[fnGetPathogenChars](3730)
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

ALTER FUNCTION [dbo].[fnGetX](
   @id int)
RETURNS TABLE
AS RETURN
(
   SELECT chars.C, ASCII(chars.C)  phi FROM staging2 
   CROSS APPLY dbo.fnGetChars (phi) as chars
   where stg2_id = @id
)

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ============================================================================
-- Author:       Terry Watts
-- Create date:  12-OCT-2023
-- Description:  Lists the table FKs - both tables
--  N.B.: only suitable for single field keys in the relationship
--  if more than 1 field in the key then it will return a row for each field
--  in which case use select distinct or string_agg
-- ============================================================================
ALTER view [dbo].[fKeys_vw] AS
SELECT TOP 10000 
    fk.name                   AS fk_nm
   ,ft.name                   AS foreign_table_nm
   ,pt.name                   AS primary_tbl_nm
   ,so.name                   AS schema_nm
   ,cu.COLUMN_NAME            AS fk_col_nm
   ,cupt.column_name          AS pk_col_nm
   ,r. UNIQUE_CONSTRAINT_NAME AS unique_constraint_name
   ,cu.ORDINAL_POSITION       AS ordinal
FROM [sys].[foreign_keys] fk 
join sys.objects o ON fk.object_id=o.object_id
join sys.foreign_key_columns c on c.constraint_object_id=fk.object_id
join sys.objects pt ON pt.object_id=c.referenced_object_id
join sys.schemas so ON so.schema_id=pt.schema_id
join sys.objects ft ON ft.object_id=c.parent_object_id
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE cu ON fk.name=cu.CONSTRAINT_NAME
JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS r ON r.CONSTRAINT_NAME = fk.name
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE cupt ON cupt.CONSTRAINT_NAME=r.CONSTRAINT_NAME
ORDER BY foreign_table_nm, fk_nm, cu.ordinal_position
;
/*
SELECT * FROM fKeys_vw 
WHERE primary_tbl_nm = 'Chemical'
SELECT CONSTRAINT_NAME, UNIQUE_CONSTRAINT_NAME FROM [INFORMATION_SCHEMA].[REFERENTIAL_CONSTRAINTS]

SELECT column_name FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE constraint_name='PK_CHEMICAL'
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =======================================================
-- Author:      Terry Watts
-- Create date: 11-OCT-2023
-- Description: Lists the table FKs for either of
--  all tables:   (NULL,NULL)
--  1 table       (tbl_nm,NULL)
--  1 FK nm       (NULL,fk_nm)
-- =======================================================
ALTER FUNCTION [dbo].[fnListFkeys]
(
    @tbl_nm NVARCHAR(100) = NULL
   ,@fk_nm  NVARCHAR(100) = NULL
)
RETURNS 
@t TABLE
(
   fk_nm             NVARCHAR(60),
   foreign_table_nm  NVARCHAR(60),
   primary_tbl_nm    NVARCHAR(60),
   fk_col_nm         NVARCHAR(60),
   pk_col_nm         NVARCHAR(60),
   ordinal           INT,
   schema_nm         NVARCHAR(60)
)
AS
BEGIN
   INSERT INTO @t (fk_nm, foreign_table_nm, primary_tbl_nm, fk_col_nm, pk_col_nm, ordinal, schema_nm)
   SELECT
       fk_nm
      ,foreign_table_nm
      ,primary_tbl_nm
      ,fk_col_nm
      ,pk_col_nm
      ,ordinal
      ,schema_nm
   FROM fKeys_vw
   WHERE
       (foreign_table_nm= @tbl_nm OR @tbl_nm IS NULL)
   AND (fk_nm  = @fk_nm  OR @fk_nm  IS NULL)
   ORDER BY foreign_table_nm, fk_nm, ordinal
   RETURN;
END
/*
foreign_table_nm	fk_nm	primary_tbl_nm	schema_nm	col_nm	ordinal
Chemical	FK_Chemical_Import	Import	dbo	import_id	1
SELECT * FROM dbo.fnListFkeys( NULL, NULL);                                 -- Should list all FKs in database
SELECT * FROM dbo.fnListFkeys( 'ChemicalProduct', NULL);                    -- Should list all FKs for the ChemicalProduct table
SELECT * FROM dbo.fnListFkeys( NULL, 'FK_PathogenChemicalStaging_ChemicalStaging');  -- Should list 1 FK: FK_ChemicalPathogenStaging_Import
SELECT * FROM fnListFKeysForPrimaryTable('Chemical')
PRINT OBJECT_NAME(1214731480)
SELECT * FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ====================================================================
-- Author:      Terry Watts
-- Create date: 12-OCT-2023
-- Description: Lists the table FKs for the @primary_table parameter
-- ====================================================================
ALTER FUNCTION [dbo].[fnListFKeysForPrimaryTable](@primary_table nvarchar(4000))
RETURNS table
AS
   RETURN
      SELECT * FROM dbo.fnListFkeys(NULL, NULL) WHERE primary_tbl_nm = @primary_table;

/*
SELECT * FROM dbo.fnListFKeysForPrimaryTable('Chemical')
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ============================================
-- Author:      Terry Watts
-- Create date: 27-JUN-20223
-- Description: Lists the important S1 fields
-- ============================================
ALTER  VIEW [dbo].[list_staging2_vw]
AS
   SELECT stg2_id, [uses], product, ingredient, entry_mode, crops, pathogens, company, notes
   FROM Staging2
/*
SELECT TOP 50 * FROM list_staging2_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===========================================
-- Author:      Terry Watts
-- Create date: 27-JUN-20223
-- Description: List the importand S2 fields
-- ===========================================
ALTER VIEW [dbo].[list_staging1_vw]
AS
   SELECT stg1_id, [uses], product, ingredient, entry_mode, crops, pathogens, company, notes
   FROM Staging1;
/*
SELECT TOP 50 * FROM list_staging1_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===================================================
-- Author:      Terry Watts
-- Create date: 27-JUN-20223
-- Description: List the 2 staging tables side by side
-- to help check update issues
-- ===================================================
ALTER VIEW [dbo].[s12_vw]
AS 
   SELECT 
    a.stg2_id
   ,a.[uses]      AS s2_uses
   ,b.[uses]      AS s1_uses
   ,a.ingredient  AS s2_chemical
   ,b.ingredient  AS s1_chemical
   ,a.entry_mode  AS s2_entry_mode
   ,b.entry_mode  AS s1_entry_mode
   ,a.crops       AS s2_crops
   ,b.crops       AS s1_crops
   ,a.pathogens   AS s2_pathogens
   ,b.pathogens   AS s1_pathogens
   ,a.product     AS s2_product
   ,a.company     AS s2_company
   ,a.notes       AS s2_notes
   FROM list_staging2_vw a FULL JOIN list_staging1_vw b ON a.stg2_id=b.stg1_id;
/*
SELECT TOP 50 * FROM s12_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 23-MAR-2024
-- Description: this returns any pathogens in S1 or S2 that match the @pathFilter
--              NB: use % etc in the parameter as parameter is not wrapped in % by this routine
--
-- CHANGES:
-- ======================================================================================================
ALTER FUNCTION [dbo].[fnListMatchingS12Pathogens]
(
   @pathFilter NVARCHAR(200)
)
RETURNS table
AS RETURN
   SELECT stg2_id,s1_pathogens, s2_pathogens
   FROM s12_vw
   WHERE
      s1_pathogens LIKE @pathFilter
   OR s2_pathogens LIKE @pathFilter;

/*
SELECT * FROM dbo.fnListMatchingS12Pathogens('%Brown leafhopper%')
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 25-MAR-2024
-- Description: List the S2 update changes e.g. after fixup XL has run
--
-- PRECONDITIONS: none
--
-- ======================================================================================================
ALTER VIEW [dbo].[ListUpdatePathogenChanges_vw]
AS
SELECT s.id, s.fixup_id,row_cnt,search_clause,replace_clause,L.stg2_id,L.old_pathogens, L.new_pathogens
FROM S2UpdateSummary s
LEFT JOIN S2Updatelog L ON s.fixup_id=L.fixup_id

/*
SELECT TOP 50 * FROM ListUpdatePathogenChanges_vw 
WHERE new_pathogens LIKE '%Nematodess%' and old_pathogens NOT LIKE '%Nematodess%';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 23-MAR-2024
-- Description: returns the update changes made to S2 pathogens
-- Note: the S2 update trigger must be enabled - uses S2UpdateSummary and S2Updatelog tables
--
-- CHANGES:
-- ======================================================================================================
ALTER FUNCTION [dbo].[fnListUpdatePathogenChangesForFixup]
(
   @fixup_id INT
)
RETURNS table
AS RETURN
SELECT *
FROM ListUpdatePathogenChanges_vw
WHERE fixup_id=@fixup_id;

/*
SELECT * FROM dbo.fnListUpdatePathogenChangesForFixup(225)
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =========================================================
-- Author:      Terry Watts
-- Create date: 25-MAR-2020
-- Description: Raises an exception
--    Ensures @state is positive
--    if @ex_num < 50000 message and raise to 50K+ @ex_num
-- =========================================================
ALTER PROCEDURE [dbo].[sp_raise_exception]
       @ex_num    INT            = 53000
      ,@msg1      NVARCHAR(200)  = NULL
      ,@msg2      NVARCHAR(200)  = NULL
      ,@msg3      NVARCHAR(200)  = NULL
      ,@msg4      NVARCHAR(200)  = NULL
      ,@msg5      NVARCHAR(200)  = NULL
      ,@msg6      NVARCHAR(200)  = NULL
      ,@msg7      NVARCHAR(200)  = NULL
      ,@msg8      NVARCHAR(200)  = NULL
      ,@msg9      NVARCHAR(200)  = NULL
      ,@msg10     NVARCHAR(200)  = NULL
      ,@msg11     NVARCHAR(200)  = NULL
      ,@msg12     NVARCHAR(200)  = NULL
      ,@msg13     NVARCHAR(200)  = NULL
      ,@msg14     NVARCHAR(200)  = NULL
      ,@msg15     NVARCHAR(200)  = NULL
      ,@msg16     NVARCHAR(200)  = NULL
      ,@msg17     NVARCHAR(200)  = NULL
      ,@msg18     NVARCHAR(200)  = NULL
      ,@msg19     NVARCHAR(200)  = NULL
      ,@msg20     NVARCHAR(200)  = NULL
      ,@state     INT            = 1
AS
BEGIN
   DECLARE
       @fn    NVARCHAR(35) = 'sp_raise_exception'
      ,@msg   NVARCHAR(4000)

      IF @ex_num IS NULL SET @ex_num = 53000; -- default

      EXEC sp_log 1, @fn, 'starting
@ex_num:[', @ex_num,']
@msg1  :[', @msg1,']
@state :[', state,']'
;

   ------------------------------------------------------------------------------------------------
   -- Validate
   ------------------------------------------------------------------------------------------------
   -- check ex num >= 50000 if not add 50000 to it
   IF @ex_num < 50000
   BEGIN
      SET @ex_num = abs(@ex_num) + 50000;
      EXEC sp_log 3, @fn, 'supplied exception number is too low changing to ', @ex_num;
   END

   -- Cannot send negative state so invert
   IF @state < 0
   BEGIN
      EXEC sp_log 3, @fn, 'supplied state number is negative ', @state, ' so making state postive';
      SET @state = 0 - @state;
   END

   SET @msg = 
      CONCAT 
      ( @msg1 ,@msg2 ,@msg3 ,@msg4 ,@msg5 ,@msg6 ,@msg7 ,@msg8 ,@msg9 ,@msg10
       ,@msg11,@msg12,@msg13,@msg14,@msg15,@msg16,@msg17,@msg18,@msg19,@msg20
      );

   ------------------------------------------------------------------------------------------------
   -- Throw the exception
   ------------------------------------------------------------------------------------------------
    EXEC sp_log 4, @fn, 'throwing exception ', @ex_num, ' ',@msg, ' st: ',@state;
   ;THROW @ex_num, @msg, @state;
END
/*
EXEC sp_raise_exception 53000, 'test exception msg 1',' msg 2', @state=2, @fn='test_fn'
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 09-JUN-2020
-- Description: Raises exception if @a is empty
-- =============================================
ALTER PROCEDURE [dbo].[sp_assert_not_empty]
    @val       NVARCHAR(3999)
   ,@msg1      NVARCHAR(2000)  = NULL
   ,@msg2      NVARCHAR(200)   = NULL
   ,@msg3      NVARCHAR(200)   = NULL
   ,@msg4      NVARCHAR(200)   = NULL
   ,@msg5      NVARCHAR(200)   = NULL
   ,@msg6      NVARCHAR(200)   = NULL
   ,@msg7      NVARCHAR(200)   = NULL
   ,@msg8      NVARCHAR(200)   = NULL
   ,@msg9      NVARCHAR(200)   = NULL
   ,@msg10     NVARCHAR(200)   = NULL
   ,@msg11     NVARCHAR(200)   = NULL
   ,@msg12     NVARCHAR(200)   = NULL
   ,@msg13     NVARCHAR(200)   = NULL
   ,@msg14     NVARCHAR(200)   = NULL
   ,@msg15     NVARCHAR(200)   = NULL
   ,@msg16     NVARCHAR(200)   = NULL
   ,@msg17     NVARCHAR(200)   = NULL
   ,@msg18     NVARCHAR(200)   = NULL
   ,@msg19     NVARCHAR(200)   = NULL
   ,@msg20     NVARCHAR(200)   = NULL
   ,@ex_num    INT             = 50001
   ,@state     INT             = 1
AS
BEGIN
   DECLARE
    @fn        NVARCHAR(35)   = N'sp_assert_not_empty'
   ,@msg       NVARCHAR(MAX)
   EXEC sp_log 0, @fn, '000 starting @val: [',@val,']';

   IF dbo.fnLen(@val) <= 0 --AND @a IS NOT NULL
   BEGIN
   -- ASSERTION: if here then either '' or NULL
      EXEC sp_log 4, @fn, '002: raising assert'
      SET @msg = CONCAT('ASSERTION FAILED: value should not be empty ', @msg1);

      IF @ex_num IS NULL SET @ex_num = 50001;

      EXEC sp_raise_exception
             @ex_num = @ex_num
            ,@msg1   = @msg
            ,@msg2   = @msg2
            ,@msg3   = @msg3
            ,@msg4   = @msg4
            ,@msg5   = @msg5
            ,@msg6   = @msg6
            ,@msg7   = @msg7
            ,@msg8   = @msg8
            ,@msg9   = @msg9
            ,@msg10  = @msg10
            ,@msg11  = @msg11
            ,@msg12  = @msg12
            ,@msg13  = @msg13
            ,@msg14  = @msg14
            ,@msg15  = @msg15
            ,@msg16  = @msg16
            ,@msg17  = @msg17
            ,@msg18  = @msg18
            ,@msg19  = @msg19
            ,@msg20  = @msg20
            ,@state  = @state
   END

   EXEC sp_log 0, @fn, '999: OK';
END;
/*
EXEC tSQLt.Run 'test.test_046_sp_assert_not_empty';

EXEC tSQLt.RunAll;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 27-MAR-2020
-- Description: Raises exception if @a is NULL
-- =============================================
ALTER PROCEDURE [dbo].[sp_assert_not_null]
       @val       SQL_VARIANT
      ,@msg1      NVARCHAR(200)   = NULL
      ,@msg2      NVARCHAR(200)   = NULL
      ,@msg3      NVARCHAR(200)   = NULL
      ,@msg4      NVARCHAR(200)   = NULL
      ,@msg5      NVARCHAR(200)   = NULL
      ,@msg6      NVARCHAR(200)   = NULL
      ,@msg7      NVARCHAR(200)   = NULL
      ,@msg8      NVARCHAR(200)   = NULL
      ,@msg9      NVARCHAR(200)   = NULL
      ,@msg10     NVARCHAR(200)   = NULL
      ,@msg11     NVARCHAR(200)   = NULL
      ,@msg12     NVARCHAR(200)   = NULL
      ,@msg13     NVARCHAR(200)   = NULL
      ,@msg14     NVARCHAR(200)   = NULL
      ,@msg15     NVARCHAR(200)   = NULL
      ,@msg16     NVARCHAR(200)   = NULL
      ,@msg17     NVARCHAR(200)   = NULL
      ,@msg18     NVARCHAR(200)   = NULL
      ,@msg19     NVARCHAR(200)   = NULL
      ,@msg20     NVARCHAR(200)   = NULL
      ,@ex_num    INT             = 50001
      ,@state     INT             = 1
AS
BEGIN
   DECLARE @fn NVARCHAR(60)    = N'sp_assert_not_null';
   EXEC sp_log 0, @fn, '000 starting';

   IF (@val IS NULL)
   BEGIN
      EXEC sp_log 4, @fn, 'value is NULL - raising exception ', @ex_num;
      -- ASSERTION: if here then is NULL -> error
      EXEC sp_raise_exception
          @msg1   = @msg1
         ,@msg2   = @msg2
         ,@msg3   = @msg3
         ,@msg4   = @msg4
         ,@msg5   = @msg5
         ,@msg6   = @msg6
         ,@msg7   = @msg7
         ,@msg8   = @msg8
         ,@msg9   = @msg9
         ,@msg10  = @msg10
         ,@msg11  = @msg11
         ,@msg12  = @msg12
         ,@msg13  = @msg13
         ,@msg14  = @msg14
         ,@msg15  = @msg15
         ,@msg16  = @msg16
         ,@msg17  = @msg17
         ,@msg18  = @msg18
         ,@msg19  = @msg19
         ,@msg20  = @msg20
         ,@ex_num = @ex_num
         ,@state  = @state
         ;
   END

   EXEC sp_log 0, @fn, '999: OK';
END
/*
EXEC tSQLt.Run 'test.test_049_sp_assert_not_null_or_empty';
EXEC tSQLt.RunAll;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 27-MAR-2020
-- Description: Raises exception if @a is null or empty
-- =============================================
ALTER PROCEDURE [dbo].[sp_assert_not_null_or_empty]
       @val       NVARCHAR(3999)
      ,@msg1      NVARCHAR(200)   = NULL
      ,@msg2      NVARCHAR(200)   = NULL
      ,@msg3      NVARCHAR(200)   = NULL
      ,@msg4      NVARCHAR(200)   = NULL
      ,@msg5      NVARCHAR(200)   = NULL
      ,@msg6      NVARCHAR(200)   = NULL
      ,@msg7      NVARCHAR(200)   = NULL
      ,@msg8      NVARCHAR(200)   = NULL
      ,@msg9      NVARCHAR(200)   = NULL
      ,@msg10     NVARCHAR(200)   = NULL
      ,@msg11     NVARCHAR(200)   = NULL
      ,@msg12     NVARCHAR(200)   = NULL
      ,@msg13     NVARCHAR(200)   = NULL
      ,@msg14     NVARCHAR(200)   = NULL
      ,@msg15     NVARCHAR(200)   = NULL
      ,@msg16     NVARCHAR(200)   = NULL
      ,@msg17     NVARCHAR(200)   = NULL
      ,@msg18     NVARCHAR(200)   = NULL
      ,@msg19     NVARCHAR(200)   = NULL
      ,@msg20     NVARCHAR(200)   = NULL
      ,@ex_num    INT             = 50001
      ,@state     INT             = 1
      ,@st_empty  INT             = NULL
AS
BEGIN
   DECLARE @fn NVARCHAR(35)    = N'sp_assert_not_null_or_empty';
   EXEC sp_log 0, @fn, '000 starting';

   IF @st_empty IS NULL
      SET @st_empty = @state + 1;

   EXEC sp_log 0, @fn, '005 calling sp_assert_not_null';
   EXEC [dbo].[sp_assert_not_null]
          @val    = @val
         ,@msg1   = @msg1
         ,@msg2   = @msg2
         ,@msg3   = @msg3
         ,@msg4   = @msg4
         ,@msg5   = @msg5
         ,@msg6   = @msg6
         ,@msg7   = @msg7
         ,@msg8   = @msg8
         ,@msg9   = @msg9
         ,@msg10  = @msg10
         ,@msg11  = @msg11
         ,@msg12  = @msg12
         ,@msg13  = @msg13
         ,@msg14  = @msg14
         ,@msg15  = @msg15
         ,@msg16  = @msg16
         ,@msg17  = @msg17
         ,@msg18  = @msg18
         ,@msg19  = @msg19
         ,@msg20  = @msg20
         ,@ex_num = @ex_num
         ,@state  = @state

   --EXEC sp_log 0, @fnThis,'02 : starting calling sp_assert_not_empty'
   EXEC [dbo].[sp_assert_not_empty]
          @val    = @val
         ,@msg1   = @msg1
         ,@msg2   = @msg2
         ,@msg3   = @msg3
         ,@msg4   = @msg4
         ,@msg5   = @msg5
         ,@msg6   = @msg6
         ,@msg7   = @msg7
         ,@msg8   = @msg8
         ,@msg9   = @msg9
         ,@msg10  = @msg10
         ,@msg11  = @msg11
         ,@msg12  = @msg12
         ,@msg13  = @msg13
         ,@msg14  = @msg14
         ,@msg15  = @msg15
         ,@msg16  = @msg16
         ,@msg17  = @msg17
         ,@msg18  = @msg18
         ,@msg19  = @msg19
         ,@msg20  = @msg20
         ,@ex_num = @ex_num
         ,@state  = @state

   EXEC sp_log 0, @fn, '999: OK';
   RETURN 0;
END
/*
EXEC tSQLt.Run 'test.test_049_sp_assert_not_null_or_empty';
EXEC tSQLt.RunAll;
EXEC sp_assert_not_null_or_empty NULL
EXEC sp_assert_not_null_or_empty ''
EXEC sp_assert_not_null_or_empty 'Fred'
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================================
-- Author:      Terry Watts
-- Create date: 06-NOV-2023
-- Description: lists the columns for the tables
-- =============================================================
ALTER VIEW [dbo].[list_table_columns_vw]
AS
SELECT TOP 10000 
    TABLE_SCHEMA
   ,TABLE_NAME
   ,COLUMN_NAME
   ,ORDINAL_POSITION
   ,DATA_TYPE
   ,CHARACTER_MAXIMUM_LENGTH
   ,isc.COLLATION_NAME
   ,is_computed
   ,so.[object_id] AS table_oid
   ,so.[type_desc]
   ,so.[type]
FROM [INFORMATION_SCHEMA].[COLUMNS] isc
JOIN sys.objects     so ON so.[name]        = isc.TABLE_NAME
JOIN sys.all_columns sac ON sac.[object_id] =  so.[object_id] AND sac.[name]=isc.column_name
ORDER BY TABLE_NAME, ORDINAL_POSITION;
/*
SELECT *FROM list_table_columns_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==========================================================================================================
-- Author:      Terry Watts
-- Create date: 28-FEB-2024
-- Description: 
--
-- PRECONDITIONS:
-- PRE 01: @spreadsheet must be specified OR EXCEPTION 58000, 'spreadsheet must be specified'
-- PRE 02: @spreadsheet exists,           OR EXCEPTION 58001, 'spreadsheet does not exist'
-- PRE 03: @range not null or empty       OR EXCEPTION 58002, 'range must be specified'
-- 
-- POSTCONDITIONS:
-- POST01:
--
-- CALLED BY:
-- sp_import_XL_new, sp_import_XL_existing
--
-- TESTS:
--
-- CHANGES:
-- 05-MAR-2024: put brackets around the field names to handle spaces reserved words etc.
-- 05-MAR-2024: added parameter validation
-- ==========================================================================================================
ALTER PROCEDURE [dbo].[sp_get_fields_from_xl_hdr]
    @spreadsheet  NVARCHAR(500)
   ,@range        NVARCHAR(100)  = N'Sheet1$'   -- for XL: like 'Table$' OR 'Table$A:B'
   ,@fields       NVARCHAR(4000) OUT            -- comma separated list
AS
BEGIN
   DECLARE 
       @fn        NVARCHAR(35)   = N'GET_FLDS_FRM_XL_HDR'
      ,@cmd       NVARCHAR(4000)

   EXEC sp_log 1, @fn, '000: starting, 
@spreadsheet:  [', @spreadsheet,']
@range:        [', @range,']'
;
   BEGIN TRY
      -------------------------------------------------------
      -- Param validation, fixup
      -------------------------------------------------------
      SET @range = ut.dbo.fnFixupXlRange(@range);

      --------------------------------------------------------------------------------------------------------
      -- PRE 01: @spreadsheet must be specified OR EXCEPTION 58000, 'spreadsheet must be specified'
      --------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '010: checking PRE 01';
      EXEC sp_assert_not_null_or_empty @spreadsheet, 'spreadsheet must be specified', @ex_num=58000--, @fn=@fn;

      --------------------------------------------------------------------------------------------------------
      -- PRE 02: @spreadsheet exists,           OR EXCEPTION 58001, 'spreadsheet does not exist'
      --------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '020: checking PRE 02';

      IF Ut.dbo.fnFileExists(@spreadsheet) = 0 
         EXEC sp_raise_exception 58001, 'spreadsheet does not exist'--, @fn=@fn

      --------------------------------------------------------------------------------------------------------
      -- PRE 03: @range not null or empty       OR EXCEPTION 58002, 'range must be specified'
      --------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '025: checking PRE 03';
      EXEC sp_assert_not_null_or_empty @range, 'range must be specified', @ex_num=58002--, @fn=@fn;

      -------------------------------------------------------
      -- ASSERTION: Passed parameter validation
      -------------------------------------------------------
      EXEC sp_log 1, @fn, '030: Passed parameter validation';

      -------------------------------------------------------
      -- Process
      -------------------------------------------------------
      EXEC sp_log 1, @fn, '040: processing';
      DROP TABLE IF EXISTS temp;

      -- IMEX=1 treats everything as text
      SET @cmd = 
         CONCAT
         (
      'SELECT * INTO temp 
      FROM OPENROWSET
      (
          ''Microsoft.ACE.OLEDB.12.0''
         ,''Excel 12.0;IMEX=1;HDR=NO;Database='
         ,@spreadsheet,';''
         ,''SELECT TOP 2 * FROM ',@range,'''
      )'
         );

      EXEC sp_log 1, @fn, '050: open rowset sql:
   ', @cmd;

      EXEC(@cmd);
      SELECT @fields = string_agg(CONCAT('concat (''['',','', column_name, ','']''',')'), ','','',') FROM list_table_columns_vw WHERE TABLE_NAME = 'temp';
      SELECT @cmd = CONCAT('SET @fields = (SELECT TOP 1 CONCAT(',@fields, ') FROM [temp])');
      EXEC sp_log 1, @fn, '060: get fields sql:
   ', @cmd;

      EXEC sp_executesql @cmd, N'@fields NVARCHAR(4000) OUT', @fields OUT;
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      EXEC sp_log 4, @fn, '500: parameters, 
@spreadsheet:  [', @spreadsheet,']
@range:        [', @range,']'
;
      THROW
   END CATCH
   EXEC sp_log 1, @fn, '99: leaving, OK';
END
/*
DECLARE @fields NVARCHAR(MAX);
EXEC sp_get_fields_from_xl_hdr 'D:\Dev\Repos\Farming\Data\Distributors.xlsx','Distributors$A:H', @fields OUT;
PRINT @fields;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 27-MAR-2020
-- Description: asserts that a is greater than b
--              raises an exception if not
-- =============================================
ALTER PROCEDURE [dbo].[sp_assert_gtr_than]
       @a         SQL_VARIANT
      ,@b         SQL_VARIANT
      ,@msg       NVARCHAR(200)  = NULL
      ,@msg2      NVARCHAR(200)  = NULL
      ,@msg3      NVARCHAR(200)  = NULL
      ,@msg4      NVARCHAR(200)  = NULL
      ,@msg5      NVARCHAR(200)  = NULL
      ,@msg6      NVARCHAR(200)  = NULL
      ,@msg7      NVARCHAR(200)  = NULL
      ,@msg8      NVARCHAR(200)  = NULL
      ,@msg9      NVARCHAR(200)  = NULL
      ,@msg10     NVARCHAR(200)  = NULL
      ,@msg11     NVARCHAR(200)  = NULL
      ,@msg12     NVARCHAR(200)  = NULL
      ,@msg13     NVARCHAR(200)  = NULL
      ,@msg14     NVARCHAR(200)  = NULL
      ,@msg15     NVARCHAR(200)  = NULL
      ,@msg16     NVARCHAR(200)  = NULL
      ,@msg17     NVARCHAR(200)  = NULL
      ,@msg18     NVARCHAR(200)  = NULL
      ,@msg19     NVARCHAR(200)  = NULL
      ,@msg20     NVARCHAR(200)  = NULL
      ,@ex_num    INT            = 53502
      ,@state     INT            = 1
AS
BEGIN
   DECLARE
       @aTxt   NVARCHAR(100)= CONVERT(NVARCHAR(20), @a)
      ,@bTxt   NVARCHAR(100)= CONVERT(NVARCHAR(20), @b)
      ,@msg0   NVARCHAR(1000)

   WHILE(1=1)
   BEGIN
      IF dbo.fnChkEquals(@a ,@b) = 1
         BREAK;    -- mismatch

      IF dbo.fnIsLessThan(@b, @a) = 1
         RETURN 1; -- match

      -- ASSERTION: if here then mismatch
      BREAK;
   END

   -- ASSERTION: if here then mismatch
   SET @msg0 = CONCAT('ASSERTION [',CONVERT( NVARCHAR(40), @a), '] > [', CONVERT( NVARCHAR(40), @b), '] failed. ');

   EXEC sp_raise_exception
          @msg1   = @msg0
         ,@msg2   = @msg
         ,@msg3   = @msg2
         ,@msg4   = @msg3
         ,@msg5   = @msg4
         ,@msg6   = @msg5
         ,@msg7   = @msg6
         ,@msg8   = @msg7
         ,@msg9   = @msg8
         ,@msg10  = @msg9
         ,@msg11  = @msg10
         ,@msg12  = @msg11
         ,@msg13  = @msg12
         ,@msg14  = @msg13
         ,@msg15  = @msg14
         ,@msg16  = @msg15
         ,@msg17  = @msg16
         ,@msg18  = @msg17
         ,@msg19  = @msg18
         ,@msg20  = @msg19
         ,@ex_num = @ex_num
         ,@state  = @state
   ;
END
/*
   EXEC tSQLt.RunAll;
   EXEC tSQLt.Run 'test.test_042_sp_assert_gtr_than';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===========================================================
-- Author:      Terry Watts
-- Create date: 31-JAN-2024
-- Description: imports an Excel sheet into an existing table
-- returns the row count [optional]
-- 
-- Postconditions:
-- POST01: IF @expect_rows set then expect at least 1 row to be imported or EXCEPTION 56500 'expected some rows to be imported'
--
-- Changes:
-- 05-MAR-2024: parameter changes: made fields optional; swopped @table and @fields order
-- 08-MAR-2024: added @expect_rows parameter defult = yes(1)
-- ===========================================================
ALTER PROCEDURE [dbo].[sp_import_XL_existing]
(
    @spreadsheet  NVARCHAR(400)              -- path to xls
   ,@range        NVARCHAR(100)              -- like 'Corrections_221008$A:P' OR 'Corrections_221008$'
   ,@table        NVARCHAR(60)               -- existing table
   ,@clr_first    BIT            = 1         -- if 1 then delete the table contets first
   ,@fields       NVARCHAR(4000) = NULL      -- comma separated list
   ,@expect_rows  BIT            = 1
   ,@row_cnt      INT            = NULL  OUT -- optional rowcount of imported rows
)
AS
BEGIN
   DECLARE 
    @fn           NVARCHAR(35)   = N'IMPORT_XL_EXISTNG'
   ,@cmd          NVARCHAR(4000)

   EXEC sp_log 0, @fn,'000: starting';

   ----------------------------------------------------------------------------------
   -- Process
   ----------------------------------------------------------------------------------
   BEGIN TRY

      EXEC sp_log 1, @fn,'510: parameters:
         spreadsheet:[', @spreadsheet, ']
         range      :[', @range, ']
         table      :[', @table, ']
         clr_first  :[', @clr_first, ']
         fields     :[', @fields,']
         expect_rows:[',@expect_rows,']'
         ;

      IF @clr_first = 1
      BEGIN
         EXEC sp_log 1, @fn,'005: clearing data from table';
         SET @cmd = CONCAT('DELETE FROM [', @table,']');
         EXEC( @cmd)
      END
      EXEC sp_log 1, @fn,'007';

      IF @fields IS NULL
      BEGIN
         EXEC sp_log 1, @fn,'010: getting fields from XL hdr';
         EXEC sp_get_fields_from_xl_hdr @spreadsheet, @range, @fields OUT;
      END

      EXEC sp_log 1, @fn,'015: importing data';
      SET @cmd = ut.dbo.fnCrtOpenRowsetSqlForXlsx(@table, @fields, @spreadsheet, @range, 0);
      EXEC sp_log 1, @fn, '020 open rowset sql:
   ', @cmd;
      EXEC( @cmd);

      SET @row_cnt = @@rowcount;
      EXEC sp_log 0, @fn, '22: imported ', @row_cnt,' rows';

      ----------------------------------------------------------------------------------
      -- Check post conditions
      ----------------------------------------------------------------------------------
      EXEC sp_log 0, @fn,'025: Checking post conditions';
      IF @expect_rows = 1 EXEC sp_assert_gtr_than @row_cnt, 0, 'expected some rows to be imported';--, @fn=@fn;

      ----------------------------------------------------------------------------------
      -- Processing complete
      ----------------------------------------------------------------------------------
      EXEC sp_log 0, @fn, '950: processing complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving OK, imported ', @row_cnt,' rows';
END
/*
EXEC sp_import_XL_existing 
    @spreadsheet = 'D:\Dev\Farming\Data\ImportCorrections 221018 230816-2000.xlsx'
   ,@range       = 'ImportCorrections'
   ,@table       = 'ImportCorrectionsStaging'
   ,@clr_first   = 1
   ,@fields      = 'id,command,search_clause,search_clause_cont,not_clause,replace_clause, case_sensitive, Latin_name, common_name, local_name, alt_names, note_clause, crops, doit, must_update, comments'
   ,@expect_rows = 1
   ,@row_cnt     = NULL
EXEC sp_import_XL_existing 
    @spreadsheet = 'D:\Dev\Repos\Farming\Data\CallRegister.xlsx'
   ,@range       = 'Call Register$A:C'
   ,@table       = 'CallRegister'
   ,@clr_first   = 1
   ,@fields      = 'id,rtn,limit'
   ,@expect_rows = 1
   ,@row_cnt     = NULL
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===========================================================================================
-- Author:      Terry Watts
-- Create date: 31-JAN-2024
-- Description: Excel sheet importer into a new table
-- returns the row count [optional]
-- 
-- Postconditions:
-- POST01: IF @expect_rows set then expect at least 1 row to be imported or EXCEPTION 56500 'expected some rows to be imported'
--
-- Changes:
-- 05-MAR-2024: parameter changes: made fields optional; swopped @table and @fields order
-- 08-MAR-2024: added @expect_rows parameter defult = yes(1)
-- ===========================================================================================
ALTER PROCEDURE [dbo].[sp_import_XL_new]
(
    @spreadsheet  NVARCHAR(400)        -- path to xls
   ,@range        NVARCHAR(100)        -- like 'Corrections_221008$A:P' OR 'Corrections_221008$'
   ,@table        NVARCHAR(60)         -- new table
   ,@fields       NVARCHAR(4000) = NULL-- comma separated list
   ,@row_cnt      INT            = NULL  OUT -- optional rowcount of imported rows
   ,@expect_rows  BIT            = 1
)
AS
BEGIN
   DECLARE 
    @fn           NVARCHAR(35)   = N'IMPRT_XL_NEW'
   ,@cmd          NVARCHAR(4000)

   EXEC sp_log 2, @fn,'00: starting:
@spreadsheet: ', @spreadsheet, '
@range      : ', @range, '
@table      : ', @table, '
@fields     : ', @fields
;

   SET @cmd = CONCAT('DROP table if exists [', @table, ']');
   EXEC( @cmd)

   IF @fields IS NULL EXEC sp_get_fields_from_xl_hdr @spreadsheet, @range, @fields OUT;

   EXEC sp_log 2, @fn,'10: importing data';
   SET @cmd = ut.dbo.fnCrtOpenRowsetSqlForXlsx(@table, @fields, @spreadsheet, @range, 1);
   PRINT @cmd;
   EXEC( @cmd);

   SET @row_cnt = @@rowcount;
   IF @expect_rows = 1 EXEC sp_assert_gtr_than @row_cnt, 0, 'expected some rows to be imported', @fn=@fn;

   EXEC sp_log 2, @fn, '99: leaving OK, imported ', @row_cnt,' rows';
END
/*
EXEC dbo.sp_import_XL_new 'D:\Dev\Repos\Farming_Dev\Data\ForeignKeys.xlsx', 'Sheet1$', 'ForeignKeys';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =================================================================
-- Author:      Terry Watts
-- Create Date: 06-AUG-2023
-- Description: Checks that the given table has at least 1 row
-- =================================================================
ALTER PROCEDURE [dbo].[sp_chk_tbl_populated]
    @table     NVARCHAR(60)
   ,@exp_cnt   INT            = NULL
   ,@ex_num    INT            = 56687
   ,@ex_msg    NVARCHAR(100)  = NULL
AS
BEGIN
   DECLARE 
    @fn        NVARCHAR(35)   = N'sp_chk_tbl_populated'
   ,@sql       NVARCHAR(MAX)
   ,@act_cnt   INT = -1
   ,@msg       NVARCHAR(200);

   SET NOCOUNT ON;

   SET @sql = CONCAT('SELECT @act_cnt = COUNT(*) FROM ', @table);
   PRINT CONCAT('@sql: ', @sql);

   EXEC sp_executesql @sql, N'@act_cnt INT OUT', @act_cnt OUT
   EXEC sp_log 1, 'table ', @table, ' has ', @act_cnt, ' rows';

   IF @exp_cnt IS NOT null
   BEGIN
      IF @exp_cnt <> @act_cnt
      BEGIN
         IF @ex_msg IS NULL
            SET @ex_msg = CONCAT('Table: ', @table, ' row count: exp ',@exp_cnt,'  act:', @act_cnt);

         THROW @ex_num, @ex_msg, 1;
      END
   END
   ELSE
   BEGIN -- check at least 1 row
      IF @act_cnt = 0
      BEGIN
         IF @ex_msg IS NULL
            SET @ex_msg = CONCAT('Table: ', @table, ' does not have any rows');

         THROW @ex_num, @ex_msg, 1;
      END
   END

END
/*
   -- This should not creaet an exception as dummytable has rows
   EXEC dbo.sp_chk_tbl_populated 'dummytable'
   
   -- This should create the following exception:
   -- Msg 56687, Level 16, State 1, Procedure dbo.sp_chk_tbl_populated, Line 27 [Batch Start Line 37]
   -- Table: [AppLog] does not have any rows
    
   EXEC dbo.sp_chk_tbl_populated 'AppLog'
   IF EXISTS (SELECT 1 FROM [dummytable]) PRINT '1' ELSE PRINT '0'
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ================================================================
-- Author:      Terry Watts
-- Create date: 25-FEB-2024
-- Description: imports a tsv file using a view
--
-- POSTCONDITIONS:
-- POST 01: if @clr_first is set then the table must be specified or EXCEPTION 62250, 'able must be specified if @clr_first is set'
--
-- Changes:
-- 07-MAR-2024  returns the count of imported rows in the @row_cnt out param
-- ================================================================
ALTER PROCEDURE [dbo].[sp_bulk_import_tsv]
    @tsv_file     NVARCHAR(MAX)
   ,@view         NVARCHAR(120)
   ,@table        NVARCHAR(60)   = NULL --POST 01: if @clr_first is set then the table must be specified or EXCEPTION 62250, 'able must be specified if @clr_first is set'
   ,@clr_first    BIT            = 1 -- if 1 then delete the table contents first
   ,@row_cnt      INT            = NULL OUT     -- optional count of imported rows
   ,@expect_rows  BIT            = 1 -- assert rows were imported if this flag is set
AS
BEGIN
   DECLARE
       @fn     NVARCHAR(35)   = N'BLK_IMPRT_TSV'
      ,@cmd    NVARCHAR(MAX)

   EXEC sp_log 1, @fn, '000: starting, 
@tsv_file: [',@tsv_file,']
@view:     [',@view,']
@table:    [',@table,']
@clr_first [',clr_first,']
';

   IF @clr_first = 1
   BEGIN
      EXEC sp_log 1, @fn, '005: deleting table [',@table,'] rows';
      -- POST 01: if @clr_first is set then the table must be specified or EXCEPTION 62250, 'table must be specified if @clr_first is set'
      IF dbo.fnTableExists(@table) = 0
      BEGIN
         EXEC Ut.dbo.sp_assert_not_null_or_empty @table;
         EXEC sp_log 4, @fn, '006: table [',@table,'] does not exist';
         THROW 62250, 'table must exist if @clr_first is set',1;
      END

      SET @cmd = CONCAT('DELETE FROM [', @table,']');
      PRINT @cmd;
      EXEC( @cmd)
   END

   EXEC sp_log 1, @fn, '010: deleting bulk import logs';
   SET @cmd = CONCAT('EXEC xp_cmdshell ''DEL D:\Logs\', @view,'.log.Error.Txt'', NO_OUTPUT;');
   EXEC sp_log 1, @fn, @cmd;
   EXEC sp_executesql @cmd;

   SET @cmd = CONCAT('EXEC xp_cmdshell ''DEL D:\Logs\', @view,'.log''          , NO_OUTPUT;');
   EXEC sp_log 1, @fn, @cmd;
   EXEC sp_executesql @cmd;

   SET @cmd = CONCAT(
      'BULK INSERT [',@view,'] FROM ''', @tsv_file, '''
      WITH
      (
         FIRSTROW        = 2
        ,ERRORFILE       = ''D:\Logs\',@view,'Import.log''
        ,FIELDTERMINATOR = ''\t''
        ,ROWTERMINATOR   = ''\n''
      );
   ');

   EXEC sp_log 1, @fn, '015: importig tsv file';
   EXEC sp_log 1, @fn, @cmd;
   EXEC sp_executesql @cmd;
   SET @row_cnt = @@ROWCOUNT;

   IF @expect_rows = 1
      EXEC ut.dbo.sp_assert_not_equal 0, @row_cnt, 'no rows were imported'

   EXEC sp_log 1, @fn, '99: leaving, OK, imported ',@row_cnt,' rows from file: ',@tsv_file;
END


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ================================================================================================================================================
-- Author:      Terry Watts
-- Create date: 25-FEB-2024
-- Description: imports a tsv or xlsx file
--
-- Parameters:    Mandatory,optional M/O
-- @import_file  [M] the import source file can be a tsv or xlsx file
--                   if an XL file then the normal format for the sheet is field names in the top row including an id for ease of debugging 
--                   data issues
-- @table        [O] the table to import the data to. 
--                if an XL file defaults to sheet name if not Sheet1$ otherwise file name less the extension
--                if a tsv defaults to file name less the extension
-- @view         [O] if a tsv this is the view used to control which columns are used n the Bulk insert command
--                   the default is NULL when the view name is constructed as import_<table name>_vw
-- @range        [O] for XL: like 'Corrections_221008$A:P' OR 'Corrections_221008$' default is 'Sheet1$'
-- @fields       [O] for XL: comma separated list
-- @clr_first    [O] if 1 then delete the table contents first           default is 1
-- @is_new       [O] if 1 then create the table - this is a double check default is 0
-- @expect_rows  [O] optional @expect_rows to assert has imported rows   default is 1
--
-- Preconditions: none
--
-- Postconditions:
-- POST01: @import file must not be null or ''             OR exception 63240, 'import_file must be specified'
-- POST02: @import file must exist                         OR exception 63241, 'import_file must exist'
-- POST03: if @is_new is false then (table must exist      OR exception 63242, 'table must exist if @is_new is false')
-- POST04: if @is_new is true  then (table must not exist  OR exception 63243, 'table must not exist if @is_new is true'))
-- 
-- RULES:
-- RULE01: @table:  if xl import then @table must be specified or deducable from the sheet name or file name OR exception 63245
-- RULE02: @table:  if a tsv then must specify table or the file name is the table 
-- RULE03: @view:   if a tsv file then if the view is not specified then it is set as Import<table>_vw
-- RULE04: @range:  if an Excel file then range defaults to 'Sheet1$'
-- RULE05: @fields: if an Excel file then @fields is optional
--                  if not specified then it is taken from the excel header (first row)
-- RULE06: @fields: if a tsv file then @fields is mandatory OR EXCEPTION 63245, 'if a tsv file then @fields is must be specified'
-- RULE07: @is_new: if new table and is an excel file and @fields is null then the table is created with fields taken from the spreadsheet header.
--
-- Changes:
-- 240326: added an optional root dir which can be specified once by client code and the path constructed here
-- ================================================================================================================================================
ALTER PROCEDURE [dbo].[sp_bulk_import]
    @import_file  NVARCHAR(1000)
   ,@import_root  NVARCHAR(1000) = NULL
   ,@table        NVARCHAR(60)   = NULL
   ,@view         NVARCHAR(60)   = NULL
   ,@range        NVARCHAR(100)  = N'Sheet1$'   -- POST09 for XL: like 'Corrections_221008$A:P' OR 'Corrections_221008$'
   ,@fields       NVARCHAR(4000) = NULL         -- for XL: comma separated list
   ,@clr_first    BIT            = 1            -- if 1 then delete the table contents first
   ,@is_new       BIT            = 0            -- if 1 then create the table - this is a double check
   ,@expect_rows  BIT            = 1            -- optional @expect_rows to assert has imported rows
   ,@row_cnt      INT            = NULL OUT     -- optional count of imported rows
AS
BEGIN
   SET NOCOUNT ON;

   DECLARE
       @fn           NVARCHAR(35)   = N'BLK_IMPRT'
      ,@ndx          INT
      ,@file_name    NVARCHAR(128)
      ,@table_exists BIT
      ,@is_xl_file   BIT
      ,@msg          NVARCHAR(500)

   PRINT '';
   EXEC sp_log 1, @fn, '000: starting';

   EXEC sp_log 1, @fn, '001: parameters,
import_file:  [', @import_file,']
table:        [', @table,']
view:         [', @view,']
range:        [', @range,']
fields:       [', @fields,']
clr_first:    [', @clr_first,']
is_new        [', @is_new,']
expect_rows   [', @expect_rows,']
';

   BEGIN TRY
      EXEC sp_log 1, @fn, '005: initial checks'
      EXEC sp_log 0, @fn, '010: checking POST01'
      ----------------------------------------------------------------------------------------------------------
      -- POST01: @import file must not be null or '' OR exception 63240, 'import_file must be specified'
      ----------------------------------------------------------------------------------------------------------
      IF @import_file IS NULL OR @import_file =''
      BEGIN
         SET @msg = 'import file must be specified';
         EXEC sp_log 4, @fn, '011 ',@msg;
         THROW 63240, @msg, 1;
      END

      IF @import_root IS NOT NULL
      BEGIN
         SET @import_file = CONCAT(@import_root, '\', @import_file);
         EXEC sp_log 1, @fn, '010: ,
modified import_file:  [', @import_file,']'
      END

      ----------------------------------------------------------------------------------------------------------
   -- POST02: @import file must exist  OR exception 63241, 'import_file must exist'
      ----------------------------------------------------------------------------------------------------------
      EXEC sp_log 0, @fn, '015: checking POST02'
      IF Ut.dbo.fnFileExists(@import_file) <> 1
      BEGIN
         EXEC sp_log 1, @fn, '015: checking POST02'
         SET @msg = CONCAT('import file [',@import_file,'] must exist');
         EXEC sp_log 4, @fn, '015 ',@msg;
         THROW 63241, @msg, 1;
      END

      SET @is_xl_file = IIF( CHARINDEX('.xlsx', @import_file) > 0, 1, 0);

      ----------------------------------------------------------------------------------------------------------
      -- Handle defaults
      ----------------------------------------------------------------------------------------------------------
      EXEC sp_log 0, @fn, '020: handle defaults'
      IF @range     IS NULL SET @range =  N'Sheet1$';
      IF @clr_first IS NULL SET @clr_first = 1;

      IF @table IS NULL 
      BEGIN
         EXEC sp_log 1, @fn, '025: setting table default value'
         IF @is_xl_file = 1
         BEGIN
            ----------------------------------------------------------------------------------------------------------
            -- POST06: @table: if xl import then @table must be specified or deducable from the sheet name or file name OR exception 63245
            ----------------------------------------------------------------------------------------------------------
            IF SUBSTRING(@range, 1, 7)<> 'Sheet1$'
            BEGIN
               SET @ndx   = CHARINDEX('$', @range);
               SET @table = SUBSTRING(@range, 1, @ndx-1);
            END
            ELSE
            BEGIN
               IF @ndx = 0 SET @ndx = Ut.dbo.fnLen(@range);
               SET @table = Ut.dbo.fnGetFileNameFromPath(@import_file,0);
            END
         END
         ELSE
         BEGIN
            ----------------------------------------------------------------------------------------------------------
            -- POST07: @table: if a tsv then must specify table or the file name is the table
            ----------------------------------------------------------------------------------------------------------
            SET @table = Ut.dbo.fnGetFileNameFromPath(@import_file,0);
         END

         IF dbo.fnTableExists(@table)=0
         BEGIN
            EXEC sp_log 1, @fn, '026: deduced table name:[', @table,'] does not exist';
            SET @table = NULL;
         END

         EXEC sp_log 1, @fn, '027: deduced table name:[', @table,']';
      END

      EXEC sp_log 0, @fn, '027: table:[', @table,']';
      SET @table_exists = iif( @table IS NOT NULL AND dbo.fnTableExists(@table)<>0, 1, 0);

      ----------------------------------------------------------------------------------------------------------
      -- RULE03: @view:  if a tsv file then if the view is not specified then it is set as Import<table>_vw
      ----------------------------------------------------------------------------------------------------------
      IF @view IS NULL AND @table_exists = 1  AND @is_xl_file = 0 
      BEGIN
         SET @view = CONCAT('Import_',@table,'_vw');
         EXEC sp_log 1, @fn, '030: if a tsv file and the view is not specified then set view default value as Import_<table>_vw: [',@view,']'
      END

      ----------------------------------------------------------------------------------------------------------
      -- Parameter Validation
      ----------------------------------------------------------------------------------------------------------

      ----------------------------------------------------------------------------------------------------------
      -- RULE05: @fields:if an Excel file then @fields is optional
      --          if not specified then it is taken from the excel header (first row)
      -- RULE07: @is_new: if new table and is an excel file and @fields is null then the table is created with
      --         fields taken from the spreadsheet header.

      ----------------------------------------------------------------------------------------------------------
      EXEC sp_log 0, @fn, '035: checking rule 5,11';
      IF @fields IS NULL AND @is_xl_file = 1
      BEGIN
         EXEC sp_get_fields_from_xl_hdr @import_file, @range, @fields OUT;
         EXEC sp_log 0, @fn, '040: if xl file and the fields are not specified then defaulting @fields to: [',@fields,']'
      END

      ------------------------------------------------------------------------------------------------------------------------------------------
      -- RULE06: @fields:if a tsv file then @fields is mandatory OR EXCEPTION 63245, 'if a tsv file then @fields is must be specified'
      ------------------------------------------------------------------------------------------------------------------------------------------
      EXEC sp_log 0, @fn, '045: checking RULE06';

      IF @fields IS NULL AND @is_xl_file = 0
      BEGIN
         SET @msg = 'if a tsv file then @fields must be specified';
         EXEC sp_log 4, @fn, '050 ',@msg;
         THROW 63245, @msg, 1;
      END

      --------------------------------------------------------------------------------------------------------------------
   -- POST03: if @is_new is false then (table must exist      OR exception 63242, 'table must exist if @is_new is false')
      --------------------------------------------------------------------------------------------------------------------
      IF @is_new = 0 AND @table_exists = 0
      BEGIN
         SET @msg = 'table must exist if @is_new is false';
         EXEC sp_log 4, @fn, '055 ',@msg;
         THROW 63244, @msg, 1;
      END

      ----------------------------------------------------------------------------------------------------------
   -- POST04: if @is_new is true  then (table does not exist  OR exception 63243, 'table must not exist if @is_new is true'))
      ----------------------------------------------------------------------------------------------------------
      IF @is_new = 1 AND @table_exists = 1
      BEGIN
         SET @msg = 'table must not exist if @is_new is true';
         EXEC sp_log 4, @fn, '060 ',@msg;
         THROW 63243, @msg, 1;
      END

      ----------------------------------------------------------------------------------------------------------
      -- Import the file
      ----------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '070: Importing file';
      IF @is_xl_file = 1
      BEGIN
         ----------------------------------------------------------------------------------------------------------
         -- Import Excel file
         ----------------------------------------------------------------------------------------------------------
         -- Parameter Validation
         EXEC sp_log 1, @fn, '075: Importing Excel file, fixup the range:[',@range,']';

         -- Fixup the range
         SET @range = ut.dbo.fnFixupXlRange(@range);
         EXEC sp_log 1, @fn, '080: Importing Excel file, fixuped the range:[',@range,']';

         ----------------------------------------------------------------------------------------------------------
         -- RULE05: @fields:if an Excel file then @fields is optional
         --          if not specified then it is taken from the excel header (first row)
         -- RULE07: @is_new: if new table and if an Excel file and @fields is null 
         --         then the table is created with fields taken from the spreadsheet header
         ----------------------------------------------------------------------------------------------------------
         EXEC sp_log 1, @fn, '085: calling sp_get_fields_from_xl_hdr';
         EXEC sp_get_fields_from_xl_hdr @import_file, @range, @fields OUT;
         EXEC sp_log 1, @fn, '087: ret frm sp_get_fields_from_xl_hdr';

         IF @is_new = 1
         BEGIN
            ----------------------------------------------------------------------------------------------------------
            -- Importing Excel file to new table
            ----------------------------------------------------------------------------------------------------------
            EXEC sp_log 1, @fn, '090: Importing Excel file to new table';
            EXEC sp_import_XL_new @import_file, @range, @table, @fields, @row_cnt=@row_cnt OUT;
         END
         ELSE
         BEGIN
            ----------------------------------------------------------------------------------------------------------
            -- Importing Excel file to existing table
            ----------------------------------------------------------------------------------------------------------
            EXEC sp_log 0, @fn, '095: Importing Excel file to existing table';
            EXEC sp_import_XL_existing @import_file, @range, @table, @clr_first, @fields, @row_cnt=@row_cnt OUT;
         END

         EXEC sp_log 0, @fn, '100: Imported Excel file';
      END
      ELSE
      BEGIN
         ----------------------------------------------------------------------------------------------------------
         -- Importing tsv file
         ----------------------------------------------------------------------------------------------------------
         EXEC sp_log 1, @fn, '105: Importing tsv file';

         ----------------------------------------------------------------------------------------------------------
         -- POST12: @is_new: if this is set then the table is created with fields based on the spreadsheet header
         ----------------------------------------------------------------------------------------------------------

         EXEC sp_bulk_import_tsv @import_file, @view, @table, @clr_first, @row_cnt=@row_cnt OUT;
      END

      ----------------------------------------------------------------------------------------------------------
      -- Checking post conditions
      ----------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '115: Checking post conditions'

      IF @expect_rows = 1
         EXEC sp_chk_tbl_populated @table;

      ---------------------------------------------------------------------
      -- Completed processing OK
      ---------------------------------------------------------------------
      EXEC sp_log 1, @fn, '120: Completed processing OK'
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;

      EXEC sp_log 1, @fn, '000: parameters:
import_file:  [', @import_file,']
import_root:  [', @import_root,']
table:        [', @table,']
view:         [', @view,']
range:        [', @range,']
fields:       [', @fields,']
clr_first:    [', @clr_first,']
is_new        [', @is_new,']
expect_rows   [', @expect_rows,']
';

      EXEC sp_log 1, @fn, '050: parameters
   @table_exists:  [', @table_exists,']
   @is_xl_file     [', @is_xl_file,']';

      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '99: leaving OK, imported ',@row_cnt,' rows to the ',@table,'  table from ',@import_file;
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_085_sp_bulk_import';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      Terry watts
-- Create date: 21-JAN-2020
-- Description: 1 line check null or mismatch and throw message
--              ASSUMES data types are the same
-- =============================================
ALTER PROCEDURE [dbo].[sp_assert_equal] 
       @a         SQL_VARIANT
      ,@b         SQL_VARIANT
      ,@msg       NVARCHAR(200)   = NULL
      ,@msg2      NVARCHAR(200)   = NULL
      ,@msg3      NVARCHAR(200)   = NULL
      ,@msg4      NVARCHAR(200)   = NULL
      ,@msg5      NVARCHAR(200)   = NULL
      ,@msg6      NVARCHAR(200)   = NULL
      ,@msg7      NVARCHAR(200)   = NULL
      ,@msg8      NVARCHAR(200)   = NULL
      ,@msg9      NVARCHAR(200)   = NULL
      ,@msg10     NVARCHAR(200)   = NULL
      ,@msg11     NVARCHAR(200)   = NULL
      ,@msg12     NVARCHAR(200)   = NULL
      ,@msg13     NVARCHAR(200)   = NULL
      ,@msg14     NVARCHAR(200)   = NULL
      ,@msg15     NVARCHAR(200)   = NULL
      ,@msg16     NVARCHAR(200)   = NULL
      ,@msg17     NVARCHAR(200)   = NULL
      ,@msg18     NVARCHAR(200)   = NULL
      ,@msg19     NVARCHAR(200)   = NULL
      ,@msg20     NVARCHAR(200)   = NULL
      ,@ex_num    INT             = 50001
      ,@state     INT             = 1
AS
BEGIN
   IF dbo.fnChkEquals(@a ,@b) = 0
      EXEC sp_raise_exception
          @msg1    = @msg
         ,@msg2   = @msg2
         ,@msg3   = @msg3
         ,@msg4   = @msg4
         ,@msg5   = @msg5
         ,@msg6   = @msg6
         ,@msg7   = @msg7
         ,@msg8   = @msg8
         ,@msg9   = @msg9
         ,@msg10  = @msg10
         ,@msg11  = @msg11
         ,@msg12  = @msg12
         ,@msg13  = @msg13
         ,@msg14  = @msg14
         ,@msg15  = @msg15
         ,@msg16  = @msg16
         ,@msg17  = @msg17
         ,@msg18  = @msg18
         ,@msg19  = @msg19
         ,@msg20  = @msg20
         ,@ex_num = @ex_num
         ,@state  = @state
END
/*
   EXEC tSQLt.RunAll;
*/

GO
GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =====================================================================================
-- Author       Terry Watts
-- Create date: 07-FEB-2024
-- Description: Registers a routine call and checks the call count against the limit
--
-- CHECKED PRECONDITIONS: PRE 01: @rtn must be registered
--
-- Changes:
-- 240414: faciltate multiple calls for example as in testing tSQLt.Runall
-- =====================================================================================
ALTER PROCEDURE [dbo].[sp_register_call]
   @rtn NVARCHAR(128)
AS
BEGIN
   DECLARE
       @fn NVARCHAR(35) = 'REGISTER_CALL'
      ,@error_msg NVARCHAR(500)
      ,@key       NVARCHAR(128)
      ,@count     INT
      ,@limit     INT
      ,@enforce_single_call_flg BIT = COALESCE(ut.dbo.fnGetSessionContextAsInt(N'ENFORCE_SINGLE_CALL'), 1);

   -- If testing ignore the single call system
   IF @enforce_single_call_flg = 0
      RETURN;

   SELECT
       @count = [count]
      ,@limit = limit
   FROM CallRegister
   WHERE rtn = @rtn;

   IF @count IS NOT NULL
   BEGIN
      SET @limit = (SELECT limit FROM CallRegister WHERE rtn = @rtn);

      -- Increment the call count
      UPDATE CallRegister 
      SET
         [count] = @count + 1
         ,updated = GetDate()
      WHERE rtn = @rtn;

      if(@count >= @limit)
      BEGIN
         SET @error_msg = CONCAT(@rtn, ' has already been called ',@limit,' times - this is the call limit for this routine');
         EXEC sp_log 4, @fn, @error_msg;
         THROW 56214, @error_msg, 1;
      END

   END
   ELSE
   BEGIN
      -- CHECKED PRECONDITIONS: PRE 01: @rtn must be registered
      SET @error_msg = CONCAT('The routine: ',@rtn, ' has not been registered');
      EXEC sp_log 4, @fn, @error_msg;
      THROW 53948, @error_msg, 1;
   END
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================
-- Author:      Terry Watts
-- Create date: 15-MAR-2024
-- Description:
--    Imports the LRAP data xls file, format spec = 221018
--
-- PRECONDITIONS:
-- file format spec = 221018
-- S1 and S2 are truncted
--
-- POSTCONDITIONS:
-- POST 01: S1 populated, s2 not
--
-- RESPONSIBILITIES:
-- R01: Clear the S1 and S2 tables
-- R02: Import the LRAP data file
-- R03: assign the import id to new data
--
-- TESTS:
--
-- CHANGES:
-- 
-- ======================================================================================
ALTER PROCEDURE [dbo].[sp_import_LRAP_file_xls_221018]
    @LRAP_data_file  NVARCHAR(150) -- the tab separated LRAP data file
   ,@range           NVARCHAR(100)  = N'Sheet1$'
AS
BEGIN
   DECLARE
    @fn              NVARCHAR(35)   = 'IMPRT_LRAP_FILE_XLS_221018'
   ,@row_cnt         INT
   ,@table           NVARCHAR(35)   = 'Staging1'
   ,@table_exists    INT

   EXEC sp_log 1, @fn, '00: starting
LRAP_data_file:[', @LRAP_data_file,']
range:         [', @range, ']'
;

   EXEC sp_register_call @fn;
   --------------------------------------------------------------------
   -- Processing start'
   --------------------------------------------------------------------
   SET @table_exists = dbo.fnTableExists(@table);
   EXEC sp_assert_equal 1, @table_exists, 'table ', @table, ' does not exist';

   ----------------------------------------------------------------------------
   -- 1. import the LRAP register file using the appropriate format importer
   ----------------------------------------------------------------------------
   -- 230721: new format
      EXEC sp_log 2, @fn, '15: import the LRAP register file (221018 fmt)';
      EXEC sp_bulk_import 
          @import_file  = @LRAP_data_file
         ,@table        = @table
         ,@range        = @range
         ,@fields       = NULL         -- for XL: comma separated list
         ,@clr_first    = 1            -- if 1 then delete the table contents first
         ,@is_new       = 0            -- if 1 then create the table - this is a double check
         ,@expect_rows  = 1            -- optional @expect_rows to assert has imported rows
         ,@row_cnt      = @row_cnt OUT  -- optional count of imported rows
         ;

   --------------------------------------------------------------------
   -- Processing complete'
   --------------------------------------------------------------------
   EXEC sp_log 2, @fn,'80: processing complete';
END
   EXEC sp_log 1, @fn, '99: leaving';
/*
EXEC sp_Import_CallRegister 'D:\Dev\Repos\Farming\Data\CallRegister.xlsx';
EXEC sp_reset_CallRegister;
EXEC sp_import_LRAP_file_xls_221018 'D:\Dev\Repos\Farming\Data\LRAP-221018-230813.xlsx', 'LRAP-221018 230813$A:N';
SELECT * FROM staging1;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================
-- Author:      Terry Watts
-- Create date: 15-MAR-2024
--    2. imports the LRAP register Excel file
--
-- PRECNDITIONS: S1, S2 truncated
--
-- POSTCONDITIONS:
-- POST 01:
--
-- TESTS:
--
-- CHANGES:
--
-- ======================================================================================
ALTER PROCEDURE [dbo].[sp_import_LRAP_file_xls]
    @LRAP_data_file  NVARCHAR(150)
   ,@range           NVARCHAR(100)
   ,@import_id       INT = 1-- handles imports ids: acceptable values: (1,2) {1:221018, 2:230721} default: 221018
AS
BEGIN
   DECLARE
    @fn              NVARCHAR(35)   = 'IMPRT_LRAP_FILE_XLS'
   ,@error_msg       NVARCHAR(500)
   ,@is_xl           BIT

   SET @import_id = dbo.fnGetImportIdFromName(@LRAP_data_file);


   EXEC sp_log 1, @fn, '00: starting
LRAP_data_file:[',@LRAP_data_file,']
import_id:     [',@import_id     ,']';

   BEGIN TRY
      EXEC sp_register_call @fn;

      --------------------------------------------------------------------
      -- Processing start'
      --------------------------------------------------------------------
      --SET @range = ut.dbo.fnFixupXlRange(@range);

      ------------------------------------------------------------------------------
      -- 3. import the LRAP register file using the appropriate format importer
      ------------------------------------------------------------------------------
      ----------------------------------------------------------------------------
      -- 1. import the LRAP register file using the appropriate format importer
      ----------------------------------------------------------------------------
      -- 230721: new format
      IF      @import_id = 1 -- 221018
      BEGIN -- currently only 2 versions: 221018, 230721. default: 221018
         EXEC sp_log 2, @fn, '15: import the LRAP register file (221018 fmt)';
         EXEC sp_import_LRAP_file_xls_221018 @LRAP_data_file, @range;
      END
      ELSE IF @import_id = 2 -- 230721
      BEGIN
         EXEC sp_log 2, @fn, '20: import the LRAP register file (230721 fmt)';
         EXEC sp_import_LRAP_file_xls_221018 @LRAP_data_file, @range;
      END
      ELSE -- Unrecognised import id
      BEGIN
         SET @error_msg = CONCAT('Unrecognised import id: ', @import_id);
         EXEC sp_log 4, @fn, '25: ', @error_msg;
         EXEC sp_raise_exception 56471, @error_msg, @fn=@fn;
      END

      --------------------------------------------------------------------
      -- Processing complete';
      --------------------------------------------------------------------
      EXEC sp_log 2, @fn,'80: processing complete';
      END TRY
      BEGIN CATCH
         EXEC Ut.dbo.sp_log_exception @fn;
         THROW;
      END CATCH
END
   EXEC sp_log 1, @fn, '99: leaving';
/*
EXEC sp_Reset_CallRegister;
EXEC sp_import_LRAP_file_xls 
    @LRAP_data_file  = 'D:\Dev\Repos\Farming_Dev\Data\LRAP-221018-230813.xlsx'
   ,@range           = 'LRAP-221018 230813$A:N'
   ,@import_id       = 221018;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================================================
-- Author:      Terry Watts
-- Create date: 08-AUG-2023
-- Description: General import rtn for all LRAP imports
--
-- PRECONDITIONS: none
--
-- POSTCONDITIONS:
--    Ready to call the fixup routne
--
-- ERROR HANDLING by exception handling
--
-- CHANGES:
-- 231103: turned auto increment off so SET IDENTITY_INSERT ON/OFF not needed
-- =============================================================================
ALTER procedure [dbo].[sp_bulk_insert_LRAP]
      @import_tsv_file  NVARCHAR(360)
     ,@view             NVARCHAR(60)
     ,@import_nm        NVARCHAR(60)
AS
BEGIN
   DECLARE
       @fn              NVARCHAR(35)   = N'BLK INSRT LRAP'
      ,@sql             NVARCHAR(4000)
      ,@RC              INT            = -1
      ,@error_msg       NVARCHAR(500)
      ,@rowcnt          INT = -1;
      ;

   EXEC sp_log 2, @fn, '01: Bulk_insert of [', @import_tsv_file, '] starting';

   BEGIN TRY
      EXEC xp_cmdshell 'DEL D:\Logs\PesticideRegisterImportErrors.log.Error.Txt', NO_OUTPUT;
      EXEC xp_cmdshell 'DEL D:\Logs\PesticideRegisterImportErrors.log'          , NO_OUTPUT;
      --SET IDENTITY_INSERT Staging1 OFF;
      EXEC sp_log 2, @fn, '02: about to import ',@import_tsv_file;

      SET @sql = CONCAT(
         'BULK INSERT ',@view,' FROM ''', @import_tsv_file, '''
          WITH
          (
             FIRSTROW = 2
            ,FIELDTERMINATOR = ''\t''
            ,ROWTERMINATOR   = ''\n''   
            ,ERRORFILE       = ''D:\Logs\PesticideRegisterImportErrors.log''
          );'
         );

        EXEC @RC = sp_executesql @sql;
        SET @rowcnt = @@ROWCOUNT;
        EXEC sp_log 2, @fn, 'imported ',@import_tsv_file, ' ', @rowcnt, ' rows',@row_count=@rowcnt;

        IF @RC <> 0
        BEGIN
            SET @error_msg = CONCAT('sp_bulk import_Registered Pesticides file failed error: :', @RC, '
            Error mmsg: ', ERROR_MESSAGE(),
            'File: ', @import_tsv_file);

            EXEC sp_log 4, @fn, '10: ', @error_msg;
            THROW 53874, @error_msg,1;
        END

      --SET IDENTITY_INSERT Staging1 ON;
      UPDATE staging1 
      SET created = FORMAT (getdate(), 'yyyy-MM-dd hh:mm')

   END TRY
   BEGIN CATCH
      --SET IDENTITY_INSERT Staging1 ON;
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, '50: caught exception: ',@error_msg;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '99: Bulk_insert of [', @import_tsv_file, ' leaving';
   RETURN @RC;
END
/*
TRUNCATE TABLE Staging1 
EXEC sp_bulk_insert_LRAP 'D:\Dev\Repos\Farming\Data\LRAP-231025-231103.txt', 'RegisteredPesticideImport_230721_vw', '2'
SELECT * FROM staging1 -- WHERE Id > 5710;
SELECT * FROM RegisteredPesticideImport_230721_vw
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ========================================================
-- Author:      Terry Watts
-- Create date: 01-AUG-2023
--
-- Description: Imports the Ph Dep Ag Pesticide register FMT: 230721 into S1
-- This imports each entire row into the staging1 table
--
-- PROCESS:
-- 1. download the Ph DepAg Registered Pesticides LRAP-221018.pdf from the Ph GovT Pha site
-- 2. exportentire pdf to Excel
-- 3. export as a tsv
-- 4.replace the singly LF line endings using notepad++:
-- 4.1:  replace ([^\r])\n  with \1
-- 4.2: save (and close) the file to the exports\tsv folder: D:\Data\Biz\Banana Farming\LRAP EXPORTS-221018\TSVs
--
-- 5: SQL Server:
-- 5.1 run EXEC [dbo].[sp_bulk_insert_Ph DepAg Registered Pesticides LRAP] 'D:\Data\Biz\Banana Farming\LRAP EXPORTS-221018\TSVs\Ph DepAg Registered Pesticides LRAP-221018 001-099.tsv'
-- 6. run [dbo].[sp_process Ph DepAg Registered Pesticides LRAP]
--
-- PRECONDITIONS:
--    rows with this version already deleted
--
-- POSTCONDITIONS:
--    CovidStaging1 staging column populated with the entire import row
--
-- Tests:
--    [test 012 sp_jh_imp_stg_1_bulk_insert]
-- ========================================================
ALTER procedure [dbo].[sp_bulk_insert_pesticide_register_221018]
     @import_tsv_file    NVARCHAR(360)
AS
BEGIN
   DECLARE
       @fn  NVARCHAR(35)   = N'_BLK_INSRT PEST REG 221018'
      ,@RC  INT            = -1

   EXEC sp_log 2, @fn, '01: Bulk_insert of [', @import_tsv_file, '] starting';
   EXEC sp_register_call @fn;
   EXEC @RC = sp_bulk_insert_LRAP @import_tsv_file = @import_tsv_file, @view='RegisteredPesticideImport_221018_vw', @import_nm='221018';
   EXEC sp_log 2, @fn, '99; return OK, bulk_insert of [', @import_tsv_file, ' leaving, @RC: ', @RC;
   RETURN @RC;
END
/*
TRUNCATE TABLE Staging1;
EXEC sp_bulk_insert_pesticide_register_221018 'D:\Dev\Repos\Farming\Data\Ph DepAg Registered Pesticides LRAP-221018 Export\LRAP-221018 230809-0815.tsv';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================================================================================================================================
-- Author:      Terry Watts
-- Create date: 19-JUN-2023
--
-- Description: Imports the Ph Dep Ag Pesticide register
-- staging table temp
-- This imports each entire row into the stagingcolumn
--
-- CALLEd BY: sp__main_import_pesticide_register
--
-- PROCESS:
-- 1. download the Ph DepAg Registered Pesticides LRAP-221018 001-099.pdf from
-- 2. split it down into 100 page pdfs as is too large for conversion 
-- 2.1: by using the pro pdf editor / edit/ Organise pages/select first 100 pages/ right click /Extract  {delete after extract} and OK to R U sure U want to delete pages 1-99
-- 2.2: save: choose a different location like: Ph DepAg Registered Pesticides LRAP-221018 001-099.pdf
-- 2.3: repeat the above steps till no pages left
-- 2.2: then extracted file like Ph DepAg Registered Pesticides LRAP-221018 001-099.tsv
-- 3. export each 100 page section pdf to Excel
-- 4. use Excel to:
-- 4.1 add 2 columns at the start sht, row and populate the sheet no (int) and the row number - 1-30 for each row on the sheet
-- 4.2 export as a tsv
-- 5: replace the singly LF line endings using notepad++:
-- 5.1:  replace ([^\r])\n  with \1
-- 5.2: save (and close) the file to the exports\tsv folder: D:\Data\Biz\Banana Farming\LRAP EXPORTS-221018\TSVs
-- 6: SQL Server
-- 6.1 run EXEC [dbo].[sp_bulk_insert_Ph DepAg Registered Pesticides LRAP] 'D:\Data\Biz\Banana Farming\LRAP EXPORTS-221018\TSVs\Ph DepAg Registered Pesticides LRAP-221018 001-099.tsv'
-- 7. run [dbo].[sp_process Ph DepAg Registered Pesticides LRAP]
--
-- PRECONDITIONS:
--    rows with this version already deleted
--
-- POSTCONDITIONS:
--    CovidStaging1 staging column populated with the entire import row
--
-- Tests:
--    [test 012 sp_jh_imp_stg_1_bulk_insert]
-- ==============================================================================================================================================================================
ALTER procedure [dbo].[sp_bulk_insert_pesticide_register_230721]
     @imprt_csv_file    NVARCHAR(360)
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35)   = N'BLK_INSRT PEST REG 230721'
      ,@RC        INT            = -1
      ,@import_nm NVARCHAR(20)

   SET @import_nm = dbo.fnGetSessionValueImportId();

   EXEC sp_log 2, @fn, '01: Bulk_insert of [', @imprt_csv_file, '] starting';
   EXEC sp_register_call @fn;
   EXEC @RC = sp_bulk_insert_LRAP @imprt_csv_file, 'RegisteredPesticideImport_230721_vw', @import_nm;
   EXEC sp_log 2, @fn, 'Bulk_insert of [', @imprt_csv_file, ' leaving, @RC: ', @RC;
   RETURN @RC;
END
/*
EXEC sp_bulk_insert_pesticide_register_230721 'D:\Dev\Repos\Farming\Data\LRAP-231025-231103.txt';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================
-- Author:      Terry Watts
-- Create date: 15-MAR-2024
-- Description:
--    Imports the LRAP register tab separated data file based on format spec (@import_id)
--
-- PRECONDITIONS: 
-- S1 and S2 are truncted
--
-- POSTCONDITIONS:
-- POST 01: S1 populated, s2 not
--
-- RESPONSIBILITIES:
-- R01: Clear the S1 and S2 tables
-- R02: Import the LRAP data file
-- R03: assign the import id to new data
--
-- TESTS:
--
-- CHANGES:
-- 
-- ======================================================================================
ALTER PROCEDURE [dbo].[sp_import_LRAP_file_tsv]
    @LRAP_data_file  NVARCHAR(150) -- the tab separated LRAP data file
   ,@import_id       INT = 221018  -- handles imports ids {1:221018, 2:230721} default: 221018
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35)   = 'IMPRT_LRAP_FILE_TSV'
      ,@is_xl     BIT

   EXEC sp_log 1, @fn, '00: starting
LRAP_data_file:[',@LRAP_data_file,']
import_id:     [',@import_id     ,']';

   EXEC sp_register_call @fn;
   --------------------------------------------------------------------
   -- Processing start'
   --------------------------------------------------------------------

   ----------------------------------------------------------------------------
   -- 1. import the LRAP register file using the appropriate format importer
   ----------------------------------------------------------------------------
   -- 230721: new format
   IF      @import_id = 1 -- 221018
   BEGIN -- currently only 2 versions: 221018, 230721. default: 221018
      EXEC sp_log 2, @fn, '15: import the LRAP register file (221018 fmt)';
      EXEC sp_bulk_insert_pesticide_register_221018 @LRAP_data_file;
   END
   ELSE IF @import_id = 2 -- 230721
   BEGIN
      EXEC sp_log 2, @fn, '20: import the LRAP register file (230721 fmt)';
      EXEC sp_bulk_insert_pesticide_register_230721 @LRAP_data_file;
   END
   ELSE -- Unrecognised import id
   BEGIN
      EXEC Ut.dbo.sp_raise_exception 56471, 'Unrecognised import id: ', @import_id, @fn=@fn;
   END

   --------------------------------------------------------------------
   -- Processing complete'
   --------------------------------------------------------------------
   EXEC sp_log 2, @fn,'80: processing complete';
END
   EXEC sp_log 1, @fn, '99: leaving';
/*
EXEC sp_import_LRAP_file_tsv;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================
-- Author:      Terry Watts
-- Create date: 15-MAR-2024
--    2. imports the LRAP register file either a tab separated file for Excel file
--
-- PRECONDITIONS: none
--
-- RESPONSIBILITIES:
-- R01: Clear the S1 and S2 tables
-- R02: Import the LRAP data file         DELEGATED
-- R03: assign the import id to new data  DELEGATED
--
-- POSTCONDITIONS:
-- POST 01:
--
-- CALLED BY: sp_main_import_stage_02
--
-- TESTS:
--
-- CHANGES:
-- 
-- ======================================================================================
ALTER PROCEDURE [dbo].[sp_import_LRAP_file]
    @LRAP_file    NVARCHAR(150)  = NULL
   ,@LRAP_range   NVARCHAR(100)  -- LRAP-221018 230813
   ,@import_id    INT = 221018 -- handles imports ids {1:221018, 2:230721} default: 221018
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35)   = 'IMPRT_LRAP_FILE'
      ,@is_xl     BIT

   EXEC sp_log 1, @fn, '00: starting
LRAP_file: [', @LRAP_file, ']
LRAP_range:[', @LRAP_range,']
import_id: [', @import_id, ']';

   BEGIN TRY
      EXEC sp_register_call @fn;

      --------------------------------------------------------------------
      -- R01: Clear the S1 and S2 tables
      --------------------------------------------------------------------
      EXEC sp_log 2, @fn, '10: truncating S1, s2';
      TRUNCATE TABLE Staging1;
      TRUNCATE TABLE Staging2;

      --------------------------------------------------------------------
      -- 2. determine the file type
      --------------------------------------------------------------------
      SET @is_xl = CHARINDEX('.xlsx', @LRAP_file);

      ------------------------------------------------------------------------------
      -- 3. R02: Import the LRAP data file
      ------------------------------------------------------------------------------
      if @is_xl = 1
      BEGIN
         -- is excel file
         EXEC sp_import_LRAP_file_xls @LRAP_file, @LRAP_range, @import_id;
      END
      ELSE
      BEGIN
         -- is tsv file
         EXEC sp_import_LRAP_file_tsv @LRAP_file, @import_id;
      END

      --------------------------------------------------------------------
      -- Processing complete';
      --------------------------------------------------------------------
      EXEC sp_log 2, @fn,'80: processing complete';
      END TRY
      BEGIN CATCH
         EXEC Ut.dbo.sp_log_exception @fn;
         throw
      END CATCH
   EXEC sp_log 1, @fn, '99: leaving';
   END
/*
EXEC sp_Reset_CallRegister;
EXEC sp_import_LRAP_file
    @LRAP_file = 'D:\Dev\Repos\Farming\Data\LRAP-221018-230813.xlsx'
   ,@LRAP_range     = 'LRAP-221018-230813$A:N'
   ,@import_id      = 221018;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2024
-- Description: does the stage 1 processing:
--    1. clears the staging 1  and staging2 tables
--    2. imports the LRAP register file using the appropriate importer
--
-- PRECONDITIONS: none
--
-- POSTCONDITIONS:
-- POST 01: handles imports ids {1:221018, 2:230721} default: 221018
--
-- TESTS:
--
-- CHANGES:
-- 240315: param name change: @import_file -> @LRAP_data_file
-- ======================================================================================
ALTER PROCEDURE [dbo].[sp_main_import_stage_02_imp_LRAP]
    @LRAP_file  NVARCHAR(150)
   ,@LRAP_range      NVARCHAR(100)  -- LRAP-221018 230813
   ,@import_id       INT            -- handles imports ids {1:221018, 2:230721} default: 221018
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35)   = 'MN_IMPRT_STG_02'

   EXEC sp_log 1, @fn, '00: starting
LRAP_file:[',@LRAP_file,']
LRAP_range:    [',@LRAP_range,    ']
import_id:     [',@import_id     ,']';


   BEGIN TRY
      EXEC sp_register_call @fn;
      EXEC sp_log 2, @fn,'05: import the LRAP register file and do some basic fixup';

      EXEC sp_import_LRAP_file 
          @LRAP_file = @LRAP_file
         ,@LRAP_range= @LRAP_range
         ,@import_id = @import_id;

      --------------------------------------------------------------------
      -- Processing complete';
      --------------------------------------------------------------------
      EXEC sp_log 2, @fn,'80: processing complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '99: leaving, OK';
END
/*
EXEC sp_Reset_CallRegister;
EXEC sp_main_import_stage_02_imp_LRAP 'D:\Dev\Repos\Farming_Dev\Data\LRAP-221018-230813.xlsx', 'LRAP-221018 230813$A:N', 1;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =========================================================================
-- Author:      Terry Watts
-- Create date: 20-AUG-2023
-- 
-- Description: imports the TypeStaging table form either a tsv or XL file
-- clears the table first
--
-- Parameters:
-- @import_file path to a tsv or excel file
-- @range [optional] if xlsx - can specify the sheet and range
-- @row_cnt [optional OUT] returns the rowcount is not null
--
-- Preconditions:
--  PRE01: all typeStaging dependent tables are cleared
--
-- Postconditions:
--   POST01: typeStaging table clean populated or error
--    
-- Tests: test.sp_import_TypeStaging
--
-- Changes:
-- 231107: imports to type_staging table not type
-- 231107: removed FK removal - now see Preconditions
-- ========================================================
ALTER procedure [dbo].[sp_import_TypeStaging]
      @import_file   NVARCHAR(500)
     ,@range         NVARCHAR(100)  = 'Sheet1$A:B'
     ,@row_cnt       INT            = NULL   OUT
AS
BEGIN
   DECLARE @fn        NVARCHAR(35)  = N'IMPRT_TypeStaging'

   EXEC sp_log 1, @fn,'000: starting
import_file:[', @import_file, ']
range      :[', @range      , ']
row_cnt    :[', @row_cnt    , ']';

   --EXEC sp_register_call @fn;

   ------------------------------------------------------
   -- Pop defaults if necessary
   ------------------------------------------------------
   IF @range IS NULL SET @range = 'Sheet1$A:B';

   ------------------------------------------------------
   -- Import
   ------------------------------------------------------
   EXEC sp_log 1, @fn,'010: calling sp_bulk_import';
   EXEC sp_bulk_import 
       @import_file  = @import_file
      ,@table        = 'TypeStaging'
      ,@view         = Import_TypeStaging_vw
      ,@range        = @range
      ,@fields       = 'type_id, type_nm'
      ,@clr_first    = 1
      ,@is_new       = 0
      ,@expect_rows  = 1
      ,@row_cnt      = @row_cnt OUT
      ;

   ------------------------------------------------------
   -- Processing complete
   ------------------------------------------------------
   EXEC sp_log 1, @fn, '999: leaving OK';
   RETURN;
END
/*
EXEC tSQLt.Run 'test.test_sp_import_TypeStaging';
EXEC sp_import_typeStaging 'D:\Dev\Repos\Farming\Data\Type.xlsx';
SELECT * FROM TypeStaging;
*/

GO
GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =========================================================
-- Author:      Terry Watts
-- Create date: 03-FEB-240203
-- Description: Import Excel sheet importer into an existing table
-- =========================================================
ALTER PROCEDURE [dbo].[sp_import_ForeignKey_XL]
(
    @spreadsheet  NVARCHAR(400)  -- path to xls
   ,@range        NVARCHAR(100)  -- like 'Corrections_221008$A:P' OR 'Corrections_221008$'
)
AS
BEGIN
   DECLARE @fn NVARCHAR(35) = 'IMPRT_FKS_XL'

   EXEC sp_log 0, @fn, '00: starting:
@spreadsheet:[',@spreadsheet,']
@range:      [',@range,']';

   EXEC sp_log 0, @fn, '05: deleting rows in ForeignKeys';
   DELETE FROM ForeignKey;

   EXEC sp_log 0, @fn, '10: importing ForeignKeys from ', @spreadsheet, ' range: ', @range;

   EXEC sp_import_XL_existing
          @spreadsheet  = @spreadsheet
         ,@range        = @range
         ,@table        = 'ForeignKey';
--   'id,fk_nm,foreign_table_nm,primary_tbl_nm,schema_nm,fk_col_nm,pk_col_nm,unique_constraint_name,ordinal,table_type'

   EXEC sp_log 0, @fn, '15: imported OK';
   EXEC sp_log 1, @fn, '99: leaving OK';
END
/*
EXEC sp_import_ForeignKey_XL 'D:\Dev\Repos\Farming\Data\ForeignKeys.xlsx', 'Sheet1$';
SELECT * FROM ForeignKeys;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===================================================================
-- Author:      Terry Watts
-- Create Date: 05-FEB-2024
-- Description: Checks that the given table does not have any rows
-- ===================================================================
ALTER PROCEDURE [dbo].[sp_chk_tbl_not_populated]
    @table        NVARCHAR(60)
AS
BEGIN
   EXEC sp_chk_tbl_populated @table, 0;
END
/*
EXEC tSQLt.Run test.test_sp_chk_tbl_not_populated';
TRUNCATE TABLE AppLog;
EXEC test_sp_chk_tbl_not_populated 'AppLog'; -- ok no rows
INSERT iNTO AppLog ()
*/

GO
GO
GO
GO
GO
GO
GO
GO
GO
GO
GO
GO
GO
GO
GO
GO
GO
GO
GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ====================================================================================================================================================
-- Author:       Terry Watts
-- Create date:  06-NOV-2023
-- Description:  clears the staging tables
--
-- PRECONDITIONS: none
--
-- POSTCONDITIONS:                                                Exception:
--    POST 01: (
--                all link and core tables cleared and not primary tables cleared and @clr_primary_tables = 0 OR
--                all tables cleared and @clr_primary_tables = 0
--             )
--             OR 
--             (
--                @clr_primary_tables     set and exception 50720, 'Error in sp_clear_staging_tables: Not all staging tables were cleared', 1;
--                OR 
--                @clr_primary_tables not set and exception 50721, 'Error in sp_clear_staging_tables: Not all non primary staging tables were cleared', 1;
--             )
--
-- CHANGES:
-- 240128: do not clear the ActionStaging Table
-- 240228: added a parameter @clr_primary_tables to signal to clear the PRIMARY staging tables that are imported from table specific imports
--         and not derivable from the LRAP import things like Action, Type that are used to validate and assign an id as an FK
-- ===========================================================================================================================================
ALTER PROCEDURE [dbo].[sp_clear_staging_tables]
   @clr_primary_tables BIT = 0
AS
BEGIN
   SET NOCOUNT ON
   DECLARE
       @fn        NVARCHAR(30)   = 'CLR_STG_TBLS'
      ,@error_msg NVARCHAR(MAX)  = NULL

   BEGIN TRY
      EXEC sp_log 2, @fn, '000: starting
@clr_primary_tables: [',@clr_primary_tables,']'

      --------------------------------------------------------------------------------------------------------
      -- Clear link staging tables
      --------------------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '005: clearing link tables'
      EXEC sp_log 1, @fn, '010: clearing link table ChemicalProductStaging     '; DELETE FROM ChemicalActionStaging;
      EXEC sp_log 1, @fn, '015: clearing link table ChemicalProductStaging     '; DELETE FROM ChemicalProductStaging;
      EXEC sp_log 1, @fn, '020: clearing link table ChemicalUseStaging         '; DELETE FROM ChemicalUseStaging;
      EXEC sp_log 1, @fn, '025: clearing link table CropPathogenStaging        '; DELETE FROM CropPathogenStaging;
      EXEC sp_log 1, @fn, '030: clearing link table PathogenChemicalStaging    '; DELETE FROM PathogenChemicalStaging;
      EXEC sp_log 1, @fn, '035: clearing link table ProductCompanyStaging      '; DELETE FROM ProductCompanyStaging;
      EXEC sp_log 1, @fn, '040: clearing link table ProductUseStaging          '; DELETE FROM ProductUseStaging;

      --------------------------------------------------------------------------------------------------------
      -- Clear core staging tables
      --------------------------------------------------------------------------------------------------------
      -- 240128: do not clear the core staging tables
      EXEC sp_log 2, @fn, '045: clearing core staging tables'
      EXEC sp_log 2, @fn, '046: clearing core table ChemicalStaging            '; DELETE FROM ChemicalStaging;
      EXEC sp_log 2, @fn, '050: clearing core table CropStaging                '; DELETE FROM CropStaging;
      EXEC sp_log 2, @fn, '055: clearing core table ImportCorrectionsStaging   '; DELETE FROM ImportCorrectionsStaging;
 --     EXEC sp_log 2, @fn, '060: clearing core table PathogenPathogenTypeStaging'; DELETE FROM PathogenPathogenTypeStaging;
      EXEC sp_log 2, @fn, '065: clearing core table PathogenStaging            '; DELETE FROM PathogenStaging;
      EXEC sp_log 2, @fn, '070: clearing core table CompanyStaging             '; DELETE FROM CompanyStaging;
      EXEC sp_log 2, @fn, '075: clearing core table ProductStaging             '; DELETE FROM ProductStaging;

      --------------------------------------------------------------------------------------------------------
      -- Clear primary tables
      --------------------------------------------------------------------------------------------------------
      IF @clr_primary_tables = 1
      BEGIN
         EXEC sp_log 2, @fn, '080: clearing core staging tables'
         EXEC sp_log 2, @fn, '085: clearing core table ActionStaging              '; DELETE FROM ActionStaging;
         EXEC sp_log 2, @fn, '085: clearing core table PathogenTypeStaging        '; DELETE FROM PathogenTypeStaging;
         EXEC sp_log 2, @fn, '090: clearing core table TypeStaging                '; DELETE FROM TypeStaging;
         EXEC sp_log 2, @fn, '095: clearing core table UseStaging                 '; DELETE FROM UseStaging;
         EXEC  sp_chk_tbl_not_populated 'ActionStaging';
         EXEC  sp_chk_tbl_not_populated 'PathogenTypeStaging';
         EXEC  sp_chk_tbl_not_populated 'TypeStaging';
         EXEC  sp_chk_tbl_not_populated 'UseStaging';
      END

      --------------------------------------------------------------------------------------------------------
      -- Postcondition checks
      --------------------------------------------------------------------------------------------------------
      -- POST 01: all tables cleared
      EXEC sp_log 2, @fn, '100: checking all non primary tables are cleared';
      EXEC  sp_chk_tbl_not_populated 'ChemicalActionStaging';
      EXEC  sp_chk_tbl_not_populated 'ChemicalProductStaging';
      EXEC  sp_chk_tbl_not_populated 'ChemicalUseStaging';
      EXEC  sp_chk_tbl_not_populated 'CropPathogenStaging';
      EXEC  sp_chk_tbl_not_populated 'PathogenChemicalStaging';
      EXEC  sp_chk_tbl_not_populated 'ProductCompanyStaging';
      EXEC  sp_chk_tbl_not_populated 'ProductUseStaging';
      EXEC  sp_chk_tbl_not_populated 'ChemicalStaging';
      EXEC  sp_chk_tbl_not_populated 'CropStaging';
      EXEC  sp_chk_tbl_not_populated 'ImportCorrectionsStaging';
      EXEC  sp_chk_tbl_not_populated 'PathogenStaging';
      EXEC  sp_chk_tbl_not_populated 'CompanyStaging';
      EXEC  sp_chk_tbl_not_populated 'ProductStaging';

      IF @clr_primary_tables = 0
      BEGIN
         EXEC sp_log 2, @fn, '110: checking no primary tables are cleared';
         EXEC  sp_chk_tbl_populated 'ActionStaging';
         EXEC  sp_chk_tbl_populated 'PathogenTypeStaging';
         EXEC  sp_chk_tbl_populated 'TypeStaging';
         EXEC  sp_chk_tbl_populated 'UseStaging';
      END

      ---------------------------------------------------------------
      -- Processing complete
      ---------------------------------------------------------------
     EXEC sp_log 2, @fn, '400: processing complete';
   END TRY
   BEGIN CATCH
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, '50: Caught exception: ', @error_msg;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '999: leaving OK'
END
/*
   EXEC sp_clear_staging_tables
*/

GO
GO
GO
GO
GO
GO
GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =========================================================================================
-- Author:      Terry Watts
-- Create date: 28-JAN-2024
--
-- Description: imports all the static data
-- Tables:
--   {1. ActionStaging,       2. UseStaging, 3.Distributor
--   ,4. PathogenTypeStaging, 5. Pathogen*,  6. TypeStaging}
--
-- NB*** Pathogen is directly imported into - it is used as a primary data table and 
--       used to check the pathogens in S2
--
-- Responsibilities:
-- R01: clear dependent tables
-- R02: import all the static data tables
--
-- Preconditions: dependent tables cleared
--
-- Postconditions:
--   POST01: all the imported tables have at least one row
--
-- Called by: sp__main_import_pesticide_register
--
-- Tests:
--
-- Changes:
-- 240223: import PathogenTypeStaging table from either a tsv or xlsx file
-- 240225: removed precondition and made part of the processing so routine is easy to test 
-- 240321: treating Pathogen as a primary data table to check the lRAP import pathogens
-- =========================================================================================
ALTER PROCEDURE [dbo].[sp_import_static_data]
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35)  = N'IMPRT_STATIC_DATA'
      ,@sql       NVARCHAR(MAX)
      ,@error_msg NVARCHAR(MAX) = NULL
      ,@rc        INT           =-1
      ;

   BEGIN TRY
      EXEC sp_log 1, @fn,'000: starting';
      EXEC sp_register_call @fn;

      --------------------------------------------------------------------------------------------
      -- R01: clear dependent tables
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'005: R01: clear dependent tables';
      EXEC sp_clear_staging_tables 1;

      --------------------------------------------------------------------------------------------
      -- R02: import all the static data tables
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'010: R02: import all the static data tables';

      --------------------------------------------------------------------------------------------
         -- 1. Import the import table
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'015: import the Import table';
      EXEC sp_bulk_import 
          @import_file   = 'D:\Dev\Farming\Data\Import.xlsx'
         ,@table         = 'Import'
         ,@range         = 'Import$A:F'
         ,@clr_first     = 1
         ,@is_new        = 0;

      --------------------------------------------------------------------------------------------
         -- 1. Import the TableType table
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'020: import the TableType table';
      EXEC sp_bulk_import 
          @import_file   = 'D:\Dev\Farming\Data\TableDef.xlsx'
         ,@table         = 'TableType'
         ,@range         = 'TableType$A:B'
         ,@clr_first     = 1
         ,@is_new        = 0;

      --------------------------------------------------------------------------------------------
         -- 2. Import the TableDef table
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'025: import the TableDef table';
      EXEC sp_bulk_import 
          @import_file   = 'D:\Dev\Farming\Data\TableDef.xlsx'
         ,@table         = 'TableDef'
         ,@range         = 'TableDef$A:E'
         ,@clr_first     = 1
         ,@is_new        = 0;

      --------------------------------------------------------------------------------------------
         -- 2. Import the ForeignKeys table
      --------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'025: Import the ForeignKeys table';
      EXEC sp_import_ForeignKey_XL 'D:\Dev\Farming\Data\ForeignKey.xlsx', 'Sheet1$'

      --------------------------------------------------------------------------------------------
         -- 3. Import the Action staging table
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'030: Import the ActionStaging table';
      EXEC dbo.sp_bulk_import 
          @import_file   = 'D:\Dev\Farming\Data\Actions.xlsx'
         ,@table         = 'ActionStaging'
         ,@view          = 'ImportActionStaging_vw'
         ,@range         = 'Actions$A:B'
         ,@clr_first     = 1;

      --------------------------------------------------------------------------------------------
         -- 4. Import the Use staging table
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'035: Import the UseStaging table';
      EXEC dbo.sp_bulk_import 
          @import_file  = 'D:\Dev\Farming\Data\use.xlsx'
         ,@table        = 'UseStaging'
         ,@range        = 'Use$A:B'
         ,@clr_first    = 1
         ,@expect_rows  = 1

      --------------------------------------------------------------------------------------------
      -- 5. Import the Distributors table
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'040: Import the Distributors table';
      EXEC dbo.sp_bulk_import 
          @import_file  = 'D:\Dev\Farming\Data\Distributors.xlsx'
         ,@table        = 'DistributorStaging'
         ,@range        = 'Distributors$A:H'
         ,@clr_first    = 1
         ,@expect_rows  = 1

      --------------------------------------------------------------------------------------------
      -- 6. Import the PathogenTypeStaging table
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'045: Import the PathogenTypeStaging table';
      EXEC dbo.sp_bulk_import 
          @import_file  = 'D:\Dev\Farming\Data\PathogenType.xlsx'
         ,@table        = 'PathogenTypeStaging'
         ,@range        = 'PathogenType$A:B'
         ,@clr_first    = 1
         ,@expect_rows  = 1

      --------------------------------------------------------------------------------------------
      -- 7. Import the Pathogen table
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'050: Import the Pathogen table';
      DELETE FROM CropPathogen;
      DELETE FROM PathogenChemical;

      EXEC dbo.sp_bulk_import 
          @import_file  = 'D:\Dev\Farming\Data\Pathogen.xlsx'
         ,@table        = 'Pathogen'
         ,@range        = 'Pathogen$A:B'
         ,@clr_first    = 1
         ,@expect_rows  = 1

      --------------------------------------------------------------------------------------------
      -- 8. Import the TypeStaging table
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'055: Import the TypeStaging table';
      EXEC sp_import_TypeStaging 'D:\Dev\Farming\Data\Type.xlsx';

      --------------------------------------------------------------------------------------------
      -- 9. Post condition checks
      --------------------------------------------------------------------------------------------
      EXEC sp_chk_tbl_populated 'ActionStaging';
      EXEC sp_chk_tbl_populated 'Distributor';
      EXEC sp_chk_tbl_populated 'ForeignKey';
      EXEC sp_chk_tbl_populated 'Import';
      EXEC sp_chk_tbl_populated 'Pathogen';
      EXEC sp_chk_tbl_populated 'PathogenTypeStaging';
      EXEC sp_chk_tbl_populated 'TableDef';
      EXEC sp_chk_tbl_populated 'TableType';
      EXEC sp_chk_tbl_populated 'TypeStaging';
      EXEC sp_chk_tbl_populated 'UseStaging';

      --------------------------------------------------------------------------------------------
      -- Completed processing OK
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'995: Completed processing OK';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving OK';
   RETURN @RC;
END
/*
---------------------------------------------------------------------
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_009_sp_import_static_data';
---------------------------------------------------------------------
EXEC sp_reset_CallRegister;
EXEC sp_clear_staging_tables 1;
EXEC sp_import_typeStaging 'D:\Dev\Repos\Farming\Data\Type.xlsx';
EXEC sp_import_static_data;
SELECT * FROM PathogenStaging
---------------------------------------------------------------------
*/

GO
GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =======================================================================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2024
-- Description: clear out staging and main tables, S1 and S2, then import the static data
--
-- PRECONDITIONS: none
--
-- POSTCONDITIONS:
-- POST 01: UseStaging and Use tables populated
-- =======================================================================================
ALTER PROCEDURE [dbo].[sp_main_import_stage_01_imp_sta_dta]
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35)   = 'MAIN_IMPRT_STG_01'

   BEGIN TRY
      EXEC sp_log 1, @fn, '00: starting';
      EXEC sp_register_call @fn;
      EXEC sp_import_ForeignKey_XL 'D:\Dev\Repos\Farming\Data\ForeignKey.xlsx', 'Sheet1$';
      EXEC sp_log 2, @fn,'05: clearout all tables and import Actions and Uses';
      EXEC sp_log 2, @fn,'102: truncate the main tables';

      --------------------------------------------------------------------------------------------
      -- import all static data tables:
      -- ActionStaging, UseStaging, PathogenTypeStaging, PathogenPathogenTypeStaging, TypeStaging
      -- Also the Distributors table
      --------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'20: calling sp_import_static_data';
      EXEC sp_import_static_data;

      --------------------------------------------------------------------------------
      -- Merge the Use Table
      EXEC sp_log 2, @fn,'30:Merge use table';
      --------------------------------------------------------------------------------
      DELETE FROM [use];
      MERGE [use]       AS target
      USING  useStaging AS S
      ON target.use_nm = s.use_nm
      WHEN NOT MATCHED BY target THEN
      INSERT (  use_id,  use_nm)
      VALUES (s.use_id, s.use_nm)
      WHEN NOT MATCHED BY SOURCE
      THEN DELETE
      ;

      ---------------------------------------------------------------------
      -- Postconditon checks: POST 01: UseStaging and Use tables populated
      ---------------------------------------------------------------------
      EXEC sp_chk_tbl_populated 'UseStaging';
      EXEC sp_chk_tbl_populated 'Use';
      ---------------------------------------------------------------------
      -- ASSERTION: POST 01: UseStaging and Use tables populated
      ---------------------------------------------------------------------
      EXEC sp_log 1, @fn, '80:processing complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '99: leaving, OK';
END
/*
EXEC sp_main_import_stage_01_imp_sta_dta;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =========================================================================
-- Author:      Terry Watts
-- Create date: 15-OCT-2023
-- Description: helper rtn to update s1 and record the update count
--              Handles errors from sp_executesql by chk the ret
--              Doubles up single quotes
-- =========================================================================
ALTER PROCEDURE [dbo].[sp_fixup_s1_preprocess_hlpr]
    @field     NVARCHAR(60)
   ,@key       NVARCHAR(200)
   ,@value     NVARCHAR(200)
   ,@ndx       INT    = NULL        OUTPUT
   ,@fixup_cnt INT    = NULL        OUTPUT
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
    @fn        NVARCHAR(35)   = 'FIXUP S1 PREPROC HLPR:'
   ,@sql       NVARCHAR(MAX)
   ,@row_count INT
   ,@ret       INT
   ,@ndx_str   NVARCHAR(35)
   ,@msg       NVARCHAR(200)

   EXEC sp_log 1, @fn,'01: starting
   @field    : [',@field, ']
   @key      : [',@key, ']
   @value    : [',@value, ']
   @ndx      : [',@ndx, ']
   @fixup_cnt: [',@fixup_cnt, ']
   '
   ;

   -- Double up single quotes
   SET @value = REPLACE(@value, '''', '''''')

   SET @sql = CONCAT('UPDATE staging1 SET [',@field,'] = REPLACE([', @field, '],''',@key,''',''',@value, ''') WHERE ',@field, ' LIKE ''%', @key, '%''');
   PRINT @sql;
   EXEC @ret = sp_executesql @sql;

   IF @ret <> 0
   BEGIN
      SET @msg = CONCAT('sp_executesql threw exception: ', Ut.dbo.fnGetErrorMsg());
      THROW 64541, @msg, 1;
   END

   SET @row_count =  @@ROWCOUNT;
   SET @ndx_str = CONCAT(Ut.dbo.fnPadLeft2(@ndx, 2, '0'),' ');
   SET @msg = CONCAT(@field, ': replaced ''',@key,''' with ''', @value, '''');
   EXEC sp_log 1, @fn, @ndx_str, @msg, @row_count = @row_count;
   SET @ndx = @ndx +1
   EXEC sp_log 1, @fn,'99: leaving'
END
/*
EXEC sp_fixup_s1_preprocess;
EXEC sp_fixup_s1_preprocess_hlpr 'pathogens',' and & ', ','
EXEC sp_fixup_s1_preprocess_hlpr  'company', '"', ''''
EXEC sp_fixup_s1_preprocess_hlpr 'product', 'á', ' '
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- --------------------------------------------------------------------------------------------------------------------------=
-- Author:      Terry Watts
-- Create date: 16=JUL=2023
-- Description: does the following std preprocess:
--    1. Removing wrapping double quotes from following columns:
--       company, ingredient product, crops, entry_mode, pathogens
--    2. remove á from pathogens
--    3. pathogens: standardise whitespace [tab, line fedd, hard space] = spc
--    4. pathogens: make all double spaces => single spc
--    5. standardise null fields to default
--    6. Camel case the following columns: company, ingredient, product, uses, entry_mode
--    7. standardise ands
--
-- CHANGES:
-- 230717: _, [, ], and ^ need to be escaped, they are special characters in LIKE searches so replace [] with () here
-- 231015: factored the update sql, cunting and msg to a helper fn: sp_fixup_s1_preprocess_hlpr
-- 240121: remove double quotes from uses
-- --------------------------------------------------------------------------------------------------------------------------=
ALTER PROCEDURE [dbo].[sp_fixup_s1_preprocess]
      @fixup_cnt       INT = 0 OUT
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(35)   = 'FIXUP S1 PREPROCESS:'
      ,@row_count    INT
      ,@ndx          INT = 3
      ,@spc          NVARCHAR(1) = N' '

   BEGIN TRY
      SET NOCOUNT OFF;
      EXEC sp_log 2, @fn, '00: starting, @fixup_cnt: ',@fixup_cnt;
      EXEC sp_register_call @fn;

      --3.1  standardise whitespace line feed in fields {company, crops, entry_mode, ingredient, mrl, phi, pathogens, product, rate, uses}
      EXEC sp_log 1, @fn, '01 standardise chrs(10) in company, crops, entry_mode, ingredient, product, pathogens, rate, mrl, phi, uses}';
      EXEC sp_log 1, @fn, '01 standardise chrs(10) in company';
      UPDATE staging1 SET company   = REPLACE(company    , NCHAR(10),  ' ') WHERE company    LIKE  '%'+NCHAR(10)+'%';   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '01 standardise chrs(10) in crops, fixup_cnt:',@fixup_cnt;
      UPDATE staging1 SET crops     = REPLACE(crops      , NCHAR(10),  ' ') WHERE crops      LIKE  '%'+NCHAR(10)+'%';   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '01 standardise chrs(10) in entry_mode, fixup_cnt:',@fixup_cnt;
      UPDATE staging1 SET entry_mode= REPLACE(entry_mode       , NCHAR(10),  ' ') WHERE entry_mode       LIKE  '%'+NCHAR(10)+'%';   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '01 standardise chrs(10) in ingredient, fixup_cnt:',@fixup_cnt;
      UPDATE staging1 SET ingredient= REPLACE(ingredient , NCHAR(10),  ' ') WHERE ingredient LIKE  '%'+NCHAR(10)+'%';   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '01 standardise chrs(10) in mrl.fixup_cnt:',@fixup_cnt;
      UPDATE staging1 SET mrl       = REPLACE(mrl        , NCHAR(10),  ' ') WHERE mrl        LIKE  '%'+NCHAR(10)+'%';   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '01 standardise chrs(10) in pathogens. fixup_cnt:',@fixup_cnt;
      UPDATE staging1 SET pathogens = REPLACE(pathogens  , NCHAR(10),  ' ') WHERE pathogens  LIKE  '%'+NCHAR(10)+'%';   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '01 standardise chrs(10) in phi, fixup_cnt:',@fixup_cnt;
      UPDATE staging1 SET phi       = REPLACE(phi        , NCHAR(10),  ' ') WHERE phi        LIKE  '%'+NCHAR(10)+'%';   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '01 standardise chrs(10) in product, fixup_cnt:',@fixup_cnt;;
      UPDATE staging1 SET product   = REPLACE(product    , NCHAR(10),  ' ') WHERE product    LIKE  '%'+NCHAR(10)+'%';   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '01 standardise chrs(10) in rate, fixup_cnt:',@fixup_cnt;
      UPDATE staging1 SET rate      = REPLACE(rate       , NCHAR(10),  ' ') WHERE rate       LIKE  '%'+NCHAR(10)+'%';   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '01 standardise chrs(10) in uses, fixup_cnt:',@fixup_cnt;
      UPDATE staging1 SET uses      = REPLACE(uses       , NCHAR(10),  ' ') WHERE uses       LIKE  '%'+NCHAR(10)+'%';   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      EXEC sp_log 1, @fn, '02: removing wrapping double quotes, @fixup_cnt:',@fixup_cnt;
      EXEC sp_log 1, @fn, '03: company: removing wrapping double quotes'
      EXEC sp_fixup_s1_preprocess_hlpr  'company', '"', ''        , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_log 1, @fn, '04: ingredient: removing wrapping double quotes'
      EXEC sp_fixup_s1_preprocess_hlpr  'ingredient', '"', ''     , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_log 1, @fn, '05: product: removing wrapping double quotes'
      EXEC sp_fixup_s1_preprocess_hlpr  'product', '"', '  '      , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_log 1, @fn, '06: crops: removing wrapping double quotes'
      EXEC sp_fixup_s1_preprocess_hlpr  'crops', '"', ''          , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_log 1, @fn, '07: entry_mode: removing wrapping double quotes'
      EXEC sp_fixup_s1_preprocess_hlpr  'entry_mode', '"', ''     , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_log 1, @fn, '08: pathogens: removing wrapping double quotes'
      EXEC sp_fixup_s1_preprocess_hlpr  'pathogens', '"', ''      , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_log 1, @fn, '09: rate: removing wrapping double quotes'
      EXEC sp_fixup_s1_preprocess_hlpr  'rate', '"', ''           , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_log 1, @fn, '10: mrl: removing wrapping double quotes'
      EXEC sp_fixup_s1_preprocess_hlpr  'mrl', '"', ''            , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_log 1, @fn, '11: phi: removing wrapping double quotes'
      EXEC sp_fixup_s1_preprocess_hlpr  'phi', '"', ''            , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_log 1, @fn, '12: registration: removing wrapping double quotes'
      EXEC sp_fixup_s1_preprocess_hlpr  'registration', '"', ''   , @ndx OUT, @fixup_cnt OUT;

      -- 240121: remove double quotes from uses
      EXEC sp_fixup_s1_preprocess_hlpr  'uses'        , '"', ''   , @ndx OUT, @fixup_cnt OUT;

      -- 240121: replace uses 'Insecticide/fu ngicide' with 'Insecticide,Fungicide' 'Insecticide/fu ngicide'
      EXEC sp_fixup_s1_preprocess_hlpr  'uses'        , 'Insecticide/fu ngicide', 'Insecticide,Fungicide'   , @ndx OUT, @fixup_cnt OUT;
      UPDATE staging1 SET uses = 'Insecticide,Fungicide' WHERE uses LIKE  '%Insecticide/fu ngicide%';
      SET @row_count =  @@ROWCOUNT;
      SET @fixup_cnt = @fixup_cnt + @row_count;

      -- 22. pathogens: á
      EXEC sp_log 1, @fn, @ndx, '. replacing á with spc'; SET @ndx = @ndx +1;
      EXEC sp_fixup_s1_preprocess_hlpr 'pathogens', 'á', @spc     , @ndx OUT, @fixup_cnt OUT;
   
      EXEC sp_fixup_s1_preprocess_hlpr 'product', 'á', ' '     , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_fixup_s1_preprocess_hlpr 'company', 'á', ' '     , @ndx OUT, @fixup_cnt OUT;

      -- 3. pathogens: standardise whitespace from [tab, line feed, hard space] = spc
      UPDATE staging1 SET pathogens = REPLACE(pathogens, NCHAR(9) ,  ' ') WHERE pathogens LIKE  '%'+NCHAR(9) +'%';
      SET @row_count =  @@ROWCOUNT;
      SET @fixup_cnt = @fixup_cnt + @row_count;
   
      EXEC sp_log 1, @fn, '06: pathogens: standardised whitespace: tab', @row_count = @row_count;

      UPDATE staging1 SET pathogens = REPLACE(pathogens, NCHAR(13),  ' ') WHERE pathogens LIKE  '%'+NCHAR(13)+'%';
      SET @row_count =  @@ROWCOUNT;
      SET @fixup_cnt = @fixup_cnt + @row_count;
      EXEC sp_log 1, @fn, '05: pathogens: standardised whitespace: CHAR(13)', @row_count = @row_count;

      UPDATE staging1 SET pathogens = REPLACE(pathogens, NCHAR(160), ' ') WHERE pathogens LIKE  '%'+NCHAR(160)+'%';
      SET @row_count =  @@ROWCOUNT;
      SET @fixup_cnt = @fixup_cnt + @row_count;
      EXEC sp_log 1, @fn, '05: pathogens: standardised whitespace: CHAR(160)', @row_count = @row_count;

      -- 3.2 (was 7) standardise ands
      EXEC sp_log 1, @fn, '7. standardise ands'
      -- Do this before calling fnStanardiseAnds()  because exists: 'Annual and Perennial grasses, sedges and and Broadleaf weeds'
      -- Do before making comma space consistent in pathogens and crops
      --UPDATE dbo.staging1 SET pathogens = REPLACE(pathogens, ' and & ', ',') WHERE pathogens like '% and & %';
      --SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_fixup_s1_preprocess_hlpr 'pathogens',' and & ', ',' , @ndx OUT, @fixup_cnt OUT;

      -- 04-JUL-2023 Added Stanardise Ands (for comparability with staging2)
      UPDATE dbo.staging1 SET pathogens = dbo.fnStanardiseAnds (pathogens) WHERE pathogens LIKE '%&%' OR pathogens LIKE '% and ' OR  pathogens LIKE '% AND '; 
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      -- Remove duplicate ands
      --UPDATE dbo.staging1 SET pathogens = REPLACE(pathogens,' and and ',' and ') WHERE pathogens like '% and and %'
      --SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_fixup_s1_preprocess_hlpr 'pathogens',' and and ',' and ' , @ndx OUT, @fixup_cnt OUT;

      -- 3.5  make comma space consistent in pathogens and crops
      EXEC sp_log 1, @fn, '8. standardise comma spcs in pathogens and crops';
      --UPDATE staging1 SET pathogens = dbo.fnReplace(dbo.fnReplace(pathogens, N', ', N','), N' ,', N',') WHERE pathogens like '%, %' OR pathogens like '% ,%';
      EXEC sp_fixup_s1_preprocess_hlpr 'pathogens',', ', ','      , @ndx OUT, @fixup_cnt OUT;
      --update staging2 set pathogens = Replace(Pathogens, ', ,', ',') WHERE Pathogens LIKE '%, ,%';
      EXEC sp_fixup_s1_preprocess_hlpr 'pathogens',', ,', ','     , @ndx OUT, @fixup_cnt OUT;
      --update staging2 set pathogens = Replace(Pathogens, ', ,', ',') WHERE Pathogens LIKE ', ,%';
      EXEC sp_fixup_s1_preprocess_hlpr 'pathogens', ', ,', ','    , @ndx OUT, @fixup_cnt OUT;
      --update staging2 set pathogens = Replace(Pathogens, ',,', ',')  WHERE Pathogens LIKE '%,,%';
      EXEC sp_fixup_s1_preprocess_hlpr 'pathogens', ',,', ','     , @ndx OUT, @fixup_cnt OUT;
      --update staging2 set pathogens = Replace(Pathogens, ', ', ',')  WHERE Pathogens LIKE  '%, %';
      EXEC sp_fixup_s1_preprocess_hlpr 'pathogens', ', ', ','     , @ndx OUT, @fixup_cnt OUT;
      --update staging2 set pathogens = Replace(Pathogens, ' ,', ',')  WHERE Pathogens LIKE '% ,%';
      EXEC sp_fixup_s1_preprocess_hlpr 'pathogens',' ,', ','      , @ndx OUT, @fixup_cnt OUT;

      --SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      -- fixup Crops 
      EXEC sp_log 1, @fn, '8.5. Fixup crops';
      EXEC sp_log 1, @fn, '8.6. crops: standardise comma spc = not counting fixups';
      UPDATE staging1 SET crops = dbo.fnReplace(dbo.fnReplace(crops, N', ', N','), N' ,', N',') WHERE crops LIKE '%, %' OR crops LIKE '% ,%';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '8.7. crops: replace char(100 with spc'
      UPDATE staging1 SET crops = REPLACE(crops, NCHAR(10),  ' ') WHERE crops LIKE '%'+NCHAR(10)+'%';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      -- fixup phi
      EXEC sp_log 1, @fn, '8.6. Fixup phi';
      EXEC sp_fixup_s1_preprocess_hlpr 'phi','  ', ' '      , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_fixup_s1_preprocess_hlpr 'phi',';', ','      , @ndx OUT, @fixup_cnt OUT;

      -- 3.6: remove double spaces in crops and pathogens, phi
      EXEC sp_log 1, @fn, '9. remove double spaces in crops and pathogens';
      EXEC sp_fixup_s1_preprocess_hlpr 'crops', '  ', ' '     , @ndx OUT, @fixup_cnt OUT;
      EXEC sp_fixup_s1_preprocess_hlpr 'pathogens', '  ', ' '     , @ndx OUT, @fixup_cnt OUT;

      -- 10  _, [, ], and ^ need to be escaped, they are special characters in LIKE searches 
      -- replace [] with () here
      EXEC sp_log 1, @fn, '10. remove square bracketes [] in crops';
      UPDATE staging1 set crops = Replace(crops, '[', '(') WHERE crops LIKE '%\[%' ESCAPE NCHAR(92);
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      UPDATE staging1 set crops = Replace(crops, ']', ')') WHERE crops LIKE '%\]%' ESCAPE NCHAR(92);
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      -- 11. standardise null fields to default sht, row
      EXEC sp_log 1, @fn, '11. standardise null fields to default';
      UPDATE staging1 SET formulation_type   = ''                   WHERE formulation_type   IS NULL;
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      UPDATE staging1 SET toxicity_category  = ''                   WHERE toxicity_category  IS NULL;
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      UPDATE staging1 SET entry_mode         = ''                   WHERE entry_mode         IS NULL;
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      UPDATE staging1 SET crops              = ''                   WHERE crops              IS NULL;
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      UPDATE staging1 SET pathogens          = ''                   WHERE pathogens          IS NULL;
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      -- 12. Camel case the following columns: company, ingredient, product, uses, entry_mode
      EXEC sp_log 1, @fn, '12. Camel case the following columns: company, ingredient, product, uses, entry_mode';

      UPDATE staging1 SET 
         company      = Ut.dbo.fnCamelCase(company   )
       , ingredient   = Ut.dbo.fnCamelCase(ingredient)
       , product      = Ut.dbo.fnCamelCase(product   )
       , uses         = Ut.dbo.fnCamelCase(uses      )
       , entry_mode   = Ut.dbo.fnCamelCase(entry_mode)
      ;
   END TRY
   BEGIN CATCH
      DECLARE @msg NVARCHAR(500);
      SET @msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, '50: caught exception: ',@msg;
      throw;
   END CATCH

   EXEC sp_log 2, @fn, '99: leaving OK, @fixup_cnt: ',@row_count = @fixup_cnt;
END
/*
EXEC sp_fixup_s1_preprocess;
SELECT distinct uses from Staging1 ORDER by uses
select stg1_id, uses FROM Staging1 WHERE uses like '%/fu%ngicide%'
select stg1_id, uses FROM Staging1 WHERE uses like '%/fu ngicide%'
select stg1_id, uses FROM Staging1 WHERE uses like '%/fu'+NCHAR(10)+'ngicide%'
------------------------------------------------------------------------------------------------=
DECLARE 
 @row_count    INT
,@ndx          INT = 1
,@fixup_cnt    INT = 0
EXEC sp_fixup_s1_preprocess_hlpr 'pathogens', 'á', ' ', @ndx OUT, @fixup_cnt OUT;

(2 rows affected)
(2 rows affected)
INFO   : FIXUP S1 PREPROCESS:          : 11. standardise null fields to default
(86 rows affected)
(0 rows affected)
ERROR  : MN_IMPORT_RTN                 : 50: caught exception: @stage_id: 2 error:564298 proc: sp_staging1_on_update_trigger line :16 msg: sp_staging1_on_insert_trigger: caught update of = in toxicity_category sev: 16 st:1, #fixups so far: 0 , ret: -1
Msg 564298, Level 16, State 1, Procedure sp_staging1_on_update_trigger, Line 16 [Batch Start Line 268]
sp_staging1_on_insert_trigger: caught update of = in toxicity_category
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 03-AUG-2023
-- Description: Fixup for the rate column 
-- =============================================
ALTER PROCEDURE [dbo].[sp_fixup_s1_rate]
      @fixup_cnt       INT OUT --- = NULL 
AS
BEGIN
   DECLARE
       @fn              NVARCHAR(35) = 'FIXUP STG1 RATE'
      ,@fixup_delta     INT = 0

   SET NOCOUNT OFF;

   BEGIN TRY
      EXEC sp_log 2, @fn, '01: starting, @fixup_cnt: ',@fixup_cnt;
      EXEC sp_register_call @fn;

      UPDATE staging1 SET rate = NULL where rate in ('-','_');
      SET @fixup_delta = @fixup_delta + @@ROWCOUNT;
   END TRY
   BEGIN CATCH
      DECLARE @error_msg NVARCHAR(MAX);
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, ' caught exception: ', @error_msg, ' , @fixup_cnt: ',@fixup_cnt;
      THROW;
   END CATCH

   SET  @fixup_cnt = @fixup_cnt + @fixup_delta ;
   EXEC sp_log 2, @fn, '99: leaving OK, @fixup_delta: ',@fixup_delta;
END
/*
SELECT distinct rate from staging1 ORDER BY rate
EXEC sp_fixup_s1
SELECT id, product, rate FROM staging1 where rate LIKE  '%tbsp./3-5 L water%' ORDER by rate, id
SELECT id, product, rate FROM staging1 where id in
(581,601,840,1004,1256,1446,1633,2518,3261,3829,4070,4292,4767,5676,5825,6245,7857,7918,7933
,8980,9209,9411,9745,10014,10174,11915,12573,13142,13254,13491,14178,14250,14749,14760,15194
,15406,17254,17669,18107,18247,18762,19128,19277,20238,21240,21247,22107,22362,22820,23130,23494
,23573,23732,24077,24263,24478,24486,24840,25283,25563)

SELECT id, product, rate FROM staging1 where rate LIKE  '%-1¢%Tbsp/16 L of water%'
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:		 Terry Watts
-- Create date: 01-JUL-2023
-- Description: Helper fn to test a fixup
-- operation
-- =============================================
ALTER PROCEDURE [dbo].[sp_chk_fixup_clause]
    @fixup_clause NVARCHAR(200)
   ,@col          NVARCHAR(60) = 'pathogens'
   ,@table        NVARCHAR(60) = 'staging2'
   
AS
BEGIN
   DECLARE 
       @cnt INT
      ,@msg NVARCHAR(200)
      ,@sql NVARCHAR(MAX)

   SET NOCOUNT OFF;

   SET @sql = CONCAT('SELECT @cnt = COUNT(*) FROM ',@table, ' WHERE ', @col, ' LIKE ''', @fixup_clause, '''');
   PRINT CONCAT('sql: ', @sql);

   EXEC sp_executesql 
      @sql
      ,N'@cnt INT OUT'
      ,@cnt OUT;
   
   IF @cnt > 0 
   BEGIN
      SET @msg = CONCAT(' there are ', @cnt,' instances of [', @fixup_clause, '] in ', @table);
      THROW 50130, @msg, 1;
   END

   PRINT CONCAT('[',@fixup_clause, '] does not exist in ', @table);
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:      Terry Watts
-- Create date: 01-JUL-2023
-- Description: deletes rows from the given table
-- where the col @col is like @delete_clause
-- =============================================
CREATE	PROC [dbo].[sp_delete]
    @delete_clause   NVARCHAR(500) 
   ,@col             NVARCHAR(60) = 'pathogens'
   ,@table           NVARCHAR(60) = 'staging2'
AS
BEGIN
   DECLARE 
       @cnt INT
      ,@msg NVARCHAR(200)
      ,@sql NVARCHAR(MAX)

   SET NOCOUNT OFF;

   PRINT CONCAT('Removing ',@delete_clause,' from col:[', @col, ' table: [', @table, ']');
   SET @sql = CONCAT('DELETE FROM [', @table, '] WHERE [', @col, '] LIKE ''', @delete_clause, '''');
   PRINT @sql;

   EXEC sp_executesql 
      @sql
      ,N'@cnt INT OUT'
      ,@cnt OUT;
   
   PRINT CONCAT('Deleted ', @@ROWCOUNT, ' rows');
   EXEC sp_chk_fixup_clause @delete_clause, @col,@table;
END
/*
EXEC sp_delete '%NAME OF COMPANY%', 'company', 'staging2'
DELETE FROM [pathogens] WHERE [company] LIKE '%NAME OF COMPANY%'
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:		 Terry Watts
-- Create date: 16-JUL-2023
-- Description: Removes the page headers and 
-- other occasional headers
-- =============================================
ALTER PROCEDURE [dbo].[sp_fixup_s1_rem_hdrs]
      @fixup_cnt       INT = NULL OUT
AS
BEGIN
   DECLARE
       @fn              NVARCHAR(35) = 'FIXUP STG1 REM HDRS'

   BEGIN TRY

      IF @fixup_cnt IS NULL SET @fixup_cnt = Ut.dbo.fnGetSessionContextAsInt(N'fixup count');
      EXEC sp_log 2, @fn, '01: starting, @fixup_cnt: ',@fixup_cnt
	   SET NOCOUNT OFF;
     -- IF EXISTS (SELECT 1 FROM staging1 WHERE pathogens like '% and and %') THROW 60000,'AND AND present',1

      EXEC sp_log 0, @fn, 'Remove page header rows'
      EXEC sp_delete '%NAME OF COMPANY%'            , 'company', 'staging1';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      EXEC sp_delete '%REPUBLIC OF THE PHILIPPINES%', 'company', 'staging1';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      EXEC sp_log 0, @fn, 'Removing rows where company LIKE REPUBLIC OF THE PHILIPPINES'
      EXEC sp_delete '%REPUBLIC OF THE PHILIPPINES%', 'company', 'staging1';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      EXEC sp_log 0, @fn, 'Removing rows where company LIKE DEPARTMENT OF AGRICULTURE'
      EXEC sp_delete '%NAME OF COMPANY%'     , 'company', 'staging1';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      EXEC sp_log 0, @fn, 'Removing rows where company LIKE DEPARTMENT OF AGRICULTURE'
      EXEC sp_delete '%Department Of Agriculture%'     , 'company', 'staging1';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      EXEC sp_log 0, @fn, 'Removing rows where company LIKE FERTILIZER AND PESTICIDE AUTHORITY'
      EXEC sp_delete '%FERTILIZER AND PESTICIDE AUTHORITY%', 'company', 'staging1';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      EXEC sp_log 0, @fn, 'sp_fixup_staging1: Removing rows where company LIKE LIST OF REGISTERED AGRICULTURAL PESTICIDES'
      EXEC sp_delete '%LIST OF REGISTERED AGRICULTURAL PESTICIDES%', 'company', 'staging1';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      EXEC sp_log 0, @fn, 'DELETE ''as of %'' rows'
      EXEC sp_delete '%as of %', 'company', 'staging1';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 0, @fn, 'DELETE null company,ingredient,product'
      DELETE FROM staging1 WHERE company IS NULL AND product IS NULL AND ingredient IS NULL;
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   END TRY
   BEGIN CATCH
      DECLARE @error_msg NVARCHAR(MAX)
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, ' caught exception: ', @error_msg, ' , @fixup_cnt: ',@fixup_cnt;
      THROW;
   END CATCH
      
   EXEC sp_log 2, @fn, '99: leaving, @fixup_cnt: ',@fixup_cnt
END

/*
EXEC sp_fixup_s1_rem_hdrs
SELECT * FROM staging1 where pathogens LIKE  '% and and %'
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==========================================================
-- Author:      Terry Watts
-- Create date: 30-OCT-2023
-- Description: Fixup specific errors for the S1.entry_mode column (actions)
--
-- PRECONDITIONS: none
--
-- POSTCONDITIONS:
-- POST 01:
-- ==========================================================
ALTER PROCEDURE [dbo].[sp_fixup_s1_entry_mode]
      @fixup_cnt       INT OUT --- = NULL
AS
BEGIN
   DECLARE
       @fn              NVARCHAR(35) = 'FIXUP STG1 ENTRY_MODE'
      ,@row_cnt         INT = 0     -- per update row count
      ,@fixup_delta     INT = 0     -- per this rtn (all updates)
      ;

   SET NOCOUNT OFF;

   BEGIN TRY
      EXEC sp_log 2, @fn, '01: starting, @fixup_cnt: ',@fixup_cnt;
      EXEC sp_register_call @fn;

      --Chlorothalonil+tetraconazole -> Systemic,Contact
      UPDATE staging1 SET entry_mode = 'Systemic,Contact' where ingredient = 'Chlorothalonil+tetraconazole';
      SET @row_cnt = @@ROWCOUNT;
      EXEC sp_log 2, @fn, '05: Chlorothalonil+tetraconazole	-> Systemic,Contact: ', @row_count=@row_cnt;
      SET @fixup_delta = @fixup_delta + @row_cnt;
   END TRY
   BEGIN CATCH
      DECLARE @error_msg NVARCHAR(MAX)
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, ' caught exception: ', @error_msg, ' , @fixup_cnt: ',@fixup_cnt;
      THROW;
   END CATCH
      
   SET  @fixup_cnt = @fixup_cnt + @fixup_delta;
   EXEC sp_log 2, @fn, '99: leaving OK, @fixup_delta: ',@fixup_delta;
END

/*
SELECT distinct rate from staging1 ORDER BY rate
EXEC sp_fixup_s1
SELECT id, product, rate FROM staging1 where rate LIKE  '%tbsp./3-5 L water%' ORDER by rate, id
SELECT id, product, rate FROM staging1 where id in
(581,601,840,1004,1256,1446,1633,2518,3261,3829,4070,4292,4767,5676,5825,6245,7857,7918,7933
,8980,9209,9411,9745,10014,10174,11915,12573,13142,13254,13491,14178,14250,14749,14760,15194
,15406,17254,17669,18107,18247,18762,19128,19277,20238,21240,21247,22107,22362,22820,23130,23494
,23573,23732,24077,24263,24478,24486,24840,25283,25563)

SELECT id, product, rate FROM staging1 where rate LIKE  '%-1¢%Tbsp/16 L of water%'
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ---------------------------------------------------------------------------------------------------------------------
-- Author:      Terry Watts
-- Create date: 29-JAN-2024
-- Description: does the following std preprocess:
--    1. fixup spelling errors:
--    [Perrenial] -> [Perennial]
--
-- RESPONSIBILITIES:
--  Fixup:
--    1. spelling errors:
--       [Perrenial] -> [Perennial]
--
-- CALLED BY: sp_fixup_s1
-- CHANGES:
-- ---------------------------------------------------------------------------------------------------------------------
ALTER PROCEDURE [dbo].[sp_fixup_s1_pathogens]
      @fixup_cnt       INT = 0 OUT
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(35)= 'FIXUP S1 PATHOGENS:'
      ,@row_count    INT
      ,@ndx          INT         = 3
      ,@spc          NVARCHAR(1) = N' '

      SET NOCOUNT OFF;

   BEGIN TRY
      EXEC sp_log 2, @fn, '01: starting';
      EXEC sp_register_call @fn;

      -- ------------------------------------------------------------------------------------------------
      --    1. fixup spelling errors: 
      -- ------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '02: fixup spelling errors';
      --       [Perrenial] -> [Perennial]
      UPDATE staging1 SET pathogens   = REPLACE(pathogens    , 'Perrenial', 'Perennial') WHERE company    LIKE  '%Perrenial%';
      SET @row_count = @@ROWCOUNT
      SET @fixup_cnt = @fixup_cnt + @row_count;
      EXEC sp_log 1, @fn, '04: fixup [Perrenial] -> [Perennial] updated ', @row_count, ' rows';

      EXEC sp_log 1, @fn, '20: fixup spelling errors completed';

   END TRY
   BEGIN CATCH
      DECLARE @msg NVARCHAR(500);
      SET @msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, '50: caught exception: ',@msg;
      throw;
   END CATCH

   EXEC sp_log 2, @fn, '99: leaving OK, @fixup_cnt: ',@row_count = @fixup_cnt;
END
/*
EXEC sp_fixup_s1_pathogens;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ================================================================================================
-- Author:      Terry Watts
-- Create date: 16-JUL-2023
-- Description: perform the stage 1 postcondition checks on the staging1 table
--
-- PRECONDITIONS: none
--
-- POSTCONDITIONS:
-- POST 01: no 'double and'
-- POST 02: no double quotes in flds: {company, ingredient, product, crops, entry_mode, pathogens, uses}
-- POST 03: no null fields tests in {company, ingredient, product, concentration, crops, formulation_type
--    uses, pathogens, toxicity_category, registrations, expiry dates, entry_modes)
--
-- CHANGES:
-- 21-JAN-2024 Added check for no double quotes in the uses field 
-- ================================================================================================
ALTER PROCEDURE [dbo].[sp_fixup_s1_postcondition_chks] 
AS
BEGIN
   DECLARE
       @fn              NVARCHAR(30)   = 'FIXUP STG1 CHKS'
      ,@RC              INT            = 0
      ,@result_msg      NVARCHAR(500)  = ''
      ,@cnt             INT            = 0
      ,@default_fld_val NVARCHAR(15)   = '*** UNKNOWN ***'
      ,@sql             NVARCHAR(MAX)  = ''

   EXEC sp_log 2, @fn, '01: starting'
   -- POST 01: no 'double and' in the following fields: {company, ingredient, product, crops, entry_mode, pathogens, uses}
   EXEC sp_log 2, @fn, 'POST 01: no ''double and'' in the following fields: {company, ingredient, product, crops, entry_mode, pathogens, uses}'
   IF EXISTS (SELECT 1 FROM staging1 WHERE pathogens like '% and and %') THROW 60400,'AND AND present in S1.pathogens',1

   -- POST 02: no double quotes in the following fields: {company, ingredient, product, crops, entry_mode, pathogens, uses}
   EXEC sp_log 2, @fn, 'POST 01: no double quotes test in the following fields: {company, ingredient, product, crops, entry_mode, pathogens, uses}'
   SELECT @cnt = COUNT(*) FROM staging1  WHERE company LIKE '%"%'
   IF @cnt > 0 Throw 50130, '" still exists in s1.company', 1
   SELECT @cnt = COUNT(*) FROM staging1  WHERE ingredient LIKE '%"%'
   IF @cnt > 0 Throw 50131, '" still exists in s1.ingredient', 1
   SELECT @cnt = COUNT(*) FROM staging1  WHERE product LIKE '%"%'
   IF @cnt > 0 Throw 50132, '" still exists in s1.product', 1
   SELECT @cnt = COUNT(*) FROM staging1  WHERE crops LIKE '%"%'
   IF @cnt > 0 Throw 50133, '" still exists in s1.crops', 1
   SELECT @cnt = COUNT(*) FROM staging1  WHERE entry_mode LIKE '%"%'
   IF @cnt > 0 Throw 50134, '" still exists in s1.entry_mode', 1
   SELECT @cnt = COUNT(*) FROM staging1  WHERE pathogens LIKE '%"%'
   IF @cnt > 0 Throw 50135, '" still exists in s1.pathogens', 1
   SELECT @cnt = COUNT(*) FROM staging1  WHERE uses LIKE '%"%'
   IF @cnt > 0 Throw 50135, '" still exists in s1.uses', 1

   -- POST 03.1,: no null fields tests in {company, ingredient, product}
   EXEC sp_log 2, @fn, 'POST 03.1: no null fields tests in {company, ingredient, product}'
   SELECT @cnt = COUNT(*) FROM staging1 WHERE company           IS NULL;         
   IF @cnt > 0 EXEC sp_log 4, @fn, '50: there are ', @cnt, ' NULL companies in S1';
   SELECT @cnt = COUNT(*) FROM staging1 WHERE ingredient        IS NULL;       
   IF @cnt > 0 EXEC sp_log 4, @fn, '50: there are ', @cnt, ' NULL ingredients in S1';
   SELECT @cnt = COUNT(*) FROM staging1 WHERE product           IS NULL;          
   IF @cnt > 0  EXEC sp_log 4, @fn, '50: there are ', @cnt, ' NULL products in S1';

   -- POST 03.2,: no null fields in {company, ingredient, product, concentration, crops, formulation_type, uses, pathogens, toxicity_category}
   EXEC sp_log 2, @fn, 'POST 03.2: null fields tests in concentration, crops, formulation_type, uses, pathogens, toxicity_category'
   SELECT @cnt = COUNT(*) FROM staging1 WHERE concentration     IS NULL;    
   IF @cnt > 0 EXEC sp_log 3, @fn, '50: there are ', @cnt, ' NULL concentration values in S1'; -- WARNING ONLY
   SELECT @cnt = COUNT(*) FROM staging1 WHERE formulation_type  IS NULL; 
   IF @cnt > 0 EXEC sp_log 4, @fn, '50: there are ', @cnt, ' NULL formulation_types in S1';
   SELECT @cnt = COUNT(*) FROM staging1 WHERE uses              IS NULL;             
   IF @cnt > 0 EXEC sp_log 4, @fn, '50: there are ', @cnt, ' NULL uses in S1';
   SELECT @cnt = COUNT(*) FROM staging1 WHERE toxicity_category IS NULL;
   IF @cnt > 0 EXEC sp_log 4, @fn, '50: there are ', @cnt, ' NULL toxicity_categories in S1';

   -- POST 03.3,: no null fields in {registrations, expiry dates, entry_modes}
   EXEC sp_log 2, @fn, 'POST 03.3: no null fields in {registrations, expiry dates, entry_modes}'
   SELECT @cnt = COUNT(*) FROM staging1 WHERE registration     IS NULL;    
   IF @cnt > 0 EXEC sp_log 4, @fn, '50: there are ', @cnt, ' NULL registrations in S1';

   SELECT @cnt = COUNT(*) FROM staging1 WHERE entry_mode            IS NULL;           
   IF @cnt > 0 EXEC sp_log 4, @fn, '50: there are ', @cnt, ' NULL entry_mode in S1';

   SELECT @cnt = COUNT(*) FROM staging1 WHERE expiry            IS NULL;           
   IF @cnt > 0 EXEC sp_log 4, @fn, '50: there are ', @cnt, ' NULL expiry dates in S1';
   
   --SELECT @cnt = COUNT(*) FROM staging1 WHERE entry_mode        IS NULL;       
   --IF @cnt > 0 EXEC sp_log 4, @fn, '50: there are ', @cnt, ' NULL entry_modes';
   EXEC sp_log 2, @fn, '99: leaving, all ok, rc:', @rc,' msg:[', @result_msg,']';
END
/*
EXEC sp_fixup_s1_chks
EXEC sp__main_import_pesticide_register @import_file = 'D:\Dev\Repos\Farming\Data\Exports Ph DepAg Registered Pesticides LRAP-230721.pdf\LRAP-20230721.tsv.txt', @mode='LOG_LEVEL:1', @stage = 0 -- full
select * FROM staging1 where company is null
SELECT * FROM Staging1

*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===================================================================================
-- Author:      Terry Watts
-- Create date: 26-JUN-2023
-- Description: Tidies up staging 1 after import so that it is comparable to staging2
--
-- RESPONSIBILITIES:
-- Remove:
-- the page header rows
-- wrapping quotes
-- standarise commas and &
-- spelling errors:
--    [Perrenial] -> [Perennial]
--
-- ERROR HANDLING by exception handling
--
-- PRECONDITIONS: none
--
-- RETURNS 
--       (0 if success and @result_msg='') OR Error code and result_msg=error message
--
-- POSTCONDITIONS:
-- POST 01: no occasional page headers as in LDAP 221008 version
-- POST 02: no wrapping quotes in the following fields {}         see sp_fixup_s1_preprocess
-- POST 03: no double quotes in flds: {company, ingredient, product, crops, entry_mode, pathogens, uses}
-- POST 04: no null fields tests in {company, ingredient, product, concentration, crops, formulation_type
--    uses, pathogens, toxicity_category, registrations, expiry dates, entry_modes)
-- POST 05: camel case the following fields {}                    see sp_fixup_s1_preprocess
-- POST 06: no double spaces in the following fields: {company, ingredient, product, crops, entry_mode, pathogens, uses}
-- POST 07: Fixup entry mode (Actions) issues                     see sp_fixup_s1_entry_mode
-- POST 08: Fixup Rate issues                                     see sp_fixup_s1_rate
-- POST 09: see sp_fixup_s1_chks
-- POST 10: no 'double and'
-- POST 11: no spelling errors
--
-- CHANGES:
-- 02-JUL-2023 Added CamelCase of various fileds (for readability)
-- 04-JUL-2023 Added Stanardise Ands (for comparability with staging2)
-- 04-JUL-2023 Added Trim [] and double quotes
-- 04-JUL-2023 pathogens: á'
-- 16-JUL-2023 refactored
-- 21-JAN-2024 replace uses, 'Insecticide/fu ngicide' with 'Insecticide,fungicide'
-- ===================================================================================
ALTER PROCEDURE [dbo].[sp_fixup_s1] @fixup_cnt INT = NULL OUTPUT
AS
BEGIN
   DECLARE
       @fn              NVARCHAR(30)   = 'FIXUP STG1'
      ,@RC              INT            = 0
      ,@result_msg      NVARCHAR(500)  = ''
      ,@cnt             INT            = 0
      ,@default_fld_val NVARCHAR(15)   = '*** UNKNOWN ***'
      ,@sql             NVARCHAR(MAX)  = ''

   EXEC sp_log 2, @fn, '01: starting';
   EXEC sp_register_call @fn;

   IF @fixup_cnt IS NULL SET @fixup_cnt = Ut.dbo.fnGetSessionContextAsInt(N'fixup count');

   EXEC sp_log 1, @fn, '02: removing occasional headers, calling: sp_fixup_s1_rem_hdrs';

   -- Remove occasional headers
   EXEC sp_fixup_s1_rem_hdrs @fixup_cnt OUT

   -- Std preprocess like removing wrapping quotes, camel case etc.
   EXEC sp_log 1, @fn, '03: removing wrapping quotes, camel casing , calling: sp_fixup_s1_preprocess';
   EXEC sp_fixup_s1_preprocess @fixup_cnt OUT;

   -- Specifics
   EXEC sp_log 1, @fn, '04: calling sp_fixup_s1_pathogens';
   EXEC sp_fixup_s1_pathogens @fixup_cnt OUT
   EXEC sp_log 1, @fn, '04: removing double spaces in company field';
   UPDATE staging1 SET company = REPLACE(company, '  ', ' ') WHERE company LIKE '%  %';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- 21-JAN-2024 replace uses, 'Insecticide/fu ngicide' with 'Insecticide,fungicide'
   UPDATE staging1 SET uses = REPLACE(uses, 'Insecticide/fu ngicide', 'Insecticide,Fungicide') WHERE uses LIKE '%Insecticide/fu ngicide%';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- Fixup entry mode (Actions) issues
   EXEC sp_log 1, @fn, '05: Fixup entry mode (Actions) issues, calling sp_fixup_s1_entry_mode';
   EXEC  sp_fixup_s1_entry_mode @fixup_cnt OUT;

   -- Fixup Rate issues
   EXEC sp_log 1, @fn, '06: Fixup Rate issues, calling sp_fixup_s1_rate';
   EXEC sp_fixup_s1_rate @fixup_cnt OUT;

   -- Checks
   EXEC sp_log 1, @fn, '90: perform post condition checks, calling sp_fixup_s1_chks';
   EXEC  dbo.sp_fixup_s1_postcondition_chks;

   EXEC sp_log 2, @fn, '99: leaving OK, @fixup_cnt: ', @fixup_cnt
END
/*
   EXEC sp_copy_staging1_s1_bak;
   EXEC sp_fixup_s1;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===================================================================================
-- Author:      Terry Watts
-- Create date: 20-JUN-2023
-- Description: copy (replaces) Staging2 with all of Staging1
--    Does some simple initital fixup. Can use S1 as a backup
-- CHANGES:
-- 231103: turned auto increment off so SET IDENTITY_INSERT ON/OFF not needed
-- 231106: increase S2 pathogens col sz from 180 to 360 - as issues in 231005 import
-- ===================================================================================
ALTER PROCEDURE [dbo].[sp_copy_s1_s2]
AS
BEGIN
   DECLARE 
       @rc   INT = 0
      ,@cnt  INT = 0
      ,@result_msg   NVARCHAR(500) = NULL
      ,@fn           NVARCHAR(500) = 'CPY_S1_S2'

   SET NOCOUNT OFF;

   BEGIN TRY
      EXEC sp_log 1, @fn, '00:starting';
      EXEC sp_register_call @fn;
      SET XACT_ABORT ON;

      EXEC sp_log 0, @fn, '01: truncating S2...';

      TRUNCATE TABLE Staging2;
      SET @rc = @@ERROR;

      IF @RC <> 0
      BEGIN
         SET @result_msg = CONCAT('stage 1 TRUNCATE TABLE Staging2; failed: ',ERROR_MESSAGE());
         EXEC sp_log 4, @fn, @result_msg;
         THROW 50600, @result_msg, 1;
      END

      EXEC sp_log 1, @fn, '03: about to copy s1 -> S2...';

      INSERT INTO dbo.staging2
      (
          stg2_id
         ,company
         ,ingredient
         ,product
         ,concentration
         ,formulation_type
         ,uses
         ,toxicity_category
         ,registration
         ,expiry
         ,entry_mode
         ,crops
         ,pathogens
         ,rate
         ,mrl
         ,phi
         ,reentry_period
         ,notes
         ,created
      )
      SELECT 
          stg1_id
         ,company
         ,ingredient
         ,product
         ,concentration
         ,formulation_type
         ,uses
         ,toxicity_category
         ,registration
         ,expiry
         ,entry_mode
         ,crops
         ,pathogens
         ,rate
         ,mrl
         ,phi
         ,reentry_period
         ,notes
         ,created
      FROM dbo.staging1;

      EXEC sp_log 1, @fn, '04: copied s1 -> S2...';
      SET @rc  = @@ERROR;
      SET @cnt = @@ROWCOUNT;

      IF @RC <> 0
      BEGIN
         SET @result_msg = CONCAT('stage 2 insert failed: ',ERROR_MESSAGE());
         EXEC sp_log 4, @fn, @result_msg;
         THROW 50601, @result_msg, 1;
      END

      EXEC sp_log 1, @fn, '05: success...';
   END TRY
   BEGIN CATCH
      DECLARE @error_msg NVARCHAR(500);
      EXEC Ut.dbo.sp_get_error_msg @error_msg OUT;
      SET @RC = -1;
      EXEC sp_log 4, @fn, '50: caught exception: ', @error_msg;
      THROW;
   END CATCH
   EXEC sp_log 1, @fn, 'leaving ok';
END
/*
EXEC sp_copy_s1_s2;
SELECT * FROM staging1;
SELECT MAX(ut.dbo.fnLen(pathogens)) FROM staging1;
SELECT stg1_id, ut.dbo.fnLen(pathogens), pathogens FROM staging1 WHERE ut.dbo.fnLen(pathogens) > 200 ORDER BY ut.dbo.fnLen(pathogens) DESC;
SELECT * FROM staging2 where pathogens LIKE '%-%';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===============================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2024
-- Description: does S1 fixup then copies S1->S2
-- ===============================================
ALTER PROCEDURE [dbo].[sp_main_import_stage_03_s1_fixup]
AS
BEGIN
   DECLARE
       @fn  NVARCHAR(35) = 'MAIN_IMPRT_STG_03'

   EXEC sp_log 1, @fn, '00: starting';
   EXEC sp_register_call @fn;
   EXEC sp_log 2, @fn, '05: calling fixup_s1';
   -----------------------------------------------------------------------------------
   -- S1 fixup
   -----------------------------------------------------------------------------------
   EXEC sp_fixup_s1;

   -----------------------------------------------------------------------------------
   -- Copiy S1->S2
   -----------------------------------------------------------------------------------
   EXEC sp_copy_s1_s2;

   EXEC sp_log 2, @fn, '10: complete';
   EXEC sp_log 1, @fn, '99: leaving';
END
/*
   EXEC sp_main_import_stage_05;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===============================================
-- Author:      Terry Watts
-- Create date: 22-OCT-2022
-- Description: fixup the entry mode in staging2
-- ===============================================
ALTER PROCEDURE [dbo].[sp_fixup_s2_action_general_hlpr]
       @index           NVARCHAR(10)
      ,@search_clause   NVARCHAR(80)
      ,@replace_clause  NVARCHAR(80)
      ,@fixup_cnt       INT OUT
      ,@must_update     BIT   = 0
AS
BEGIN
   SET NOCOUNT OFF;
   DECLARE
       @fn        NVARCHAR(35)   = 'SP_FIXUP_S2_ACTION_GEN_HPR'
      ,@sql       NVARCHAR(MAX)
      ,@delta     INT            = 0
      ,@error_msg NVARCHAR(2000)

   EXEC sp_log 1, @fn, '00: starting
 @index         :[',@index         ,']
,@search_clause :[',@search_clause ,']
,@replace_clause:[',@replace_clause,']
,@fixup_cnt     :[',@fixup_cnt     ,']
,@must_update   :[',@must_update   ,']
   ';

   SET @sql= CONCAT(
   'UPDATE staging2 SET entry_mode = REPLACE(entry_mode, ''', @search_clause, ''',''',@replace_clause,''')
   WHERE entry_mode LIKE ''%', @search_clause,'%'';'
   );

   BEGIN TRY
      PRINT @sql;
      EXEC (@sql);
      SET @delta = @@rowcount;
      SET @fixup_cnt   = @fixup_cnt + @delta;
      EXEC sp_log 1, @fn, @index,': @sql: ', @sql, @row_count = @delta;

      IF @must_update = 1 AND @delta = 0
      BEGIN
         DECLARE @msg NVARCHAR(500)
         SET @msg = CONCAT('Error: ', @fn, ' ', @sql, ' updated no rows');
         EXEC sp_log 4, @fn, @msg;
         THROW 53487, @msg, 1;
      END
      END TRY
      BEGIN CATCH
         SET @error_msg = Ut.dbo.fnGetErrorMsg();
         EXEC sp_log 4, @fn, '50: caught exception
   exception:      [', @error_msg     , ']'
   ;

         THROW;
      END CATCH
   EXEC sp_log 1, @fn, 'leaving, @row_cnt: ',@delta, ' @fixup_cnt: ',@fixup_cnt, @row_count = @delta;
END

/*
DECLARE @delta INT = 0
EXEC sp_fixup_s2_mode_hlpr '01', 'Contact/selective', 'Contact',@delta OUT;
PRINT CONCAT('@delta: ', @delta, ' rows');

SELECT stg2_id, entry_mode from Staging2 WHERE entry_mode LIKE '%Early post-emergent%';

UPDATE staging2 SET entry_mode = REPLACE(entry_mode, 'Early post-emergent','Post-emergent')
   WHERE entry_mode LIKE '%Early post-emergent%';

SELECT * FROM dbo.fnRptGetChemicalForPathogenCrop('Sigatoka', 'Banana');
SELECT * FROM dbo.fnRptGetChemicalForPathogenCrop(NULL, NULL);
SELECT * FROM chemical_pathogen_crop_vw where pathogen_nm = 'Sigatoka'
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ========================================================
-- Author:      Terry Watts
-- Create date: 04-FEB-2024
-- Description: fixup the entry mode or (mode of) actions
-- ========================================================
ALTER PROCEDURE [dbo].[sp_fixup_s2_action_general_hlpr2]
       @index                    NVARCHAR(10)
      ,@replace_clause           NVARCHAR(MAX)
      ,@ingredient_search_clause NVARCHAR(MAX)
      ,@entry_mode_operator      NVARCHAR(15)   = NULL
      ,@entry_mode_clause        NVARCHAR(MAX)  = NULL
      ,@fixup_cnt                INT            = NULL OUT
      ,@must_update              BIT   = 0
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35)   = 'SP_FIXUP_S2_ACTION_GEN_HLPR2'
      ,@delta     INT
      ,@sql       NVARCHAR(MAX)
      ,@error_msg NVARCHAR(2000)

   EXEC sp_log 1, @fn, '00: starting
 @index                    :[',@index         ,']
,@replace_clause           :[',@replace_clause,']
,@ingredient_search_clause :[',@ingredient_search_clause ,']
,@entry_mode_operator      :[',@entry_mode_operator ,']
,@ingredient_search_clause :[',@ingredient_search_clause ,']
,@ingredient_search_clause :[',@ingredient_search_clause ,']
,@must_update              :[',@must_update   ,']
   ';

   SET @sql = CONCAT('UPDATE staging2 SET entry_mode=''', @replace_clause
   , ''' WHERE ingredient LIKE ''', @ingredient_search_clause, ''''
   ,IIF(@entry_mode_operator IS NULL, '', CONCAT(' AND entry_mode ', @entry_mode_operator, ' ''', @entry_mode_clause, '''')));

   BEGIN TRY
      PRINT @sql;
      EXEC (@sql);
      SET @delta = @@rowcount;

      IF @fixup_cnt IS NOT NULL SET @fixup_cnt   = @fixup_cnt + @delta;
      ELSE                      SET @fixup_cnt = @delta;
      END TRY
      BEGIN CATCH
         SET @error_msg = Ut.dbo.fnGetErrorMsg();
         EXEC sp_log 4, @fn, '50: caught exception
  exception:      [', @error_msg, ']'
   ;

         THROW;
      END CATCH

   EXEC sp_log 1, @fn, @index,': @delta: ', @delta , ', @sql: ', @sql, @row_count = @fixup_cnt;
END

GO
GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 22-OCT-2022
-- Description: fixup the entry mode
--
-- PRECONDITIONS: none
--
-- POSTCONDITIONS:                                                Exception:
--    POST 01: IF if now rows were processed from the EntryModeFixup table 50697, 'Error in sp_fixup_s2_action_general: No rows were processed', 1;
--    POST 02: IF 'Early post-emergent' still exists i staging2            50698, 'Error in sp_fixup_s2_action_general: Early post-emergent still exists in S2.entry_mode', 1
--    POST 03: IF unrecognised routine                                     50699, 'Error in sp_fixup_s2_action_general: unrecognised routine <rtn>', 1;
--    POST 04: EntryModeFixup table has rows
-- =============================================
ALTER PROCEDURE [dbo].[sp_fixup_s2_action_general]
   @fixup_cnt       INT = NULL OUT
AS
BEGIN
   SET NOCOUNT OFF;
   DECLARE
       @fn              NVARCHAR(35)   = 'FIXUP_S2_ACTION_GEN'
      ,@delta           INT            = 0
      ,@cursor          CURSOR
      ,@id              INT            = 0
      ,@routine         NVARCHAR(50)
      ,@search_clause   NVARCHAR(50)
      ,@clause_1        NVARCHAR(50)
      ,@clause_2        NVARCHAR(50)
      ,@clause_3        NVARCHAR(50)
      ,@error_msg       NVARCHAR(500)
      ,@msg             NVARCHAR(500)

   EXEC sp_log 1, @fn, '00 starting @row_cnt: ', @fixup_cnt;
   EXEC sp_register_call @fn;

   -- POST 04: EntryModeFixup table has rows
   EXEC sp_chk_tbl_populated 'EntryModeFixup';

   EXEC sp_log 1, @fn, '01 importing ACTIONStaging fixup from : ', @fixup_cnt;
   SET @cursor = CURSOR FOR
      SELECT id, routine, search_clause, clause_1, clause_2, clause_3
      FROM EntryModeFixup order by id;

   OPEN @cursor;
   EXEC sp_log 1, @fn, '05: @@FETCH_STATUS before first fetch: [', @@FETCH_STATUS, ']';
   FETCH NEXT FROM @cursor INTO @id, @routine, @search_clause, @clause_1, @clause_2, @clause_3;

   IF @@FETCH_STATUS <> 0
   BEGIN
      -- POST 01: IF if now rows were processed from the EntryModeFixup table 50697, 'Error in sp_fixup_s2_action_general: No rows were processed', 1;
      SET @error_msg = CONCAT('06: Error in sp_fixup_s2_action_general: fetch status: ', @@FETCH_STATUS, ' opening cursor to the EntryModeFixup table');
      EXEC sp_log 4, @fn, @error_msg;
      THROW 54501, @error_msg,1;
   END

   WHILE (@@FETCH_STATUS = 0)
   BEGIN
      BEGIN TRY
         IF @routine = 'sp_fixup_s2_action_general_hlpr'
         BEGIN
            EXEC sp_log 1, @fn, '20: calling sp_fixup_s2_action_general_hlpr
 @id           =@id            [',@id,']
,@search_clause=@search_clause [',@search_clause,']
,@replace_clause=@clause_1     [',@clause_1,']
,@delta=@fixup_cnt OUT ';

            EXEC sp_fixup_s2_action_general_hlpr 
                @index           = @id
               ,@search_clause   = @search_clause
               ,@replace_clause  = @clause_1
               ,@fixup_cnt       = @fixup_cnt OUT
               ,@must_update     = 0;
         END
         ELSE IF @routine = 'sp_fixup_s2_action_general_hlpr2'
         BEGIN
            EXEC sp_log 1, @fn, '20: calling sp_fixup_s2_action_general_hlpr2';
            EXEC sp_fixup_s2_action_general_hlpr2
                @index                    = @id
               ,@replace_clause           = @search_clause
               ,@ingredient_search_clause = @clause_1
               ,@entry_mode_operator      = @clause_2
               ,@entry_mode_clause        = @clause_3
               ,@fixup_cnt                = @fixup_cnt
               ,@must_update              = 0

          EXEC sp_log 1, @fn, '21: @fixup_cnt: ', @fixup_cnt;
         END
         ELSE
         BEGIN
            -- POST 03: IF unrecognised routine  throw ex: 50699, 'Error in sp_fixup_s2_action_general: unrecognised routine <rtn>', 1;
            SET @error_msg = CONCAT('Error in sp_fixup_s2_action_general: unrecognised routine [',@routine,']');
            EXEC sp_log 4, @fn, '20: ', @error_msg;
            THROW 50699, @error_msg, 1;
         END

         -- Increment the fixup cnt
         SET @delta = @@ROWCOUNT;
         IF @fixup_cnt IS NOT NULL SET @fixup_cnt = @fixup_cnt + @delta;

         EXEC sp_log 1, @fn, '10:
   @id: [', @id, ']
   @routine:       [', @routine, ']
   @search_clause: [', @search_clause, ']
   @clause_1:      [', @clause_1, ']
   @clause_2:      [', @clause_2, ']
   @clause_3:      [', @clause_3, ']
   rows updated:   [', @delta, ']
   @fixup_cnt:     [', @fixup_cnt, ']'
   ;

         FETCH NEXT FROM @cursor INTO @id, @routine, @search_clause, @clause_1, @clause_2, @clause_3;
      END TRY
      BEGIN CATCH
         SET @error_msg = Ut.dbo.fnGetErrorMsg();
         EXEC sp_log 4, @fn, '50: caught exception
   @id: [', @id, ']
   @routine:       [', @routine, ']
   @search_clause: [', @search_clause, ']
   @clause_1:      [', @clause_1, ']
   @clause_2:      [', @clause_2, ']
   @clause_3:      [', @clause_3, ']
   rows updated:   [', @delta, ']
   @fixup_cnt:     [', @fixup_cnt, ']
   exception:      [', @error_msg, ']'
   ;
         THROW;
      END CATCH
   END

   --------------------------------------------------------------------------------------
   -- POSTCONDITION checks
   --------------------------------------------------------------------------------------
   IF @id = 0
   BEGIN
      ;THROW 50697, 'Error in sp_fixup_s2_action_general: No rows were processed', 1;
   END

   --------------------------------------------------------------------------------------
   -- Processing completed OK
   --------------------------------------------------------------------------------------
   EXEC sp_log 1, @fn, '99: leaving, @fixup_cnt: ', @fixup_cnt;
END
/*
-------------------------------------------------------
EXEC sp_fixup_s2_action_general;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================================
-- Author:		 Terry Watts
-- Create date: 16-JUL-2023
-- Description: Corrects entries in the crops column of the staging 1 table
--
-- CHANGES:
--    231007: parameter: @must_update now defaults to no not yes
--            added try catch and log error
--            added @idx out parmeter to help with finding error 
-- ==============================================================================
ALTER PROCEDURE [dbo].[sp_fixup_s2_crops_hlpr]
    @search_clause   NVARCHAR(250)
   ,@replace_clause  NVARCHAR(250)
   ,@not_clause      NVARCHAR(250)  = NULL
   ,@note_clause     NVARCHAR(250)  = ''
   ,@must_update     BIT            = 0
   ,@fixup_cnt       INT             OUTPUT
   ,@wrap_wc         BIT            = 1
   ,@idx             int            = null output
AS
BEGIN
   DECLARE 
       @fn              NVARCHAR(30)   = 'FIXUP_S2_CROPS_HLPR'
      ,@nl              NVARCHAR(1)    = NCHAR(13)
      ,@error_msg       NVARCHAR(500)
      ,@delta_fixup_cnt INT            = 0
      ,@sql             NVARCHAR(MAX)

   IF @idx IS NULL SET @idx = 0

   BEGIN TRY
	   SET NOCOUNT OFF;
   
      IF @fixup_cnt IS NULL SET @fixup_cnt = 0;

      SET @sql = CONCAT
      (
'UPDATE dbo.staging2 
   SET 
       crops = Replace(crops, ''', @search_clause,''',''', @replace_clause,''' )
      ,notes = CONCAT(notes, ''', @note_clause,''')
   WHERE crops like CONCAT(''',iif(@wrap_wc=1,'%',''), ''', ''',@search_clause, iif(@wrap_wc=1,'%''',''''),') ESCAPE ''\'''
   , IIF(@not_clause IS NOT NULL, CONCAT(' AND crops NOT LIKE ''%',@not_clause,'%'''), ''), '
   SET @delta_fixup_cnt = @@rowcount;
'); -- end concat

      EXEC sp_log 2, @fn, 'executing sql: ', @nl, @sql;

      EXEC sp_executesql @sql, N'@wrap_wc BIT, @delta_fixup_cnt INT OUT', @wrap_wc, @delta_fixup_cnt OUT;

      IF @delta_fixup_cnt = 0 AND @must_update <> 0
      BEGIN
         DECLARE @msg NVARCHAR(500)
         SET @msg = CONCAT('sp_correct_crops did not find any rows matching the search clause: [', @search_clause, ']');
         EXEC sp_log 4, ''',@fn, ''',@msg;
         THROW 56384, @msg, 1;     
      END

      SET @fixup_cnt = @fixup_cnt + @delta_fixup_cnt;
   END TRY
   BEGIN CATCH
      SET  @error_msg = ut.dbo.fnGetErrorMsg();
      EXEC sp_log 2, @fn, 'caught exception: ', @error_msg, '
idx            : [', @idx, ']        
search_clause  : [', @search_clause, ']
replace_clause : [', @replace_clause, ']
not_clause     : [', @not_clause,']
note_clause    : [', @note_clause,']
must_update    : [', @must_update,'] 
fixup_cnt      : [', @fixup_cnt  ,'] 
wrap_wc        : [', @wrap_wc    ,']';

      THROW;
   END CATCH

   EXEC sp_log 2, @fn, ' leaving OK:
idx            : [', @idx, ']        
search_clause  : [', @search_clause, ']
replace_clause : [', @replace_clause, ']
not_clause     : [', @not_clause,']
note_clause    : [', @note_clause,']
delta_fixup_cnt: [', @delta_fixup_cnt,'] 
must_update    : [', @must_update,'] 
fixup_cnt      : [', @fixup_cnt  ,'] 
wrap_wc        : [', @wrap_wc    ,'] 
row count      : [', @@ROWCOUNT,']'
;

   -- Increment for next time
   SET @idx = @idx +1;
END

/*
   DECLARE 
       @fn                 NVARCHAR(30) = 'FIXUP_S2_CROPS_HLPR: '
      ,@nl                 NVARCHAR(1)  = NCHAR(13)
      ,@error_msg          NVARCHAR(500)
      ,@delta_fixup_cnt    INT = 0
      ,@sql                NVARCHAR(MAX)
   EXEC sp_fixup_s2_crops_hlpr
    @search_clause='Crucifer'
   ,@replace_clause='Cruciferae'
   ,@note_clause=''
   ,@must_update=0
   ,@wrap_wc=0


---------------------------------------------------------------------------------
   DECLARE       @delta_fixup_cnt    INT = 0
   UPDATE dbo.staging2 
   SET 
       crops = Replace(crops, 'Cowpea and other beans','Cowpea,Beans' )
      ,notes = CONCAT(notes, '')
   WHERE crops like CONCAT('%', 'Cowpea and other beans%') ESCAPE '\';

   SET @delta_fixup_cnt = @@rowcount;
---------------------------------------------------------------------------------
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 01-AUG-2023
-- Description: Fixes up the crops field
-- Fixups:
--    '--' -> '-'
--    ''   -> '-'Bittergourd ─mpalaya'
--
-- CHANGES:
--    231006: Additional fixes - does not seem to be doing all fixes??
-- ======================================================================================================
ALTER PROCEDURE [dbo].[sp_fixup_s2_crops]
       @must_update  BIT = 0
      ,@fixup_cnt    INT = NULL OUT
AS
BEGIN
   DECLARE 
       @fn              NVARCHAR(30)= N'FIXUP S2 CROPS'
      ,@fixup_cnt_delta INT         = 0
      ,@idx             INT         = 1

   SET NOCOUNT OFF;
   EXEC sp_log 2, @fn,'01: starting: ';
   EXEC sp_register_call @fn;

   UPDATE staging2 SET crops = 'Rice' WHERE crops LIKE '%Direct-seeded%Pre-germinated%rice%'                                           SET @fixup_cnt_delta = @fixup_cnt_delta + @@rowcount; SET @idx = @idx +1;
   UPDATE staging2 SET crops = 'Rice' WHERE crops LIKE '%Dry-seeded%Upland%rice%'                                                      SET @fixup_cnt_delta = @fixup_cnt_delta + @@rowcount; SET @idx = @idx +1;
  
   EXEC sp_fixup_s2_crops_hlpr '(Dry-seeded (Upland) rice','Rice'                                                                      ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'As an adjuvant in combination with',''                                                                 ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'As surfactant intended for ZYTOX 10 SC',''                                                             ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Banana (an adjuvant for use in spreading &','Banana'                                                   ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Banana oil (as emulsifier)','Banana'                                                                   ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr '[Cavendish banana as insecticidal soap]', 'Banana (Cavendish)'                                         ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   UPDATE dbo.staging2 SET crops = 'Banana (Cavendish)' WHERE crops='Banana (Cavendish) as bunch spray'                                SET @fixup_cnt_delta = @fixup_cnt_delta + @@rowcount; SET @idx = @idx +1;
   UPDATE dbo.staging2 SET crops = 'Banana (Cavendish)' WHERE crops='Banana (Cavendish) as disinfectant'                               SET @fixup_cnt_delta = @fixup_cnt_delta + @@rowcount; SET @idx = @idx +1;
   UPDATE dbo.staging2 SET crops = 'Banana (Cavendish)' WHERE crops='Banana (Cavendish) as insecticidal soap'                          SET @fixup_cnt_delta = @fixup_cnt_delta + @@rowcount; SET @idx = @idx +1;
   UPDATE dbo.staging2 SET crops = 'Banana (Cavendish)' WHERE crops='Banana (Cavendish) as tool disinfectant'                          SET @fixup_cnt_delta = @fixup_cnt_delta + @@rowcount; SET @idx = @idx +1;
   EXEC sp_fixup_s2_crops_hlpr 'Banana (Cavendish) (Post- harvest treatment)' ,'Banana (Cavendish)'                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Banana (Cavendish) as bunch spray'            ,'Banana (Cavendish)'                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Banana (Cavendish) as disinfectant'           ,'Banana (Cavendish)'                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Banana (Cavendish) as insecticidal soap'      ,'Banana (Cavendish)'                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Banana (Cavendish) as insecticidal soap'      ,'Banana (Cavendish)'                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Banana (Cavendish) as tool disinfectant'      ,'Banana (Cavendish)'                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Banana (Cavendish),foot'                      ,'Banana (Cavendish)'                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Beans)','Beans'                                                                                        ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr ' Beans','Beans', @not_clause='_ Beans'                                                                 ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr ', Beans,',',Beans'                                                                                     ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Bitter gourd','Bittergourd'                                                                            ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   UPDATE dbo.staging2 SET crops = 'Bittergourd'  WHERE crops like '%Bitter%palaya%';                                                  SET @fixup_cnt_delta = @fixup_cnt_delta + @@rowcount; SET @idx = @idx +1;
   EXEC sp_fixup_s2_crops_hlpr 'Bnana','Banana'                                                                                        ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Bulb Onion','Onion'                                                                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cabbage & other crucifers','Cabbage, '                                                                 ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cabbage & othercrucifers','Cabbage,Cruciferae'                                                         ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cabbage (as seed treatment)','Cabbage'                                                                 ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cabbage/ Crucifers','Cruciferae'                                                                       ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cabbage/Crucifers','Cruciferae'                                                                        ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cabbage/Wongbook','Cabbage,Chinese Cabbage'                                                            ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cavendish Banana (Post-harvest treatment)','Banana'                                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cantaloupes','Cantaloupe'                                                                              ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Carrots','Carrot'                                                                                      ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cavendish Banana astool disinfectant,foot','Banana (Cavendish)'                                        ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cucurbits (melon,cucumber,squash,','Cucurbits'                                                         ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cucurbits (Cucumber,melon,squash,','Cucurbits'                                                         ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cucurbits (Cucumber,melon,watermelon)','Cucurbits'                                                     ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cavendish Banana asbunch spray','Banana'                                                               ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cavendish banana asdisinfectant','Banana'                                                              ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cavendish banana asinsecticidal soap','Banana'                                                         ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cavendish Banana','Banana (Cavendish)'                                                                 ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Chili (pepper)','Chili pepper'                                                                         ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Chili/Pepper','Chili pepper'                                                                           ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Chinese Cabbage','Chinese cabbage'                                                                     ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cocoa as PGR','Cocoa'                                                                                  ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Corn (as pheromone lure)','Corn'                                                                       ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Corn as Plant- Incorporated','Corn'                                                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Corn as Plant-Incorporated','Corn'                                                                     ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Corn (as seed treatment)','Corn'                                                                       ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Corn (Drone application)','Corn'                                                                       ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Corn,Glyphosate tolerant','Corn (Glyphosate tolerant)'                                                 ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   UPDATE staging2 set crops = 'Corn (Sweet corn)' WHERE crops like 'Corn%sweet corn%' AND crops not like 'Corn (Sweet corn)';         SET @fixup_cnt_delta = @fixup_cnt_delta + @@rowcount; SET @idx = @idx +1;
   UPDATE staging2 set crops = 'Corn'              WHERE crops like 'Corn(sweet and popcorn)';                                         SET @fixup_cnt_delta = @fixup_cnt_delta + @@rowcount; SET @idx = @idx +1;

   EXEC sp_fixup_s2_crops_hlpr 'Corn hybrid (preplant)','Corn'                                                                         ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Corn (Sweet andPopcorn)','Corn'                                                                        ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Corn(sweet & popcorn)','Corn'                                                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Corn(sweet andpopcorn)'  ,'Corn'                                                                       ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cotton seed'             ,'Cotton'                                                                     ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cowpea and other beans','Cowpea,Beans'                                                                 ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cowpea and otherbeans','Cowpea,Beans'                                                                  ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Crucifer','Cruciferae',                            @wrap_wc=0                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Crucifers','Cruciferae'                                                                                ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cruciferae (Chinese Cabbage )','Cruciferae,Chinese Cabbage'                                            ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cruciferae (Chinese Cabbage)','Cruciferae,Chinese Cabbage'                                             ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cucumber and othecucurbits','Cucurbits'                                                                ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cucumber and other cucurbits','Cucurbits'                                                              ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cucurbits (melon,cucumber, squash,','Cucurbits'                                                        ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cucurbits (Cucumbermelon,squash,','Cucurbits'                                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cucurbits (Cucumbermelon,watermelon)','Cucurbits'                                                      ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Direct seeded rice','Rice'                                                                             ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Field legumes','Legumes'                                                                               ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Garden Peas (Legumes)','Peas (garden),Legumes'                                                         ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Garden Peas','Peas (garden)',                      @wrap_wc=0                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Glyphosate tolerant','Corn,Glyphosate tolerant',   @wrap_wc=0                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Glyphosate tolerant corn','Corn,Glyphosate tolerant'                                                   ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Glyphosate tolerantcorn','Corn,Glyphosate tolerant'                                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Grape','Grapes',                                   @wrap_wc=0                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Grapes seedling','Grapes'                                                                              ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Green Peas (Legumes)', 'Peas (green),Legumes'                                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Green peas', 'Peas (green)',                       @wrap_wc=0                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Institutional agricultural crops (pineapple &','Pineapple'                                             ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Legumes (MongoBeans,Soybeans,Other Beans)','Legumes,Mongo beans,Soyabean,Other beans'                  ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Legumes (Mongo,Soybean,Beans','Legumes,Mongo beans,Soybeans,Beans'                                     ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Legumes (Mongo,Soyabeans,Beans','Legumes,Mongo beans,Soybeans,Beans'                                   ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'lettuce','Lettuce'                                                                                     ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Lettuce and other Cruciferae','Lettuce,Cruciferae'                                                     ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr ',Mongo,',',Mungbeans,'                                                                                 ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Msngo','Mango'                                                                                         ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Mungbean','Mungbeans',                             @wrap_wc=0                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Mungo','Mungbeans',                                @wrap_wc=0                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'N/A',''                                                                                                ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Non-Agricultural Crop Areas','Non-crop areas'                                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'non-crop & minimal tillage system','Non-crop areas'                                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'non-crop & minimum tillage system','Non-crop areas'                                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Non-crop agricultural areas','Non-crop areas'                                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Non-crop agrricultural areas','Non-crop areas'                                                         ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'non-crop areas','Non-crop areas'                                                                       ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Non-crop land','Non-crop areas'                                                                        ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Non-cropped Land','Non-crop areas'                                                                     ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'non-crop','Non-crop areas',                        @wrap_wc=0                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Onion (Bulb/green)','Onion'                                                                            ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Onion (Transplanted)','Onion'                                                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Onion(as Pheromone)','Onion'                                                                           ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Papaya (Solo plant)','Papaya'                                                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Papaya(Direct seeded)','Papaya'                                                                        ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'peas,Legumes','Peas,Legumes'                                                                           ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Potted%','Potted plants',                                @wrap_wc=0                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   UPDATE staging2 SET crops = 'Potted plants' WHERE crops like 'Potted%';                                                             SET @fixup_cnt_delta = @fixup_cnt_delta + @@rowcount; SET @idx = @idx +1;
   UPDATE staging2 SET crops = 'Soyabeans'     WHERE crops ='Soyabean';                                                                SET @fixup_cnt_delta = @fixup_cnt_delta + @@rowcount; SET @idx = @idx +1;
   EXEC sp_fixup_s2_crops_hlpr 'Rice ( direct-seeded)','Rice'                                                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice (as seed treatment)','Rice'                                                                       ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice (Direct Seeded Pre- Germinated)','Rice'                                                           ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice (Direct Seeded)','Rice'                                                                           ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice (Direct-Seeded and transplanted)','Rice'                                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice (Direct-Seeded lowland)','Rice'                                                                   ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice (Direct-seeded Wet Sown)','Rice'                                                                  ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice (Direct-Seeded)','Rice'                                                                           ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice (Direct-Seededlowland)','Rice'                                                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice (Dry-Seeded)','Rice'                                                                              ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice (hybrid)','Rice'                                                                                  ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice (lowland)','Rice'                                                                                 ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice (Pre-emergent and early post-emergent','Rice'                                                     ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice (Transplanted and Direct-Seeded)','Rice'                                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice (Transplanted)','Rice'                                                                            ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice (Upland)','Rice'                                                                                  ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice(Direct seeded)','Rice'                                                                            ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice(Direct seeded lowland)','Rice'                                                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rice(Transplanted)','Rice'                                                                             ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Rodenticide',''                                                                                        ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Soil and Space Fumigant','','Soil and Space Fumigant'                                                  ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Soil fumigant','','Soil fumigant'                                                                      ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Solanaceous crops',''                                                                                  ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Soybeanss','Soyabeans'                                                                                 ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Soyabeans & other beans','Soyabeans,Beans'                                                             ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Soyabeans/Mungbeans','Soyabeans,Mungbeans'                                                             ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Soyabean,','Soyabeans,',@not_clause='Soyabeans'                                                        ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   UPDATE staging2 SET crops = 'Soyabeans'     WHERE crops ='Soybeans';                                                                SET @fixup_cnt_delta = @fixup_cnt_delta + @@rowcount; SET @idx = @idx +1;
   EXEC sp_fixup_s2_crops_hlpr 'Stored commodities & processed foods','','Stored commodities & processed foods'                        ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Stored grain','','Stored grain'                                                                        ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Stringbean','Stringbeans',                              @wrap_wc=0                                     ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Sugarcane (plant canes) & ratoon','Sugarcane'                                                          ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Sugarcane (plant canes)& ratoon','Sugarcane'                                                           ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Sweet peas','Peas (sweet)'                                                                             ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Swine and poultry farms',''                                                                            ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Tomato and other','Tomato,Solanaceae'                                                                  ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Transplante rice','Rice'                                                                               ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Transplanted onion','Onion'                                                                            ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Transplanted rice','Rice'                                                                              ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Turf','Turf grass',                                     @wrap_wc=0                                     ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Vegetables (under minimum or reduced','Vegetables'                                                     ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Vegetables under minimum or tillage','Vegetables'                                                      ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   UPDATE staging2 SET crops = 'Vegetables'     WHERE crops LIKE'Vegetables %under minimum%';                                          SET @fixup_cnt_delta = @fixup_cnt_delta + @@rowcount; SET @idx = @idx +1;
   EXEC sp_fixup_s2_crops_hlpr 'Wongbok','Chinese cabbage'                                                                             ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Cabbage, ','Cabbage',                                   @wrap_wc=0                                     ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;

   -- 231007: additional fixes
   EXEC sp_fixup_s2_crops_hlpr 'Banana (Cavendish) (Post- harvest treatment)' ,'Banana (Cavendish)', @note_clause='Post- harvest treatment',@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Banana (Cavendish) as bunch spray' ,'Banana (Cavendish)', @note_clause='as bunch spray'                ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Banana (Cavendish) as disinfectant' ,'Banana (Cavendish)', @note_clause='as disinfectant'              ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Banana (Cavendish) as insecticidal soap' ,'Banana (Cavendish)', @note_clause='as insecticidal soap'    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Banana (Cavendish) as tool disinfectant' ,'Banana (Cavendish)', @note_clause='as tool disinfectant'    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Chili' ,'Chili pepper'                                 , @not_clause='Chili pepper'                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Corn (Sweet corn' ,'Corn ', @note_clause='(Sweet corn)', @not_clause='Corn (Sweet corn)'               ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Corn (Sweet corn)' ,'Corn', @note_clause='(Sweet corn)'                                                ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Corn, Popcorn)' ,'Corn'   , @note_clause='(Sweet and Popcorn)'                                         ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Peas (garden)', 'peas'    , @note_clause='(garden)'                                                    ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT; 
   EXEC sp_fixup_s2_crops_hlpr 'Peas (green)' , 'peas'    , @note_clause='(green)'                                                     ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT; 
   EXEC sp_fixup_s2_crops_hlpr 'Peas (sweet)' , 'peas'    , @note_clause='(sweet)'                                                     ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT; 
   EXEC sp_fixup_s2_crops_hlpr 'Soybeans & other beans', 'Soyabeans,Beans'                                                             ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Soybeans/Mungbeans', 'Soyabeans,Mungbeans'                                                             ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Soybeans', 'Soyabeans'                                                                                 ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Soybean', 'Soyabeans'                                                                                  ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Stored commodities & processed foods', ''  , @note_clause='Stored commodities & processed foods'       ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Grassland','Grass'                         , @note_clause='Grassland'                                  ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;
   EXEC sp_fixup_s2_crops_hlpr 'Corn,Glyphosate tolerant','Corn'           , @note_clause='Glyphosate tolerant'                        ,@fixup_cnt=@fixup_cnt_delta OUTPUT, @must_update=@must_update, @idx = @idx OUT;

   UPDATE Staging2 SET crops = '' WHERE crops = 'Field' AND ingredient='Zinc Phosphide' AND uses='Rodenticide';SET @fixup_cnt_delta = @fixup_cnt_delta + @@rowcount; SET @idx = @idx +1;
   UPDATE Staging2 SET crops = '' WHERE crops = 'Soil and Space Fumigant' AND ingredient='Methyl Bromide+chloropicrin' AND uses='Fumigant';SET @fixup_cnt_delta = @fixup_cnt_delta + @@rowcount; SET @idx = @idx +1; 
   UPDATE Staging2 SET crops = '', uses='Soil Sterilant' WHERE crops = 'Soil fumigant' AND ingredient='Dazomet' AND uses='Others';SET @fixup_cnt_delta = @fixup_cnt_delta + @@rowcount; SET @idx = @idx +1;

   EXEC sp_log 2, @fn,'99: leaving OK, @fixup_cnt_delta: ',@fixup_cnt_delta, ' @fixup_cnt: ',@fixup_cnt;
END
/*
EXEC sp_fixup_s2_crops;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==========================================================================
-- Author:		 Terry Watts
-- Create date: 25-OCT-2023
-- Description: Fixup hlpr rtn for s2_entry_modes
--              modifies staging2
--
-- Changes:
-- 231030: only change the action if the ingredient 
--         is the only ingredient for the row 
-- 23113: added an exception handler that reports the  parameters and error
-- ==========================================================================
ALTER PROCEDURE [dbo].[sp_fixup_s2_action_specific_hlpr]
    @ingredient      NVARCHAR(60)
   ,@replace_clause  NVARCHAR(100)
   ,@delta_fixup_cnt INT = NULL OUT
AS
BEGIN
   DECLARE 
       @fn              NVARCHAR(35)=N'SP_FIXUP_S2_ACTION_SPEC_HLPR'
      ,@row_cnt         INT

	SET NOCOUNT OFF;
   EXEC sp_log 2, @fn, '01: starting';

   BEGIN TRY
      UPDATE staging2 
      SET entry_mode = @replace_clause 
      WHERE 
         ingredient = @ingredient
         --ingredient LIKE CONCAT('%', @ingredient, '%')
      ;

      SET @row_cnt = @@rowcount;
      EXEC sp_log 2, @fn, '99: leaving: 
   @ingredient    :[', @ingredient,']
   @replace_clause:[',@replace_clause, ']
   ', @row_count = @row_cnt;
      SET @delta_fixup_cnt = @delta_fixup_cnt + @row_cnt;
   END TRY
   BEGIN CATCH
      DECLARE @error_msg NVARCHAR(MAX);
      EXEC Ut.dbo.sp_get_error_msg @error_msg OUT;

      EXEC sp_log 4, @fn, '50: caught exception: 
@ingredient    :[', @ingredient,']
@replace_clause:[', @replace_clause, ']
error: ',@error_msg;

      THROW;
   END CATCH
END 
/*
EXEC sp_fixup_s2_entry_modes_hlpr ...
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ================================================================================================================
-- Author:      Terry Watts
-- Create date: 24-OCT-2023
-- Description: Fixup rtn for stging2.(z9,e12)9,12-Tetradecadien-1-Ol Acetate
-- Jobs:
--    1. fixup separators to + no spcs
--
-- Changes:
-- 231130: added an exception handler
-- 231103: moved Bacillus Thuringiensis Vipaa20 and Vip3aa20 from sp_fixup_s2_action_specific to sp_fixup_s2_chems
-- ================================================================================================================
ALTER PROCEDURE [dbo].[sp_fixup_s2_action_specific]
   @fixup_cnt INT = NULL OUT
AS
BEGIN
   DECLARE
       @fn              NVARCHAR(35)=N'FIXUP_S2_ACTION_SPECIFIC'
      ,@delta_fixup_cnt INT = 0

   SET NOCOUNT OFF;
   BEGIN TRY
      EXEC sp_log 2, @fn, '01: starting, @fixup_cnt: ',@fixup_cnt;
      EXEC sp_register_call @fn;
      EXEC sp_log 2, @fn, '02: fixup separators: ,+ spcs, & '' and ''';
      -- 1. general fixup modes
      UPDATE staging2 SET entry_mode = 'Systemic' WHERE ingredient ='(z9,e12)9,12-Tetradecadien-1-Ol Acetate' AND entry_mode = '';
      UPDATE staging2 SET entry_mode = 'Contact,Post-Emergent,Selective,Systemic' WHERE ingredient LIKE '%2,4-D%';
      UPDATE staging2 SET entry_mode = 'Contact,Post-Emergent,Selective,Systemic' WHERE ingredient LIKE 'Imazosulfuron';

      EXEC sp_fixup_s2_action_specific_hlpr '1,8 Cineole'                               , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr '2,4-D'                                     , 'Contact,Post-Emergent,Selective,Systemic'             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Abamectin'                                 , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Acetamiprid'                               , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Alkyl Dimethyl Benzyl Ammonium Chloride'   , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Alkyl Modified Heptamethyltrisiloxane'     , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Alkyl Polyethylene Glycol Monoalkyl Ether' , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Alkylphenol-Hydroxypolyoxyethelene'        , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Allyl Ethoxylate'                          , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Alpha-Cypermethrin'                        , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Acephate'                                  , 'Contact,Systemic'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Aluminum Potassium Sulfate'                , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Ametoctradin'                              , 'Contact,Systemic'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Amyloliquefaciens'                         , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Bacillus Thuringiensis'                    , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Beauveria Bassiana'                        , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Benomyl'                                   , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Bensulfuron Methyl'                        , 'Selective,Systemic'                                   , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Benzalkonium Chloride'                     , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Beta-cyfluthrin'                           , 'Selective,Systemic'                                   , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Aviglycine Hydrochloride'                  , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Azadirachtin'                              , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Azoxystrobin'                              , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Benzoxonium Chloride'                      , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Beta-Cypermethrin'                         , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Bifenthrin'                                , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Bispyribac Sodium'                         , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Bitertanol'                                , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Bordeaux Mixture'                          , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'BPMC'                                      , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Branched Hydrocarbons'                     , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Brodifacoum'                               , 'Ingested'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Brofanilide'                               , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Bromacil'                                  , 'Pre-Emergent,Post-Emergent,Non-selective'             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Bufrofezin'                                , 'Contact,Systemic'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Butachlor'                                 , 'Selective,Systemic,Pre-Emergent,Post-Emergent'        , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'C14 18 Alkyl Carboxylic Acid Methyl Ester' , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'C18-C24 Linear'                            , 'Others'                                               , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Calcium Alkyl Benzene Sulfonate'           , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Calcium Hypochlorite'                      , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Canola Oil'                                , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Canola Oil Methyl Ester'                   , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Captan'                                    , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Carbaryl'                                  , 'Contact,Ingested'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Carbendazim'                               , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Carbofuran'                                , 'Systemic '                                            , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Carbosulfan'                               , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Carfentrazone-Ethyl'                       , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Cartap Hydrochloride'                      , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Chlorantraniliprole'                       , 'Contact,Systemic'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Chlorfenapyr'                              , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Chlorfluazuron'                            , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Chlorimuron Ethyl'                         , 'Selective,Systemic,Pre-Emergent,Post-Emergent'        , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Chloropicrin'                              , 'Soil Sterilant'                                       , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Chlorothalonil'                            , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Chlorpyrifos'                              , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Chlothianidin'                             , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Cinnamaldehyde'                            , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Clethodim'                                 , 'Selective,Systemic'                                   , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Clothianidin'                              , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Copper Hydroxide'                          , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Copper Oxychloride'                        , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Coumatetralyl'                             , 'Ingested'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Cry1a.105'                                 , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Cry1ab'                                    , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Cry1f'                                     , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Cry2ab2'                                   , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Cupric Hydroxide'                          , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Cuprous Oxide'                             , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Cyantraniliprole'                          , 'Contact,Systemic'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Cyazofamid'                                , 'Contact,Systemic'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Cyhalofop-Butyl'                           , 'Selective,Post-Emergent,Systemic'                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Cymoxanil'                                 , 'Contact,Systemic'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Cypermethrin'                              , 'Contact,Ingested'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Cyromazine'                                , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Dazomet'                                   , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Deltamethrin'                              , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Di-1-P-Menthene'                           , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Diazinon'                                  , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Dibromo-3-Nitrilopropionamide'             , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Dichloropropene'                           , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Didecyl Dimethyl Ammonium Chloride'        , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Difenoconazole'                            , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Diuron'                                    , 'Selective,Systemic'                                   , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'D-Limonene'                                , 'Contact,Systemic'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Dodine'                                    , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Elemental Sulphur'                         , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Ethephon'                                  , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Ethoxylated Dodecyl Alcohol'               , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Ethoxysulfuron'                            , 'Selective,Systemic'                                   , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Ethyl Formate'                             , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Famoxadone'                                , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Fatty Alcohol Polyglycolether'             , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Fenazaquin'                                , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Fenbuconazole'                             , 'Protective,Curative,Systemic'                         , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Fenpyroximate'                             , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Fenthion'                                  , 'Contact,Ingested'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Fenvalerate'                               , 'Contact,Ingested'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Fipronil'                                  , 'Selective'                                            , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Flocoumafen'                               , 'Ingested'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Florpyrauxifen Benzyl'                     , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Floupyram'                                 , 'Curative,Protective,Systemic'                         , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Fluazifop-P-Butyl'                         , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Fluazinam'                                 , 'Contact,Protective'                                   , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Flubendiamide'                             , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Flucetosulfuron'                           , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Fludioxonil'                               , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Flumioxazin'                               , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Fluopicolide'                              , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Fluopyram'                                 , 'Protective,Systemic'                                  , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Fluoxastrobin'                             , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Flusulfamide'                              , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Fluxapyroxad'                              , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Formetanate Hci'                           , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Fosthiazate'                               , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Gibberellin'                               , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Glufosinate-Ammonium'                      , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Glyphosate-Ammonium'                       , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Glyphosate-Ipa'                            , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Heat-Killed Burkholderia Spp .strain A396' , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Hexaconazole'                              , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Hexazinone'                                , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Hexythiazox'                               , 'Contact,Ingested'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Hydramethylnon'                            , 'Contact,Ingested'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Hydrogen Peroxide'                         , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Imazalil'                                  , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Imazapic'                                  , 'Selective,Systemic'                                   , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Imidacloprid'                              , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Iminoctadine Tris (albesilate)'            , 'Contact,Protective'                                   , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Indoxacarb'                                , 'Ingested'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Iodine'                                    , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Isoprothiolane'                            , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Isopyrazam'                                , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Isotianil'                                 , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Kerosene'                                  , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Kresoxim-Methyl'                           , 'Contact,Protective,Curative'                          , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Lambda-Cyhalothrin'                        , 'Contact,Ingested'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Lauryl Alcohol Polyglycol Ether'           , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Limonene'                                  , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Lufenuron'                                 , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Magnesium Phosphide'                       , 'Contact,Ingested'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Mancozeb'                                  , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Malathion'                                 , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Mandipropamid'                             , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Metalaxyl-M'                               , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Metaldehyde'                               , 'Contact,Ingested'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Metam-Sodium'                              , 'Ingested'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Methomyl'                                  , 'Contact,Systemic,Ingested'                            , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Methyl Bromide'                            , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Methyl Eugenol'                            , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Methylated Seed Oil'                       , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Metiram'                                   , 'Contact,Protective'                                   , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Metsulfuron Methyl'                        , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Milbemectin'                               , 'Contact,Ingested'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Mipcin'                                    , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Natamycin'                                 , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Niclosamide'                               , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Niclosamide Ethanolamine Salt'             , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Nonylphenol Polyethylene Glycol Ether'     , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Novaluron'                                 , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Oxadiazon'                                 , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Oxyfluorfen'                               , 'Contact,Pre-Emergent,Post-Emergent'                   , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Oxytetracycline'                           , 'Contact,Ingested'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Paclobutrazol'                             , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Paraffin'                                  , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Peg Oleate(mono-Ester)'                    , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Peg-300'                                   , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Penoxsulam'                                , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Permethrin'                                , 'Contact,Ingested'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Phenthoate'                                , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Phosphine'                                 , 'Fumigant'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Piperonyl Butoxide'                        , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Pirimiphos Methyl'                         , 'Fumigant'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Polyalkylene Oxide Block Copolymer'        , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Polyether-Polymethylsiloxane Copolymer'    , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Polymeric Terpenes'                        , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Polyoxyethylene Alkyl Ether'               , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Polyoxyethylene Dodecyl Ether'             , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Polyoxyethylene Sorbitan Fatty Acid'       , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Polyoxyethylene Sorbitan Monooleate'       , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Potassium Peroxymonosulfate'               , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Potassium salts of fatty acids'            , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Potassium Silicate'                        , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Pretilachlor'                              , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Prochloraz'                                , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Profenofos'                                , 'Contact,Ingested'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Propamocarb-hydrochloride'                 , 'Contact,Systemic'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Propiconazole'                             , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Propineb'                                  , 'Contact,Systemic'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Propylene Glycol'                          , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Propyrisulfuron'                           , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Pthalic Glycerol Alkyd'                    , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Pymetrozine'                               , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Pyraclostrobin'                            , 'Contact,Systemic,Ingested'                            , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Pyrazosulfuron Ethyl'                      , 'Selective,Systemic'                                   , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Pyribenzoxim'                              , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Pyrimethanil'                              , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Sabadilla Alkaloids'                       , 'Contact,Ingested'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Safener'                                   , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Saponin'                                   , 'Contact,Ingested'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Sethoxydim'                                , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Sodium Dichloroisocyanurate'               , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Sodium Percarbonate'                       , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Soybean Oil'                               , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Soybean Oil,Ethoxylated'                   , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Spinetoram'                                , 'Contact,Systemic'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Spinosad'                                  , 'Systemic,Contact,Ingested'                            , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Spirotetramat'                             , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Spiroxamine'                               , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Sulfoxaflor'                               , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Sulfuryl Flourides'                        , 'Fumigant'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Sulphur'                                   , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Tea Tree Oil'                              , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Tebuconazole'                              , 'Systemic,Protective,Curative,Eradicant'               , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Tebufenozide'                              , 'Contact,Selective'                                    , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Terbufos'                                  , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Tetraconazole'                             , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Tetramethrin'                              , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Tetraniliprole'                            , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Thiamethoxam'                              , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Thiodiazole Copper'                        , 'Systemic,Protective,Therapeutic '                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Thiophanate Mesp_fixup_s2_action_specific_hlpr_hlprthyl'                        , 'Systemic'        , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Thiram'                                    , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Tributylpenol-Polyglycother'               , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Triclopyr'                                 , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Trifloxystrobin'                           , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Triflumezopyrim'                           , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Triflumizole'                              , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Triforine'                                 , 'Systemic'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'White Mineral Oil'                         , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Tetradecadien'                             , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Z-9 Tetradecenol'                          , 'Contact'                                              , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Zinc Phosphide'                            , 'Ingested'                                             , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Zineb'                                     , 'Contact,Systemic'                                     , @delta_fixup_cnt OUT;
      EXEC sp_fixup_s2_action_specific_hlpr 'Zoxamide'                                  , 'Contact'                                              , @delta_fixup_cnt OUT;

      IF @fixup_cnt IS NOT NULL SET @fixup_cnt = @fixup_cnt + @delta_fixup_cnt;

      EXEC sp_log 2, @fn, '99: leaving, made: ',@delta_fixup_cnt, ' changes';
   END TRY
   BEGIN CATCH
      DECLARE @error_msg NVARCHAR(MAX);
      EXEC Ut.dbo.sp_get_error_msg @error_msg OUT;
      EXEC sp_log 4, @fn, '50: caught exception: @stage_id: ',' error:', @error_msg;
      THROW;
   END CATCH
END
/*
EXEC sp_fixup_s2_entry_modes
SELECT * FROM S12_vw WHERE s1_chemical like '%Flusulfamide%' ORDER BY s2_chemical;
SELECT * FROM S12_vw WHERE s2_chemical like '%Fenazaquin%' ORDER BY s2_chemical;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==========================================================
-- Author:		 Terry watts
-- Create date: 07-JUL-2023
-- Description: Capitalise first character of the first word 
-- ===========================================================
ALTER PROCEDURE [dbo].[sp_cap_first_char_of_word]
AS
BEGIN
   -- pathogens: Capitalise first character of the first word 
   PRINT 'sp_cap_first_char_of_word pathogens: Capitalise first character of the first word  '
   UPDATE staging2 SET pathogens = agPathogens
   FROM staging2 s2 JOIN 
   (SELECT stg2_id, STRING_AGG( ut.dbo.fnInitialCap(cs.value), ',') as agPathogens
   FROM staging2
   CROSS APPLY string_split(pathogens, ',') cs
   GROUP BY stg2_id) X ON s2.stg2_id = X.stg2_id;
END
/*
EXEC sp_cap_first_char_of_word
SELECT * FROM s2vw;

*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 02-AUG-2023
-- Description: fixup staging2 pathogens: modifies the staging 2 table
--
-- POSTCONDITIONS:
-- PO1: 'Cabagge moth' and 'Golden apple Snails' do not exists in staging2.pathogens
--
-- CHANGES:
-- 231013: added post condition 'Cabagge moth' and 'Golden apple Snails' do not exists in staging2.pathogens
--         changed import replace from based on id to based on data - id is nt good
--         added changes to the fixup cnt
--         added post condition chks on 'Cabagge moth' and 'Golden apple Snails'
-- ======================================================================================================
ALTER PROCEDURE [dbo].[sp_fixup_s2_pathogens]
     @fixup_cnt       INT=NULL OUT
AS
BEGIN
   SET NOCOUNT OFF
   DECLARE
       @fn              NVARCHAR(35) = 'FIXUP S2 PATHOGENS'

   EXEC sp_log 2, @fn, '01: starting, @fixup_cnt: ',@fixup_cnt
   EXEC sp_register_call @fn;

   -- pathogens: standardise -
   EXEC sp_log 1, @fn, '2.03: pathogens: standardise -'
   UPDATE dbo.staging2 SET pathogens = '' WHERE pathogens = '-';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   UPDATE dbo.staging2 SET pathogens = '' WHERE pathogens = '- ';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   UPDATE dbo.staging2 SET pathogens = '' WHERE pathogens = ' ';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- pathogens: standardise ' and ', ', and ', '',',And ' to ','
   EXEC sp_log 1, @fn, '2.10: pathogens: standardise '' and '' to '','' ';
   UPDATE staging2 SET pathogens = REPLACE(pathogens, ', and ',',');
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   UPDATE staging2 SET pathogens = REPLACE(pathogens, ' and ',',');
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   -- ,And 
   UPDATE staging2 SET pathogens = REPLACE(pathogens, ',And ',',');
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- pathogens: Capitalise first character of the first word 
   EXEC sp_log 1, @fn, '2.14: pathogens: Capitalise first character of the first word';
   EXEC sp_cap_first_char_of_word;

   -- Missing data: pathogens
   EXEC sp_log 1, @fn, '2.15: pathogens: Fixup some missing data - cotton/Mancozeb -> Path: Alternaria Leaf Spot';

   UPDATE staging2 SET pathogens = CONCAT(pathogens, ',', 'Alternaria Leaf Spot')
   WHERE crops like '%Cotton%' AND ingredient like '%Mancozeb%' AND pathogens NOT like 'Alternaria Leaf Spot';

   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   EXEC sp_log 1, @fn, '03: As foot';
   UPDATE staging2
   SET 
     notes = 'As foot bath,tire dip,tool and machinery disinfectant'
    ,pathogens='Moko disease,Fusarium wilt'
   WHERE pathogens like '%As foot bath,tire dip,tool and machinery disinfectant for the control of Moko disease and Fusarium wilt%';

   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   EXEC sp_log 1, @fn, '04: ''Anthracnose fruit rot leaf spot'' -> ''Anthracnose fruit rot, Leaf spot''';
   UPDATE staging2 SET pathogens=REPLACE(pathogens, 'Anthracnose fruit rot leaf spot', 'Anthracnose fruit rot, Leaf spot')  WHERE pathogens like '%Anthracnose fruit rot leaf spot%'; -- 282 rows
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- Cabagge moth
   EXEC sp_log 1, @fn, '056: ''Cabagge moth'' -> ''Cabbage moth''';
   UPDATE staging2 SET pathogens=REPLACE(pathogens, 'Cabagge moth', 'Cabbage moth')  WHERE pathogens like '%Cabagge moth%'; -- 393 rows
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   EXEC sp_log 1, @fn, '3: pathogens, replacing Cabagge moth, @ROWCOUNT: ',@@ROWCOUNT;

   -- Cadelle beetle beetles
   EXEC sp_log 1, @fn, '06: ''Cadelle beetle beetles'' -> ''Cadelle beetle''';
   UPDATE staging2 SET pathogens=REPLACE(pathogens, 'Cadelle beetle beetles', 'Cadelle beetle')  WHERE pathogens like '%Cadelle beetle beetles%';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- Coconut coconut nut rot
   EXEC sp_log 1, @fn, '07: ''Coconut coconut nut rot'' -> ''Coconut nut rot''';
   UPDATE staging2 SET pathogens=REPLACE(pathogens, 'Coconut coconut nut rot', 'Coconut nut rot')  WHERE pathogens like '%Coconut coconut nut rot%';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- Confused flour beetles
   EXEC sp_log 1, @fn, '08: ''Confused flour beetles'' -> ''Confused flour beetle''';
   UPDATE staging2 SET pathogens=REPLACE(pathogens, 'Confused flour beetles', 'Confused flour beetle')  WHERE pathogens like '%Confused flour beetles%';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- Cotton cotton leafworm
   EXEC sp_log 1, @fn, '09: ''Cotton cotton leafworm'' -> ''Cotton leafworm''';
   UPDATE staging2 SET pathogens=REPLACE(pathogens, 'Cotton cotton leafworm', 'Cotton leafworm')  WHERE pathogens like '%Cotton cotton leafworm%';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- [Diamondback moth caterpillars] ->[Diamondback moth caterpillar]
   EXEC sp_log 1, @fn, '10: ''Diamondback moth caterpillars'' -> ''Diamondback moth caterpillar''';
   UPDATE staging2 SET pathogens=REPLACE(pathogens, 'Diamondback moth caterpillars', 'Diamondback moth caterpillar')  WHERE pathogens like '%Diamondback moth caterpillars%';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- Egyptian cotton cotton leafworm
   EXEC sp_log 1, @fn, '12: ''Egyptian cotton cotton leafworm'' -> ''Egyptian cotton leafworm''';
   UPDATE staging2 SET pathogens=REPLACE(pathogens, 'Egyptian cotton cotton leafworm', 'Egyptian cotton leafworm')  WHERE pathogens like '%Egyptian cotton cotton leafworm%';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- Mango mango tip borer
   EXEC sp_log 1, @fn, '13: ''Mango mango tip borer'' -> ''Mango tip borer''';
   UPDATE staging2 SET pathogens=REPLACE(pathogens, 'Mango mango tip borer', 'Mango tip borer')  WHERE pathogens like '%Mango mango tip borer%';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- Sugarcane sugarcane white grub
   EXEC sp_log 1, @fn, '14: ''Sugarcane sugarcane white grub'' -> ''Sugarcane white grub''';
   UPDATE staging2 SET pathogens=REPLACE(pathogens, 'Sugarcane sugarcane white grub', 'Sugarcane white grub')  WHERE pathogens like '%Sugarcane sugarcane white grub%';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- POST conditions:
   -- PO1: chk 'Cabagge moth' and 'Golden apple Snails' do not exists in staging2.pathogens
   IF EXISTS ( SELECT 1 FROM staging2 WHERE pathogens like '%Cabagge%' )-- 393 rows
   THROW 53978, 'sp_fixup_s2_pathogens: ''Cabagge moth'' still exists in pathogens', 1;

   EXEC sp_log 2, @fn, '99: leaving OK, @fixup_cnt: ',@fixup_cnt;
END
/*
EXEC sp_fixup_s2_pathogens
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================================================================
-- Author:       Terry Watts
-- Create date:  06-AUG-2023
-- Description:  Fixup the Stage 1 phi field@replace_clause
--    @replace_all means if any part of the field matches the @search_clause then replace all the field with 
--    @exact       means whle field must match teh search clause
-- ==============================================================================================================
ALTER PROCEDURE [dbo].[sp_fixup_s2_phi_hlpr] 
    @search_clause   NVARCHAR(150)
   ,@replace_clause  NVARCHAR(150)
   ,@not_clause      NVARCHAR(150)  = NULL
   ,@replace_all     BIT            = 0
   ,@exact           BIT            = 0
   ,@case_sensitive  BIT            = 0
   ,@fixup_cnt       INT            OUT
AS
BEGIN
   SET NOCOUNT OFF;
   DECLARE 
       @fn              NVARCHAR(35)  = N'FIXUP S2 PHI HLPR'
      ,@delta           INT = 0
      ,@sql             NVARCHAR(MAX)
      ,@nl              NVARCHAR(1) = NCHAR(13)
      ,@collate_clause  NVARCHAR(150)

   EXEC sp_log 0, @fn, '000 starting'

   SET @collate_clause = CONCAT('COLLATE ', IIF(@case_sensitive=1, 'Latin1_General_CS_AI', ' Latin1_General_CI_AI'), @nl)

   If @replace_all = 1
   BEGIN
      -- replace all
      SET @sql = CONCAT
      (
         'UPDATE staging2 SET phi = ''', @replace_clause, ''' WHERE phi LIKE ''%',@search_clause,'%'' ', @collate_clause
         , 'AND phi NOT like ''%',@replace_clause,'%'' '                                               , @collate_clause
         , IIF(@not_clause IS NOT NULL
            , CONCAT
            (
                'AND phi NOT like ''%'
               ,@not_clause,'%'''
               ,@collate_clause), ''
            )
      );
  END
   ELSE
   BEGIN
      SET @sql = CONCAT
      (
           'UPDATE staging2 SET phi = REPLACE(phi, ''', @search_clause, ''',''', @replace_clause, ''') ' ,@nl
         , 'WHERE phi LIKE '
         , IIF
           (
              @exact = 0
            , CONCAT
            (
                '''%'
               , @search_clause
               , '%'''
            )
            , CONCAT
            (
                ''''
               ,@search_clause
               ,''' '
            )
          ) -- iif
          ,  @collate_clause
         , 'AND phi NOT like ''%',@replace_clause,'%'' '                                                                   , @collate_clause
         , IIF
           (
             @not_clause IS NOT NULL
            ,CONCAT
             (
                'AND phi NOT like ''%'
               ,@not_clause,'%'' '
               ,@collate_clause
             )
            , ''
           ) -- iif
      ); -- main concat
   END

   --PRINT @sql;
   EXEC (@sql);

   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   EXEC sp_log 0, @fn,'099: leaving, @fixup_cnt: ', @fixup_cnt,' @exact_filter:', @exact;
END
/*
EXEC sp_copy_s3_s2
------------------------------------------------------------------------------------------------------------
DECLARE @fixup_cnt INT = 0
EXEC sp_fixup_s2_phi_hlpr  'No PHI', 'No PHI necessary', @replace_all=1, @case_sensitive=0;
SELECT id, phi from staging2 order by phi
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================================================================
-- Author:      Terry Watts
-- Create date: 04-AUG-2023
-- Description: Fixup the Stage 2 phi field
--
-- Clean is done in various parts, the process is as follows:
-- 1. Import the main xls (as a tab delimted file)
-- 2. Use sp_fixup_s1_std_preprocessing to handle standard faults like Line feed (496) and quotes (745)
-- 3. sp_fixup_s1_phi will do some basic fixups ahead of the phi import like:
--    a) spelling mistakes
--         mdays -> days
--         harvested2
--          _ -> 0 days
--         'day '->'days '
--        requried -> required
--    b) convert spelled numbers to numbers like 'one' -> 1  'twenty four'-> 24
--    b) standardise the no PHI necessary
--       *no %harvest interval*      -> No PHI necessary
--       *No PHI *                  -> No PHI necessary
--       *on the day of *           -> No PHI necessary
--       '-'                        -> No PHI necessary
--       'No Pre-harvest Interval necessary'
--       No PHI necessary -> 0
-- No restriction
-- 4. Use the following rules to extract the PHI days number
--  1. *no harvest interval * -> No PHI necessary -> 0
--  2.
--  3. (n) hours -> /1 div 24 
--  (mmm-nnn) .* days -> average of mmm, nnn
--  (n) weeks  -> /1 * 7
--  (n) months -> /1 * 30
--  '(nnn)'    -> /1 days
--  
-- MORE INFO:
-- Numbers of days recommeded between last spray until harvest of the crops indicated in the table above
-- 120 days 15 days
-- ==============================================================================================================
ALTER PROCEDURE [dbo].[sp_fixup_s2_phi]
       @fixup_cnt    INT = NULL OUT
AS
BEGIN
   SET NOCOUNT OFF;
   DECLARE 
       @fn            NVARCHAR(30)  = N'FIXUP S2 PHI'
      ,@fixup_cnt_delta         INT = 0

   EXEC sp_log 2, @fn,'01: starting: @fixup_cnt: ',@fixup_cnt;
   EXEC sp_register_call @fn;

   -- trim d quotes
   UPDATE staging2 SET phi = ut.dbo.fnTrim2(phi, '"') WHERE phi LIKE '"%"';
   -- replace char 10 with ' '
   UPDATE staging2 SET phi = REPLACE(phi, NCHAR(10), ' ') WHERE phi LIKE CONCAT('%',NCHAR(10),'%'); -- 496 rows
   SET @fixup_cnt_delta = @fixup_cnt_delta + @@ROWCOUNT;
   -- double spcs -> single spcs 
   EXEC sp_fixup_s2_phi_hlpr '  '            , ' '             ,@fixup_cnt=@fixup_cnt_delta OUT;
   -- - . NULL-> ??
   EXEC sp_fixup_s2_phi_hlpr '_', '??',@fixup_cnt=@fixup_cnt_delta OUT, @exact=1;
   EXEC sp_fixup_s2_phi_hlpr '-', '??',@fixup_cnt=@fixup_cnt_delta OUT, @exact=1;
   UPDATE staging2 SET phi = '??'  WHERE phi IS NULL
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   EXEC sp_fixup_s2_phi_hlpr '.', '??',@fixup_cnt=@fixup_cnt_delta OUT, @exact=1;

   -- replace commas so we can set up maps
   EXEC sp_fixup_s2_phi_hlpr ',', ';'                          ,@fixup_cnt=@fixup_cnt_delta OUT;
    -- Remove round brackets
   UPDATE staging2 SET phi= REPLACE(phi,' (', ' ') WHERE phi LIKE '% (%';
   UPDATE staging2 SET phi= REPLACE(phi, '(', ' ') WHERE phi LIKE '%(%';
   UPDATE staging2 SET phi= REPLACE(phi,')', '') WHERE phi LIKE '%)%';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- Spelling/ grammar mistakes:
   EXEC sp_fixup_s2_phi_hlpr 'foilar', 'foliar'                ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_fixup_s2_phi_hlpr 'haevested', 'harvested'          ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_fixup_s2_phi_hlpr 'Ni PHI needed', 'No PHI needed'  ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_fixup_s2_phi_hlpr 'o day', '0 days', @not_clause='two day',@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_fixup_s2_phi_hlpr 'requried', 'required'            ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_fixup_s2_phi_hlpr 'trated', 'treated'               ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_fixup_s2_phi_hlpr ' fpr ', ' for '                  ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_fixup_s2_phi_hlpr 'haevested', 'haevested'          ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_fixup_s2_phi_hlpr 'rggplant', 'eggplant'            ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_fixup_s2_phi_hlpr 'harvested2', 'harvested 2'       ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_fixup_s2_phi_hlpr 'Do nor spray'  , 'Do not spray'  ,@fixup_cnt=@fixup_cnt_delta OUT;

   EXEC sp_fixup_s2_phi_hlpr 'Pre-harvest interval must consider at least 6 and 10 weeks from application on aper bud basis for banana cv'
   , '6-10 weeks from application on aper bud for bananas' ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_fixup_s2_phi_hlpr 'For Banana; harvesting may be done on the days of application. For other crops; do not apply  within 7-14', 'Banana: 0 days, other crops:7-14 days'  ,@fixup_cnt=@fixup_cnt_delta OUT;

   -- errata:
   -- Crops sprayed with ORTHENE 75 SP can be harvested 2 weeks after treated
   UPDATE Staging2 set phi = '14 days' WHERE product = 'Lancer 75 Sp' and phi like '%ORTHENE 75 SP can be harvested 2 weeks after treated%'; -- 230721:  8 records

   -- Pluralise day units
   EXEC sp_fixup_s2_phi_hlpr ' day'                  , ' days'                               ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_fixup_s2_phi_hlpr ' Days'                 , ' days'            ,@case_sensitive=1 ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_fixup_s2_phi_hlpr ' week '                , ' weeks '                             ,@fixup_cnt=@fixup_cnt_delta OUT;

   -- Consistency
     
   -- Remove prduct from phi as the name often contains a number which messes up our phi extraction;
   UPDATE Staging2 SET phi = REPLACE( phi, product, '') WHERE phi like CONCAT('%', product, '%') COLLATE SQL_Latin1_General_CP1_CI_AI;
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   -- Crops trated With  can be harvested 3 days after application.
   -- Same time remove redundant 'Crops sprayed with ' 
   --: product: 'Alphamax 10 Ec'	phi:'Alphamax can be harvested three 3 days after spray application	Crops treated with Alphamax can be harvested three (3) days after spray application'
   EXEC sp_fixup_s2_phi_hlpr 'Alphamax can', 'Alphamax 10 Ec can',@fixup_cnt=@fixup_cnt_delta OUT;
  -- UPDATE Staging2 SET phi = REPLACE( phi, 'Crops sprayed with ', '') WHERE phi like '%Crops sprayed with %';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   UPDATE Staging2 SET phi = REPLACE( phi, 'Crops treated with ', 'Crops sprayed with ') WHERE phi like '%Crops treated with %';

   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   -- standardise time unit
   -- just a number (n) no unit -> n days
   update staging2 set phi = CONCAT(phi, ' days') WHERE isnumeric(phi) =1;
   -- twenty four hours -> 1 day
   EXEC sp_fixup_s2_phi_hlpr 'twenty four hours',  '1 days',@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_fixup_s2_phi_hlpr '24 hours'         ,  '1 days',@fixup_cnt=@fixup_cnt_delta OUT;
   -- two days-> 2 days
   EXEC sp_fixup_s2_phi_hlpr 'two days'         ,  '2 days',@fixup_cnt=@fixup_cnt_delta OUT;
   -- two weeks-> 2 weeks -> 14 days
   EXEC sp_fixup_s2_phi_hlpr 'two weeks'        , '14 days',@fixup_cnt=@fixup_cnt_delta OUT;
   -- 1 weeks-> 2 weeks -> 14 days
   EXEC sp_fixup_s2_phi_hlpr '1 week'           ,  '7 days'    ,@fixup_cnt=@fixup_cnt_delta OUT;
   -- 8 months -> 240 days
   EXEC sp_fixup_s2_phi_hlpr '8 months'         , '240 days',@fixup_cnt=@fixup_cnt_delta OUT;

   -- 'No PHI necessary' variants
   EXEC sp_fixup_s2_phi_hlpr 'No PHI needed'                   , 'No PHI necessary', @replace_all=1   ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_fixup_s2_phi_hlpr 'No PHI required'                 , 'No PHI necessary', @replace_all=1   ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_fixup_s2_phi_hlpr 'No PHI proposed'                 , 'No PHI necessary', @replace_all=1   ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_fixup_s2_phi_hlpr 'No PHI'                          , 'No PHI necessary',@fixup_cnt=@fixup_cnt_delta OUT;

   EXEC sp_fixup_s2_phi_hlpr 'No%pre-harvest interval'         , 'No PHI necessary', @replace_all=1   ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_fixup_s2_phi_hlpr 'Non Pre-harvest Interval'        , 'No PHI necessary', @replace_all=1   ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_fixup_s2_phi_hlpr 'No harvest interval is necessary', 'No PHI necessary', @replace_all=1   ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_fixup_s2_phi_hlpr 'No_restriction'                  , 'No PHI necessary', @replace_all=1   ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_fixup_s2_phi_hlpr 'Not applicable'                  , 'No PHI necessary', @replace_all=1   ,@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_fixup_s2_phi_hlpr 'Not required'                    , 'No PHI necessary', @replace_all=1   ,@fixup_cnt=@fixup_cnt_delta OUT;
   
   -- spelled durations
   EXEC sp_fixup_s2_phi_hlpr 'one days'                 , '1 days',@fixup_cnt=@fixup_cnt_delta OUT;

   -- Apply as long as pest threatens -> ??
   EXEC sp_fixup_s2_phi_hlpr 'Apply as long as pest threatens', '??',@fixup_cnt=@fixup_cnt_delta OUT;
   -- number n with no period unit -> d days e.g.
   -- do this after '-' and '.' have been converted
   UPDATE staging2 SET phi = IIF(ISNUMERIC(phi)=1, CONCAT(phi, ' days'), phi);
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   -- It is recommended to observe a 7-days pre-harvest interval
   EXEC sp_fixup_s2_phi_hlpr '7-days', '7 days',@fixup_cnt=@fixup_cnt_delta OUT;
   -- 14 days, Stem and Mat - 0 day   
   EXEC sp_fixup_s2_phi_hlpr '14 days; Stem and Mat - 0 day', 'Fruit: 14 days, Stem and Mat: 0 day',@fixup_cnt=@fixup_cnt_delta OUT;
   -- 14 days; Stem and Mat 0-day
   EXEC sp_fixup_s2_phi_hlpr '14 days; Stem and Mat 0-day'  , 'Fruit: 14 days, Stem and Mat: 0 day',@fixup_cnt=@fixup_cnt_delta OUT;
   -- n - m days -> n days
   -- Harvesting may be done right after spraying
   EXEC sp_fixup_s2_phi_hlpr 'Harvesting may be done right after spraying'  , 'No PHI necessary', @replace_all=1,@fixup_cnt=@fixup_cnt_delta OUT;
   -- Harvesting may be done on the days of application
   EXEC sp_fixup_s2_phi_hlpr 'Harvesting may be done on the days of application'  , 'No PHI necessary', @replace_all=1,@fixup_cnt=@fixup_cnt_delta OUT;
   -- Fruits that are already ripe on the days of treatment can be harvested without any harmful residue.Generally;
   EXEC sp_fixup_s2_phi_hlpr 'Fruits that are already ripe on the days of treatment can be harvested without any harmful residue.Generally'  , 'No PHI necessary', @replace_all=1,@fixup_cnt=@fixup_cnt_delta OUT;
   -- Crop sprayed with  can be done as soon as spray deposits have dried
   EXEC sp_fixup_s2_phi_hlpr 'Crop sprayed with  can be done as soon as spray deposits have dried'  , 'No PHI necessary', @replace_all=1,@fixup_cnt=@fixup_cnt_delta OUT;
   -- A days after spraying
   EXEC sp_fixup_s2_phi_hlpr 'A day% after spraying'  , '1 days', @replace_all=1,@fixup_cnt=@fixup_cnt_delta OUT;
   -- Harvest can be done on the application days
   EXEC sp_fixup_s2_phi_hlpr 'Harvest can be done on the application day'  , 'No PHI necessary', @replace_all=1,@fixup_cnt=@fixup_cnt_delta OUT;
   -- Harvesting can be done even a days after application;as long as the spray has already dried.
   EXEC sp_fixup_s2_phi_hlpr 'Harvesting can be done even a days after application'  , '1 days', @replace_all=1,@fixup_cnt=@fixup_cnt_delta OUT;
   -- When applied of recommended rates; very shrort or no harvest interval will be normaly necessary
   EXEC sp_fixup_s2_phi_hlpr 'When applied at recommended rates; very short or no harvest interval will be necessary'  , 'No PHI necessary', @replace_all=1,@fixup_cnt=@fixup_cnt_delta OUT;
   -- When applied of recommended rates; very shrort or no harvest interval will be normaly necessary
   EXEC sp_fixup_s2_phi_hlpr 'When applied of recommended rates; very shrort or no harvest interval will be normaly necessary'  , 'No PHI necessary', @replace_all=1,@fixup_cnt=@fixup_cnt_delta OUT;

   -- spelled numbers
   EXEC sp_fixup_s2_phi_hlpr ' one '  , ' 1 ',@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_fixup_s2_phi_hlpr ' two '  , ' 2 ',@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_fixup_s2_phi_hlpr ' three ', ' 3 ',@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_fixup_s2_phi_hlpr ' four ' , ' 4 ',@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_fixup_s2_phi_hlpr ' five ' , ' 5 ',@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_fixup_s2_phi_hlpr ' six '  , ' 6 ',@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_fixup_s2_phi_hlpr ' seven ', ' 7 ',@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_fixup_s2_phi_hlpr ' eight ', ' 8 ',@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_fixup_s2_phi_hlpr ' nine ',  ' 9 ',@fixup_cnt=@fixup_cnt_delta OUT;

   -- Crop sprayed with LANCER 75 SP can be done as soon as spray deposits have dried -> 0 days
   EXEC sp_fixup_s2_phi_hlpr 'Crop sprayed with % can be done as soon as spray deposits have dried', '0 days',@fixup_cnt=@fixup_cnt_delta OUT;

   -- 1:M  Map of crop -> PHI  
   -- 7 days (Banana)
   EXEC sp_fixup_s2_phi_hlpr '7 days (Banana)', 'Banana: 7 days',@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_fixup_s2_phi_hlpr '7-14 days% except in banana 0 day%','Banana: 0 days, Other crops: 7-14 days',@fixup_cnt=@fixup_cnt_delta OUT;
   EXEC sp_fixup_s2_phi_hlpr 'Allow 7-14 days from last spray until harvest for all crops. Except for banana 0 day.%','Banana: 0 days, Other crops: 7-14 days',@fixup_cnt=@fixup_cnt_delta OUT;

   -- like 14 days before harvest fpr potato. 7 days before harvest for onion
   -- -> potato: 14 days, onion: 7 days
   -- 14 days for fruits, 10 days for field crops
   -- 7 days (Banana) -> Banana: 7 days
   -- 7-14 days. Banana 0 day -> Banana: 0 days, Oter crops: -14 days

   -- convert weeks to days

   -- pop phi resolved
   -- for now do not handle a-b days
   UPDATE staging2 set phi_resolved = dbo.fnGetFirstNumberFromString(phi) WHERE ISNUMERIC(dbo.fnGetFirstNumberFromString(phi)) =1;
   UPDATE staging2 set phi_resolved = dbo.fnGetNumericPairFromString(phi) WHERE phi like '%[0-9]-[0-9]%';
   UPDATE staging2 set phi_resolved = 0 WHERE phi like '%No PHI necessary%'
   SET @fixup_cnt = @fixup_cnt + @fixup_cnt_delta;
   EXEC sp_log 2, @fn,'99: leaving: @fixup_cnt_delta: ',@fixup_cnt_delta, ' @fixup_cnt: ', @fixup_cnt;
END
/*
EXEC sp_fixup_s2_phi
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:       Terry Watts
-- Create date:  02-AUG-2023
-- Description:  Stage 2 products fixup
-- ======================================================================================================
ALTER PROCEDURE [dbo].[sp_fixup_s2_products]
     @fixup_cnt       INT = NULL OUT
AS
BEGIN
   SET NOCOUNT OFF
   DECLARE
       @fn              NVARCHAR(35) = 'FIXUP S2 PRODUCTS'

   EXEC sp_log 2, @fn, '01: starting, @fixup_cnt: ',@fixup_cnt;
   EXEC sp_register_call @fn;

   UPDATE staging2 SET product = 'Perfekthion 40 EC' WHERE product IS NULL AND company='Basf Philippines, Inc.' AND ingredient='Dimethoate';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   UPDATE staging2 SET product = 'Agrotechno Lambdacyhalothrin 2.5 Ec' WHERE product = 'Agrotechno Lambdacyhalothrin 2.5 ec' COLLATE Latin1_General_CS_AI;
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   UPDATE staging2 SET product = 'Zulpac Lambda 2.5 Ec' WHERE product='Zulpac -Lambda 2.5 Ec';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   UPDATE staging2 SET product = 'Benomax 50 Wp' WHERE product='Benomex 50 Wp';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   EXEC sp_log 2, @fn, '99: leaving, @fixup_cnt: ',@fixup_cnt;
END
/*
SELECT product From Staging2 WHERE product like '%Agrotechno Lambdacyhalothrin 2.5 ec%';
DECLARE @fixup_cnt       INT = 0;
EXEC sp_fixup_s2_products  @fixup_cnt OUT;
PRINT CONCAT('@fixup_cnt: ', @fixup_cnt);
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 07-OCT-2023
-- Description: helper for sp_fixup_s2_uses
--
-- PRECONDITIONS: 
--    PRE01: @where_clause must be specified
--    PRE02: @new_uses must be specified
--    PRE03: @where_field must be specified
--
-- CHANGES:
-- 231024: @fixup_cnt param is now optional
-- =============================================
ALTER PROCEDURE [dbo].[sp_fixup_s2_uses_hlpr]
    @where_field  NVARCHAR(30) -- '=' or LIKE
   ,@where_op     NVARCHAR(20) -- '=' or LIKE
   ,@where_clause NVARCHAR(500)-- e.g. 'Pgr' (for =) or '%insecticide%/%nematicide%' for like
   ,@new_uses     NVARCHAR(100)-- uses replacement
   ,@fixup_cnt    INT = NULL OUT
AS
BEGIN
   DECLARE 
       @fn NVARCHAR(35) = 'FIXUP_S2_USES_HLPR'
      ,@sql    NVARCHAR(MAX)
      ,@rowcnt INT = 0
      ,@rc    INT = 0;

	SET NOCOUNT OFF;
   SET @sql = CONCAT('UPDATE staging2 SET uses = ''', @new_uses,''' WHERE ', @where_field, ' ', @where_op, ' ''', @where_clause, '''');

   -- Validation: PRE01, PRE02, PRE03
   IF @where_clause IS NULL OR ut.dbo.fnLen(@where_clause) = 0 THROW 53214, '@where_clause must be specified', 1;
   IF @new_uses     IS NULL OR ut.dbo.fnLen(@new_uses)     = 0 THROW 53215, '@new_uses must be specified'    , 1;
   IF @where_field  IS NULL OR ut.dbo.fnLen(@where_field)  = 0 THROW 53215, '@where_field must be specified'    , 1;

   -- Execute
   EXEC @rc = sp_executesql @sql;
   SET @rowcnt = @@ROWCOUNT;

   IF @rc <> 0 
   BEGIN
      DECLARE @msg NVARCHAR(500);
      SET @msg = CONCAT( 'sp_executesql failed: SQL: ', @sql, ' rc: ', @rc);
      EXEC sp_Log 4, @fn, @msg;
      THROW 65487, 'sp_fixup_s2_uses_hlpr: failed', 1;
   END

   IF @fixup_cnt IS NOT NULL
      SET @fixup_cnt = @fixup_cnt + @rowcnt;
END
/*
DECLARE @delta        INT = 0
--EXEC sp_fixup_s2_uses_hlpr 'uses', 'LIKE', '%insecticide%/%nematicide%', @new_uses ='Insecticide,Nematicide', @delta=@delta OUT
EXEC sp_fixup_s2_uses_hlpr 'ingredient', 'LIKE', '%Ethephon%', @new_uses ='Growth Regulator', @delta=@delta OUT
PRINT CONCAT('@delta: ', @delta, ' rows updated')
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:       Terry Watts
-- Create date:  31-JUL-2012
-- Description:  Fixup routine for staging2 uses
--
-- CHANGES:
-- 231007: added Biophero'; other --> Biological Insecticide
-- 241021: cleanup for quoted items in uses
-- ======================================================================================================
ALTER PROCEDURE [dbo].[sp_fixup_s2_uses]
   @fixup_cnt INT = NULL OUTPUT
AS
BEGIN
   DECLARE
        @fn             NVARCHAR(35)= 'FIXUP S2 USES'

   IF @fixup_cnt is NULL SET @fixup_cnt=0;

   EXEC sp_log 2, @fn, '01: starting, @fixup_cnt: ', @fixup_cnt;
   EXEC sp_register_call @fn;

   -- Bulk updates
   UPDATE staging2 SET uses = REPLACE(uses, 'Insecticide/fu Ngicide','Insecticide,Fungicide') WHERE uses LIKE '%Insecticide/fu Ngicide%';                    SET @fixup_cnt=@fixup_cnt + @@ROWCOUNT;
   UPDATE Staging2 SET uses = REPLACE(uses, '"','') WHERE uses LIKE '%"%';

   -- specific updates
   EXEC sp_fixup_s2_uses_hlpr @where_field='uses'      , @where_op='LIKE', @where_clause='%Adjuvant%'                   , @new_uses ='Wetting Agent'           , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='uses'      , @where_op='LIKE', @where_clause='%Emulsifier%'                 , @new_uses ='Wetting Agent'           , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='uses'      , @where_op='LIKE', @where_clause='%insecticide%/%nematicide%'   , @new_uses ='Insecticide,Nematicide'  , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='uses'      , @where_op='='   , @where_clause='Others*'                      , @new_uses ='Others'                  , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='uses'      , @where_op='='   , @where_clause='Pgr'                          , @new_uses ='Growth Regulator'        , @fixup_cnt=@fixup_cnt OUT;

   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Alcohol C13 Iso,-Ethoxylated%', @new_uses='Wetting Agent'           , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Allyl Ethoxylate%'            , @new_uses='Wetting Agent'           , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Alkyl Modified Heptamethyltrisiloxane%',@new_uses ='Wetting Agent'  , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Alkylphenol-Hydroxypolyoxyethelene%',@new_uses ='Wetting Agent'     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Aluminum Potassium Sulfate%' , @new_uses ='Wetting Agent'           , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%ammonium chloride%'          , @new_uses ='Wetting Agent'           , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Aviglycine Hydrochloride%'   , @new_uses ='Growth Regulator'        , @fixup_cnt=@fixup_cnt OUT;

   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='Like', @where_clause='%Benzalkonium Chloride%'      , @new_uses ='Wetting Agent'           , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%C18-C24 Linear+Branched Hydrocarbons%',@new_uses ='Fungicide'       , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Carboxylic Acid%'            , @new_uses ='Biological Insecticide'  , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Carboxylic Acid%'            , @new_uses ='Biological Insecticide'  , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Canola Oil%'                 , @new_uses ='Wetting Agent'           , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Carbofuran%'                 , @new_uses ='Insecticide,Nematicide'  , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Dazomet%'                    , @new_uses ='Soil Sterilant'          , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Di-1-P-Menthene%'            , @new_uses ='Foliar antitranspirant'  , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Ethephon%'                   , @new_uses ='Growth Regulator'        , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Ethoxylated Dodecyl Alcohol%', @new_uses ='Wetting Agent'           , @fixup_cnt=@fixup_cnt OUT;

   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Fenamiphos%'                 , @new_uses ='Nematicide'              , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Fenazaquin%'                 , @new_uses ='Miticide,Acaricide,Insecticide', @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%glycol%Ether%'               , @new_uses ='Wetting Agent'           , @fixup_cnt=@fixup_cnt OUT;

   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Glyphosate-Ipa%'             , @new_uses ='Ripener'                 , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Heat-Killed Burkholderia Spp .strain A396%', @new_uses ='Biological Insecticide', @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Hydrogen Peroxide%'          , @new_uses ='Bleaching agent'         , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Iodine%'                     , @new_uses ='Fungicide'               , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Kerosene%'                   , @new_uses ='Fungicide,Insecticide'   , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Limonene%'                   , @new_uses ='Fungicide,Insecticide'   , @fixup_cnt=@fixup_cnt OUT;

   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Metam-Sodium%'               , @new_uses ='Soil Sterilant'          , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Metiram%'                    , @new_uses ='Fungicide'               , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Methyl Eugenol%'             , @new_uses ='Insecticide'             , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Methylated Seed Oil%'        , @new_uses ='Wetting Agent'           , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Oxytetracycline%'            , @new_uses ='Bactericide'             , @fixup_cnt=@fixup_cnt OUT;

   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Paclobutrazol%'              , @new_uses ='Growth Regulator'        , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Paraffin%'                   , @new_uses ='Insecticide,Fungicide'   , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Polyethylene Sorbitan Oleate%',@new_uses ='Wetting Agent'           , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Polymeric Terpenes%'         , @new_uses ='Insecticide'             , @fixup_cnt=@fixup_cnt OUT;

   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Polyoxyethylene Dodecyl Ether%',@new_uses='Wetting Agent'           , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Polyoxyethylene Sorbitan Monooleate%',@new_uses='Wetting Agent'     , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Pthalic Glycerol Alkyd%'     ,@new_uses = 'Wetting Agent'           , @fixup_cnt=@fixup_cnt OUT;
   
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Sodium Dichloroisocyanurate' , @new_uses ='Disinfectant'            , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='Sodium Percarbonate'          , @new_uses ='Bleaching Agent'         , @fixup_cnt=@fixup_cnt OUT;

   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='Soybean Oil'                  , @new_uses ='Insecticide,Acaricide,Growth regulator,Herbicide', @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='Soybean Oil,Ethoxylated'      , @new_uses ='Wetting Agent'           , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='Spirotetramat'                , @new_uses ='Insecticide'             , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='Tea Tree Oil'                 , @new_uses ='Fungicide'               , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Tetradecadien%Acetate%'      , @new_uses ='Biological Insecticide'  , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Trisiloxane Alkoxylate%'     , @new_uses ='Wetting Agent'           , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%Vipaa20%'                    , @new_uses ='Biological Insecticide'  , @fixup_cnt=@fixup_cnt OUT;
   EXEC sp_fixup_s2_uses_hlpr @where_field='ingredient', @where_op='LIKE', @where_clause='%White Mineral Oil%'          , @new_uses ='Insecticide'             , @fixup_cnt=@fixup_cnt OUT;
   
   EXEC sp_log 2, @fn, '99: leaving, @fixup_cnt: ',@fixup_cnt;
END
/*
   EXEC sp_fixup_s2_uses;

   SELECT stg2_id, ingredient
   FROM Staging2
   WHERE ingredient in
   (SELECT distinct ingredient FROM staging2
   WHERE ingredient LIKE  '%Thur%'
   )  
   ORDER BY ingredient
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===============================================================================================
-- Author:		 Terry Watts
-- Create date: 28-JUL-2023
-- Description: sp_fixup_staging2_chemicals helper
--
-- Changes:
-- 03-AUG-2023: Amtryn -> Amtryne OK Amtryne -> Amtryn NOT OK 
--                IF len(replace) < (len search) do not include the the not like clause
-- 231104: addede a must_update param
-- ======================================================================================================
ALTER PROCEDURE [dbo].[sp_fixup_s2_chems_hlpr]
    @search_clause   NVARCHAR(150)
   ,@replace_clause  NVARCHAR(150)
   ,@not_clause      NVARCHAR(150) = NULL
   ,@case_sensitive  BIT = 0
   ,@fixup_cnt       INT  = NULL OUT
   ,@must_update     BIT = 0
AS
BEGIN
   DECLARE
      @fn            NVARCHAR(30)=N'FIXUP_S2_CHEMS_HLPR'
     ,@nl            NVARCHAR(1)=NCHAR(13)
     ,@sql           NVARCHAR(MAX)
     ,@not_clause2   NVARCHAR(150)
     ,@len_search    INT
     ,@len_replace   INT
     ,@rowcnt        INT = 0

   EXEC sp_log 1, @fn, '01: Starting,@search_clause:[', @search_clause, '] @replace_clause:[', @replace_clause,'] @not_clause:[',@not_clause, '] cs:', @case_sensitive;
   SET @len_search  = ut.dbo.fnLen(@search_clause);
   SET @len_replace = ut.dbo.fnLen(@replace_clause);
   --PRINT CONCAT('@len_search: ',@len_search, ' @len_replace: ',@len_replace);

   SET @not_clause2 = iif(@not_clause IS NULL, '', CONCAT(@nl, 'AND ingredient NOT LIKE ''%', @not_clause, '%''',iif(@case_sensitive=1, ' COLLATE Latin1_General_CS_AI','')));

   SET @sql = CONCAT
   (
    'UPDATE staging2 set ingredient = REPLACE(ingredient, ''',@search_clause, ''',', '''',@replace_clause, ''')',@nl
   ,'WHERE ingredient     LIKE CONCAT(''%'',''', @search_clause, ''',''%'')'
   -- IF len(replace) < (len search) do not include the the not like clause
   --  'Ametryne','Ametryn'  
   ,iif(@len_search <= @len_replace, CONCAT('AND   ingredient NOT LIKE CONCAT(''%'',''', @replace_clause, ''',''%'')'), '')
   ,iif(@case_sensitive=1, ' COLLATE Latin1_General_CS_AI','')
   ,@not_clause2
   , ';'
   );

   --PRINT CONCAT('sql:', @nl, @sql);
   EXEC sp_log 1, @fn, @sql;
   EXEC (@sql);
   SET @rowcnt = @@ROWCOUNT;

   IF @must_update = 1 AND @rowcnt = 0
   BEGIN
      DECLARE @error_msg NVARCHAR(500)
      SET @error_msg = 'sp_fixup_s2_chems_hlpr did not update any rows when @must_update set'
      EXEC sp_log 4, @fn, @error_msg;
      THROW 51050, @error_msg, 1;
   END

   SET @fixup_cnt = @fixup_cnt + @rowcnt;
   EXEC sp_log 1, @fn, '99: leaving ', @row_count=@rowcnt;
END
/*
EXEC sp_copy_staging3_staging2; 
EXEC sp_fixup_s2_chems
EXEC sp_fixup_s2_chems_hlpr 'Ametryne','Ametryn'  
SELECT distinct ingredient FROM staging2 WHERE ingredient LIKE '%Ametryn%'-- COLLATE Latin1_General_CS_AI
-- Ametryne+Atrazine  Ametryn+Atrazine     Ametryn
-- UPDATE staging2 set ingredient = REPLACE(ingredient, 'Ametryne','Ametryn') WHERE ingredient     LIKE CONCAT('%','Ametryne','%')
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =======================================================================================================
-- Author:      Terry Watts
-- Create date: 27-JUL-2023
-- Description: Fixup rtn for stging2.chemicals
-- Jobs:
--    1. fixup separators to + no spcs
--
-- CHANGES:
-- 231024: updated the Bacillus Thuringiensis Varieties to reflect the bacteria name
-- 231103: moved Bacillus Thuringiensis Vipaa20 and Vip3aa20 from sp_fixup_s2_action_specific to here
-- =======================================================================================================
ALTER PROCEDURE [dbo].[sp_fixup_s2_chems]
   @fixup_cnt       INT = NULL OUT
AS
BEGIN
   DECLARE 
       @fn              NVARCHAR(30)=N'FIXUP_S2_CHEMS'
      ,@delta_fixup_cnt INT = 0

   SET NOCOUNT OFF;
   EXEC sp_log 2, @fn, '01: starting, @fixup_cnt: ',@fixup_cnt;
   EXEC sp_register_call @fn;

   EXEC sp_log 2, @fn, '02: fixup separators: ,+ spcs, & '' and ''';

   -- 1. fixup separators: can be , + ' and '
   UPDATE staging2 set ingredient = REPLACE(ingredient, ', '   , ',') WHERE ingredient like '%, %';
   SET @delta_fixup_cnt = @delta_fixup_cnt + @@ROWCOUNT;

   -- 2 spcs to 1 spc
   UPDATE staging2 set ingredient = REPLACE(ingredient, '  '   , ' ') WHERE ingredient like '%  %';
   SET @delta_fixup_cnt = @delta_fixup_cnt + @@ROWCOUNT;
   EXEC sp_log 2, @fn, '03:'
   UPDATE staging2 set ingredient = REPLACE(ingredient, ' & '  , '+') WHERE ingredient like '% & %';
   SET @delta_fixup_cnt = @delta_fixup_cnt + @@ROWCOUNT;
   UPDATE staging2 set ingredient = REPLACE(ingredient, ' + '  , '+') WHERE ingredient like '% + %';
   EXEC sp_log 2, @fn, '04:'
   UPDATE staging2 set ingredient = REPLACE(ingredient, ' and ', '+') WHERE ingredient like '% and %';

   EXEC sp_fixup_s2_chems_hlpr '(z)-11-Hexadecenylacetate (7)-7 Dodecenyl Acetate','(z)-11-Hexadecenyl Acetate (7)-7 Dodecenyl Acetate', @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_log 2, @fn, '06: '
   EXEC sp_fixup_s2_chems_hlpr 'acetic Acid', 'Acetic Acid'                         , @case_sensitive=1     , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'alkyl Dimethyl Benzyl ammonium Chloride', 'Alkyl Dimethyl Benzyl Ammonium Chloride', @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'alkyl Phenyl Polyoxyethylene Polyoxypropylene Ether', 'Alkyl Phenyl Polyoxyethylene Polyoxypropylene Ether', @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_log 2, @fn, '07:'
   EXEC sp_fixup_s2_chems_hlpr 'alkyldimethyl Benzyl Ammonium Chloride', 'Alkyl Dimethyl Benzyl Ammonium Chloride', @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'allyl Ethoxylate', 'Allyl Ethoxylate'               , @case_sensitive=1     , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Amectrotradin','Ametoctradin'                                               , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_log 2, @fn, '08:'                                                                               
   EXEC sp_fixup_s2_chems_hlpr 'Ametryne','Ametryn'                                                         , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Ammonium Salt Of Glyphosate','Glyphosate-Ammonium'                          , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'atrazine', 'Atrazine', @case_sensitive=1                                    , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_log 2, @fn, '10:'
   EXEC sp_fixup_s2_chems_hlpr 'Bacillus Thuringiensis Ss. Aizawai', 'Bacillus Thuringiensis Var. Aizawai', @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Bacillus Thuringiensis Subsp.kurstaki Strain', 'Bac. Thur. Var. Kurstaki' , @case_sensitive=1 , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Cry1a.105', 'Bac. Thur. Var. Cry1a.105', @fixup_cnt=@delta_fixup_cnt OUT; 
   EXEC sp_fixup_s2_chems_hlpr 'Bacillus Thuringiensis Var. Bacillus Thuringiensis Var. Vip3aa20','Ba. Thur. Var. Vip3aa20'           , @case_sensitive=1     , @fixup_cnt=@delta_fixup_cnt
   EXEC sp_fixup_s2_chems_hlpr 'Vip3aa20','Bac. Thur. Var. Vip3aa20', @case_sensitive=1         , @fixup_cnt=@delta_fixup_cnt
   EXEC sp_fixup_s2_chems_hlpr 'Cry1ab'  , 'Bac. Thur. Var. Cry1ab'                             , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Cry2ab2' , 'Bac. Thur. Var. Cry2ab2'                            , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Cry1f'   , 'Bac. Thur. Var. Cry1f'                              , @fixup_cnt=@delta_fixup_cnt OUT;

   UPDATE staging2 
      SET
          ingredient = REPLACE(ingredient, 'Bifenthrin+starbunch 2% Masterbatch', 'Bifenthrin+Starbunch') 
         ,notes='Use banana bags: starbunch 2% Masterbatch'
      WHERE ingredient LIKE '%Bifenthrin+starbunch 2%';

   SET @delta_fixup_cnt = @delta_fixup_cnt + @@ROWCOUNT;
   EXEC sp_fixup_s2_chems_hlpr 'Bifenthrin+starbunch', 'Bifenthrin+Starbunch'       , @case_sensitive=1     , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'bensulfuron-Methyl', 'Bensulfuron Methyl'           , @case_sensitive=1     , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Benzyl C12 Alkyldimethylchloride','Benzyl C12 Alkyldimethyl Chloride',         @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'benzyl-C12-18-Alkyldimethyl Chloride)','Benzyl-C12-18-Alkyldimethyl Chloride', @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'beta-Cyfluthrin', 'Beta-Cyfluthrin'                 , @case_sensitive=0     , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Betacyfluthrin', 'Beta-Cyfluthrin'                  , @case_sensitive=1     , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'bispyribac', 'Bispyribac'                           , @case_sensitive=1     , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'bispyribac', 'Bispyribac'                           , @case_sensitive=1     , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Bifenthrin/starbunch 2% Masterbatch' , 'Bifenthrin+starbunch 2% Masterbatch', @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'bifenthrin'                          , 'Bifenthrin' , @case_sensitive=1     , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Bordeaux Mixture Micronized Tricalcium Tetracupric Sulfate' ,'Bordeaux Mixture',@fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Bordeux Mixture','Bordeaux Mixture'                                         , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'bpmc', 'BPMC'                                       , @case_sensitive=1     , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_log 2, @fn, '15:'
   EXEC sp_fixup_s2_chems_hlpr 'Branched/hydrocarbons', 'Branched Hydrocarbons'                             , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'bufrofezin/banaflex 21% Mb', 'Bufrofezin'                                   , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'buprofezin', 'Bufrofezin'                                                   , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'butachlor', 'Butachlor'                             , @case_sensitive=1     , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'C14c18alkyl', 'C14 18 Alkyl', @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Calciumalkyl Benzene Sulfonate', 'Calcium Alkyl Benzene Sulfonate'          , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'calcium Dodecylbenzene','Calcium Dodecylbenzene',     @case_sensitive=1     , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_log 2, @fn, '20:'
   EXEC sp_fixup_s2_chems_hlpr 'carbendazim' , 'Carbendazim'                                                , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'chlorimuron' , 'Chlorimuron'                                                , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'chloropicrin', 'Chloropicrin'                                               , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'chlorpyrifos', 'Chlorpyrifos'                                               , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'clothianidin', 'Clothianidin'                                               , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Condenced Oligosaccharides', 'Condensed Oligosaccharides'                   , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_log 2, @fn, '25:'
   EXEC sp_fixup_s2_chems_hlpr 'copper Hydroxide', 'Copper Hydroxide'               , @case_sensitive=1     , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'cyhalofop-Butyl', 'Cyhalofop-Butyl'                 , @case_sensitive=1     , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Cymoxamil', 'Cymoxanil'                                                     , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'cypermethrin', 'Cypermethrin'                       , @case_sensitive=1     , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_log 2, @fn, '30:'
   EXEC sp_fixup_s2_chems_hlpr 'Dialkyl Dimethyl Ammonium Chloride', 'Didecyl dimethyl ammonium chloride', @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Dibromo-3-Nitropropionamide', 'Dibromo-3-Nitrilopropionamide'               , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'didecyldimethyllammonium Chloride', 'Didecyl Dimethyl Ammonium Chloride'    , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Didecyl Dimethyl Ammonium Chloride', 'Didecyl Dimethyl Ammonium Chloride', @case_sensitive=1     , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'difenoconazole', 'Difenoconazole'                   , @case_sensitive=1     , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'dimethomorph', 'Dimethomorph'                       , @case_sensitive=1     , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'diuron', 'Diuron'                                   , @case_sensitive=1     , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_log 2, @fn, '35:'
   EXEC sp_fixup_s2_chems_hlpr 'Elemental Sulfur','Sulfur'                         , @case_sensitive=1     , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'ethoxysulfuron', 'Ethoxysulfuron'                   , @case_sensitive=1     , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'famoxadone', 'Famoxadone'                           , @case_sensitive=1     , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'florpyrauxifen', 'Florpyrauxifen'                   , @case_sensitive=1     , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Fludioxinil', 'Fludioxonil'                                                 , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Gamma-Cyhalothrin', 'Cyhalothrin'                                           , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_log 2, @fn, '40:'
   EXEC sp_fixup_s2_chems_hlpr 'Gibberellic Acid', 'Gibberellin'                                            , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Glufosinate Ammonium', 'Glufosinate-Ammonium'
   EXEC sp_fixup_s2_chems_hlpr 'Glyphosate Ammonium' ,'Glyphosate-Ammonium'                                 , @fixup_cnt=@delta_fixup_cnt OUT                                    -- 230721
   EXEC sp_fixup_s2_chems_hlpr 'Glyphosate As Potassium Salt','Glyphosate-potassium'                        , @fixup_cnt=@delta_fixup_cnt OUT;  
   EXEC sp_fixup_s2_chems_hlpr 'Glyphosate Ipa','Glyphosate-Ipa'                                            , @fixup_cnt=@delta_fixup_cnt OUT;                                    -- 230721
   EXEC sp_fixup_s2_chems_hlpr 'Glyphosate-potassium', 'Glyphosate-Potassium', @case_sensitive=1            , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Heavy Paraffinic', 'Heavy Paraffinic Oil'                                   , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Hydrotreated Light, Heavy Paraffinic Andnapthenic Oil', 'Paraffin+napthenic Oil'    , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Hydrotreated Light,Heavy Paraffinic Oil AndNapthenic Oil', 'Paraffin+Napthenic Oil' , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Hydrotreated Light Paraffinic Distillates', 'Paraffin'                      , @fixup_cnt=@delta_fixup_cnt OUT;                                    -- 230721
   EXEC sp_log 2, @fn, '45:'
   EXEC sp_fixup_s2_chems_hlpr 'imidacloprid', 'Imidacloprid'                       , @case_sensitive=1     , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Iminoctadine Tris (albesilate)', 'Iminoctadine Tris (Albesilate)'           , @case_sensitive=1     , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Lambdacyhalothrin','Lambda-Cyhalothrin'                                     , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'mancozeb', 'Mancozeb'                               , @case_sensitive=1     , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Mesotrione, Glyphosate, S-Metachlor', 'Mesotrione+Glyphosate+S-Metachlor'   , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'metalaxyl-M', 'Metalaxyl-M'                                                 , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_log 2, @fn, '50:'
   EXEC sp_fixup_s2_chems_hlpr 'Metalaxyl-M+mancozeb', 'Metalaxyl-M+Mancozeb'                               , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'metalaxyl','Metalaxyl'                                                      , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Metam Sodium', 'Metam-Sodium'                                                                  , @fixup_cnt=@delta_fixup_cnt OUT
   EXEC sp_fixup_s2_chems_hlpr 'mipc', 'Mipcin'                                                             , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;                                   
   EXEC sp_fixup_s2_chems_hlpr 'napthenic Oil', 'Napthenic Oil'                                             , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_log 2, @fn, '55:'
   EXEC sp_fixup_s2_chems_hlpr 'nonypenol- Polyglycother', 'Nonylphenol Polyethylene Glycol Ether'          , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Oxadiazinon', 'Oxadiazon'                                                   , @fixup_cnt=@delta_fixup_cnt OUT;
   UPDATE Staging2 SET ingredient = 'Oxytetracycline' WHERE ingredient='Oxytetracycline Hci';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   UPDATE Staging2 SET ingredient = 'Paraffin'        WHERE ingredient LIKE '%Paraffinic%Oil%';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   EXEC sp_fixup_s2_chems_hlpr 'peg-300', 'Peg-300'                                                         , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'peg 300 Di-Oleate(di- Ester)', 'Peg-300'                                    , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'peg 300 Di-Oleate'           , 'Peg-300'                                    , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr '+Peg-300+Peg-300'            , 'Peg-300'                                    , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_log 2, @fn, '60:'
   EXEC sp_fixup_s2_chems_hlpr 'Pentapotassuim Bis (peroxymonosulfate) Bis(sufate)' , 'Potassium Peroxymonosulfate' , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Pentapotassuim Bis (peroxymonosulfate) Bis (sufate)', 'Potassium Peroxymonosulfate' , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Phosphorous Acid Technical','Phosphoric Acid'                                       , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'piperonyl butoxide', 'Piperonyl Butoxide'                                   , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'piperonybutoxide','Piperonyl Butoxide'                                      , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'plastech','Plastech'                                                        , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'pyritiline','Pyritiline'                                                    , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Polyether-Polymethylsiloxane Copolymer','Polyoxyethylene Alkyl Ether'       , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'polyoxyethylene Alkyl Ether','Polyoxyethylene Alkyl Ether'                  , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'polyoxyethylene Dodecyl Ether','Polyoxyethylene Dodecyl Ether'              , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'polyalkylene', 'Polyalkylene'                                               , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Polyalkylene Oxide Blockcopolymer','Polyalkylene Oxide Block Copolymer'     , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Polyethylene Sorbitanoleats', 'Polyethylene Sorbitan Oleate'                , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Polyethylene Sorbitan Oleats','Polyethylene Sorbitan Oleate'                , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_log 2, @fn, '65:'
   EXEC sp_fixup_s2_chems_hlpr 'Polyoxyethylene Sorbitanmonooleate', 'Polyoxyethylene Sorbitan Monooleate'  , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Polyoxyethylene Sorbitan Fattyacid','Polyoxyethylene Sorbitan Fatty Acid'   , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'polyoxyethylene', 'Polyoxyethylene'                    , @case_sensitive=1  , @fixup_cnt=@delta_fixup_cnt OUT;
   UPDATE Staging2 SET ingredient  = 'Potassium Hydrogencarbonate' WHERE ingredient='Potassium Hydrogenerated Carbonate';
   EXEC sp_fixup_s2_chems_hlpr 'polyoxyethylene', 'Polyoxyethylene'                    , @case_sensitive=1  , @fixup_cnt=@delta_fixup_cnt OUT;
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   EXEC sp_fixup_s2_chems_hlpr 'Potassium Peroxymonosulphate', 'Potassium Peroxymonosulfate'                , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Potassium salts of fatty acid', 'Potassium Salts of Fatty Acids'            , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Pottasium Silicate','Potassium Silicate'                                    , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_log 2, @fn, '70:'
   EXEC sp_fixup_s2_chems_hlpr 'pretilachlor', 'Pretilachlor'                                               , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'propamocarb Hci', 'Propamocarb-Hydrochloride'                               , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Propamocarb Hcl', 'Propamocarb-Hydrochloride'                               , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'propamocarb Hcl', 'Propamocarb-Hydrochloride'                               , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'propamocarb-hydrochloride', 'Propamocarb-Hydrochloride'                     , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'propanil', 'Propanil'                                                       , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'propiconazole', 'Propiconazole'                                             , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'pymetrozine', 'Pymetrozine'                                                 , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_log 2, @fn, '75:'
   EXEC sp_fixup_s2_chems_hlpr 'pyrimethanil', 'Pyrimethanil'                                               , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT
   EXEC sp_fixup_s2_chems_hlpr 'pyriproxyfen', 'Pyriproxyfen'                                               , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT 
   EXEC sp_fixup_s2_chems_hlpr 'safener', 'Safener'                                                         , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'sodium Dichloroisocyanurate', 'Sodium Dichloroisocyanurate'                 , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   UPDATE Staging2 SET ingredient  = 'Sulphur' WHERE ingredient='Sulfur'
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   EXEC sp_fixup_s2_chems_hlpr 'tebuconazole', 'Tebuconazole'                                               , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'tetraconazole', 'Tetraconazole'                                             , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_log 2, @fn, '80: '
   EXEC sp_fixup_s2_chems_hlpr 'tetrametrin', 'Tetramethrin'                                                , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'thiamethoxam', 'Thiamethoxam'                                               , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'thiamethoxam', 'Thiamethoxam'                                               , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'thiencarbazone-Methyl','Thiencarbazone-Methyl'                              , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Thiodiazole','Thiodiazole Copper'                                           , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'thiodicarb','Thiodicarb'                                                    , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'triadimenol', 'Triadimenol'                                                 , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'triafamone', 'Triafamone'                                                   , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;

   EXEC sp_log 2, @fn, '85: '
   EXEC sp_fixup_s2_chems_hlpr 'Tricalciumtetracupric Sulfate', 'Tricalcium Tetra Cupric Sulfate'           , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'trifloxystrobin', 'Trifloxystrobin'                                         , @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Z-9tetradecenol', 'Z-9 tetradecenol'                                        , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr '(z,e)-9,12-Tetradecadien-1-Yl Acetate)', 'Z,e-9,12-Tetradecadienyl Acetate' , @fixup_cnt=@delta_fixup_cnt OUT;
   EXEC sp_fixup_s2_chems_hlpr 'Z,e-9,12- Tetradecadienyl Acetate',      'Z,e-9,12-Tetradecadienyl Acetate' , @fixup_cnt=@delta_fixup_cnt OUT;

   SET @fixup_cnt = @fixup_cnt + @delta_fixup_cnt
   EXEC sp_log 2, @fn, '99: leaving, made: ',@delta_fixup_cnt, ' changes';
END 
/*
--------------------------------------
EXEC sp_copy_s3_s2;
EXEC sp_fixup_s2_chems;
SELECT chemical from dbo.fnListChemicals() where chemical >= 'Peg' ORDER BY chemical;
SELECT chemical from dbo.fnListChemicals() where chemical like '%beta%' ORDER BY chemical;
--------------------------------------------------------------------------------------------------------
DECLARE @delta_fixup_cnt INT = 0;
EXEC sp_fixup_s2_chems_hlpr 'peg 300 Di-Oleate(diester)', 'Peg 300 Di-Oleate(diester)', @case_sensitive=1, @fixup_cnt=@delta_fixup_cnt OUT;
PRINT @delta_fixup_cnt;
-----------------------------------------------------------------------------------------------------------

Alkyl Dimethyl Benzyl Ammonium Chloride
alkyl Dimethyl Benzyl ammonium Chloride
--------------------------------------
SELECT distinct ingredient FROM staging2 WHERE ingredient LIKE '%Ametryn%'-- COLLATE Latin1_General_CS_AI;
SELECT id, ingredient FROM staging2            WHERE ingredient LIKE '%alkyl Dimethyl Benzyl ammonium Chloride%'-- COLLATE Latin1_General_CS_AI;
SELECT id, ingredient FROM staging2_bak_221008 WHERE ingredient LIKE '%alkyl Dimethyl Benzyl ammonium Chloride%'-- COLLATE Latin1_General_CS_AI;
SELECT distinct ingredient FROM staging1  ORDER BY ingredient;
SELECT distinct ingredient FROM staging2  where INGREDIENT LIKE '%+%' ORDER BY ingredient;
SELECT distinct ingredient FROM [dbo].[staging2_bak_221008] ORDER BY ingredient;
SELECT distinct ingredient FROM staging2  ORDER BY ingredient;
SELECT chemical from dbo.fnListChemicals(0) ORDER BY chemical;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================================================
-- Author:      Terry Watts
-- Create date: 21-AUG-2023
-- Description: Stage 2 company fixup
--
-- CHANGES:
-- 05-MAR-2024: added 'Sinochem Crop Protection (phils.) Inc.' -> 'Sinochem'
-- =============================================================================
ALTER PROCEDURE [dbo].[sp_fixup_s2_company]
     @fixup_cnt       INT = NULL OUT
AS
BEGIN
   SET NOCOUNT OFF
   DECLARE
       @fn              NVARCHAR(35) = 'FIXUP S2 COMPANY'

   --SET @fixup_cnt = Ut.dbo.fnGetSessionContextAsInt(N'fixup count');
   EXEC sp_log 2, @fn, '01: starting, @fixup_cnt: ',@fixup_cnt;
   EXEC sp_register_call @fn;

   UPDATE staging2 SET company = '2HJL Development Co.'   WHERE Company = '2hjl Development Co.';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   UPDATE staging2 SET company = 'B.M.Cusipag Agri Trade' WHERE Company = 'B.m. Cusipag Agri Trade' ;
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   UPDATE staging2 SET company = 'Sinochem'   WHERE Company = 'Sinochem Crop Protection (phils.) Inc.';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   EXEC sp_log 2, @fn, '99: leaving, @fixup_cnt: ',@fixup_cnt;
END
/*
DECLARE @fixup_cnt       INT = 0
EXEC sp_fixup_s2_company  @fixup_cnt  OUT
PRINT CONCAT('@fixup_cnt: ', @fixup_cnt);
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:       Terry Watts
-- Create date:  04-AUG-2023
-- Description:  sp_fixup_s1_mrl row helper
-- ======================================================================================================
ALTER PROCEDURE [dbo].[sp_fixup_s1_mrl_hlpr]
       @search_clause   NVARCHAR(100)
      ,@replace_clause  NVARCHAR(100)
      ,@fixup_cnt       INT OUT
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(30)  = N'FIXUP S1 MRL HLPR'
      ,@delta     INT
   SET NOCOUNT ON
   UPDATE staging1 SET mrl = @replace_clause WHERE mrl LIKE @search_clause;
   SET @delta =  @@ROWCOUNT;
   SET @fixup_cnt = @fixup_cnt + @delta;
   EXEC sp_log 2, @fn, 'fixup count: ',@fixup_cnt, ' SRC: ',@search_clause, ' REP: ', @replace_clause;
END
/*
EXEC sp_copy_s1_bak_s1;
EXEC dbo.sp_fixup_s1;
---------------------------------------
DECLARE  @fixup_cnt    INT = 0;
EXEC dbo.sp_fixup_s1_mrl @fixup_cnt OUT;
PRINT CONCAT('fixup_cnt: ',@fixup_cnt);
SELECT DISTINCT mrl FROM staging1 ORDER BY mrl;
---------------------------------------
SELECT id, mrl from staging1 where mrl like CONCAT('%',NCHAR(10),'%');
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 04-AUG-2023
-- Description: Fixup the Stage 1 mrl field
-- ======================================================================================================
ALTER PROCEDURE [dbo].[sp_fixup_s2_mrl] 
   @fixup_cnt INT = NULL OUT
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn                       NVARCHAR(30)  = N'FIXUP S2 MRL'

   EXEC sp_log 2, @fn,'01: starting: @fixup_cnt: ',@fixup_cnt;
   EXEC sp_register_call @fn;

   UPDATE staging1 SET mrl = REPLACE(mrl, NCHAR(10), ',') WHERE mrl LIKE CONCAT('%',NCHAR(10),'%');
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   EXEC sp_fixup_s1_mrl_hlpr '-'                                                 , NULL                                                         , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '--'                                                , NULL                                                         , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '.'                                                 , NULL                                                         , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '_'                                                 , NULL                                                         , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '='                                                 , NULL                                                         , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.0ppm'                                            , '0.0 ppm'                                                    , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.01 ug/g'                                         , '0.01 µg/g'                                                  , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.02 mg/ kg Pyriftalid  0.02,mg/kg Bensulfuron-methyl','Pyriftalid: 0.02 mg/kg, Bensulfuron-methyl: 0.02 mg/kg'   , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.03 ppm,0.03 ppm'                                 , '0.03 ppm, 0.03 ppm'                                         , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.05 Ág/g'                                         , '0.05 µg/g'                                                  , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.05-0.10'                                         , '0.05-0.10 ppm'                                              , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.2mg/ kg'                                         , '0.2 mg/kg'                                                  , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.2mg/Kg'                                          , '0.2 mg/kg'                                                  , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.2ppm'                                            , '0.2 ppm'                                                    , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.5mg/Kg'                                          , '0.5 mg/kg'                                                  , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.5ppm'                                            , '0.5 ppm'                                                    , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.5ppm Thiamethoxam;, 0.5ppm Lambdacyhalothrin'    , 'Thiamethoxam: 0.5 ppm, Lambdacyhalothrin: 0.5 ppm'          , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.60 ppm'                                          , '0.6 ppm'                                                    , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.80ppm'                                           , '0.8 ppm'                                                    , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.8ppm'                                            , '0.8 ppm'                                                    , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '1.00 ppm'                                          , '1 ppm'                                                      , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '1ppm'                                              , '1 ppm'                                                      , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '1.0ppm'                                            , '1 ppm'                                                      , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '1.0ppm Thiamethoxam; 0.50ppm Lambdacyhalothrin'    , 'Thiamethoxam: 1 ppm, Lambdacyhalothrin: 0.50 ppm'           , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '2.0ppm'                                              , '2 ppm'                                                    , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '10ppm'                                             , '10 ppm'                                                     , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Azoxystrobin 0.01ppm,Difenoconazole 0.01ppm'       , 'Azoxystrobin: 0.01 ppm, Difenoconazole: 0.01 ppm'           , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Azoxystrobin 0.05ppm Difenoconazole 0.1ppm'        , 'Azoxystrobin: 0.05 ppm, Difenoconazole: 0.1 ppm'            , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Azoxystrobin 0.20ppm Tebuconazole 0.10ppm'         , 'Azoxystrobin: 0.2 ppm, Tebuconazole: 0.10 ppm'              , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Azoxystrobin 0.2ppm Difenoconazole 0.07ppm'        , 'Azoxystrobin: 0.2 ppm, Difenoconazole: 0.07 ppm'            , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Azoxystrobin-0.01 Difenoconazole-0.01'             , 'Azoxystrobin: 0.01 ppm, Difenoconazole: 0.01 ppm'           , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Azoxystrobin-0.01 mg/Kg; Difenoconazole-0.01 mg/Kg', 'Azoxystrobin: 0.01 mg/kg; Difenoconazole: 0.01 mg/kg'       , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Azoxystrobin-0.2 Difenoconazole-0.07'              , 'Azoxystrobin: 0.2 ppm, Difenoconazole: 0.07 ppm'            , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Azoxystrobin-0.3 mg/Kg; Difenoconazole-0.3 mg/Kg'  , 'Azoxystrobin: 0.3 mg/kg, Difenoconazole: 0.3 mg/kg'         , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Azoxystrobin-1.0ppm Tebuconazole-0.1ppm'           , 'Azoxystrobin: 1 ppm, Tebuconazole: 0.1 ppm'                 , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Azoxystrobin-5.0 ppm Tebuconazole-1.0ppm'          , 'Azoxystrobin: 5.0 ppm, Tebuconazole: 1 ppm'                 , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.1 mg/kg (Beta-cyfluthrin) ; 0.7 mg/ kg (Imidacloprid)','Beta-cyfluthrin: 0.1 mg/kg, Imidacloprid: 0.7 mg/kg'    , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Beta-cyfluthrin 0.02ppm,Imidacloprid 0.20ppm'      , 'Beta-cyfluthrin: 0.02 ppm, Imidacloprid: 0.20 ppm'          , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Buprofezin 0.5ppm MIPC 0.5ppm'                     , 'Buprofezin: 0.5 ppm, MIPC: 0.5 ppm'                         , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Butachlor 0.1ppm Propanil 0.1ppm'                  , 'Butachlor: 0.1 ppm Propanil: 0.1 ppm'                       , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Difenoconazole 0.5ppm Propiconazole 0.5ppm'        , 'Difenoconazole: 0.5 ppm Propiconazole: 0.5 ppm'             , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Fenoxaprop p-ethyl 0.05ppm Ethoxysulfuron 0.01 ppm', 'Fenoxaprop p-ethyl 0.05 ppm, Ethoxysulfuron: 0.01 ppm'      , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '1.0 mg/kg Floupyram 0.7,mg/kg Trifloxystobin'      , 'Floupyram: 1.0 mg/kg, Trifloxystobin: 0.7,mg/kg'            , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Imidacloprid = 2.0 Ág/g Deltamethrin -  0.5Ág/g'   , 'Imidacloprid: 2.0 µg/g, Deltamethrin: 0.5 µg/g'             , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Phenthoate-0.05 ppm'                               , 'Phenthoate: 0.05 ppm'                                       , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Tebuconazole-0.05 ppm;Triadimenol-0.2 ppm'         , 'Tebuconazole: 0.05 ppm, Triadimenol: 0.2 ppm'               , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Tebuconazole-0.09 Trifloxystrobin-0.08'            , 'Tebuconazole: 0.09 ppm, Trifloxystrobin: 0.08 ppm'          , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'z', 'z'                                                                                                           , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.02 mg/ kg Pyriftalid  0.02,mg/kg Bensulfuron-methyl', 'Pyriftalid: 0.02 mg/kg, Bensulfuron-methyl: 0.02 mg/kg'  , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.005ppm',										                  '0.005 ppm'                                              , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.01 mg/ Kg',                                            '0.01 mg/kg'                                             , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.008-Tebuconazole 0.01- Trifloxystrobin',               'Tebuconazole: 0.008, Trifloxystrobin: 0.01'             , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.008-Tebuconazole 0.01-,Trifloxystrobin',               'Tebuconazole: 0.008, Trifloxystrobin: 0.01'             , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.01 mg/kg Clothianidin 0.05,mg/kg Imidacloprid',        'Clothianidin: 0.01 mg/kg, Imidacloprid 0.05 mg/kg'      , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.01 mg/kg(Tefuryltrione),0.01 mg/kg(Triafamone)',       'Tefuryltrione: 0.01 mg/kg, Triafamone: 0.01 mg/kg'      , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.01 ppm(Mesotrione)',                                   'Mesotrione: 0.01 ppm'                                   , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.01 ug/g',                                              '0.01 ug/g'                                              , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.01ppm',                                                '0.01 ppm'                                               , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.02 mg/ Kg',                                            '0.02 mg/kg'                                             , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.02 mg/kg Floupyram; 0.08,mg/kg Trifloxystrobin',       'Floupyram: 0.02 mg/kg, Trifloxystrobin: 0.08mg/kg'      , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.02 mg/kg Isoxafloute 0.03,mg/kg Thiencarbazone-',      'Isoxafloute: 0.02 mg/kg, Thiencarbazone: 0.03 mg/kg'    , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.02ppm',                                                '0.02 ppm'                                               , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.03 mg/Kg',                                             '0.03 mg/kg'                                             , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.04 mg/Kg',                                             '0.04 mg/kg'                                             , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.05 mg/Kg Fluopicolide; 0.3 mg/Kg Propamocarb HCI',     'Fluopicolide: 0.05 mg/kg, Propamocarb HCI: 0.3 mg/kg'   , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.05ppm',                                                '0.05 ppm'                                               , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.05ppm Thiamethoxam; 0.5ppm Lambdacyhalothrin',         'Thiamethoxam: 0.05 ppm, Lambdacyhalothrin: 0.5 ppm'     , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.05ppm Thiamethoxam;,0.5ppm Lambdacyhalothrin',         'Thiamethoxam: 0.05 ppm, Lambdacyhalothrin: 0.5 ppm'     , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.0603 Áq/q',                                            '0.0603 ug/q'                                            , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.07 mg/Kg (Floupyram) 0.08 mg/Kg (Trifloxystrobin)',    'Floupyram: 0.07 mg/kg, Trifloxystrobin: 0.08 mg/kg '    , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.1 mg/kg (Beta-cyfluthrin) ;,0.7 mg/ kg (Imidacloprid)','Beta-cyfluthrin: 0.1 mg/kg, Imidacloprid: 0.7 mg/kg'    , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.1 Thiamethoxam; 0.1,Lambdacyhalothrin',                'Thiamethoxam: 0.1, Lambdacyhalothrin: 0.1'              , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.1 Thiamethoxam; 0.1 Lambdacyhalothrin',                'Thiamethoxam: 0.1, Lambdacyhalothrin: 0.1'              , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.1 Thiamethoxam; 0.2 Lambdacyhalothrin',                '0.1 Thiamethoxam: 0.2 Lambdacyhalothrin'                , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.1 Thiamethoxam; 0.2,Lambdacyhalothrin',                '0.1 Thiamethoxam: 0.2 Lambdacyhalothrin'                , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.1 Thiamethoxam: 0.2 Lambdacyhalothrin',                'Thiamethoxam: 0.1, Lambdacyhalothrin: 0.2'              , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.15 mg/kg Floupyram; 0.02,mg/kg Trifloxystrobin',       'Floupyram: 0.15 mg/kg,Trifloxystrobin: 0.02 mg/kg'      , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.1ppm',                                                 '0.1 ppm'                                                , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.2 Thiamethoxam; 0.2 Lambdacyhalothrin',                'Thiamethoxam: 0.2, Lambdacyhalothrin: 0.2'              , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.2 Thiamethoxam; 0.2,Lambdacyhalothrin',                'Thiamethoxam: 0.2, Lambdacyhalothrin: 0.2'              , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.20 mg/kg',                                             '0.2 mg/kg'                                              , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.20 ppm',                                               '0.2 ppm'                                                , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.20-2.0 mg/kg',                                         '0.2-2.0 mg/kg'                                          , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.3mg/kg',                                               '0.3 mg/kg'                                              , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.3ppm',                                                 '0.3 ppm'                                                , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.4 mg/Kg',                                              '0.4 mg/kg'                                              , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.40 mg/kg Floupyram; 1.00,mg/kg Trifloxystrobin',       'Floupyram: 0.4 mg/kg, Trifloxystrobin: 1 mg/kg'         , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.5 mg/kg Floupyram 0.1,mg/kg Trifloxystrobin',          'Floupyram: 0.5 mg/kg, Trifloxystrobin: 0.1,mg/kg'       , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.5 mg/kg Floupyram 1.0,mg/kg Trifloxystrobin',          'Floupyram: 0.5 mg/kg, Trifloxystrobin: 1,mg/kg'         , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.5 ppm Thiamethoxam; 0.5 ppm, Lambdacyhalothrin',       'Thiamethoxam: 0.5 ppm, Lambdacyhalothrin: 0.5 ppm'      , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.50 ppm',                                               '0.5 ppm'                                                , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.5 Thiamethoxam; 0.2(with pod) Lambdacyhalothrin',      'Thiamethoxam: 0.5, Lambdacyhalothrin: 0.2'              , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.5 Thiamethoxam; 0.2(with,pod) Lambdacyhalothrin',      'Thiamethoxam: 0.5, Lambdacyhalothrin: 0.2'              , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.5ppm Thiamethoxam;,0.5ppm Lambdacyhalothrin',          'Thiamethoxam: 0.5 ppm, Lambdacyhalothrin: 0.5 ppm'      , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.60 mg/kg',                                             '0.6 mg/kg'                                              , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.6-mg/kg(Tebuconazole),0.01mg/kg(Fluoxastrobin)',       'Tebuconazole: 0.6 mg/kg, Fluoxastrobin: 0.01 mg/kg'     , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.80 ppm',                                               '0.8 ppm'                                                , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '0.90 ppm',                                               '0.9 ppm'                                                , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '1.0 mg/kg',                                              '1 mg/kg'                                                , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '1.0 mg/kg, Fluopyram: 1.5 mg/Kg',                        '1 mg/kg, Fluopyram: 1.5 mg/Kg'                          , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '1.0 ppm',                                                '1 ppm'                                                  , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '1 ppm Thiamethoxam, 0.50 ppm, Lambdacyhalothrin',        'Thiamethoxam: 1 ppm, Lambdacyhalothrin: 0.50 ppm'       , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '1 mg/kg Fluopicolide  2mg/kg,Propamocarb HCI',           'Fluopicolide: 1 mg/kg, Propamocarb HCI: 2 mg/kg'        , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '1.0 mg/kg Fluopyram 1.5 mg/Kg',                          '1.0 mg/kg, Fluopyram: 1.5 mg/kg'                        , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '1.0ppm Thiamethoxam;,0.50ppm Lambdacyhalothrin',         'Thiamethoxam: 1.0 ppm, Lambdacyhalothrin: 0.50 ppm'     , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '10.0 mg/kg',                                             '10 mg/kg'                                               , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '2.0 mg/Kg',                                              '2 mg/kg'                                                , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '2 mg/Kg',                                                '2 mg/kg'                                                , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '2.0 ppm',                                                '2 ppm'                                                  , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '2.00 ppm',                                               '2 ppm'                                                  , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '2.0mg/Kg',                                               '2 mg/kg'                                                , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '3.0 mg/kg',                                              '3 mg/kg'                                                , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '3.0 ppm',                                                '3 ppm'                                                  , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '3.0 mg/kg Floupyram 0.1 mg/kg Trifloxystrobin',          'Floupyram: 3 mg/kg, Trifloxystrobin: 0.1 mg/kg'         , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '3.00 ppm',                                               '3 ppm'                                                  , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '3ppm',                                                   '3 ppm'                                                  , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '4.0 ppm',                                                '4 ppm'                                                  , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '5.0 mg/Kg',                                              '5 mg/kg'                                                , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '6 mg/Kg',                                                '6 mg/kg'                                                , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '5 mg/kg Propamocarb HCI 0.5 mg/kg Fluopicolide',         'Propamocarb HCI: 5 mg/kg, Fluopicolide: 0.5 mg/kg'      , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr '5.00 ppm',                                               '5 ppm'                                                  , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Azoxystrobin 0.01 mg/Kg; Difenoconazole 0.01 mg/Kg',     'Azoxystrobin: 0.01 mg/kg, Difenoconazole: 0.01 mg/kg'   , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Azoxystrobin 0.01 ppm, Difenoconazole 0.01 ppm',         'Azoxystrobin: 0.01 ppm, Difenoconazole: 0.01 ppm'       , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Azoxystrobin 0.05 ppm, Difenoconazole 0.1 ppm',          'Azoxystrobin: 0.05 ppm, Difenoconazole: 0.1 ppm'        , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Azoxystrobin 0.05ppm,Difenoconazole 0.1ppm',             'Azoxystrobin: 0.05 ppm, Difenoconazole 0.1 ppm'         , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Azoxystrobin 0.06ppm,Difenoconazole 0.4ppm',             'Azoxystrobin: 0.06 ppm, Difenoconazole: 0.4 ppm'        , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Azoxystrobin 0.2 ppm, Difenoconazole 0.07 ppm',          'Azoxystrobin: 0.2 ppm, Difenoconazole: 0.07 ppm'        , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Azoxystrobin 0.2 ppm, Difenoconazole-0.07 ppm',          'Azoxystrobin: 0.2 ppm, Difenoconazole: 0.07 ppm'        , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Azoxystrobin 0.2 ppm, Tebuconazole 0.10 ppm',            'Azoxystrobin: 0.2 ppm, Tebuconazole 0.10 ppm'           , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Azoxystrobin 0.2ppm,Difenoconazole 0.07ppm',             'Azoxystrobin: 0.2 ppm, Difenoconazole: 0.07 ppm'        , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Azoxystrobin 0.3 mg/Kg, Difenoconazole 0.3 mg/Kg',       'Azoxystrobin: 0.3 mg/kg, Difenoconazole: 0.3 mg/kg'     , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Azoxystrobin 0.6ppm,Difenoconazole 0.4ppm',              'Azoxystrobin: 0.6 ppm,Difenoconazole: 0.4 ppm'          , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Azoxystrobin 1 ppm, Tebuconazole 0.1 ppm',               'Azoxystrobin: 1 ppm, Tebuconazole: 0.1 ppm'             , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Azoxystrobin 5.0 ppm, Tebuconazole 1 ppm',               'Azoxystrobin: 5 ppm, Tebuconazole: 1 ppm'               , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Azoxystrobin: 0.01 ppm, Difenoconazole: 0.01 ppm',       'Azoxystrobin: 0.01 ppm, Difenoconazole: 0.01 ppm'       , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Azoxystrobin-0.01,Difenoconazole-0.01',                  'Azoxystrobin: 0.01 ppm, Difenoconazole: 0.01 ppm'       , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Azoxystrobin-0.05,Difenoconazole-0.01',                  'Azoxystrobin: 0.05 ppm, Difenoconazole: 0.01 ppm'       , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Azoxystrobin-0.6,Difenoconazole-0.4',                    'Azoxystrobin: 0.6 ppm, Difenoconazole: 0.4 ppm'         , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Azoxystrobin-1.0ppm,Tebuconazole-0.1ppm',                'Azoxystrobin 1 ppm, Tebuconazole: 0.1 ppm'              , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Beta-cyfluthrin: 0.02 ppm, Imidacloprid: 0.20 ppm',      'Beta-cyfluthrin: 0.02 ppm, Imidacloprid: 0.20 ppm'      , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Buprofezin 0.5 ppm, MIPC 0.5 ppm',                       'Buprofezin: 0.5 ppm, MIPC: 0.5 ppm'                     , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Buprofezin 0.5ppm,MIPC 0.5ppm',                          'Buprofezin: 0. 5ppm, MIPC: 0.5 ppm'                     , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Butachlor 0.1 ppm Propanil 0.1 ppm',                     'Butachlor: 0.1 ppm, Propanil: 0.1 ppm'                  , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Butachlor 0.1ppm 2,4-D IBE 0.1ppm',                      'Butachlor: 0.1ppm 2,4-D IBE: 0.1 ppm'                   , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Butachlor 0.1ppm,2,4-D IBE 0.1ppm',                      'Butachlor: 0.1ppm,2,4-D IBE 0.1 ppm'                    , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Butachlor 0.1ppm,Propanil 0.1ppm',                       'Butachlor: 0.1ppm, Propanil: 0.1 ppm'                   , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Cabbage: 3ppm, broccoli &,cauliflower: 2 ppm',           'Cabbage: 3 ppm, Broccoli & cauliflower: 2 ppm'          , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Cucumber & melon: 0.2 ppm, watermelon and other',        'Cucumber & melon: 0.2 ppm, Watermelon and other'        , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Cyantraniliprole 4mg/kg,Pymetrozine 1mg/kg',             'Cyantraniliprole: 4 mg/kg, Pymetrozine: 1 mg/kg'        , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Difenoconazole 0.5 ppm Propiconazole 0.5 ppm',           'Difenoconazole: 0.5 ppm, Propiconazole: 0.5 ppm'        , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Difenoconazole 0.5ppm,Propiconazole 0.5ppm',             'Difenoconazole: 0.5 ppm, Propiconazole: 0.5 ppm'        , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Fenoxaprop p-ethyl 0.05 ppm, Ethoxysulfuron 0.01 ppm',   'Fenoxaprop p-ethyl: 0.05 ppm, Ethoxysulfuron: 0.01 ppm' , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Fenoxaprop p-ethyl 0.05ppm,Ethoxysulfuron 0.01 ppm',     'Fenoxaprop p-ethyl: 0.05ppm, Ethoxysulfuron: 0.01 ppm'  , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Floupyram: 1.0 mg/kg, Trifloxystobin: 0.7,mg/kg',        'Floupyram: 1.0 mg/kg, Trifloxystobin: 0.7 mg/kg'        , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Imidacloprid - 0.005 ppm Deltamethrin -  0.02 ppm',      'Imidacloprid: 0.005 ppm, Deltamethrin: 0.02 ppm'        , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Imidacloprid - 0.005 ppm,Deltamethrin -  0.02 ppm',      'Imidacloprid: 0.005 ppm, Deltamethrin: 0.02 ppm'        , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Imidacloprid - 0.2 ppm,Deltamethrin -  0.5 ppm',         'Imidacloprid: 0.2 ppm, Deltamethrin: 0.5 ppm'           , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Imidacloprid - 0.5 ppm,Deltamethrin -  0.1 ppm',         'Imidacloprid: 0.5 ppm, Deltamethrin: 0.1 ppm'           , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Imidacloprid = 2.0 µg/g, Deltamethrin -  0.5 µg/g',      'Imidacloprid: 2.0 µg/g, Deltamethrin: 0.5 µg/g'         , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'M - 0.2 ppm B - 0.02 ppm',                               'M: 0.2 ppm, B: 0.02 ppm'                                , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Penoxsulam 0.1 ppm',                                     'Penoxsulam: 0.1 ppm'                                    , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Phenthoate 0.05 ppm',                                    'Phenthoate: 0.05 ppm'                                   , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Pyriftalid: 0.02 mg/kg, Bensulfuron-methyl: 0.02 mg/kg', 'Pyriftalid: 0.02 mg/kg, Bensulfuron-methyl: 0.02 mg/kg' , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Tebuconazole 0.05 ppm, Triadimenol-0.2 ppm',             'Tebuconazole: 0.05 ppm, Triadimenol: 0.2 ppm'           , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Tebuconazole 0.09 ppm, Trifloxystrobin 0.08 ppm',        'Tebuconazole: 0.09 ppm, Trifloxystrobin: 0.08 ppm'      , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Tebuconazole-0.01 mg/kg,Trifloxystrobin-0.05 mg/kg',     'Tebuconazole: 0.01 mg/kg, Trifloxystrobin: 0.05 mg/kg'  , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Tebuconazole-0.09,Trifloxystrobin-0.08',                 'Tebuconazole: 0.09, Trifloxystrobin: 0.08'              , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Tebuconazole-1.01 mg/kg,Trifloxystrobin-0.02 mg/kg',     'Tebuconazole: 1 mg/kg, Trifloxystrobin: 0.02 mg/kg'     , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Tetraconazole -0.5ppm,Carbendazim-0.5 ppm',              'Tetraconazole: 0.5ppm, Carbendazim: 0.5 ppm'            , @fixup_cnt OUT
   EXEC sp_fixup_s1_mrl_hlpr 'Triafamone: 0.01 mg/Kg,Ethoxysulfuron: 0.1 mg/Kg',       'Triafamone: 0.01 mg/kg, Ethoxysulfuron: 0.1 mg/kg'      , @fixup_cnt OUT

   EXEC sp_log 2, @fn,'99: leaving OK, @fixup_cnt: ', @fixup_cnt;
END
/*
EXEC sp_fixup_s2_mrl;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ================================================================================================================
-- Author:      Terry Watts
-- Create date: 28-JUN-2023
-- Description: tidies up staging 2 after import and copy s1-s2
-- Remove:
-- the page header rows
-- wrapping quotes
-- standarise commas and &
-- 
-- CHANGES:
-- 06-JUL-2023 pathogens: replace and with ,
-- 06-JUL-2023 pathogens: standardise each pathogen in pathogens to capitalise first character of the first word
-- 22-OCT-2023 added ingredient fixup
-- ================================================================================================================
ALTER PROCEDURE [dbo].[sp_fixup_s2]
AS
BEGIN
   DECLARE
       @fn                    NVARCHAR(35)  = N'FIXUP_S2'
      ,@rc                    INT
      ,@cnt                   INT =0
      ,@default_fld_val_dash  NVARCHAR(15)  = '--'
      ,@fixup_cnt             INT

   SET NOCOUNT OFF;

   BEGIN TRY
      SET @fixup_cnt = Ut.dbo.fnGetSessionContextAsInt(N'fixup count');
      EXEC sp_log 1, @fn, '00: starting, @fixup_cnt: ', @fixup_cnt;
      EXEC sp_register_call @fn;

      EXEC sp_log 1, @fn, '01: pathogens: trim [] brackets, @fixup_cnt: ', @fixup_cnt;
      UPDATE dbo.staging2 SET pathogens = REPLACE(pathogens, '[, ]', ', ') WHERE pathogens LIKE '%[, ]%';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      EXEC sp_log 1, @fn, '20: calling sp_fixup_s2_products';
      EXEC sp_fixup_s2_products @fixup_cnt = @fixup_cnt OUT;

      -- fixup pathogens
      EXEC sp_log 1, @fn, '30: calling sp_fixup_s2_pathogens';
      EXEC sp_fixup_s2_pathogens @fixup_cnt = @fixup_cnt OUT;

      -- Fixup the ingredient/chemical column
      EXEC sp_log 1, @fn, '40: calling sp_fixup_s2_chems';
      EXEC sp_fixup_s2_chems @fixup_cnt = @fixup_cnt OUT;

      -- Fixup crops
      EXEC sp_log 1, @fn, '50: calling sp_fixup_s2_crops';
      EXEC sp_fixup_s2_crops @must_update = 0, @fixup_cnt = @fixup_cnt OUT;

      -- Fixup uses
      EXEC sp_log 1, @fn, '60: calling sp_fixup_s2_uses';
      EXEC sp_fixup_s2_uses @fixup_cnt = @fixup_cnt OUT;

      -- Fixup entry_mode
      EXEC sp_log 1, @fn, '65: calling sp_fixup_s2_action_general';
      EXEC sp_fixup_s2_action_general  @fixup_cnt = @fixup_cnt OUT;

      EXEC sp_log 1, @fn, '70: calling sp_fixup_s2_action_specific';
      EXEC sp_fixup_s2_action_specific @fixup_cnt = @fixup_cnt OUT;

      -- Fixup MRL
      EXEC sp_log 1, @fn, '75: calling @fixup_cnt';
      EXEC  sp_fixup_s2_mrl @fixup_cnt = @fixup_cnt OUT;

      -- Fixup phi
      EXEC sp_log 1, @fn, '80: calling sp_fixup_s2_phi';
      EXEC sp_fixup_s2_phi @fixup_cnt = @fixup_cnt OUT;

      -- Fixup Company
      EXEC sp_log 1, @fn, '85: calling sp_fixup_s2_company';
      EXEC sp_fixup_s2_company @fixup_cnt = @fixup_cnt OUT;

      -- Fixup rate

      -- Fixup reentry
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_set_session_context N'fixup count', @fixup_cnt;
   EXEC sp_log 1, @fn, '999: leaving, @fixup_cnt: ',@fixup_cnt;
END
/*
EXEC sp_copy_s3_s2
EXEC sp_fixup_s2
*/

GO
GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 09-JUL-2023
-- Description: Caches a copy of Staging2 to Staging3 
--    Do after any stage once S2 is populated
--
-- CHANGES:
-- 231103: turned auto increment off so SET IDENTITY_INSERT ON/OFF not needed
-- ==============================================================================
ALTER PROCEDURE [dbo].[sp_copy_s2_s3]
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(35)  = N'CPY_S2_S3'

   SET NOCOUNT OFF;
   EXEC sp_log 2, @fn,'00: Caching COPYING staging2 to staging3 (backup) starting';

   TRUNCATE TABLE Staging3;

   INSERT INTO dbo.Staging3
   (
       stg_id
      ,company
      ,ingredient
      ,product
      ,concentration
      ,formulation_type
      ,uses
      ,toxicity_category
      ,registration
      ,expiry
      ,entry_mode
      ,crops
      ,pathogens
      ,rate
      ,mrl
      ,phi
      ,phi_resolved
      ,reentry_period
      ,notes
      ,comment
   )
   SELECT 
       stg2_id
      ,company
      ,ingredient
      ,product
      ,concentration
      ,formulation_type
      ,uses
      ,toxicity_category
      ,registration
      ,expiry
      ,entry_mode
      ,crops
      ,pathogens
      ,rate
      ,mrl
      ,phi
      ,phi_resolved
      ,reentry_period
      ,notes
      ,Comment
     FROM Staging2;

   EXEC sp_log 2, @fn,'99: leaving: OK';
END
/*
EXEC sp_copy_s2_s3
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==================================================================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2024
-- Description: does S2 fixup using the sp_fixup_s2 stored procedure not the xls
--              then caches Staging2->Staging3
-- ===============================================
ALTER PROCEDURE [dbo].[sp_main_import_stage_04_s2_fixup]
AS
BEGIN
   DECLARE
       @fn  NVARCHAR(35)  = 'MAIN_IMPRT_STG_04'

   BEGIN TRY
      EXEC sp_log 1, @fn, '00: starting';
      EXEC sp_register_call @fn;

      -----------------------------------------------------------------------------------
      -- S2 fixup using the sp_fixup_s2 stored procedure not the xls
      -----------------------------------------------------------------------------------
      IF EXISTS (SELECT 1 FROM staging2 WHERE entry_mode LIKE '%Early post-emergent%')
         EXEC ut.dbo.sp_raise_exception 58740, 'Early post-emergent now exists after stage 3', @fn=@fn;

      EXEC sp_log 1, @fn, '10: cache S2->S3';
      EXEC sp_fixup_s2;

      IF EXISTS (SELECT 1 FROM staging2 WHERE entry_mode LIKE '%Early post-emergent%')
         EXEC ut.dbo.sp_raise_exception 58741, 'Early post-emergent now exists after stage 3', @fn=@fn;

      -----------------------------------------------------------------------------------
      -- Cache a backup of Staging2 to Staging3
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '15: cache S2->S3';
      EXEC sp_copy_s2_s3;

      EXEC sp_log 2, @fn, '90: processing complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
   END CATCH

   EXEC sp_log 1, @fn, '99: leaving OK';
END
/*
SELECT COUNT(*) FROM staging1 WHERE entry_mode LIKE '%Early post-emergent%'
SELECT COUNT(*) FROM staging2 WHERE entry_mode LIKE '%Early post-emergent%'
EXEC sp_main_import_stage_04;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==================================================================================================
-- Author:      Terry Watts
-- Create date: 31-JAN-2024
-- 
-- Description: Imports the corrections Excel file for the Ph Dep Ag Pesticide register
-- staging table 
-- This:
-- 1: imports the corrections data sheet: @imprt_xls_file into the ImportCorrectionsStaging table
-- NB does NOT truncate tables as it may be used many times with different files incrementally
-- RETURNS:
--    0 if OK, else OS error code
--
-- PRECONDITIONS:
--    none
--
-- POSTCONDITIONS:
--    POST01: ImportCorrectionsStaging table clean populated or error
--    POST02: ImportCorrections truncated
--    POST03: @import_xls_file must exist OR exception 64871 thrown
--    POST04: openrowset cmd succeeded    OR exception 64872 thrown
--    POST05: at least 1 row was imported OR exception 64873 thrown
--
-- THROWS:
-- 64871 if @import_xls_file does not exist
-- 64872 if openrowset cmd errored
-- 64873 if no rows were imported
--
-- Tests:
--
-- Changes:
--    240201: changed to use direct XL import: sp_import_XL_existing
-- ==================================================================================================
ALTER PROCEDURE [dbo].[sp_import_corrections_xls]
    @import_xls_file    NVARCHAR(360) -- Full path to import file
   ,@range              NVARCHAR(100) = 'Sheet1$A:S'
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(35)  = N'IMPRT_CRCTNS_XLS'
      ,@sql          NVARCHAR(MAX)
      ,@error_msg    NVARCHAR(500)
      ,@file_exists  INT
      ,@row_cnt      INT   = -1
      ;

   EXEC sp_log 2, @fn, '000: starting, 
file:  [', @import_xls_file, ']
@range:[',@range,']';

   BEGIN TRY
      -- Set defaults
      IF @range IS NULL SET @range = 'Sheet1$A:S'

      ----------------------------------------------------------------------------
      -- Parameter validation
      ----------------------------------------------------------------------------
      -- chk if file exists
      EXEC sp_log 1, @fn, '005: chk if file exists';
      EXEC xp_fileexist @import_xls_file, @file_exists OUT;

      -- POST03: @import_xls_file must exist OR exception 64871 thrown
      IF @file_exists = 0
      BEGIN
         SET @error_msg = CONCAT(@import_xls_file, ' does not exist');
         EXEC sp_log 4, @fn, '010: ', @error_msg;
         THROW 64871, '',1;
      END

      ----------------------------------------------------------------------------
      -- ASSERTION: file exists
      ----------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '015: ASSERTION: file exists';

      ----------------------------------------------------------------------------
      -- Import file
      ----------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '020: importig file: calling sp_import_XL_existing';

      EXEC sp_import_XL_existing
          @spreadsheet  = @import_xls_file
         ,@range        = @range
         ,@table        = 'ImportCorrectionsStaging'
         ,@clr_first    = 1
         ,@fields       = 'id,command,search_clause,search_clause_cont,not_clause,replace_clause, case_sensitive, Latin_name, common_name, local_name, alt_names, note_clause, crops, doit, must_update, comments'
         ,@row_cnt      = @row_cnt OUT
         ,@expect_rows  = 1
         ;

      EXEC sp_log 1, @fn, '021';
      EXEC sp_log 1, @fn, '025: imported file OK (', @row_cnt, ' rows)';

      ----------------------------------------------------------------------------
      -- Checking post conditions
      -- POST04: openrowset cmd succeeded   OR exception 64872 thrown
      ----------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '030: Checking post conditions';
      -- POST01: ImportCorrectionsStaging table clean populated or error:  sp_import_XL_existing @clr_first = 1
      -- POST02: ImportCorrections truncated
      -- POST03: @import_xls_file must exist OR exception 64871 thrown     sp_import_XL_existing 
      -- POST04: openrowset cmd succeeded    OR exception 64872 thrown     sp_import_XL_existing 
      -- POST05: at least 1 row was imported OR exception 64873 thrown     sp_import_XL_existing @expect_rows  = 1

      IF @row_cnt = 0
      BEGIN
         SET @error_msg = 'No rows were imported';
         EXEC sp_log 4, @fn, @error_msg;
         THROW 64873, @error_msg, 1;
      END
   END TRY
   BEGIN CATCH
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, '50: caught exception: ',@error_msg;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '99: leaving, OK';
   RETURN;
END
/*
EXEC sp_import_corrections_xls 'D:\Dev\Repos\Farming\Data\ImportCorrections 221018 230816-2000.xlsx'

SELECT * FROM ImportCorrectionsStaging
EXEC sp_import_corrections_xls 'D:\Dev\Repos\Farming\Data\ImportCorrections 231025 231106-0000.xlsx'

EXEC tSQLt.Run 'test.test_sp_import_correction_files_xls'
TRUNCATE TABLE ImportCorrectionsStaging;
TRUNCATE TABLE ImportCorrections;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================
-- Author:      Terry Watts
-- Create date: 28-JUN-2023
-- 
-- Description: Imports the Ph Dep Ag Pesticide register
-- staging table 
-- This:
-- 1: truncates the ImportCorrections and ImportCorrectionsStaging tables
-- 2: imports the corrections data sheet: @imprt_tsv_file into the ImportCorrectionsStaging table
--
-- RETURNS:
--    0 if OK, else OS error code
--
-- PRECONDITIONS:
--    none
--
-- POSTCONDITIONS:
--    POST01: ImportCorrectionsStaging table clean populated or error
--    POST02: ImportCorrections truncated
--    POST03: @import_tsv_file must exist OR exception 64871 thrown
--    POST04: bulk insert cmd succeeded   OR exception 64872 thrown
--    POST05: at least 1 row was imported OR exception 64873 thrown
--
-- THROWS:
-- 64871 if @import_tsv_file does not exist
-- 64872 if bulk insert cmd errored
-- 64873 if no rows were imported
-- 
-- Tests:
--    test.test_sp_import_correction_files
--
-- Changes:
-- 231109: added exceptions thrown if errors (see POSTCONDITIONS  )
-- ======================================================================
ALTER procedure [dbo].[sp_import_corrections_tsv]
    @import_tsv_file   NVARCHAR(360) -- Full path to import file
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(35)  = N'IMPRT_CRCTNS_TSV'
      ,@sql          NVARCHAR(MAX)
      ,@rc           INT   = 1
      ,@error_msg    NVARCHAR(500)
      ,@file_exists  INT
      ,@row_cnt      INT   = -1
      ;

   EXEC sp_log 2, @fn, '01: starting, file: [', @import_tsv_file, ']';

   BEGIN TRY
      /*
      TRUNCATE TABLE ImportCorrectionsStaging;
      TRUNCATE TABLE ImportCorrections;
      */
      --SET IDENTITY_INSERT ImportCorrections OFF;
      EXEC xp_cmdshell 'DEL D:\Logs\PesticideRegisterImportCorrectionsErrors.log.Error.Txt', NO_OUTPUT;
      EXEC xp_cmdshell 'DEL D:\Logs\PesticideRegisterImportCorrectionsErrors.log'          , NO_OUTPUT;
      --         ,LASTROW  = 7

      -- chk if file exists
      EXEC xp_fileexist @import_tsv_file, @file_exists OUT;

      -- POST03: @import_tsv_file must exist OR exception 64871 thrown
      IF @file_exists = 0
      BEGIN
         SET @error_msg = CONCAT(@import_tsv_file, ' does not exist');
         EXEC sp_log 4, @fn, '02: ', @error_msg;
         THROW 64871, '',1;
      END
      SET @sql = CONCAT(
      'BULK INSERT CorrectionsImport_Vw FROM ''', @import_tsv_file, '''
      WITH
      (
          FIRSTROW = 4
         ,FIELDTERMINATOR = ''\t''
         ,ROWTERMINATOR   = ''\n''   
         ,ERRORFILE       = ''D:\Logs\PesticideRegisterImportCorrectionsErrors.log''
      );'
      );
      --EXEC sp_log 2, @fn, '04: exec sp_executesql...';
      EXEC @RC = sp_executesql @sql;
      SET @row_cnt =  @@ROWCOUNT
      EXEC sp_log 2, @fn, '05: imported ', @row_cnt, ' rows';

      -- POST04: bulk insert cmd succeeded   OR exception 64872 thrown
      IF @RC <> 0
      BEGIN
         SET @error_msg = Ut.dbo.fnGetErrorMsg();
         EXEC sp_log 4, @fn, 'error raised during bulk insert cmd :', @RC, 'Error msg: ', @error_msg, ' File: ', @import_tsv_file;
         THROW 64872, @error_msg,1;
      END

      -- POST05: at least 1 row was imported OR exception 64873 thrown
      IF @row_cnt = 0
      BEGIN
         SET @error_msg = 'No rows were imported';
         EXEC sp_log 4, @fn, @error_msg;
         THROW 64873, @error_msg, 1;
      END

      --SET IDENTITY_INSERT ImportCorrections ON;
   END TRY
   BEGIN CATCH
      --SET IDENTITY_INSERT ImportCorrections ON;
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, '50: caught exception: ',@error_msg;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '99: leaving';
   RETURN @RC;
END
/*
EXEC tSQLt.Run 'test.test_sp_import_correction_files'
TRUNCATE TABLE ImportCorrectionsStaging;
TRUNCATE TABLE ImportCorrections;
EXEC sp_import_corrections_file 'D:\Dev\Repos\Farming\Data\ImportCorrections 221008.txt'
SELECT * FROM CorrectionsImport_Vw;
EXEC sp_import_corrections_file 'D:\Dev\Repos\Farming\Data\ImportCorrections 231025.txt'
SELECT * FROM CorrectionsImport_Vw
*/

GO
GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 28-JUN-2023
-- Description: copies the import corecctions staging table
--              to the main corrections table
--
-- CALLED BY:   sp__main_import_Pesticide_Import_corrections
--
-- ERROR HANDLING by exception handling
--
-- RETURNS 0
-- CHANGES:
-- 231103: turned auto increment off so SET IDENTITY_INSERT ON/OFF not needed
-- 231108: added better row count capture
-- ==============================================================================
ALTER PROCEDURE [dbo].[sp_copy_corrections_staging_to_mn]
AS
BEGIN
   SET NOCOUNT OFF;
   DECLARE
       @fn     NVARCHAR(30)   = N'CPY CORRECTNS STG->MN'
      ,@rc     INT            = 0
      ,@msg    NVARCHAR(500)  = ''
      ,@rowcnt INT = -1;

   BEGIN TRY
      EXEC sp_log 2, @fn, '01: starting copying frm staging tbl to the main corrections tbl';
      EXEC sp_register_call @fn;

      INSERT INTO ImportCorrections(
                  id, [command], search_clause, not_clause, replace_clause, case_sensitive, latin_name, common_name, local_name, alt_names, note_clause, crops, doit, must_update, chk, created)
      SELECT      id, [command], search_clause, not_clause, replace_clause, case_sensitive, latin_name, common_name, local_name, alt_names, note_clause, crops, doit, must_update, chk, created
      FROM ImportCorrectionsStaging
      WHERE id IS NOT NULL;

      SET @rowcnt = @@ROWCOUNT;
      SET @rc     = @@ERROR;

      IF @rc <> 0
      BEGIN
         SET @msg = ERROR_MESSAGE();
         EXEC sp_log 4, @fn,  '90: caught exception: ', @msg;
         THROW 55000, @msg, 1;
      END

      EXEC sp_log 2, @fn, '60: processing complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn,  '99: leaving, RC: ', @rc, @row_count=@rowcnt;
   RETURN @rc;
END
/*
SET XACT_ABORT ON
EXEC sp_copy_corrections_staging_to_mn;
SELECT * from ImportCorrections order by id;
SELECT * from ImportCorrectionsStaging order by id;
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ========================================================================================================
-- Author:      Terry Watts
-- Create date: 28-JUN-2023
--
-- Description: Called immediatly after import to fixup the
-- MS  tsv import issues like wrapping double quotes "
-- The import data issues like our wrapping [] used to highlight
-- leading/trailing spaces
--
-- PRECONDITIONS:
--    corrections staging Bulk import done
--
-- POSTCONDITIONS:
--    Ready to process the pesticide register import
--    Clean bulk insert to tble from file
--    No wrapping " or {}
--    If error throws exception
--
-- Sets the following defaults:
--    doit -> 1
--    must_update to 1
--
-- ERROR HANDLING by exception handling
--
-- Tests:
--    test 012 sp_jh_imp_stg_1_bulk_insert
--
-- Called by the min import corrections routine
--
-- CHANGES:
-- 230710: wrapping barckets are now {} to avoid clash with regex [] brackets
-- 230712: rtn is now responsible for its own chk: - throw exception if error
-- 240201: XL imports using openrowset to the xl file directly limit the field width to 255
--         so we are using a second field to hold chars 256-end then concat this to the search field here
-- ========================================================================================================
ALTER procedure [dbo].[sp_fixup_import_corrections_staging]
AS
BEGIN
   DECLARE
       @fn     NVARCHAR(35)   = N'FIXUP_IMP_CRCTNS_STG'
      ,@sql    NVARCHAR(4000)
      ,@msg    NVARCHAR(500)
      ;

   EXEC sp_log 1, @fn, '00: starting';
   EXEC sp_register_call @fn;

   -- Remove wrapping "
   EXEC sp_log 1, @fn, '01: remove wrapping double quotes from the following columns: search_clause, not_clause, replace_clause, crops, chk';

   -- REMOVE the first 2 imported header rows
   DELETE FROM ImportCorrectionsStaging WHERE id2<3;

   UPDATE ImportCorrectionsStaging
   SET 
       chk            = Ut.dbo.fnTrim2( chk           , '"')
      ,crops          = Ut.dbo.fnTrim2( crops         , '"')
      ,not_clause     = Ut.dbo.fnTrim2( not_clause    , '"')
      ,replace_clause = Ut.dbo.fnTrim2( replace_clause, '"')
      ,search_clause  = Ut.dbo.fnTrim2( search_clause , '"')
      ;

   -- we do use regex - but they wont have an opening [
   EXEC sp_log 1, @fn, '02: remove wrapping []{}';


   -- 10-JUL-2023: Wrapping barckets are now {} to avoid clash with regex [] brackets
   UPDATE ImportCorrectionsStaging  
   SET
        search_clause  = Ut.dbo.fnTrim2( search_clause,  '{')
       ,replace_clause = Ut.dbo.fnTrim2( replace_clause, '{')
       ,not_clause     = Ut.dbo.fnTrim2( not_clause,     '{')
       ,chk            = Ut.dbo.fnTrim2( chk,            '[')
       ;

   UPDATE ImportCorrectionsStaging
   SET
        search_clause  = Ut.dbo.fnTrim2( search_clause,  '}')
       ,replace_clause = Ut.dbo.fnTrim2( replace_clause, '}')
       ,not_clause     = Ut.dbo.fnTrim2( not_clause,     '}')
       ,chk            = Ut.dbo.fnTrim2( chk,            ']')
       ;

   -- 240201: XL imports using openrowset to the xl file directly limit the field width to 255
   --         so we are using a second field to hold chars 256-end then concat this to the search field here
   EXEC sp_log 1, @fn, '03: joining search_clause and  search_clause_cont => search_clause';
   UPDATE ImportCorrectionsStaging SET search_clause = CONCAT(search_clause, search_clause_cont);

   -- Run checks
   EXEC sp_log 1, @fn, '04: running checks';
   IF EXISTS
   (
      SELECT 1 from ImportCorrectionsStaging 
      WHERE 
         search_clause  LIKE '{%'
      OR search_clause  LIKE '%}'
      OR replace_clause LIKE '{%'
      OR replace_clause LIKE '%}'
      OR not_clause     LIKE '{%'
      OR not_clause     LIKE '%}'

      OR search_clause  LIKE '"%'
      OR search_clause  LIKE '%"'
      OR replace_clause LIKE '"%'
      OR replace_clause LIKE '%"'
      OR not_clause     LIKE '"%'
      OR not_clause     LIKE '%"'
      OR chk            LIKE '"%'
      OR chk            LIKE '%"'
      OR chk            LIKE '[%'
      OR chk            LIKE '%]'
  )
   BEGIN
      SET @msg = '05: [sp_fixup_import_corrections_staging failed: {,}or " still exist in in search_clause or replace_clause or not_clause';
      EXEC sp_log 4, @fn, @msg;
      THROW 58126, @msg, 1;
   END
   -- set defaults: 
   -- doit controls whether the command is run or not
   EXEC sp_log 1, @fn,  '06: set doit col default if not specd';

   UPDATE ImportCorrectionsStaging
   SET doit = '1' WHERE doit IS NULL OR doit = '';

   -- must_update
   EXEC sp_log 1, @fn, '07: set must_update col default if not specd';
   UPDATE ImportCorrectionsStaging 
   SET must_update = '0' WHERE must_update IS NULL OR must_update = '';

   IF NOT EXISTS (SELECT 1 FROM ImportCorrectionsStaging WHERE ut.dbo.fnLen(search_clause_cont)>1)
      THROW 60001, 'FIXUP_IMP_CRCTNS_STG failed to import search_clause_cont', 1;

   EXEC sp_log 1, @fn, '99: leaving OK';
   RETURN 0;
END
/*
EXEC sp_fixup_import_corrections_staging;
EXEC sp_copy_corrections_staging_to_mn;
SELECT id, search_clause, replace_clause, chk FROM ImportCorrectionsStaging WHERE replace_clause like '%{%';
SELECT id, search_clause, replace_clause, chk FROM ImportCorrectionsStaging WHERE replace_clause like '%}%';
SELECT id, search_clause, replace_clause, chk FROM ImportCorrectionsStaging
WHERE id =43;
SELECT id, search_clause, replace_clause  FROM ImportCorrections WHERE search_clause  like '%{%';
SELECT id, search_clause, replace_clause  FROM ImportCorrections WHERE replace_clause like '%}%';
SELECT id, search_clause, replace_clause  FROM ImportCorrections WHERE replace_clause like '%"%';

SELECT * FROM ImportCorrectionsStaging;
EXEC sp_fixup_import_corrections_staging;
SELECT Count(*) from ImportCorrectionsStaging;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===============================================================================================
-- Author:      Terry Watts
-- Create date: 08-NOV-2023
--
-- Description:
--    imports 1 file, either a tsv or excel file
--    initially cleans out ImportCorrectionsStaging and ImportCorrections (resets stging id2 key)
--    imports all the correction files to ImportCorrectionsStaging
--    does fixup of ImportCorrectionsStaging
--    copies ImportCorrectionsStaging to ImportCorrections
--
-- Parameters:
--    @import_root:               the directory holding the file
--    @correction_file_inc_range: holds the file name and the possible excel range like <file path>!<sheet nm>$<range>
--
-- PRECONDITIONS - none?
--
-- POSTCONDITIONS:
-- POST 01: must be at least 1 corrections file import.                           EX 52410
-- POST 02: import root must be specified                                         EX 52411
-- POST 03: import file name must be specified                                    EX 52412
-- POST 04: import root folder must exist                                         EX 52413
-- POST 05: ImportCorrectionsStaging search_clause_cont merged into search_clause EX 60000
--
-- CHANGES:
-- 240322: only handles 1 file: either a tsv or excel file
-- ===============================================================================================
ALTER PROCEDURE [dbo].[sp_import_corrections_file]
    @import_root               NVARCHAR(450)
   ,@correction_file_inc_range NVARCHAR(MAX) -- file path includng range if an Excel file
AS
BEGIN
   DECLARE
       @fn                 NVARCHAR(35)   = N'IMPRT_CRTN_FILE'
      ,@correction_file    NVARCHAR(250)  = NULL -- 1 import file from the import files parameter list
      ,@range              NVARCHAR(32)
      ,@error_msg          NVARCHAR(200)
      ,@import_id          INT            = NULL
      ,@msg                NVARCHAR(500)  = ''
      ,@file_exists        INT            = -1
      ,@folder_exists      INT            = -1
      ,@is_csv_file        BIT

   SET NOCOUNT ON;

   BEGIN TRY
      EXEC sp_log 2, @fn,'000: starting
import_root              :[',@import_root,']
correction_file_inc_range:[',@correction_file_inc_range,']'
;
      EXEC sp_register_call @fn;

      --------------------------------------------------------------------------------------------------------
      -- Validate params
      --------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '005: Validating params...';
      -- POST 02: import root must be specified
      IF ((@import_root IS NULL ) OR( Ut.dbo.fnLen(@import_root)=0))
         THROW 52411,'import root must be specified',1;

      --------------------------------------------------------------------------------------------------------
      -- Process
      --------------------------------------------------------------------------------------------------------
      -- Get the file path and the possible excel range from the @correction_file_inc_range parameter
      SELECT
          @correction_file = file_path
         ,@range           = [range]
      FROM ut.dbo.fnGetRangeFromFileName(@correction_file_inc_range);

      -- POST04: import root folder must exist               EX 52413
      EXEC Ut.dbo.sp_file_exists @import_root,@file_exists OUT ,@folder_exists OUT;

      IF @folder_exists < 1
      BEGIN
         SET @error_msg = CONCAT('010: POST04: import root folder [',@import_root,'] must exist');
         EXEC sp_log 4, @error_msg;
         THROW 52413, @error_msg, 1;
      END

      EXEC sp_log 1, @fn, '015: Validated params ok';

      EXEC sp_log 1, @fn,'020: Clean ImportCorrections table';
      TRUNCATE TABLE ImportCorrections;
      EXEC sp_log 1, @fn, '025: truncating staging table ready for this batch';
      TRUNCATE TABLE ImportCorrectionsStaging;
      SET @is_csv_file = IIF(CHARINDEX('.csv', @correction_file)>0, 1, 0);
      EXEC sp_log 1, @fn, '035: fetch OK, processing Corrections file: [',@correction_file, ']';

      -- POST 03: import file must be specified
      IF ((@correction_file IS NULL) OR (Ut.dbo.fnLen(@correction_file) = 0)) THROW 52412, 'import file name must be specified',1;
      --SET @correction_file = CONCAT(@import_root, '\', @correction_file);
      EXEC sp_log 1, @fn, '040: correction_file:', @correction_file

      --------------------------------------------------------------------------------------------------------
      -- Run the import
      --------------------------------------------------------------------------------------------------------
      --EXEC sp_log @fn, 1, '30: calling sp_bulk_insert_pesticide_import_corrections ', @correction_file
      EXEC sp_log 1, @fn, '045: run the import ', @correction_file, @range, ' @is_csv_file: ', @is_csv_file;

      -- Handle either TSV or Excel file
      IF @is_csv_file = 1
         EXEC sp_import_corrections_tsv @correction_file;
      ELSE
         EXEC sp_import_corrections_xls @correction_file, @range;

      EXEC sp_log 1, @fn, '050: returned frm the import_corrections rtn ', @correction_file

      --------------------------------------------------------------------------------------------------------
      -- Fixup import_corrections  like the XL 255 bug
      --------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '055: fixup import_corrections like the XL 255 buge...';
      EXEC sp_fixup_import_corrections_staging;

      EXEC sp_log 1, @fn, '060: copying correction staging to corrections table...';
      EXEC sp_copy_corrections_staging_to_mn;

      --------------------------------------------------------------------------------------------------------
      -- Check postconditions
      --------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'800: checking postconditions';
      -- POST 01: must be at least 1 corrections file import.                           EX 52410
      EXEC sp_chk_tbl_populated 'ImportCorrections';

      --------------------------------------------------------------------------------------------------------
      -- Completed processing
      --------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'950: Completed processing';
   END TRY
   BEGIN CATCH
      EXEC Ut.dbo.sp_get_error_msg @error_msg OUT
      EXEC sp_log 4, @fn, '500: caught exception:  error: ', @error_msg;
      --SELECT * FROM AppLog;
      THROW;
   END CATCH

   -- SELECT * FROM AppLog;
   EXEC sp_log 2, @fn,'999: leaving';
END
/*
EXEC sp_reset_CallRegister;
EXEC sp_import_corrections_file 'D:\Dev\Repos\Farming\Data\', 'ImportCorrections 221018 230816-2000.xlsx!ImportCorrections$A:S';

EXEC tSQLt.Run 'test.test_sp_import_correction_files';
Select * FROM AppLog;
EXEC tSQLt.RunAll;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===============================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2024
-- Description: import the import correction files
-- ===============================================
ALTER PROCEDURE [dbo].[sp_main_import_stage_05_imp_cor]
    @import_root              NVARCHAR(450)  = 'D:\Dev\Repos\Farming\Data'
   ,@correction_file_inc_rng  NVARCHAR(MAX)
AS
BEGIN
   DECLARE
       @fn  NVARCHAR(35) = 'MAIN_IMPRT_STG_05'

   EXEC sp_log 1, @fn, '00: starting
import_root            :[', @import_root, ']
correction_file_inc_rng:[', @correction_file_inc_rng, ']'
;

   EXEC sp_register_call @fn;

   -----------------------------------------------------------------------------------
   -- Process
   -----------------------------------------------------------------------------------
   EXEC sp_log 2, @fn, '05: Import the import correction files';
   EXEC sp_import_corrections_file @import_root, @correction_file_inc_rng;

   -----------------------------------------------------------------------------------
   -- Process complete
   -----------------------------------------------------------------------------------
   EXEC sp_log 2, @fn, '80: processing complete';
   EXEC sp_log 1, @fn, '99: leaving';
END
/*
   EXEC sp_main_import_stage_05;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =========================================================================================================
-- Author:      Terry Watts
-- Create date: 15-MAR-2024
-- Description: This routine performs teh parameter validation for sp_write_results_to_cor_file
--
-- Parameters:
--  @cor_file_path : the corrections Excel full file path
--  @cor_range     : the specified range to write to - uses the columns act_cnt and results
--
-- POSTCONDITIONS:
-- POST 01: @cor_file_path must be specified exception 90000, 'The cor file must be specified'
-- POST 02: @cor_file_path must be an .xlsx file or exception 90001, 'The cor file [',@cor_file_path,'] must be an Excel file'
-- POST 03: cor_file_pathfile must exist or exception 90002, 'The cor file [',@cor_file_path,'] does not exist'
-- POST 04: results written back to @cor_file_path or error message logged
-- =========================================================================================================
ALTER PROCEDURE [dbo].[sp_write_results_to_cor_file_param_val]
    @cor_file        NVARCHAR(132)
   ,@cor_file_path   NVARCHAR(1000)
   ,@cor_range       NVARCHAR(1000) = 'Corrections$A:S'
AS
BEGIN
   DECLARE
    @fn        NVARCHAR(35)   = N'WRT RES2COR F VAL'
   ,@sql       NVARCHAR(MAX)

   -----------------------------------------------------------------------------------------------------------
   -- Validating parameters
   -----------------------------------------------------------------------------------------------------------
   EXEC sp_log 1, @fn,'00 starting
@cor_file     [', @cor_file     , ']
@cor_file_path[', @cor_file_path, ']
@cor_range    [', @cor_range    , ']';

-- POST 02: @cor_file_path must be an .xlsx file or exception 90000, 'The cor file [',@cor_file_path,'] must be an Excel file'
   IF ((@cor_file IS NULL) OR (@cor_file=''))
      EXEC sp_raise_exception 90000, 'The cor file must be specified', @fn=@fn

   IF ((@cor_file_path IS NULL) OR (@cor_file_path=''))
      EXEC sp_raise_exception 90004, 'The cor file path must be specified', @fn=@fn


-- POST 02: @cor_file_path must be an .xlsx file or exception 90000, 'The cor file [',@cor_file_path,'] must be an Excel file'
   IF CHARINDEX('.xlsx', @cor_file_path) = 0
      EXEC sp_raise_exception 90001, 'The cor file [',@cor_file_path,'] must be an Excel file', @fn=@fn

   -- POST 03: cor_file_pathfile must exist or exception 90001, 'The cor file [',@cor_file_path,'] does not exist'
   if Ut.dbo.fnFileExists(@cor_file_path) = 0
      EXEC sp_raise_exception 90002, 'The cor file [',@cor_file_path,'] does not exist', @fn=@fn;

   EXEC sp_log 1, @fn, '99: leaving, OK';
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ============================================================================================================================
-- Author:      Terry Watts
-- Create date: 15-MAR-2024
-- Description: This routine writes the results back to the cor file in the import root folder
--
-- Parameters:
--  @cor_file_path : the corrections Excel full file path
--  @cor_range     : the specified range to write to - uses the columns act_cnt and results
--
-- PRECONDITIONS:
-- PRE 01: ImportCorrections table results and cnt fields populated
--
-- POSTCONDITIONS:
-- POST 01: @cor_file_path must be specified exception 90000, 'The cor file must be specified'
-- POST 02: @cor_file_path must be an .xlsx file or exception 90001, 'The cor file [',@cor_file_path,'] must be an Excel file'
-- POST 03: cor_file_pathfile must exist or exception 90002, 'The cor file [',@cor_file_path,'] does not exist'
-- POST 04: results written back to @cor_file_path or error message logged
--
-- Changes:
-- 240329: changed input parameter @cor_file_path to @cor_file i.e. just the file name - the folder is now the import rot
--          if just the file name is specified in @cor_file then the default folder is the import root
--
-- ============================================================================================================================
ALTER PROCEDURE [dbo].[sp_write_results_to_cor_file]
    @cor_file        NVARCHAR(1000)
   ,@cor_range       NVARCHAR(1000) = 'ImportCorrections$A:S'
AS
BEGIN
   DECLARE
    @fn              NVARCHAR(35)   = N'WRITE_RSLTS_TO_COR_FILE'
   ,@sql             NVARCHAR(MAX)
   ,@cnt             INT
   ,@cor_file_path   NVARCHAR(1000)

   SET NOCOUNT ON;

   EXEC sp_log 2, @fn,'00: starting:
@cor_file:     [',@cor_file,      ']
@cor_range:    [',@cor_range,     ']
';

   -- if just the file name is specified in @cor_file then the default folder is the import root
   IF CHARINDEX('\', @cor_file) = 0
      SET @cor_file_path = CONCAT(ut.dbo.fnGetImportRoot(), '\', @cor_file);
   ELSE
   BEGIN
      SET @cor_file_path = @cor_file;
      SET @cor_file = Ut.dbo.fnGetFileNameFromPath(@cor_file, 1); -- if @cor_file was spec'd as full path - set it to be the file only
   END

   EXEC sp_log 1, @fn,'05: updated params:
@cor_file:     [',@cor_file,      ']
@cor_file_path:[',@cor_file_path, ']
@cor_range:    [',@cor_range,     ']
';

    BEGIN TRY
      -----------------------------------------------------------------------------------------------------------
      -- Validating parameters
      -----------------------------------------------------------------------------------------------------------
      EXEC sp_write_results_to_cor_file_param_val
          @cor_file      = @cor_file
         ,@cor_file_path = @cor_file_path
         ,@cor_range     = @cor_range;

      -----------------------------------------------------------------------------------------------------------
      -- Processing
      -----------------------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'10: processing';
      SELECT @cnt = COUNT(*) FROM ImportCorrections
      EXEC sp_log 2, @fn,'15: updating Excel cor file, ImportCorrections has ', @cnt, ' rows ...';
      EXEC sp_executesql @sql, N'@cnt INT OUT', @cnt OUT;
      EXEC sp_log 2, @fn,'20: Excel cor file JOIN ImportCorrections has ', @cnt, ' common rows ...';

      SET @sql = 
CONCAT
(
'UPDATE xl
SET act_cnt=ic.act_cnt,results=ic.results
FROM OPENROWSET
(
      ''Microsoft.ACE.OLEDB.12.0''
   ,''Excel 12.0;HDR=YES;Database='    , @cor_file_path , ';''
   ,''SELECT id,results,act_cnt FROM [', @cor_range, ']''
) AS xl
JOIN ImportCorrections ic ON xl.id=ic.id'
);

      PRINT @sql;
      EXEC(@sql);

      -----------------------------------------------------------------------------------------------------------
      -- Processing complete
      -----------------------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '30: completed processing;'
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '50: sql:',@sql;
      EXEC Ut.dbo.sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '99: leaving, OK';
END
/*                                                                                              -- Expect:
EXEC sp_write_results_to_cor_file @cor_file_path = NULL, @cor_range = 'ImportCorrections$A:S'              -- exception 90000, 'The cor file must be specified'
EXEC sp_write_results_to_cor_file @cor_file_path = '', @cor_range   = 'ImportCorrections$A:S'              -- exception 90000, 'The cor file must be specified'
EXEC sp_write_results_to_cor_file @cor_file_path = 'x.xlsy'                                     -- exception 90001, 'The cor file [x.xlsy] must be an Excel file'
EXEC sp_write_results_to_cor_file @cor_file_path = 'ImportCorrections 221018 230816-2000.xlsx'  -- exception 90002, 'The cor file [ImportCorrections 221018 230816-2000.xlsx] does not exist'

EXEC sp_write_results_to_cor_file
 @cor_file   ='ImportCorrections 221018 230816-2000.xlsx'
,@cor_range  ='ImportCorrections$A:S'
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===============================================================
-- Author:      Terry Watts
-- Create date: 06-JUL-2023
-- Description: Performs the SQL operation
--
-- PRECONDITIONS: none
--
-- POSTCONDITIONS:
-- 
--
-- CALLER:      sp_fixup_import_register_row
--
-- CHANGES
-- 230819: removing the expected count get and check
-- 230816: changed param name from @fixup_cnt to @row_count
-- ===============================================================
ALTER PROCEDURE [dbo].[sp_execute_sql_cmd]
     @doit            BIT 
   , @table           NVARCHAR(50)
   , @result_msg      NVARCHAR(500)  OUTPUT
   , @row_count       INT            OUTPUT
   , @sql             NVARCHAR(MAX)
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(20)  = N'EXEC_SQL_CMD'
      ,@msg          NVARCHAR(MAX)
      ,@where_clause NVARCHAR(MAX)
      ,@nl           NVARCHAR(2) = NCHAR(10)+NCHAR(13)
      ,@ndx          INT = 0
      ,@rc           INT = -1
      ,@stage        INT = 1;

   SET NOCOUNT OFF;
   EXEC sp_log 1, @fn, 'starting'

   BEGIN TRY
      WHILE 1=1
      BEGIN
         --SET @act_cnt = -1;
         -- Occasionally the cursor get witl wrap the sql in double quotes
         SET @sql = ut.dbo.fnTrim2(@sql, '"');

         -- Replace <TABLE> with staging2
         SET @sql = REPLACE(@sql, '<TABLE>', 'staging2');
         SET @ndx = CHARINDEX('WHERE', @sql);
         SET @where_clause = CONCAT(' ', substring( @sql, @ndx, ut.dbo.fnLen(@sql) - @ndx + 1)); 
         EXEC sp_log 0, @fn, 'SQL COMMAND sql         : [', @sql         , ']';
         EXEC sp_log 0, @fn, 'SQL COMMAND Where clause: [', @where_clause, ']';

         SET @stage =2
         EXEC sp_log 0, @fn, 'sp_execute_sql_cmd: stage 2: executing cnt sql';

         IF @doit = 1
         BEGIN
            SET @stage = 3;
            EXEC sp_log 0, @fn, 'stage 3: executing update sql';
            EXEC sp_log 0, @fn, 'UPDATE SQL             : [', @sql        , ']';
            EXEC @rc = sp_executesql @sql; -- Msg 103, Level 15, State 4, Line 156 The identifier that starts with 'update dbo.staging SET notes   = '(STEM and MAT spray application of mealy bugs)' , pathogens = REPLACE(pathogens, '(STEM and MA' is too long. Maximum length is 128.
            SET @row_count = @@ROWCOUNT;
   
            IF @rc = 0
            BEGIN
               EXEC sp_log 0, @fn, '@fixup_cnt: ', @row_count, ' rows';
                SET @result_msg = 'OK';
            END
            ELSE
               BEGIN  
                  SET @msg = ERROR_MESSAGE();
                  -- Return -1 to the calling program to indicate failure.  
                  SET @result_msg = CONCAT('sp_execute_sql_cmd UPDATE SQL failed, error: ', @msg);  
                  SET @rc = -1;  
                  BREAK;
               END  
            END
          
         ELSE -- IF @doit = 1
         BEGIN
            SET @result_msg = 'Not processing command (@doit=0)';
         END

         SET @stage = 4;
         EXEC sp_log 0, @fn, 'stage 4: executed both sqls OK';
         SET @result_msg = 'OK';
         BREAK;
      END -- WHILE 1
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, 'leaving, updated ', @row_count, ' rows,  @rc:', @rc;
   RETURN @rc;
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================
-- Author:      Terry Watts
-- Create date: 10-JUL-2023
-- Description: Creates the where clause SQL
--
-- PRECONDITIONS - all inputs valid
-- @search_clause will be wrapped with % % 
--  do not make a search clause like '%abcd%'
--
-- POSTCONDITIONS and RET CODES:
-- PO1: @where_clause is populated Always returns 0: OK
--
-- Changes:
-- 240325: if not case sensistive dont use the collation clause:
--         if @collation_clause is null then it is not included
-- ==============================================================
ALTER PROCEDURE [dbo].[sp_update_if_exists_crt_where_clause]
    @search_clause      NVARCHAR(MAX)
   ,@not_clause         NVARCHAR(MAX)
   ,@crops              NVARCHAR(MAX)
   ,@field              NVARCHAR(60)   = 'pathogens'
   ,@table              NVARCHAR(60)   = 'Staging2'
   ,@collation_clause   NVARCHAR(30)
   ,@where_clause       NVARCHAR(MAX) OUTPUT
 AS
BEGIN
   SET @where_clause = CONCAT('WHERE [', @field, '] LIKE ''', @search_clause, '''');
   
   IF ((@not_clause IS NOT NULL) AND (@not_clause <> ''))
   BEGIN
      SET @where_clause = CONCAT(@where_clause,  ' AND [', @field, '] NOT LIKE ''%', @not_clause, '%''');
   END

   IF @collation_clause IS NOT NULL
      SET  @where_clause = CONCAT(@where_clause, ' ',@collation_clause);

   IF @crops IS NOT NULL AND @crops NOT LIKE ''
   BEGIN
      SET @where_clause = CONCAT(@where_clause,  ' AND crops IN (''',REPLACE(@crops, ''',''', ''''','''''),''')');
   END

   RETURN 0;
END

/*
----------------------------------------------
DECLARE  @where_clause NVARCHAR(MAX)

exec sp_update_if_exists_crt_where_clause
    @search_clause   = 'Blight'
   ,@not_clause      = NULL
   ,@crops           = 'Celery'
   ,@field           = 'pathogens'
   ,@table           = 'Staging2'
   ,@where_clause    = @where_clause OUTPUT

PRINT CONCAT('where_clause:[',@where_clause, ']');
----------------------------------------------
DECLARE @cnt_sql NVARCHAR(MAX), @updt_sql NVARCHAR(MAX), @exp_cnt INT

EXEC sp_update_if_exists_crt_updt_sql 
    @search_clause     = 'Corn borer'
   ,@replace_clause    = 'Asian corn borer'
   ,@not_clause        = 'Asian corn borer'
   ,@notes             =  NULL
   ,@field             = 'pathogens'
   ,@table             = 'staging2' 
   ,@case_sensitive    = 0
   ,@crops             = 'Celery'
   ,@cnt_sql           =  OUTPUT
   ,@updt_sql          =  OUTPUT
   ,@id                = 605
   ,@exp_cnt = NULL

PRINT CONCAT('cnt_sql:
',@cnt_sql, ']');
PRINT CONCAT('updt_sql:
',@updt_sql, ']');

--SELECT @exp_cnt = COUNT(*) FROM [staging2] WHERE [pathogens] LIKE '%Corn borer%' AND [pathogens] NOT LIKE '%Asian corn borer%' COLLATE Latin1_General_CI_AI;
EXEC sp_executesql @cnt_sql, N'@exp_cnt INT OUTPUT', @exp_cnt OUTPUT
PRINT CONCAT('@exp_cnt:',@exp_cnt, '
,@cnt_sql:', @cnt_sql, ']');
----------------------------------------------

SELECT COUNT(*) FROM [staging2] WHERE [pathogens] LIKE '%Corn borer%' COLLATE Latin1_General_CI_AI AND crops IN ('Corn') ;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =========================================================================================================================
-- Author:      Terry Watts
-- Create date: 05-JUL-2023
-- Description: Creates the update SQL
--
-- PRECONDITIONS - all inputs valid
-- @search_clause will be wrapped with % % 
--  do not make a search clause like '%abcd%'
--
-- POSTCONDITIONS and RET CODES:
-- PO1: returns 0 SUCCESS, and @updt_sql and @search_sql populated or throws exception 56427 or 56428
--
-- Changes:
-- 230819: removing the expected count get and check
-- 231014: in the exception handler: rollback txn before logging
-- 231015: removed the cor_id, search_clause, replace_clause, not_clause insertions from the update table sql
-- 231015: removed the try catch block and the TRANSACTION
-- 231106: added postcondition chk
-- 231106: removed the search sql
-- 240211: added @srch_sql_clause out param to use to select the rows or count that should like 'FOM Staging2 Where ...
-- =========================================================================================================================
ALTER PROCEDURE [dbo].[sp_update_if_exists_crt_updt_sql]
    @search_clause   NVARCHAR(MAX)
   ,@replace_clause  NVARCHAR(MAX)
   ,@not_clause      NVARCHAR(MAX)
   ,@note_clause     NVARCHAR(MAX)
   ,@field           NVARCHAR(60)
   ,@table           NVARCHAR(60)
   ,@case_sensitive  BIT = 0
   ,@crops           NVARCHAR(MAX)
   ,@id              INT
   ,@updt_sql        NVARCHAR(MAX)                 OUTPUT
   ,@srch_sql_clause NVARCHAR(MAX)                 OUTPUT
 AS
BEGIN
   DECLARE 
       @fn                 NVARCHAR(30)   = N'UPDT_IFEXSTS_CRTSQL'
      ,@set_clause         NVARCHAR(MAX)  = N'SET'
      ,@msg                NVARCHAR(MAX)
      ,@where_clause       NVARCHAR(MAX)
      ,@tgt_clause         NVARCHAR(MAX)
      ,@collation_clause   NVARCHAR(30)   = NULL
      ,@nl                 NVARCHAR(1)    = NCHAR(0x0d)

   BEGIN TRY
      EXEC sp_log 0, @fn, '01: starting';
      SET @set_clause = 'SET' + @nl + '    ';

      -- Validate params
      IF SUBSTRING( @search_clause, 1, 1) = '%' OR SUBSTRING( @search_clause, Ut.dbo.fnLen(@search_clause), 1) = '%'
      BEGIN
         SET @msg = 'sp_update_if_exists expects @search_clause not to be wrapped in %%';
         EXEC sp_log 4, @fn, '02: ',@msg;
         THROW 51871, @msg, 1;
      END

      SET @tgt_clause = @search_clause;
      SET @search_clause = CONCAT('%', @tgt_clause,'%');

      IF @case_sensitive <> 0
         SET @collation_clause = dbo.fnGetCollation(@case_sensitive);

      -- ASSERTION: if here then validation ok

      -- set clauses
      -- log the action in the comment
      IF ((@note_clause IS NOT NULL) AND (@note_clause <> ''))
      BEGIN
         SET @set_clause = CONCAT(@set_clause, ' notes = CONCAT( notes, ''', ' ', @note_clause, ''')', @nl, ',');
      END

      -- Set where clause
      EXEC sp_update_if_exists_crt_where_clause @search_clause, @not_clause, @crops, @field, @table, @collation_clause, @where_clause OUTPUT;

      SET @set_clause = CONCAT
      (
          @set_clause 
         ,' [', @field, ']=Replace(', @field, ', ''', @tgt_clause, ''', ''', @replace_clause, ''') ' -- , '''  ', @collation_clause, ') '
      );

      -- Create the main update query
      SET @updt_sql = CONCAT('UPDATE ', @table, @nl, @set_clause, @nl, @where_clause, @nl);
      SET @srch_sql_clause = CONCAT('FROM ', @table, ' ', @where_clause);

      --EXEC sp_log 1, @fn, '10: update sql:', @nl, @updt_sql;

      -- PO1: returns 0 SUCCESS, and @updt_sql and @search_sql populated or throws exception 56427 or 56428
      IF @updt_sql IS NULL OR Ut.dbo.fnLen(@updt_sql) = 0 THROW 56427, 'update sql not populated', 1;
   END TRY
   BEGIN CATCH
      EXEC Ut.dbo.sp_log_exception @fn
      ,'@search_clause [',@search_clause , ']
@replace_clause[',@replace_clause, ']
@not_clause    [',@not_clause    , ']
@note_clause   [',@note_clause   , ']
@field         [',@field         , ']
@table         [',@table         , ']
@case_sensitive[',@case_sensitive, ']
@crops         [',@crops         , ']
@id            [',@id            , ']';

      THROW;
   END CATCH

   EXEC sp_log 0, @fn, '99: leaving, OK';
   RETURN 0;
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===============================================================
-- Author:		 Terry Watts
-- Create date: 04-JUL-2023
-- Description: part of the factorisation of sp_update_if_exists
--
-- IF fatal error then triws exception to stop processing
--
-- RULES:
--    @search_clause must exist and not be empty else exception
-- DEFAULTS:
-------------------------------------------
--    field           default
-------------------------------------------
--    @replace_clause ''
--    @and_not_clause NULL
--    @notes          NULL
--    @field          'pathogens'
--    @table          'Staging2'
--    @doit           1
--    @must_update    1
--    @id            -1
--    @result_msg     NULL
--    @exp_cnt       -1
--    @row_count     0
--    @case_sensitive 0  i.e. case -nsensitive
-------------------------------------------
--
-- Changes:
-- 231015:  changed ,@act_cn nm to @row_count for consistency
-- ===============================================================
ALTER PROCEDURE [dbo].[sp_update_if_exists_set_defaults]
    @search_clause   NVARCHAR(MAX)   OUTPUT
   ,@replace_clause  NVARCHAR(MAX)   OUTPUT
   ,@field           NVARCHAR(60)    OUTPUT
   ,@table           NVARCHAR(60)    OUTPUT
   ,@doit            BIT             OUTPUT
   ,@must_update     BIT             OUTPUT
   ,@id              NVARCHAR(60)    OUTPUT
   ,@result_msg      NVARCHAR(MAX)   OUTPUT
   ,@row_count       INT             OUTPUT
   ,@case_sensitive  INT             OUTPUT
AS
BEGIN
   DECLARE 
       @msg          NVARCHAR(MAX)  = NULL
      ,@nl           NVARCHAR(2)    = NCHAR(13)

   -- Validation
   IF (@search_clause IS NULL) OR (ut.dbo.fnLen(@search_clause) = 0) 
   BEGIN 
      SET @msg = CONCAT('sp_update_if_exists search_clause must be specified id: ', @id);
      THROW 53200, @msg, 1;
   END
 
   IF substring( @search_clause, 1, 1) = '%' OR substring( @search_clause, Ut.dbo.fnLen(@search_clause), 1) = '%'
      THROW 51871, 'sp_update_if_exists expects @search_clause not to be wrapped in %%', 1;

   IF (@replace_clause IS NULL) 
   BEGIN 
      SET @replace_clause = '';
   END

   -- Set defaults
   IF (@doit IS NULL)
   BEGIN 
      SET @doit = 1;
   END

   IF (@must_update IS NULL) 
   BEGIN 
      SET @must_update =1;
   END

   IF (@id IS NULL) 
   BEGIN 
      SET @id = -1;
   END

/*   IF (@exp_cnt IS NULL) 
   BEGIN 
      SET @exp_cnt = -1;
   END */

   IF (@row_count IS NULL) 
   BEGIN 
      SET @row_count = -1;
   END

   IF (@case_sensitive IS NULL) 
   BEGIN 
      SET @case_sensitive = 0;
   END

   IF (@field IS NULL)  OR (@field = '') 
   BEGIN 
      SET @field = 'pathogens';
   END
   
   IF (@table IS NULL)  OR (@table = '') 
   BEGIN 
      SET @table = 'Staging2';
   END

   --PRINT 'sp_update_if_exists_set_defaults: leaving';
END
/*

SELECT id, pathogens FROM Staging2
DECLARE 
       @msg          NVARCHAR(500)  = NULL
      ,@nl           NVARCHAR(2)    = NCHAR(13)

   , @search_clause  NVARCHAR(1000) = 'fred'
   , @replace_clause NVARCHAR(1000) = NULL
   , @not_clause NVARCHAR(1000) = NULL
   , @notes          NVARCHAR(100)  = NULL
   , @field          NVARCHAR(60)   = NULL
   , @table          NVARCHAR(60)   = NULL
   , @doit           BIT            = NULL
   , @must_update    BIT            = NULL
   , @id             NVARCHAR(60)   = NULL
   , @result_msg     NVARCHAR(150)  = NULL 
   , @exp_cnt        INT            = NULL 
   , @act_cnt        INT            = NULL 

EXEC sp_update_if_exists_set_defaults
     @search_clause  = @search_clause   OUTPUT
   , @replace_clause = @replace_clause  OUTPUT
   , @not_clause = @not_clause  OUTPUT
   , @notes          = @notes           OUTPUT
   , @field          = @field           OUTPUT
   , @table          = @table           OUTPUT
   , @doit           = @doit            OUTPUT
   , @must_update    = @must_update     OUTPUT
   , @id             = @id              OUTPUT
   , @result_msg     = @result_msg      OUTPUT
   , @exp_cnt        = @exp_cnt         OUTPUT
   , @act_cnt        = @act_cnt         OUTPUT

PRINT CONCAT
(
   '@search_clause  =[',COALESCE (@search_clause , 'NULL'),']',@nl
 , '@replace_clause =[',COALESCE (iif(@replace_clause='','''''' ,@replace_clause), 'NULL'),']',@nl
 , '@not_clause =[',COALESCE (@not_clause, 'NULL'),']',@nl
 , '@notes          =[',COALESCE (@notes         , 'NULL'),']',@nl
 , '@field          =[',COALESCE (@field         , 'NULL'),']',@nl
 , '@table          =[',COALESCE (@table         , 'NULL'),']',@nl
 , '@doit           =[',COALESCE (@doit          , 'NULL'),']',@nl
 , '@must_update    =[',COALESCE (@must_update   , 'NULL'),']',@nl
 , '@id             =[',COALESCE (CONVERT(NVARCHAR(20),@id)            , 'NULL'),']',@nl
 , '@result_msg     =[',COALESCE (@result_msg    , 'NULL'),']',@nl
 , '@exp_cnt        =[',COALESCE (CONVERT(NVARCHAR(20),@exp_cnt)       , 'NULL'),']',@nl
 , '@act_cnt        =[',COALESCE (CONVERT(NVARCHAR(20),@act_cnt)       , 'NULL'),']',@nl
);


GO
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==================================================================================================================================
-- Author:   Terry Watts
-- Create date: 26-JUN-2023
-- Description: updates 1 clause with another in a given table and field
--   e.g: UPDATE dbo.temp SET pathogens= REPLACE(pathogens, 'Annual and
--   Perennial broadleaves', 'Annual broad leaved weeds,  Perennial broad leaved weeds')
--   WHERE pathogens like '%Annual and Perennial broadleaves%'
--
-- This does a check if search clause exists, then updates if so -
-- if the search clause exists then if the update fails to update anything it will throw error
--
-- PRECONDITIONS: none
--
-- POSTCONDITIONS:
-- Return codes:
--  0: success
-- -1: error and @result_msg populated
-- POST 01: if @must_update is set but no rows were updated then exception 87001, 'expected rows to be returned but none were'
--
-- Changes:
-- 230628: added and not clause
-- 230629: added do it
-- 230630: added must update
-- 230701: added skip, stop
-- 230705: removed automatic wrapping of search clause in %% - let user have more control
-- 230705: added case sensivity to the searches
-- 230819: removed the expected count get and check
-- 231015: simplified the update sql
-- 231016: changed parameter @fixup_cnt nm to @row_count for consistency
-- 231019: re-adding the chk sql option
-- 240211: moved must update failure logic here from sp_fixup_s2_using_corrections_file
--         also added a chk when failed to update when @must_update set then chk rows would be selected using the srch_sql_clause
-- ==================================================================================================================================
ALTER PROCEDURE [dbo].[sp_update_if_exists]
    @search_clause   NVARCHAR(500)
   ,@replace_clause  NVARCHAR(500)
   ,@not_clause      NVARCHAR(150)     = NULL
   ,@note_clause     NVARCHAR(250)     = NULL
   ,@field           NVARCHAR(60)      = NULL
   ,@table           NVARCHAR(60)      = NULL
   ,@doit            BIT               = 1
   ,@must_update     BIT               = 1
   ,@id              NVARCHAR(60)      = 0
   ,@case_sensitive  BIT               = 0
   ,@crops           NVARCHAR(150)
   ,@chk             BIT               = 0
   ,@result_msg      NVARCHAR(150)     = NULL OUTPUT
   ,@row_count       INT OUTPUT
AS
BEGIN
   DECLARE 
       @fn              NVARCHAR(20)  = N'UPDT IF EXISTS'
      ,@updt_sql        NVARCHAR(MAX)
      ,@chk_sql         NVARCHAR(MAX)
      ,@set_clause      NVARCHAR(MAX)
      ,@where_clause    NVARCHAR(MAX)
      ,@srch_sql_clause NVARCHAR(MAX)
      ,@msg             NVARCHAR(2000) = NULL
      ,@rc              INT            = 0
      ,@nl              NVARCHAR(2)    = NCHAR(13)
      ,@act_cnt         INT            = -1

   EXEC sp_log 0, @fn, '00: starting'
   SET NOCOUNT OFF;

   BEGIN TRY
      EXEC sp_log 0, @fn, '05:  calling sp_update_if_exists_set_defaults ...'
      EXEC sp_update_if_exists_set_defaults
          @search_clause  = @search_clause   OUTPUT
         ,@replace_clause = @replace_clause  OUTPUT
         ,@field          = @field           OUTPUT
         ,@table          = @table           OUTPUT
         ,@doit           = @doit            OUTPUT
         ,@must_update    = @must_update     OUTPUT
         ,@id             = @id              OUTPUT
         ,@result_msg     = @result_msg      OUTPUT
         ,@row_count      = @row_count       OUTPUT
         ,@case_sensitive = @case_sensitive  OUTPUT

      IF @doit <> 0
      BEGIN

         EXEC sp_log 0, @fn, '10:  calling sp_update_if_exists_crt_updt_sql '

         -- The return status is the status of the cnt query
         -- This now determines the exp_cnt
         EXEC dbo.sp_update_if_exists_crt_updt_sql
             @search_clause   = @search_clause
            ,@replace_clause  = @replace_clause
            ,@not_clause      = @not_clause
            ,@note_clause     = @note_clause
            ,@field           = @field
            ,@table           = @table
            ,@case_sensitive  = @case_sensitive
            ,@crops           = @crops
            ,@id              = @id
            ,@updt_sql        = @updt_sql        OUTPUT
            ,@srch_sql_clause = @srch_sql_clause OUTPUT

         EXEC @rc = sp_executesql @Query = @updt_sql
         SET @row_count = @@ROWCOUNT;
         EXEC sp_log 1, @fn, '30:  @updt_sql:
', @updt_sql, @row_count=@row_count;

         IF @rc<>0 
         BEGIN
            SET @msg = CONCAT('sp_executesql returned error: @rc', @rc);
            EXEC sp_log 4, @fn, '30: ', @msg;
            THROW 87001, @msg, 1;
            --RETURN @RC;
         END

         -- if do it and must update then must update at least 1 row, 
         -- OR if do it and @exp_cnt not equal act_cnt -> raise error
         IF @must_update=1 AND @row_count = 0
         BEGIN
            -- POST 01: if @must_update is set but no rows were updated then exception 87001, 'expected rows to be returned but none were'
            SET @msg = 'expected rows to be returned but none were';
            EXEC sp_log 4, @fn, @msg;
            THROW 87002, @msg,1;
         END

         --EXEC sp_log 1, @fn, '60: executed update query',@row_count = @row_count;

         IF @chk <> 0
         BEGIN
            EXEC sp_log 0, @fn, '65: checking update';
            -- we are looking for rows that contain the replace clause, but not the search clause
            SET @chk_sql = CONCAT(' SELECT COUNT(*) FROM STAGING WHERE pathogens like ''',@replace_clause,'%'')
 AND pathogens NOT LIKE ''%',@search_clause,'%''');

            EXEC sp_log 0, @fn, '70: chk sql: ',@nl, @chk_sql;
          
            EXEC sp_executesql @chk_sql, @Params  = N'@act_cnt INT OUTPUT', @act_cnt = @act_cnt OUTPUT;

            IF @act_cnt = -1
            BEGIN
               SET @result_msg =CONCAT(@fn, '75: update chk failed - sql did not execute:', @nl, @chk_sql);
               EXEC sp_log 4, @fn, @msg;
              return -1;
            END

            IF @act_cnt = 0 -- and we are checking ...
            BEGIN
               SET @result_msg = CONCAT('80: update chk failed - did not update any rows, sql: ', @nl, 'chk sql:', @nl, @chk_sql);
               EXEC sp_log 4, @fn, @msg;
               RETURN -1;
            END

            -- ASSERTION: if here the chk found at least 1 rule
             EXEC sp_log 1, @fn,  '85: Chk passed, found ', @act_cnt, ' updated rows';
         END
      END -- IF @doit <> 0
      ELSE 
      BEGIN
         EXEC sp_log 0, @fn, '90: @doit = false so not updating';
      END

      EXEC sp_log 0, @fn, '95: completed processing OK'
   END TRY
   BEGIN CATCH
      SET @act_cnt = Ut.dbo.fnLen(@updt_sql);
      SET @result_msg = CONCAT(' row: ', @id,', len(updt_sql): ', @act_cnt);
      EXEC Ut.dbo.sp_log_exception @fn, @result_msg;
      EXEC sp_log 4, @fn, '150:', @updt_sql;
      THROW;
   END CATCH

   SET @result_msg = 'OK';
   EXEC sp_log 1, @fn, '99: leaving, RC: ', @rc, @row_count = @row_count;
   RETURN @rc;
END
/*
SELECT CONCAT('[', pathogens, ']') FROM staging2 where pathogens like '%Golden apple Snails%'

UPDATE Staging2
SET
     [pathogens]   = Replace(pathogens, 'Golden apple Snails (kuhol)', 'Golden apple snail'  COLLATE Latin1_General_CI_AI)
    ,cor_id        = 417
    ,search_clause = '%Golden apple Snails (kuhol)%'
    ,replace_clause= 'Golden apple snail'
    ,not_clause    = ''
WHERE [pathogens] LIKE '%Golden apple Snails (kuhol)%' COLLATE Latin1_General_CI_AI -- 99 rows updated

UPDATE Staging2
SET
     [pathogens]   = Replace(pathogens, 'Golden apple Snails', 'Golden apple snail'  COLLATE Latin1_General_CI_AI)
    ,cor_id = 418
    ,search_clause = '%Golden apple Snails%'
    ,replace_clause= 'Golden apple snail'
    ,not_clause    = ''
WHERE [pathogens] LIKE '%Golden apple Snails%' COLLATE Latin1_General_CI_AI -- 181 rows updated
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==========================================================================================================
-- Author:      Terry Watts
-- Create date: 22-JUN-2023
-- Description: uses 1 row of the ImportCorrections table to fixup
--              the Pesticide register table from the fixup table.
--
-- Process: reads the command and from that determines which
-- process rtn to call and calls it.
--
-- CALLED BY:sp_FixupImportRegister
--
-- CALLS:
--   Command handlers:
--       sp_updateAndSetNote
--       sp_Singularise
--       sp_update
--       SQL handler (inline)
--
-- RETURNS:
--              severity   result
--       if OK  0          rows updates
--       stop   1          do it was false - but continue
--       error -1          error so stop, @result_msg will have the error msg
--
-- PRECONDITIONS:
--    none
--
-- RESPONSIBILITOES:
-- RESP 01. remove {} from the search_clause parameter
-- RESP 02. remove {} from the replace_clause parameter
-- RESP 03. remove "  from the search_clause parameter
-- RESP 04. remove "  from the replace_clause parameter
-- RESP 05. remove {} from the not_clause parameter
-- RESP 06. remove "  from the not_clause parameter
--
-- POSTCONDITIONS:
-- Returns rc: 0 if ok
--             1 if ok but warning
--            -1 if error  - so record and stop
-- POST 01: command must be valid 1 of {SQL, sp_update, stop}
-- POST 02: @result_msg must be set and not 'NOT SET' else exception 87000 '@result_msg not set'
-- POST 03: if @must_update set then if no rows returned then EXCEPTION 87001, 'expected rows to be returned but none were', 1;

-- CHANGES
-- 230819: removing the expected count get and check
-- 231106: RC 0,1 are considered success codes, 0 is update, 1 is skip or doit =0
-- 240129: added preprocessing to remove wrapping {} and "" from @search_clause, @replace_clause,@not_clause
-- 240324: improved validation
-- ==========================================================================================================
ALTER PROCEDURE [dbo].[sp_fixup_s2_using_corrections_file_row]
    @id              INT
   ,@command         NVARCHAR(100)
   ,@search_clause   NVARCHAR(4000)
   ,@replace_clause  NVARCHAR(4000)
   ,@not_clause      NVARCHAR(4000)
   ,@note_clause     NVARCHAR(4000)
   ,@doit            BIT
   ,@must_update     BIT
   ,@case_sensitive  BIT
   ,@crops           NVARCHAR(4000)
   ,@chk             NVARCHAR(150)
   ,@result_msg      NVARCHAR(150)  OUTPUT
   ,@row_count       INT            OUTPUT
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
    @fn              NVARCHAR(30)  = N'FIXUP_S2_USING FILE ROW'
   ,@error_msg       NVARCHAR(4000)
   ,@cnt_sql         NVARCHAR(MAX)
   ,@exists_sql      NVARCHAR(MAX)
   ,@fixup_id        INT
   ,@id_key          NVARCHAR(30) = N'FIXUP_ROW_ID'
   ,@search_cls_key  NVARCHAR(30) = N'SEARCH_CLAUSE'
   ,@replace_cls_key NVARCHAR(30) = N'REPLACE_CLAUSE'
   ,@line            NVARCHAR(200)= '---------------------------------------------------------------------------'
   ,@msg             NVARCHAR(MAX)
   ,@ndx             INT =  0
   ,@nl              NVARCHAR(2) = NCHAR(10)+NCHAR(13)
   ,@rc              INT = -1
   ,@str             NVARCHAR(30)
   ,@where_clause    NVARCHAR(MAX)


   EXEC sp_log 2, @fn, '00: starting: parameters:
id            :[', @id              , ']
command       :[', @command         , ']
search_clause :[', @search_clause   , ']
replace_clause:[', @replace_clause  , ']
not_clause    :[', @not_clause      , ']
note_clause   :[', @note_clause     , ']
doit          :[', @doit            , ']
must_update   :[', @must_update     , ']
case_sensitive:[', @case_sensitive  , ']
crops         :[', @crops           , ']
chk           :[', @chk             , ']'
;

   SET @result_msg = 'NOT SET';

   BEGIN TRY
      WHILE 1=1
      BEGIN
         EXEC ut.dbo.sp_set_session_context @id_key, @id;
         EXEC ut.dbo.sp_set_session_context @search_cls_key,  @search_clause
         EXEC ut.dbo.sp_set_session_context @replace_cls_key, @replace_clause

         -- 240129: added preprocessing to remove wrapping {} and "" from @search_clause, @replace_clause,@not_clause
         -- Preprocess params
         -- RESP 01. remove {} from the search_clause parameter
         SET @search_clause  = REPLACE( REPLACE(@search_clause , '{',''), '}','');
         -- RESP 03. remove "  from the search_clause parameter
         SET @search_clause  = REPLACE(@search_clause, '"','');
         -- RESP 02. remove {} from the replace_clause parameter
         SET @replace_clause = REPLACE( REPLACE(@replace_clause, '{',''), '}','');
         -- RESP 04. remove "  from the replace_clause parameter
         SET @replace_clause = REPLACE(@replace_clause, '"','');
         -- RESP 05. remove {} from the not_clause parameter
         SET @not_clause     = REPLACE( REPLACE(@not_clause, '{',''), '}','');
         -- RESP 06. remove "  from the not_clause parameter
         SET @not_clause     = REPLACE(@not_clause, '"','');

         ---------------------------------------------------------------------------------------------------------------------
         -- Validate args
         ---------------------------------------------------------------------------------------------------------------------
         -- POST 01: command must be valid 1 of {SQL, sp_update, stop} OR EXCEPTION 63574, 'command must be one of {SQL, sp_update, stop}',1;
         IF (@command IS NULL OR ut.dbo.fnTrim(@command) = '')
         BEGIN
            SET @result_msg = CONCAT( 'sp_FixupRow: search_clause or @sql or cmd must be specified row id: [', @id,']');
            EXEC sp_log 4, @fn, '10: command = stop: so stopping';
            SET @rc = -1; -- Error
            BREAK;
         END

         IF @command NOT IN ('SQL', 'sp_update', 'stop')--63574, 'command must be one of {SQL, sp_update, stop}',1;
         BEGIN
            SET @error_msg = CONCAT('invalid command:[',@command,']');
            EXEC sp_log 4, @fn, '15: ', @error_msg;
            THROW 63574, @error_msg, 1;
         END

         IF LOWER(@command) = 'stop' -- stop sht prcessing
         BEGIN
            SET @result_msg = 'sp_FixupRow: command = stop: so stopping';
            EXEC sp_log 4, @fn, '20: command = stop: so stopping';
            SET @rc = 1; -- OK
            BREAK;
         END

         ---------------------------------------------------------------------------------------------------------------------
         -- Process
         ---------------------------------------------------------------------------------------------------------------------
         IF (@command = 'sp_update')
         BEGIN
            EXEC sp_log 0, @fn, '25 handling command: sp_update';

            IF @doit = 1
            BEGIN
               -- POST 03: if @must_update set then if no rows returned then EXCEPTION 87001, 'expected rows to be returned but none were', 1;
               EXEC @rc = dbo.sp_update_if_exists
                       @search_clause  = @search_clause
                      ,@replace_clause = @replace_clause
                      ,@not_clause     = @not_clause
                      ,@note_clause    = @note_clause
                      ,@doit           = @doit
                      ,@must_update    = @must_update
                      ,@case_sensitive = @case_sensitive
                      ,@crops          = @crops
                      ,@id             = @id
                      ,@chk            = @chk
                      ,@result_msg     = @result_msg        OUTPUT
                      ,@row_count      = @row_count         OUTPUT;
            END
            ELSE
            BEGIN
               EXEC sp_log 4, @fn, '30 Not processing command as @doit is false';
               SET @rc = 1; -- OK
            END

            BREAK;
         END

         IF @command = 'SQL' -- sql contains the sql
         BEGIN
            EXEC sp_log 0, @fn, '30 handling command: SQL';

            EXEC @rc = dbo.sp_execute_sql_cmd
                  @doit            = 1
               , @table           = 'staging2'
               , @result_msg      = @result_msg OUTPUT
               , @row_count       = @row_count  OUTPUT
               , @sql             = @search_clause

            -- POST 03: if @must_update set then if no rows returned then EXCEPTION 87001, 'expected rows to be returned but none were', 1;
            IF @row_count = 0 AND @must_update = 1
            BEGIN
               EXEC sp_log 4, @fn, ' expected rows to be returned but none were',1;
               THROW 87001, 'expected rows to be returned but none were',1;
            END

            BREAK;
         END -- end IF @command = 'SQL'

         ----------------------------------------------------------------------------------------
         -- ASSERTION: if here then error
         ----------------------------------------------------------------------------------------
         SET @result_msg = CONCAT( 'ERROR unrecognised command: [', @command, '] id: ', @id, ' ',@result_msg);
         EXEC sp_log 4, @fn, '40: ', @result_msg;
         SET @rc=-1;
         THROW 53124, @msg, 1;
      END -- end while 1=1

      ---------------------------------------------------------------------------------------------------------------------
      -- Chk postconditions
      ---------------------------------------------------------------------------------------------------------------------

      IF @rc NOT IN (0, 1) -- 1 means doit=0
         EXEC sp_log 4, @fn, '45: invalid return code: ', @rc, @row_count = @row_count;

      -- POST02
      EXEC Ut.dbo.sp_assert_not_equal 'NOT SET', '@result_msg not set: ', @result_msg, @ex_num=87000, @fn=@fn;
      EXEC Ut.dbo.sp_assert_not_equal '',        '@result_msg not set: ', @result_msg, @ex_num=87000, @fn=@fn;

      ---------------------------------------------------------------------------------------------------------------------
      -- Process complete
      ---------------------------------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, 'Process complete';
   END TRY
   BEGIN CATCH
      EXEC .sp_log_exception @fn, 'XL row id:', @id;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '99: leaving';
   RETURN @rc;
END
/*
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================
-- Author:      Terry Watts
-- Create date: 27-JUN-2023
-- Description: sets the result of the fixup for the row
--              in the ImportCorrections table.
-- ======================================================
ALTER PROCEDURE [dbo].[sp_set_fixup_result]
      @id               INT
     ,@act_cnt          INT
     ,@result_msg       NVARCHAR(150)
--     ,@cursor           CURSOR VARYING OUTPUT
AS
BEGIN
   DECLARE @fn NVARCHAR(35)='SET_FXUP_RESLT'
   SET NOCOUNT ON;

   BEGIN TRY
      UPDATE ImportCorrections
      SET 
          act_cnt          = @act_cnt
         ,results          = @result_msg
      WHERE 
         id=@id --CURRENT OF @cursor
      ;

      IF @@ROWCOUNT = 0
      BEGIN
         DECLARE @msg NVARCHAR(200);
         SET @msg = CONCAT
         ('sp_setFixupResult failed to update corrections table, 
id        :[', @id,']
act_cnt   :[', @act_cnt,']
result_msg:[', @result_msg,']'
         );

         THROW 51500, @msg, 1;
      END
   END TRY
   BEGIN CATCH
      EXEC Ut.dbo.sp_log_exception @fn;
      THROW;
   END CATCH
END

GO
GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =======================================================================================================================================================
-- Author:      Terry Watts
-- Create date: 22-JUN-2023
-- Description: Fixup the staging 2 table for import Register, using the
--              ImportCorrections table as the src to get the values to change
--              Does not handle the initial dequote, special characters
--              as there are problems with MS import of  special characters
--
-- CALLED BY    sp__main_import_pesticide_register
--
-- PRECONDITIONS:
--    ImportCorrections table populated
--
-- POSTCONDITIONS:
--    POST 01: @cor_file_path exists or exception 53600, 'correction file must exist',1;

-- RETURNS:
--    0  :  OK
--    1  :  STOP signal detected
--   -1  :  Error
--
-- CHANGES
-- 230622: added Skip
-- 230625: added Do it to print the action SQL but not actually run the sql
-- 230629: added must_update to make sure something changed in the table
-- 230703: added user supllied skip to to overrride the spreadsheet skip
-- 230704: added comment lines
-- 230715: doit now supports STOP AFTER[ DOIT=[0,1]]
--         added user supplied skip to
-- 231014: renamed the fixupimport register sp for Staging to:  sp_fixup_s2_using_corrections_file
-- 231014: added postcondition chks for the non existence of 'Golden apple Snails' and 'Golden apple Snails (kuhol)'
-- 231014: added a @stop_after_row parameter to stop the import from the main commandline, changed the order of params
-- 231019: tidied up the logging not to be repetitive @skip_to_row, @stop_after_row, [import id], [@fixup_cnt] moved to header log
-- 231106: RC 0,1 are considered success codes, 0 is update, 1 is skip or doit =0
-- 240129: change of logic if doit undefined: sewt default = 1 (do it anyway)
-- 240211: moved must update failure logic to sp_update_if_exists
--         also added a chk to sp_update_if_exists when failed to update when @must_update set then chk rows would be selected using the srch_sql_clause
-- 240329: parameter @cor_file_path changed to @cor_file - now uses the root folder
-- =======================================================================================================================================================
ALTER PROCEDURE [dbo].[sp_fixup_s2_using_corrections_file]
    @start_row             INT            = 1
   ,@stop_row              INT            = 100000
   ,@cor_file              NVARCHAR(500) = NULL
   ,@cor_range             NVARCHAR(1000) = 'Sheet1$A:S'
   ,@fixup_cnt             INT            = NULL   OUTPUT

AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
    @fn                    NVARCHAR(30)  = N'FIXUP_S2_USING FILE'
   ,@alt_names             NVARCHAR(MAX)
   ,@cnt                   INT
   ,@case_sensitive        BIT
   ,@chk                   BIT
   ,@command               NVARCHAR(50)
   ,@common_name           NVARCHAR(MAX)
   ,@cor_file_path         NVARCHAR(500) = NULL
   ,@cor_log_flg_key       NVARCHAR(30) = N'COR_LOG_FLG'
   ,@crops                 NVARCHAR(MAX)
   ,@cursor                CURSOR
   ,@doit                  BIT
   ,@doit_s                NVARCHAR(100)
   ,@first_time            BIT            = 1
   ,@id                    INT = 0
   ,@import_id             INT
   ,@latin_name            NVARCHAR(MAX)
   ,@len                   INT
   ,@line                  NVARCHAR(80) = '---------------------------------'
   ,@local_name            NVARCHAR(MAX)
   ,@msg                   NVARCHAR(2000)
   ,@must_update           BIT
   ,@ndx                   INT            = 0
   ,@nl                    NVARCHAR(2)
   ,@not_clause            NVARCHAR(MAX)
   ,@note_clause           NVARCHAR(MAX)
   ,@rc                    INT            = 0
   ,@replace_clause        NVARCHAR(MAX)
   ,@result_msg            NVARCHAR(150)
   ,@row_count             INT            = 0
   ,@search_clause         NVARCHAR(MAX)
   ,@sql                   NVARCHAR(MAX)
   ,@stop_after_this_row   BIT            = 0
   ,@updated_field         NVARCHAR(60)
   ,@updated_table         NVARCHAR(60)

   EXEC sp_log 2, @fn, '000: starting:
start_row:    [', @start_row,    ']
stop_row:     [', @stop_row,     ']
cor_file:     [', @cor_file,']
cor_range:    [', @cor_range,    ']'
;

   EXEC sp_register_call @fn;
   SET @nl = NCHAR(13);

   BEGIN TRY

      -------------------------------------------------------
      -- Parameter Validation
      -------------------------------------------------------

      -------------------------------------------------------
      -- Process
      -------------------------------------------------------
      -- Go to the desired stage:
      -- Remove page header rows
      EXEC sp_log 0, @fn, '005: deleting CorrectionLog, ';

      DELETE FROM CorrectionLog;
      EXEC sp_log 0, @fn, '010: deleting header rows from the LRAP import';
      --DELETE FROM dbo.staging2 WHERE company LIKE '%NAME OF COMPANY%'; -- 22714 rows

      -- Remove the old import comments
      EXEC sp_log 0, @fn, '015: Remove old import comments';
      UPDATE staging2 SET Comment='';

      -------------------------------------------------------
      -- ASSERTION: ready to import
      -------------------------------------------------------

      -- Enable the S2 trigger
      ENABLE TRIGGER staging2.sp_Staging2_update_trigger ON Staging2;

      -- Turn on S2 update logging
      EXEC Ut.dbo.sp_set_session_context @cor_log_flg_key, 1;
      EXEC sp_log 0, @fn, '020: B4 main do loop';

      -------------------------------------------------------
      -- Main do loop
      -------------------------------------------------------
      WHILE 1 = 1
      BEGIN
         SET @cursor = CURSOR FOR
         SELECT id, [command],  search_clause, not_clause, replace_clause, case_sensitive, latin_name, common_name
                  ,local_name, alt_names, note_clause, crops, doit, must_update, chk
         FROM ImportCorrections order by id
         FOR UPDATE OF act_cnt,results;

         OPEN @cursor;
         EXEC sp_log 1, @fn, '025: before Row fetch loop, @@FETCH_STATUS: [', @@FETCH_STATUS, ']';

      -------------------------------------------------------
      -- Row fetch loop
      -------------------------------------------------------
         WHILE (@@FETCH_STATUS = 0) OR (@first_time = 1)
         BEGIN
            SET @first_time = 0
            SET @stop_after_this_row = 0;
--          SELECT                        id, [command], search_clause,  not_clause,  replace_clause,  case_sensitive,  latin_name,  common_name,  local_name,  alt_names,  note_clause,  crops,  doit  ,  must_update,  chk,  result
            FETCH NEXT FROM @cursor INTO @id, @command, @search_clause, @not_clause, @replace_clause, @case_sensitive, @latin_name, @common_name, @local_name, @alt_names, @note_clause, @crops, @doit_s, @must_update, @chk;
            EXEC sp_log 1, @fn, '030: top of row fetch loop, id: ',@id, ' @@FETCH_STATUS : [', @@FETCH_STATUS, ']';

            IF @@FETCH_STATUS <> 0
            BEGIN
               EXEC sp_log 1, @fn, '035: processing Corrections Completed at row: ', @id;

               IF @id < 1
               BEGIN
                  -- MUST process at least 1 row
                  SET @msg = ' No Corrections rows were processed';
                  EXEC sp_log 4, @fn, '040', @msg;
                  SET @msg = CONCAT(@fn, @msg);
                  THROW 52417, @msg, 1;
               END

               BREAK;
            END

            IF @id < @start_row
            BEGIN
               EXEC sp_log 0, @fn, '045: skipping row: ', @id;
               CONTINUE;
            END

            PRINT CONCAT( CONCAT(NCHAR(13), NCHAR(10)), @line, 'row ', @id, @line);
            SET @len = Ut.dbo.fnLen(@search_clause);

            -- Standardise command and doit
            SET @command= LOWER(Ut.dbo.fnTrim(@command));
            SET @doit_s = LOWER(Ut.dbo.fnTrim(@doit_s));

            -- Skip comments
            IF (@doit_s LIKE '%skip%') OR (@command LIKE '%skip%') OR  (@search_clause LIKE ';%' OR @search_clause LIKE 'COMMENT%')
            BEGIN
               EXEC sp_log 0, @fn,'050: skipping comment row: ', @id;
               CONTINUE;
            END

            IF (@doit_s = 'stop' OR @command = 'stop' )
            BEGIN
               SET @result_msg = 'STOP';
               EXEC sp_log 1, @fn, '055: STOP ENCOUNTERED: sp_fixup_import_register: 3.5: stopping at row: ', @id;
               SET @rc = 1;
               EXEC sp_set_fixup_result @id, @row_count, @result_msg;
               BREAK
            END

            -- doit now supports STOP AFTER[ DOIT=[0,1]]
            IF (@doit_s like 'stop after%')
            BEGIN
               SET @stop_after_this_row = 1;
               EXEC sp_log 1, '060: STOP AFTER ENCOUNTERED: sp_fixup_import_register: 3.5: stopping after executing this row: ', @id, ' @doit_s:[', @doit_s, ']';
               SET @ndx =  CHARINDEX( 'DOIT=', @doit_s);
               IF @ndx>0
               BEGIN
                  SET @doit_s = SUBSTRING(@doit_s, @ndx+5, 1);
                  EXEC sp_log 1, @fn, '065: @doit_s:[', @doit_s;
               END
            END

            SET @doit = CONVERT( BIT, @doit_s);

            -- 240129: change of logic if doit undefined: set default = 1 (do it anyway)
            IF (@doit IS NULL) OR ((@doit <>0) AND (@doit <> 1))
            BEGIN
               SET @doit = 1;
            END

            EXEC sp_log 1, @fn, '070: calling sp_fixup_s2_using_corrections_file_row';

            EXEC @rc = sp_fixup_s2_using_corrections_file_row
                 @id             = @id
                ,@command        = @command
                ,@search_clause  = @search_clause
                ,@replace_clause = @replace_clause
                ,@not_clause     = @not_clause
                ,@note_clause    = @note_clause
                ,@doit           = @doit
                ,@must_update    = @must_update
                ,@case_sensitive = @case_sensitive
                ,@crops          = @crops
                ,@chk            = @chk
                ,@result_msg     = @result_msg    OUTPUT
                ,@row_count      = @row_count     OUTPUT

            EXEC sp_log 1, @fn, '075: ret frm sp_fixup_s2_using_corrections_file_row, @row_count:', @row_count, ' @fixup_cnt:', @fixup_cnt, @row_count = @row_count;
            SET @fixup_cnt = @fixup_cnt + @row_count;
            -- Update the corrections table
           -- EXEC sp_log 2, @fn, '18.1';
            EXEC sp_set_fixup_result @id, @row_count, @result_msg--, @cursor;

            IF @rc IN (0,1)
            BEGIN
               SET @result_msg = CONCAT('OK, ', @result_msg);
            END
            ELSE
            BEGIN
               SET @msg = CONCAT('ERROR: sp_fixup_import_register returned ', @rc);
               EXEC sp_log 4, @fn, '080: ', @msg;
               THROW 50003, @msg, 1;
            END

            IF ((@stop_row = 1) OR (@stop_row <= @id))
            BEGIN
               EXEC sp_log 2, @fn, '085: STOP AFTER ENCOUNTERED: ', @id, ' stopping after this row';
               SET @rc = 1;
               BREAK;
            END

            EXEC sp_log 1, @fn, '090: end of fetch row loop for this row';
         END --  end of WHILE (@@FETCH_STATUS = 0) OR (@first_time = 1)

         SET @rc=0; -- OK

         -------------------------------------------------------
         -- Process complete
         -------------------------------------------------------
         EXEC sp_log 1, @fn, '095: Process complete';
         BREAK;
      END -- While 1=1

      EXEC sp_log 1, @fn, '100: completed main do loop';

      -- If XL file then update the results status
      IF @cor_file IS NOT NULL
      BEGIN
      -------------------------------------------------------
      -- Close normally
      -------------------------------------------------------
         EXEC sp_log 1, @fn, '105: Process complete, close normally';

         -- Close the cursor
         EXEC sp_log 2, @fn, '110: Close the cursor, disable trigger';
         CLOSE      @cursor;
         DEALLOCATE @cursor;

         -- Disable the trigger
         DISABLE TRIGGER staging2.sp_Staging2_update_trigger ON staging2;
         EXEC sp_set_session_context N'fixup count',     @fixup_cnt;

         EXEC sp_log 1, @fn, '115: writing results back to cor file
            @cor_file =[',@cor_file ,']
           ,@cor_range=[',@cor_range,']';

         EXEC sp_write_results_to_cor_file
            @cor_file = @cor_file
           ,@cor_range= @cor_range;

         EXEC Ut.dbo.sp_set_session_context @cor_log_flg_key, 0;
      END
   END TRY
   BEGIN CATCH
      DECLARE 
          @ex_num INT
         ,@ex_msg NVARCHAR(500)

      EXEC sp_log_exception @fn, @msg01 = '@result_msg: ', @msg02 = @result_msg, @ex_num = @ex_num OUT, @ex_msg = @ex_msg OUT;

      BEGIN TRY
         -- Log the error in the cor table
         EXEC sp_log 1, @fn, '120: calling sp_set_fixup_result: @result_msg: ',@result_msg;
         EXEC sp_set_fixup_result @id, -1, @result_msg--, @cursor OUT;
      END TRY
      BEGIN CATCH
         EXEC Ut.dbo.sp_log_exception @fn, '130: error raised in sp_set_fixup_result '
         -- Continue
      END CATCH

      -------------------------------------------------------
      -- Close abnormally
      -------------------------------------------------------
      -- Close the cursor
      EXEC sp_log 1, @fn, '135: Close abnormally: Close the cursor, disable trigger';
      CLOSE      @cursor;
      DEALLOCATE @cursor;

      -- Update context
      EXEC sp_set_session_context N'fixup count', @fixup_cnt;
      EXEC Ut.dbo.sp_set_session_context @cor_log_flg_key, 0;

      -- Disable the trigger
      DISABLE TRIGGER staging2.sp_Staging2_update_trigger ON staging2;

   -- Update the cor file with the results
      IF @cor_file IS NOT NULL
      BEGIN
         EXEC sp_log 1, '140: writing results back to cor file
            @cor_file =[',@cor_file ,']
           ,@cor_range=[',@cor_range,']';

         EXEC sp_write_results_to_cor_file
            @cor_file = @cor_file
           ,@cor_range= @cor_range;
      END

         EXEC sp_log 1, @fn, '145: rethrow exception';
      ;THROW;
   END CATCH

   EXEC sp_log 2, @fn, '999: leaving, @fixup_cnt: ',@fixup_cnt, ' @rc: ', @rc;
   RETURN @rc
END
/*
EXEC sp_reset_CallRegister;
EXEC dbo.sp_fixup_s2_using_corrections_file;
SELECT id, must_update FROM ImportCorrectionsStaging WHERE ID > 1999
SELECT id, must_update FROM ImportCorrectionsStaging WHERE must_update >0

------------------------------------------------------------------------------------------
EXEC sp_write_results_to_cor_file 
 @cor_file = 'D:\Dev\Repos\Farming\Data\ImportCorrections 221018 240322-2000.xlsx'
,@cor_range= 'ImportCorrections$A:S';
------------------------------------------------------------------------------------------
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ========================================================================================
-- Author:      Terry Watts
-- Create date: 21-JUN-20223
-- Description: List the Pathogens in order - use to
--    look for duplicates and misspellings and errors
--
--    *** NB: use list_unregistered_pathogens_vw in preference to fnListPathogens()
--    as fnListPathogens yields a false leading space on some items
-- ========================================================================================
ALTER FUNCTION [dbo].[fnListPathogens]()
RETURNS 
@t TABLE (pathogen NVARCHAR(400))
AS
BEGIN
   INSERT INTO @t
   SELECT DISTINCT TOP 100000 
   cs.value AS pathogen 
   FROM Staging2 
   CROSS APPLY string_split(pathogens, ',') cs
   WHERE cs.value <> ''
   ORDER BY pathogen;

   RETURN;
END
/*
SELECT pathogen from dbo.fnListPathogens();
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ====================================================================
-- Author       Terry Watts
-- Create date: 21-MAR-2024
-- Description: List the pathogen erros in the LRAP Import S2 table
--              NB: use this in preference to fnListPathogens() 
-- ====================================================================
ALTER view [dbo].[list_unregistered_pathogens_vw]
AS
   SELECT TOP 1000 Pathogen as Pathogen
   FROM dbo.fnListPathogens()
   WHERE pathogen NOT in (SELECT pathogen_nm FROM Pathogen)
   ORDER BY pathogen;

/*
SELECT * FROM list_unregistered_pathogens_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2024
-- Description: fixup S2 using a Spreadsheets.xlsx file
--              then cache S2->S3 to make re-entry after this point quicker
--
-- Parameters:
-- @start_row:       this is the row id - the id column in the excel sheet default: 1
-- @stop_row:        [OPT] last row to be processed                        default: 100000
-- @cor_file_path:   [REQ] full path to the cor file
-- @cor_range:       [OPT]                                                 default: 'Sheet1$A:S'
-- @fixup_cnt        [OPT,OUT] returns the count of rows changed in the S2 table
--
-- POSTCONDITIONS:
-- POST 01: all pathogens should exist in the primary pathogens table or EX 57980, '<cnt> Unregistered pathogens exist in S2 see last results table', 1
-- POST 02: summary results (count and status msg) are always written back to the excel sheet in the act_cnt and results column
--
-- RETURNS:
--    0:  OK
--    1:  STOP signal detected
--   -1:  Error
--
-- CHANGES:
-- 240315: added optional parameters:
-- 240315: @cor_file to apply the feed back - results,errors, act counts
-- 240315: @cor_range to specifiy the range of the cor file
-- ======================================================================================
ALTER PROCEDURE [dbo].[sp_main_import_stage_06_fixup_xl]
    @start_row       INT            = 1
   ,@stop_row        INT            = 100000
   ,@cor_file_path   NVARCHAR(1000) = NULL
   ,@cor_range       NVARCHAR(1000) = 'Sheet1$A:S'
   ,@fixup_cnt       INT            = NULL OUTPUT
AS
BEGIN
   DECLARE
    @fn              NVARCHAR(35)   = 'MAIN_IMPRT_STG_06'
   ,@rc              INT            = 0
   ,@cnt             INT            = -1
   ,@msg             NVARCHAR(500)

   EXEC sp_log 1, @fn, '00: starting
start_row: [', @start_row,     ']
stop_row : [', @stop_row ,     ']
cor_file : [', @cor_file_path ,']
cor_range: [', @cor_range,     ']
fixup_cnt: [', @fixup_cnt,     ']
';

   BEGIN TRY
      EXEC sp_register_call @fn;

      ---------------------------------------------------------------------------------------------
      -- Fixup S2 using a Spreadsheets.xlsx file
      ---------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '05: calling sp_fixup_s2_using_corrections_file';

      EXEC @rc = sp_fixup_s2_using_corrections_file
          @start_row    = @start_row
         ,@stop_row     = @stop_row
         ,@fixup_cnt    = @fixup_cnt OUTPUT
         ,@cor_file     = @cor_file_path
         ,@cor_range    = @cor_range
         ;

      -- POST 01: all S2 pathogens should exist in the primary pathogens table or EX 57980, 'Unregistered pathogens exist in S2 see last results table', 1
      EXEC sp_log 1, @fn, '06: ret frm sp_fixup_s2_using_corrections_file';

      SET @cnt = (SELECT COUNT(*) FROM list_unregistered_pathogens_vw);

      IF @cnt <> 0
      BEGIN
         SELECT * FROM list_unregistered_pathogens_vw;
         SET @msg = CONCAT(@cnt, ' unregistered pathogens exist in S2 see last results table');
         EXEC sp_log 4, @fn, @msg;
         THROW 57980, @msg, 1;
      END

      ---------------------------------------------------------------------------------------------
      -- ASSERTION: all S2 pathogens exist in the primary pathogens table
      ---------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '10: ASSERTION: all S2 pathogens exist in the primary pathogens table';

      ---------------------------------------------------------------------------------------------
      -- if successful - and not stopped then cache a backup of Staging2 to Staging3 again 
      -- so can make re-entry after this point quicker
      ---------------------------------------------------------------------------------------------
      IF @rc = 0
      BEGIN
         EXEC sp_log 2, @fn, '15: caching S2->S3';
         EXEC sp_copy_s2_s3;
      END

      ---------------------------------------------------------------------------------------------
      -- Processing complete
      ---------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '80: Processing complete';
   END TRY
   BEGIN CATCH
      EXEC Ut.dbo.sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '95: leaving, @rc: ',@rc;
   RETURN @rc;
END
/*
   ---------------------------------------------------------------------------------------------
   EXEC sp_reset_CallRegister;
   DECLARE    ,@fixup_cnt    INT
   EXEC sp_main_import_stage_06_fixup_xl
    @start_row    = 1
   ,@stop_row     = 100000
   ,@cor_file     = ''
   ,@cor_range    = 'Sheet1$A:S'
   ,@fixup_cnt    = NULL OUTPUT
   ---------------------------------------------------------------------------------------------
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 29-JUL-2023
-- Description: this is the main view relating all fields, it splits out the multiple value fields
--              into a field that holds only 1 value. 
--              Examples are [Pathogens, Pathogen], [Uses Use], [Ingredient, Chemical]
--
-- PRECONDITIONS: Dependencies:
--                Tables: Staging2, [Use], ChemicalStaging, CropStaging, PathogenStaging, ProductStaging
--
-- CHANGES:
-- 20-JAN-2024 now uses only the staging2 table
-- 22-JAN-2024 added actions
-- ======================================================================================================
ALTER VIEW [dbo].[all_vw]
AS
SELECT
       s.stg2_id
      ,company
      ,product        AS product_nm
      ,ingredient     AS chemicals
      ,Chem.    value AS chemical_nm
      ,entry_mode     AS actions
      ,E.       value AS action_nm
      ,crops
      ,Crp.     value AS crop_nm
      ,pathogens
      ,P.       value AS pathogen_nm
      ,s.uses
      ,u.       value AS use_nm
FROM 
   Staging2 s 
   CROSS APPLY string_split(ingredient, '+') as Chem
   CROSS APPLY string_split(crops     , ',') as Crp
   CROSS APPLY string_split(pathogens , ',') as P
   CROSS APPLY string_split(uses      , ',') as U
   CROSS APPLY string_split(entry_mode, ',') as E
/*
SELECT * FROM all_vw
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 29-JUL-2023
-- Description: lists the individual crop and pathogen permutations for Staging2
--    use to create the crop - pathogen link table
--
-- PRECONDITIONS:
-- Dependencies:
--  Pathogen_staging_vw -> Staging2 table
--  PathogenStaging     -> 
--  Crop_staging_vw     -> Staging2 table
--  CropStaging         -> 
-- ======================================================================================================
ALTER VIEW [dbo].[crop_pathogen_staging_vw]
AS
SELECT DISTINCT TOP 10000 crop_nm, pathogen_nm
FROM all_vw
WHERE crop_nm NOT IN ('','-')
   AND pathogen_nm <> ''
ORDER BY crop_nm, pathogen_nm
/*
SELECT * FROM crop_pathogen_staging_vw;
SELECT * FROM cropPathogenStaging ORDER BY crop_nm, pathogen_nm;
*/

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "s"
            Begin Extent = 
               Top = 333
               Left = 663
               Bottom = 488
               Right = 865
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "pv"
            Begin Extent = 
               Top = 331
               Left = 977
               Bottom = 442
               Right = 1165
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "p"
            Begin Extent = 
               Top = 324
               Left = 1300
               Bottom = 457
               Right = 1488
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cv"
            Begin Extent = 
               Top = 334
               Left = 281
               Bottom = 445
               Right = 469
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "c"
            Begin Extent = 
               Top = 343
               Left = 0
               Bottom = 476
               Right = 188
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'crop_pathogen_staging_vw'

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'crop_pathogen_staging_vw'

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'crop_pathogen_staging_vw'

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =================================================================
-- Author:      Terry Watts
-- Create date: 31-MAY-2020
-- Description: creates the message and raises the assertion
--    assuming in a fail state (i.e. check already done and failed)
-- =================================================================
ALTER PROCEDURE [dbo].[sp_raise_assert]
       @a         SQL_VARIANT
      ,@b         SQL_VARIANT
      ,@msg       NVARCHAR(200)  = NULL
      ,@msg2      NVARCHAR(200)  = NULL
      ,@msg3      NVARCHAR(200)  = NULL
      ,@msg4      NVARCHAR(200)  = NULL
      ,@msg5      NVARCHAR(200)  = NULL
      ,@msg6      NVARCHAR(200)  = NULL
      ,@msg7      NVARCHAR(200)  = NULL
      ,@msg8      NVARCHAR(200)  = NULL
      ,@msg9      NVARCHAR(200)  = NULL
      ,@msg10     NVARCHAR(200)  = NULL
      ,@msg11     NVARCHAR(200)  = NULL
      ,@msg12     NVARCHAR(200)  = NULL
      ,@msg13     NVARCHAR(200)  = NULL
      ,@msg14     NVARCHAR(200)  = NULL
      ,@msg15     NVARCHAR(200)  = NULL
      ,@msg16     NVARCHAR(200)  = NULL
      ,@msg17     NVARCHAR(200)  = NULL
      ,@msg18     NVARCHAR(200)  = NULL
      ,@msg19     NVARCHAR(200)  = NULL
      ,@msg20     NVARCHAR(200)  = NULL
      ,@ex_num    INT
      ,@state     INT            = 1
      ,@fn_       NVARCHAR(60)   = '*'  -- assertion rtn calling the raise excption
      ,@fn        NVARCHAR(60)   = NULL -- function testing the assertion
      ,@sf        INT            = 1
AS
BEGIN
   DECLARE
       @fnThis    NVARCHAR(60)    = N'sp_raise_assert'

/*   EXEC sp_log 1, @fnThis,'01: starting
msg :[',@msg,']
msg2:[',@msg2,']
msg3:[',@msg3,']';*/
   IF dbo.fnChkEquals(@a ,@b) = 0
      EXEC sp_raise_exception
          @ex_num
         ,@msg1   = @msg
         ,@msg2   = @msg2
         ,@msg3   = @msg3
         ,@msg4   = @msg4
         ,@msg5   = @msg5
         ,@msg6   = @msg6
         ,@msg7   = @msg7
         ,@msg8   = @msg8
         ,@msg9   = @msg9
         ,@msg10  = @msg10
         ,@msg11  = @msg11
         ,@msg12  = @msg12
         ,@msg13  = @msg13
         ,@msg14  = @msg14
         ,@msg15  = @msg15
         ,@msg16  = @msg16
         ,@msg17  = @msg17
         ,@msg18  = @msg18
         ,@msg19  = @msg19
         ,@msg20  = @msg20
         ,@state  = @state
         ,@fn_    = @fn_     -- assertion rtn calling the raise excption
         ,@fn     = @fn      -- function testing the assertion
         ,@sf     = @sf
END
/*
EXEC test.sp_crt_tst_rtns 'dbo].[sp_raise_assert'
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:       Terry Watts
-- Create date:  22-JAN-2024
-- Description:  Populates the ChemicalActionStaging table from all_vw:
--               Takes the minimum set of uses from the products containing the chemical
--               2:[OPTIONAL] add the extra chemical action data from a spreadsheet tsv
--
-- PRECONDITIONS:
--       PRE01: S2 table populated
--
-- POSTCONDITIONS:
-- POST01: ChemicalActionStaging table populated
-- POST02: mancozeb exists and is only contact
--
-- ALGORITHM:
--    0: PRECONDITION VALIDATION CHECKS
--    1: TRUNCATE the ChemicalActionStaging table
--    2: using All_vw get each chemical and its set of actions for products with ingredients containing only 1 chemical
--
-- CHANGES:
-- Tests:
-- ======================================================================================================
ALTER PROCEDURE [dbo].[sp_pop_ChemicalActionStaging]
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35)   = N'POP CHEM ACTN STAGING'
      ,@sql       NVARCHAR(MAX)
      ,@error_msg NVARCHAR(MAX)  = NULL
      ,@rc        INT            =-1
      ,@cnt       INT            = 0
      ;

   BEGIN TRY
      EXEC sp_log 2, @fn,'01: starting, running precondition checks';
      EXEC sp_register_call @fn;

      -- PRE01: S2 table populated
      EXEC sp_log 1, @fn,'02: PRE01: S2 table must be populated';
      EXEC sp_chk_tbl_populated 'Staging2';
      EXEC sp_chk_tbl_populated 'ActionStaging';
      EXEC sp_chk_tbl_populated 'ChemicalStaging';

      --------------------------------------------------------------------------------
      -- ASSERTION: S2 table populated
      --------------------------------------------------------------------------------

      EXEC sp_log 1, @fn,'03: truncating ChemicalActionStaging table';
      TRUNCATE TABLE dbo.ChemicalActionStaging;

      -- 2: using All_vw get each chemical and its set of actions for products with ingredients containing only 1 chemical

      EXEC sp_log 1, @fn,'05: populating the ChemicalActionStaging table from ALL_vw ';
      INSERT INTO ChemicalActionStaging(chemical_nm, action_nm)
      SELECT DISTINCT chemical_nm, action_nm
      FROM ALL_vw 
      WHERE
               chemical_nm IS NOT NULL 
         AND action_nm   IS NOT NULL
         AND action_nm NOT IN (' ','-')
         AND chemicals   NOT LIKE '%+%'
      ORDER BY chemical_nm, action_nm;

      -- Chk POST01: ChemicalActionStaging table populated
      -- Chk POST02: mancozeb exists and is only contact
      SELECT @cnt = COUNT(*) FROM ChemicalActionStaging WHERE chemical_nm='Mancozeb';
      EXEC sp_raise_assert @cnt, 1, 'Mancozeb should only have 1 entry in ChemicalActionStaging, count: ', @cnt, @ex_num=53224, @fn=@fn;
      SELECT @cnt = COUNT(*) FROM ChemicalActionStaging WHERE chemical_nm='Mancozeb' AND action_nm='CONTACT';
      EXEC sp_raise_assert @cnt, 1, 'Mancozeb mode should be CONTACT in ChemicalActionStaging, count: ', @cnt, @ex_num=53224, @fn=@fn;

      EXEC sp_chk_tbl_populated 'ChemicalActionStaging';
   END TRY
   BEGIN CATCH
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '99: leaving OK';
   RETURN @RC;

END
/*
EXEC sp_pop_chemical_use_staging 1
SELECT * FROM ChemicalActionStaging ORDER BY chemical_nm, action_nm

*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 06-OCT-2023
-- Description: Populates the chemical use table from 2 sources:
--              1: once the S2 table use ALL_vw
--              2: add the extra product use data to the chemical use table from the spreadsheet tsv
--
-- PRECONDITIONS:
--       PRE01: UseStaging table       must be populated
--       PRE02: ChemicalStaging table  must be populated
--
-- POSTCONDITIONS:
--       POST01: ProductUse table populated
--
-- ALGORITHM:
--    0: PRECONDITION VALIDATION CHECKS
--    1: TRUNCATE the staging table
--    2: we can pop the Chemical Use staging table using All_vw
--
-- CALLED BY: -- CALLED BY: sp_main_import_stage_07_pop_stging
--
-- CHANGES:
-- 240124: removed import id parameter
--
-- Tests:
-- ======================================================================================================
ALTER PROCEDURE [dbo].[sp_pop_ChemicalUseStaging]
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35)   = N'POP CHEM USE STAGING'
      ,@sql       NVARCHAR(MAX)
      ,@error_msg NVARCHAR(MAX)  = NULL
      ,@rc        INT            =-1
      ,@cnt       INT            = 0
      ;

   BEGIN TRY
      EXEC sp_log 2, @fn,'01: starting, running precondition checks';
      EXEC sp_register_call @fn;

      --------------------------------------------------------------------------------
      -- PRECONDITION checks
      --------------------------------------------------------------------------------

      -- PRE02: UseStaging must be populated
      EXEC sp_log 1, @fn,'03: PRE02: UseStaging must be populated';
      EXEC sp_chk_tbl_populated 'UseStaging';

      -- PRE03: ChemicalStaging table must be populated
      EXEC sp_chk_tbl_populated 'ChemicalStaging';

      --------------------------------------------------------------------------------
      -- ASSERTION: @import_id known and not NULL or ''
      -- ASSERTION chemicalStaging and [Use] tables are populated
      --------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'04: truncating ChemicalUseStaging table';
      TRUNCATE TABLE dbo.ChemicalUseStaging;

      -- 2: pop the ChemicalUse staging table using the distinct all_vw
      EXEC sp_log 1, @fn,'05: populating the ChemicalUseStaging table from ALL_vw ';

      INSERT INTO ChemicalUseStaging (chemical_nm, use_nm)
      SELECT DISTINCT chemical_nm, use_nm
      FROM ALL_vw
      WHERE chemical_nm IS NOT NULL AND use_nm IS NOT NULL
      ORDER BY chemical_nm, use_nm;

      --------------------------------------------------------------------------------
      -- POSTECONDITION checks
      --------------------------------------------------------------------------------
      -- Chk POST01: ProductUse table populated
      EXEC sp_chk_tbl_populated 'ChemicalUseStaging';
   END TRY
   BEGIN CATCH
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, '50: Caught exception: ', @error_msg;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '99: leaving OK';
   RETURN @RC;
END
/*
EXEC sp_pop_ChemicalUseStaging
SELECT * FROM ChemicalUseStaging
SELECT top 50 * FROM all_vw;

SELECT DISTINCT chemical_nm, use_nm
FROM ALL_vw WHERE chemical_nm IS NOT NULL AND use_nm IS NOT NULL
AND use_nm NOT IN ( SELECT use_nm FROM UseStaging) ORDER BY chemical_nm, use_nm;
SELECT DISTINCT uses from staging1 order by uses

------------------------------------------------
chemical_nm	   use_nm	(No column name)
------------------------------------------------
Azadirachtin	"insecticide/fu ngicide"
*/
------------------------------------------------

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =================================================================
-- Author:      Terry Watts
-- Create date: 09-FEB-2024
-- Description:  deletes the table and logs the deletion
--
-- PRECONDITIONS:
--
-- POSTCONDITIONS:
-- =================================================================
ALTER PROCEDURE [dbo].[sp_delete_table]
   @table NVARCHAR(60)
AS
BEGIN
   DECLARE
       @fn     NVARCHAR(35)   = 'DELETE_TABLE'
      ,@sql    NVARCHAR(max)

   SET NOCOUNT ON;

   BEGIN TRY
      SET @sql = CONCAT('DELETE FROM ', @table, ';');
      EXEC (@sql);
      EXEC sp_log 1, @fn, '10: deleted ', @@ROWCOUNT, ' rows from the ', @table, ' table';
   END TRY
   BEGIN CATCH
      DECLARE @msg NVARCHAR(35);
      SET @msg = Ut.dbo.fnGetErrorMsg();
      SET @msg = CONCAT('Error deleting rows from the ', @table,' ', @msg);
      EXEC sp_log 4, @fn, @msg;
      THROW 69403, @msg, 1;
   END CATCH
END
/*
   EXEC sp_delete_table 'ChemicalUseStaging';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===================================================
-- Author:		 Terry Watts
-- Create date: 17-JUL-20223
-- Description: List the Companies in order - use to
--    look for duplicates and misspellings and errors
-- ===================================================
ALTER FUNCTION [dbo].[fnListCompanies]()
RETURNS 
@t TABLE (company NVARCHAR(250))
AS
BEGIN
   INSERT INTO @t
   SELECT DISTINCT TOP 99999  company
   FROM Staging2 
   --WHERE company NOT IN ('', '-','--') AND company IS NOT NULL
   ORDER BY company;

	RETURN 
END
/*
SELECT company from dbo.fnListCompanies();
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===================================================
-- Author:		 Terry Watts
-- Create date: 17-JUL-20223
-- Description: List the Crops in order - use to
--    look for duplicates and misspellings and errors
-- ===================================================
ALTER FUNCTION [dbo].[fnListCrops]()
RETURNS 
@t TABLE (crop NVARCHAR(250))
AS
BEGIN
   INSERT INTO @t
   SELECT DISTINCT 
   cs.value AS crop
   FROM Staging2 
   CROSS APPLY string_split(crops, ',') cs
   WHERE cs.value NOT IN ('', '-','--')

	RETURN 
END
/*
SELECT crop from dbo.fnListCrops()
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==================================================================================================================================================================
-- Routine:     dbo.sp_pop_staging_tables
-- Author:      Terry Watts
-- Create date: 25-AUG-2023
-- Description: clears out the staging tables in order
--
-- Called by: sp_main_import_stage_6, sp_main_import
--
-- PRECONDITIONS:
-- PRE 01: ActionStaging               imported
-- PRE 02: UseStaging                  imported
-- PRE 03: PathogenTypeStaging         imported
-- PRE 04: PathogenPathogenTypeStaging populated
-- PRE 05: TypeStaging                 populated
--
-- POSTCONDITIONS: ALL staging tables are populated:
-- POST 01: ActionStaging                populated
-- POST 02: ChemicalStaging              populated
-- POST 03: ChemicalActionStaging        populated
-- POST 04: ChemicalUseStaging           populated
-- POST 05: CompanyStaging               populated
-- POST 06: CropStaging                  populated
-- POST 07: CropPathogenStaging          populated
-- POST 08: PathogenStaging              populated
-- POST 09: PathogenChemicalStaging      populated
-- POST 10: PathogenTypeStaging          populated
-- POST 11: PathogenPathogenTypeStaging  populated
-- POST 12: ProductStaging               populated
-- POST 13: ProductCompanyStaging        populated
-- POST 14: ProductUseStaging            populated
-- POST 15: TypeStaging                  populated
-- POST 16: UseStaging                   populated
--
-- TESTS:
--
-- CALLED BY: sp_main_import_stage_07_pop_stging
--
-- CHANGES:
-- 231007: fix: Violation of PRIMARY KEY constraint 'PK_ChemicalProductStaging'. Cannot insert duplicate key in object 'dbo.ChemicalProductStaging'.
-- 231008: added company nm info to the product staging table
-- 231013: added PRE 01: import_id must be passed as a parameter or be part of the session context
--         made @import_id a parameter for ease of testing
-- 231014: changed name from sp_pop_normalised_tables to sp_pop_normalised_staging_tables
--         added order by clause to INSERT INTO PathogenStaging(pathogen_nm, import_id) SELECT pathogen, @import_id from dbo.fnListPathogens()
-- 231104: added PathogenChemicalStaging
-- 240124: removed import id parameter - this is common accross all import staging tables
-- 240209: tidy up and refactor to valid postconditions at end.
-- ==================================================================================================================================================================
ALTER PROCEDURE [dbo].[sp_pop_staging_tables]
AS
BEGIN
   SET NOCOUNT OFF;
   DECLARE
       @fn        NVARCHAR(30)   = 'POP STG TBLS'
      ,@error_msg NVARCHAR(MAX)  = NULL
      ,@file_path NVARCHAR(MAX)

   BEGIN TRY
      EXEC sp_log 2, @fn, '00: starting, chking preconditions';
      EXEC sp_register_call @fn;

      ---------------------------------------------------------------------------------
      -- PRE 01: ActionStaging               imported
      -- PRE 02: UseStaging                  imported
      -- PRE 03: PathogenTypeStaging         imported
      -- PRE 04: PathogenPathogenTypeStaging populated
      -- PRE 05: TypeStaging                 populated
      ---------------------------------------------------------------------------------
      EXEC sp_chk_tbl_populated 'ActionStaging';
      EXEC sp_chk_tbl_populated 'UseStaging';
      EXEC sp_chk_tbl_populated 'PathogenTypeStaging';
      EXEC sp_chk_tbl_populated 'TypeStaging';

      ---------------------------------------------------------------------------------
      -- ASSERTION: ActionStaging, UseStaging, PathogenTypeStaging tables imported
      ---------------------------------------------------------------------------------

      ---------------------------------------------------------------------------------
      -- 1. Clear out old data now, dependencies first
      ---------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '01: deleting all rows from all the staging tables';
      -- Dependencies first
      EXEC sp_delete_table ChemicalActionStaging;
      EXEC sp_delete_table ChemicalProductStaging;
      EXEC sp_delete_table ChemicalUseStaging;
      EXEC sp_delete_table PathogenChemicalStaging;
      EXEC sp_delete_table CropPathogenStaging;
      EXEC sp_delete_table ImportCorrectionsStaging;
      EXEC sp_delete_table PathogenChemicalStaging;
      EXEC sp_delete_table ProductCompanyStaging;
      EXEC sp_delete_table ProductUseStaging;

      -- Primary table next
      EXEC sp_delete_table ChemicalStaging;
      EXEC sp_delete_table CompanyStaging;
      EXEC sp_delete_table CropStaging;
      EXEC sp_delete_table PathogenStaging;
      EXEC sp_delete_table ProductStaging;

      ---------------------------------------------------------------------------------
      -- 02: Asertion: all staging tables cleared
      ---------------------------------------------------------------------------------
      EXEC sp_chk_tbl_not_populated 'ChemicalStaging';
      EXEC sp_chk_tbl_not_populated 'ChemicalActionStaging';
      EXEC sp_chk_tbl_not_populated 'ChemicalProductStaging';
      EXEC sp_chk_tbl_not_populated 'ChemicalUseStaging';
      EXEC sp_chk_tbl_not_populated 'CompanyStaging';
      EXEC sp_chk_tbl_not_populated 'CropStaging';
      EXEC sp_chk_tbl_not_populated 'CropPathogenStaging';
      EXEC sp_chk_tbl_not_populated 'PathogenStaging';
      EXEC sp_chk_tbl_not_populated 'PathogenChemicalStaging';
      EXEC sp_chk_tbl_not_populated 'ProductStaging';
      EXEC sp_chk_tbl_not_populated 'ProductCompanyStaging';
      EXEC sp_chk_tbl_not_populated 'ProductCompanyStaging';

      ---------------------------------------------------------------------------------
      -- 02: Populate the normalised primary staging tables
      ---------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '02: Populate the normalised primary staging tables';

      ---------------------------------------------------------------------------------
      -- 03: Pop ChemicalStaging table
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '02: Pop ChemicalStaging table';
      INSERT INTO ChemicalStaging(chemical_nm)
         SELECT distinct cs.value as chemical
         FROM Staging2 s CROSS APPLY string_split(ingredient,'+') cs
         ORDER BY cs.value;

      -- POST 05.1: ChemicalStaging table populated

      ---------------------------------------------------------------------------------
      -- 04: Pop CompanyStaging table
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '04: Pop PathogenStaging table';
      INSERT INTO CompanyStaging(company_nm) select company from dbo.fnListCompanies();

      ---------------------------------------------------------------------------------
      -- 05: Pop CropStaging table
      ---------------------------------------------------------------------------------
      -- Violation of UNIQUE KEY constraint 'UQ_CropStaging_nm'. Cannot insert duplicate key in object 'dbo.CropStaging'. The duplicate key value is (Green Peas (Legumes)).
      EXEC sp_log 1, @fn, '05: Pop CropStaging table';
      INSERT INTO CropStaging(crop_nm) SELECT crop FROM dbo.fnListCrops() WHERE crop NOT IN ('','-','--') AND crop IS NOT NULL;


      ---------------------------------------------------------------------------------
      -- 06: Pop PathogenStaging table
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '06: Pop PathogenStaging table';
      INSERT INTO PathogenStaging(pathogen_nm)
      SELECT pathogen
      FROM dbo.list_unregistered_pathogens_vw
      ORDER BY pathogen;

      -- Import and update the pathogen type
      UPDATE PathogenStaging
      SET pathogenType_nm = S.pathogenType_nm
      FROM OPENROWSET ( 'Microsoft.ACE.OLEDB.12.0',
'Excel 12.0;HDR=YES;IMEX=1; Database=D:\Dev\Repos\Farming\Data\Pathogen.xlsx',
'SELECT *
FROM [Pathogen$A:B]') S JOIN PathogenStaging P ON S.pathogen_nm = P.pathogen_nm;

      ---------------------------------------------------------------------------------
      -- 07: Pop ProductStaging table
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '07: Pop ProductStaging table from the S2 info';
      INSERT INTO ProductStaging(product_nm) SELECT distinct product From staging2 WHERE product IS NOT NULL ORDER by product;

       --------------------------------------------------------------------------------
       -- 08: Populate the staging link tables
      ---------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '08: Populate the staging link tables';

      ---------------------------------------------------------------------------------
      -- 09: Pop PathogenChemicalStaging table
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '09: Pop PathogenChemicalStaging staging table';

      EXEC sp_log 1, @fn, '09.2: INSERT INTO PathogenChemicalStaging';
      INSERT INTO PathogenChemicalStaging (pathogen_nm, chemical_nm)
      SELECT distinct pathogen_nm, chemical_nm
      FROM all_vw
      WHERE pathogen_nm <> '';

      ---------------------------------------------------------------------------------
      -- 10: POP the ChemicalActionStaging table
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '10: calling sp_pop_ChemicalActionStaging';
      EXEC sp_pop_ChemicalActionStaging;

      ---------------------------------------------------------------------------------
      -- 11: Pop the ChemicalProductStaging table - 231005: added nm fields for ease of merging
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '11: Pop ChemicalProductStaging table';
     -- 231007 fix: Violation of PRIMARY KEY constraint 'PK_ChemicalProductStaging'. Cannot insert duplicate key in object 'dbo.ChemicalProductStaging'.
      INSERT INTO ChemicalProductStaging(chemical_nm, product_nm)
      SELECT distinct chemical_nm, product_nm
      FROM all_vw;

      ---------------------------------------------------------------------------------
      -- 12: Pop the ChemicalUseStaging table
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '12: Pop ChemicalUseStaging table, calling sp_pop_chemical_use_staging';
      EXEC sp_pop_ChemicalUseStaging;

      ---------------------------------------------------------------------------------
      -- 13: Pop CropPathogenStaging table
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '13: Pop CropPathogenStaging table';

      INSERT INTO CropPathogenStaging (crop_nm, pathogen_nm)
      SELECT crop_nm, pathogen_nm
      FROM crop_pathogen_staging_vw;

      -- POST 06.4: CropPathogenStaging table populated
      -- 231008:
      ---------------------------------------------------------------------------------
      -- 14.: Pop ProductCompanyStaging table
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '14: Pop ProductCompanyStaging table';
      INSERT INTO ProductCompanyStaging (product_nm, company_nm)
      SELECT distinct product_nm, company
      FROM all_vw;

      EXEC sp_chk_tbl_populated 'ProductCompanyStaging';
      -- POST 06.7: ProductCompanyStaging table populated

      ---------------------------------------------------------------------------------
      -- 15: Pop ProductUseStaging table ids
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '15: pop ProductUseStaging table';
      INSERT INTO ProductUseStaging (product_nm, use_nm)
      SELECT distinct product_nm, use_nm
      FROM all_vw
      ORDER BY product_nm, use_nm ASC;

      ---------------------------------------------------------------------------------
      -- 16: Validate postconditions - ALL staging tables populated
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '16: table population completed checking postconditions';
      EXEC sp_chk_tbl_populated 'ActionStaging';
      EXEC sp_chk_tbl_populated 'ChemicalStaging';
      EXEC sp_chk_tbl_populated 'ChemicalActionStaging';
      EXEC sp_chk_tbl_populated 'ChemicalProductStaging';
      EXEC sp_chk_tbl_populated 'ChemicalUseStaging';
      EXEC sp_chk_tbl_populated 'CompanyStaging';
      EXEC sp_chk_tbl_populated 'CropStaging';
      EXEC sp_chk_tbl_populated 'CropPathogenStaging';
--      EXEC sp_chk_tbl_populated 'PathogenStaging';
      EXEC sp_chk_tbl_populated 'PathogenTypeStaging';
      EXEC sp_chk_tbl_populated 'PathogenChemicalStaging';
      EXEC sp_chk_tbl_populated 'ProductStaging';
      EXEC sp_chk_tbl_populated 'ProductCompanyStaging';
      EXEC sp_chk_tbl_populated 'ProductCompanyStaging';
      EXEC sp_chk_tbl_populated 'TypeStaging';
      EXEC sp_chk_tbl_populated 'UseStaging';

      ---------------------------------------------------------------------------------
      -- COMPLETED PROCESSING
      ---------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,  '49: completed processing OK';
   END TRY
   BEGIN CATCH
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, '50: Caught exception: ', @error_msg;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '99: leaving OK';
END
/*
EXEC sp_reset_callRegister
EXEC sp_pop_staging_tables;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =======================================================
-- Author:      Terry Watts
-- Create date: 21-JAN-2024
-- Description: Lists the staging table counts
-- use to check the import and staging pop processes
-- =======================================================
ALTER VIEW [dbo].[list_stging_tbl_counts_vw]
AS
SELECT 'ActionStaging'       AS [table], COUNT(*) AS row_count  FROM ActionStaging                UNION
SELECT 'ChemicalStaging'               , COUNT(*)               FROM ChemicalStaging              UNION
SELECT 'ChemicalActionStaging'         , COUNT(*)               FROM ChemicalActionStaging        UNION
SELECT 'ChemicalUseStaging'            , COUNT(*)               FROM ChemicalUseStaging           UNION
SELECT 'CompanyStaging'                , COUNT(*)               FROM CompanyStaging               UNION
SELECT 'CropStaging'                   , COUNT(*)               FROM CropStaging                  UNION
SELECT 'CropPathogenStaging'           , COUNT(*)               FROM CropStaging                  UNION
SELECT 'PathogenStaging        '       , COUNT(*)               FROM PathogenStaging              UNION
SELECT 'PathogenChemicalStaging'       , COUNT(*)               FROM PathogenChemicalStaging      UNION
SELECT 'PathogenTypeStaging'           , COUNT(*)               FROM PathogenTypeStaging          UNION
SELECT 'ProductStaging'                , COUNT(*)               FROM ProductStaging               UNION
SELECT 'ProductCompanyStaging'         , COUNT(*)               FROM ProductCompanyStaging        UNION
SELECT 'ProductUseStaging'             , COUNT(*)               FROM ProductUseStaging            UNION
SELECT 'TypeStaging'                   , COUNT(*)               FROM TypeStaging                  UNION
SELECT 'UseStaging'                    , COUNT(*)               FROM UseStaging
;
/*
SELECT * FROM list_stging_tbl_counts_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =====================================================================
-- Author:      Terry Watts
-- Create Date: 21-JAN-2024
-- Description: Post condition chk for pop staging tables
--       Checks that the staging tables have at least 1 row each
--
-- POSTCONDITIONS: The following tables are populated:
-- POST 01: ActionStaging                populated
-- POST 02: ChemicalStaging              populated
-- POST 03: ChemicalActionStaging        populated
-- POST 04: ChemicalUseStaging           populated
-- POST 05: CompanyStaging               populated
-- POST 06: CropStaging                  populated
-- POST 07: CropPathogenStaging          populated
---- POST 08: PathogenStaging              populated
-- POST 09: PathogenChemicalStaging      populated
-- POST 10: PathogenTypeStaging          populated
-- POST 12: ProductStaging               populated
-- POST 13: ProductCompanyStaging        populated
-- POST 14: ProductUseStaging            populated
-- POST 15: TypeStaging                  populated
-- POST 16: UseStaging                   populated
--
-- CHANGES:
-- =====================================================================
ALTER PROCEDURE [dbo].[sp_pop_staging_tables_post_condition_checks]
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35)   = N'POP_STG_TBLS_POST_CNDTN_CHCK'

   EXEC sp_log 2, @fn,'01: starting';
   EXEC sp_register_call @fn;

   SELECT * FROM list_stging_tbl_counts_vw;

   EXEC sp_chk_tbl_populated 'ActionStaging'              ; -- 01 ActionStaging'
   EXEC sp_chk_tbl_populated 'ChemicalStaging'            ; -- 02 ChemicalStaging'
   EXEC sp_chk_tbl_populated 'ChemicalActionStaging'      ; -- 03 ChemicalActionStaging'
   EXEC sp_chk_tbl_populated 'ChemicalProductStaging'     ; -- 04 ChemicalProductStaging'
   EXEC sp_chk_tbl_populated 'ChemicalUseStaging'         ; -- 05 ChemicalUseStaging'
   EXEC sp_chk_tbl_populated 'CompanyStaging'             ; -- 06 CompanyStaging'
   EXEC sp_chk_tbl_populated 'CropStaging'                ; -- 07 CropStaging'
   EXEC sp_chk_tbl_populated 'CropPathogenStaging'        ; -- 08 CropPathogenStaging'
   --EXEC sp_chk_tbl_populated 'PathogenStaging        '    ; -- 09 PathogenStaging'
   EXEC sp_chk_tbl_populated 'PathogenChemicalStaging'    ; -- 10 PathogenChemicalStaging'
   EXEC sp_chk_tbl_populated 'PathogenTypeStaging'        ; -- 11 PathogenTypeStaging
   EXEC sp_chk_tbl_populated 'ProductStaging'             ; -- 13 ProductStaging'
   EXEC sp_chk_tbl_populated 'ProductCompanyStaging'      ; -- 14 ProductUseStaging'
   EXEC sp_chk_tbl_populated 'ProductUseStaging'          ; -- 15 TypeStaging'
   EXEC sp_chk_tbl_populated 'TypeStaging'                ; -- 16 UseStaging'
   EXEC sp_chk_tbl_populated 'UseStaging'                 ; -- 17  Import'

   EXEC sp_log 2, @fn, '99: leaving: OK';
END
/*
EXEC sp_reset_call_register;
EXEC sp_pop_staging_tables_post_condition_checks;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ============================================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2024
-- Description: populate the staging tables from S2 after fixup
--              run staging post condition checks
--
-- PRECONDITIONS: S2 fixed up
--
-- POSTCONDITIONS: See sp_pop_staging_tables_post_condition_checks
-- =============================================================
ALTER PROCEDURE [dbo].[sp_main_import_stage_07_pop_stging]
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35)   = 'MAIN_IMPRT_STG_07'

   EXEC sp_log 1, @fn, '00: starting';
   EXEC sp_register_call @fn;

   -----------------------------------------------------------------------------------
   -- Populate the staging tables
   -----------------------------------------------------------------------------------
   EXEC sp_log 2, @fn, '10:populating the staging tables';
   EXEC sp_pop_staging_tables;

   -----------------------------------------------------------------------------------
   -- Populate the staging tables post condition check
   -----------------------------------------------------------------------------------
   EXEC sp_log 2, @fn, '10: post condition checks: calling sp_pop_staging_tables_post_condition_checks';
   EXEC sp_pop_staging_tables_post_condition_checks;     -- Post condition chk

   EXEC sp_log 2, @fn, '90: processing complete';
   EXEC sp_log 1, @fn, '99: leaving';
END
/*
   EXEC sp_main_import_stage_07;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 08-FEB-2020
-- Description: checks if table exists 
--    if not throws @ex_num=62250, @ex_msg= '[<table spec>] does not exist.'
;
-- Parameters:
-- @table_spec <db>.<schema>.<table> or <table>
-- @ex_num default @ex_num=62250
-- @ex_msg default is '[<table spec>] does not exist.'
-- =============================================
ALTER PROCEDURE [dbo].[sp_assert_table_exists]
    @table_spec   NVARCHAR(60) -- LIKE dbo.
   ,@ex_num       INT            = NULL OUT
   ,@ex_msg       NVARCHAR(500)  = NULL OUT
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35)   = N'sp_assert_table_exists'
      ,@schema_nm NVARCHAR(20)
      ,@table_nm  NVARCHAR(60)
      ,@sql       NVARCHAR(200)
      ,@n         INT
      ,@exists    BIT

   EXEC sp_log 1, @fn, '00: starting, 
@table_spec:[',@table_spec,']
@ex_num:    [',@ex_num,']
@ex_msg:    [',@ex_msg,']'
;

   IF @ex_num IS NULL SET @ex_num = 62250;
   IF @ex_msg IS NULL SET @ex_msg = CONCAT('[',@table_spec,'] does not exist.');

   IF dbo.fnTableExists(@table_spec) = 0
   BEGIN
      EXEC sp_raise_exception @ex_num, @ex_msg;
   END
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_036_sp_chk_table_exists';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ================================================================
-- Author:      Terry Watts
-- Create date: 25-FEB-2024
-- Description: imports a tsv file using a view
--
-- POSTCONDITIONS:
-- POST 01: if @clr_first is set then the table must be specified or EXCEPTION 62250, 'table must be specified if @clr_first is set'
--
-- ================================================================
ALTER PROCEDURE [dbo].[sp_import_tsv]
    @tsv_file  NVARCHAR(MAX)
   ,@view      NVARCHAR(120)
   ,@table     NVARCHAR(60)   = NULL --POST 01: if @clr_first is set then the table must be specified or EXCEPTION 62250, 'able must be specified if @clr_first is set'
   ,@clr_first    BIT        = 1 -- if 1 then delete the table contents first
AS
BEGIN
   DECLARE
       @fn     NVARCHAR(35)   = N'BLK_IMPRT_TSV'
      ,@cmd    NVARCHAR(MAX)

   EXEC sp_log 1, @fn, '00: starting, 
@tsv_file: [',@tsv_file,']
@view:     [',@view,']
@table:    [',@table,']
@clr_first [',clr_first,']'
;

   IF @clr_first = 1
   BEGIN
      -- POST 01: if @clr_first is set then the table must be specified or EXCEPTION 62250, 'table must be specified if @clr_first is set'

      if dbo.fnTableExists(@table) = 1
      BEGIN
         EXEC sp_assert_table_exists @table;
      END

      SET @cmd = CONCAT('DELETE FROM [', @table,']');
      PRINT @cmd;
      EXEC( @cmd)
   END

   SET @cmd = CONCAT('EXEC xp_cmdshell ''DEL D:\Logs',NCHAR(92), @view,'.log.Error.Txt'', NO_OUTPUT;');
   EXEC sp_log 1, @fn, @cmd;
   EXEC sp_executesql @cmd;

   SET @cmd = CONCAT('EXEC xp_cmdshell ''DEL D:\Logs',NCHAR(92), @view,'.log''          , NO_OUTPUT;');
   EXEC sp_log 1, @fn, @cmd;
   EXEC sp_executesql @cmd;

   SET @cmd = CONCAT(
      'BULK INSERT [',@view,'] FROM ''', @tsv_file, '''
      WITH
      (
         FIRSTROW        = 2
        ,ERRORFILE       = ''D:\Logs',NCHAR(92),@view,'Import.log''
        ,FIELDTERMINATOR = ''\t''
        ,ROWTERMINATOR   = ''\n''
      );
   ');
   EXEC sp_log 1, @fn, @cmd;
   EXEC sp_executesql @cmd;

   RETURN @cmd;
END
/*
EXEC dbo.sp_bulk_import @import_file='D:\Dev\CRM\data\Selling Resort - Agents.csv', @table= 'ImportedData', @view='ImportedData';


EXEC tSQLt.RunAll;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =====================================================================================
-- Author       Terry Watts
-- Create date: 07-FEB-2024
-- Description: Registers a routine call and checks the call count against the limit
--
-- CHECKED PRECONDITIONS: PRE 01: @rtn must be registered
-- =====================================================================================
ALTER PROCEDURE [dbo].[sp_import_CallRegister]
    @spreadsheet  NVARCHAR(500)
   ,@range        NVARCHAR(60) = 'Call Register$A:C'
AS
BEGIN
   DECLARE
        @fn       NVARCHAR(35) = 'IMPRT_CALL_REGISTER'
       ,@is_XLS   BIT

   EXEC sp_log 2, @fn,'00: starting: 
@spreadsheet: [',@spreadsheet,']
@range:       [',@range,']';

   EXEC sp_log 2, @fn,'10: clearing existing records';
   DELETE FROM CallRegister;
   SET @is_XLS = iif( dbo.fnGetFileExtension(@spreadsheet) = 'xlsx', 1 , 0);
   EXEC sp_log 2, @fn,'20: importing call configuration...@is_XLS: ', @is_XLS;

   IF @is_XLS = 1
   BEGIN
      EXEC sp_log 2, @fn,'25: ';
      EXEC sp_import_XL_existing @spreadsheet, @range, 'CallRegister';  --, 'id,rtn,limit'
   END
   ELSE
   BEGIN
      EXEC sp_log 2, @fn,'30: ';
      EXEC sp_import_tsv @spreadsheet, 'Import_CallRegister_vw', 'CallRegister';
   END

   EXEC sp_log 2, @fn,'99: leaving OK';
END
/*
EXEC sp_import_call_register 'D:\Dev\Repos\Farming\Data\CallRegister.xlsx';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:		  Terry Watts
-- Create date:  19-AUG-2023
-- Description:  SETS a session context
-- ======================================================================================================
ALTER PROCEDURE [dbo].[sp_set_session_context_cor_id]
   @val     INT
AS
BEGIN
   DECLARE     @key     NVARCHAR(30)
   SET @key = dbo.fnGetSessionKeyCorId();
   EXEC sp_set_session_context @key, @val;
END
/*
EXEC sp_set_session_context_cor_id 35
PRINT CONCAT('old cor_id: [', dbo.fnGetSessionValueCorId(),']');
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==========================================================
-- Author:		  Terry Watts
-- Create date:  19-AUG-2023
-- Description:  SETS the import_id session context
-- ==========================================================
ALTER PROCEDURE [dbo].[sp_set_session_context_import_id]
   @val  INT
AS
BEGIN
   DECLARE     @key     NVARCHAR(30)
   SET @key = dbo.fnGetSessionKeyImportId();
   EXEC sp_set_session_context @key, @val;
END
/*
EXEC sp_set_session_context_import_id 240530
PRINT CONCAT('import_id: [', dbo.fnGetSessionValueImportId(),']');
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 20-SEP-2024
--
-- Description: Gets the file details from the supplied file path:
--    [Folder, File name woyhout ext, extension]
--
-- Tests:
--
-- CHANGES:
-- ======================================================================================================
ALTER FUNCTION [dbo].[fnGetFileDetails]
(
   @file_path NVARCHAR(MAX)
)
RETURNS
@t TABLE
(
    folder        NVARCHAR(MAX)
   ,[file_name]   NVARCHAR(MAX)
   ,ext           NVARCHAR(MAX)
   ,fn_pos        INT
   ,dot_pos       INT
   ,[len]         INT
)
AS
BEGIN
   DECLARE
       @fn_pos  INT
      ,@dot_pos INT
      ,@len     INT

   SET @len    = dbo.fnLen(@file_path);
   SET @fn_pos = IIF(@len=0, NULL,@len - CHARINDEX('\', REVERSE(@file_path)));
   SET @dot_pos= IIF(@len=0, NULL,@len - CHARINDEX('.', REVERSE(@file_path)));

   INSERT INTO @t(folder, [file_name], ext, fn_pos, dot_pos, [len])
   VALUES
   (
       SUBSTRING(@file_path, 1, @fn_pos)               -- folder
      ,IIF(@len=0, NULL,SUBSTRING(@file_path, @fn_pos +2, @dot_pos-@fn_pos-1)) -- file_name
      ,IIF(@len=0, NULL,SUBSTRING(@file_path, @dot_pos+2, @len-@dot_pos-1))    -- ext
      ,@fn_pos
      ,@dot_pos
      ,@len
   );

   RETURN;
END
/*
EXEC tSQLt.Run 'test.test_096_fnGetFileDetails';
SELECT * FROM dbo.fnGetFileDetails('D:\Dev\Ut\Tests\test_096_GetFileDetails\CallRegister.abc.txt')
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 02-AUG-2023
-- Description: Encapsulate all the main import routine init - not 
-- Called by:   sp_main__import_pesticide_register
--
-- Responsibilities:
-- 01: Determine the file type - xlsx or csv (txt)
-- 02: Clear the applog 
-- 03: Set the log level
-- 04: Configure routine call control to avoid multiple calls of single call routines
-- 05: Set session ctx vals: fixup count: 0, import_root
-- 06: Get the import id from the file name
-- 07: Override import_id with @import_id parameter if supplied
-- 08: Delete bulk import log files
-- 09: Postcondition checks
-- 10: Completed processing
-- 
-- POST CONDITIONS:
-- POST 1: session settings[fixup count] set to 0
-- POST 2: @import_root set 
-- POST 3: @import_id  AND session settings[IMPORT_ID] set and >1,
--         if import id < 0 exception thrown 
-- POST 4: if mode contains logging level the session settings[IMPORT_ID] set 
-- POST 5: clear the staging import logs
--
-- CHANGES:
-- 230811: Clean import then merge into the main tables, save the import_id as a session setting in import-init
-- 231013: Override @import_id if supplied
-- 231014: ADDED POST Condition CHKS: import_id NOT NULL AND > 0
--         Added support of table logging: clear the table before the main procedure starts
-- 231016: Truncate the AppLog table
-- 231108: removed params: @import_root which is now supplied to the main fn with a default
-- 240207: added call to sp_clear_call_register to clear the routine call register table
-- 240309: moved the tuncate applog to main as we dont get any logging of main import right now
-- 240323: added sp_write_results_to_cor_file validation now so as to waste time processing if bad p
-- ======================================================================================================
ALTER PROCEDURE [dbo].[sp_main_import_init]
    @LRAP_data_file  NVARCHAR(150)  OUT
   ,@import_root     NVARCHAR(450)
   ,@log_level       INT
   ,@cor_file        NVARCHAR(450)
   ,@cor_range       NVARCHAR(40)
   ,@cor_file_path   NVARCHAR(450)  OUT
   ,@import_id       INT            OUT
   ,@file_type       NCHAR(4)       OUT -- 'txt' or 'xlsx'
AS
BEGIN
   DECLARE
    @fn              NVARCHAR(35)   = N'MAIN_IMPORT_INIT'
   ,@msg             NVARCHAR(500)  = ''
   ,@ndx             INT
   ,@import_id_cpy   INT
   ,@import_file     NVARCHAR(500)

   -- Set nocount off so we can see the update counts
   SET NOCOUNT OFF
   -- Set the stop at first error flag
   SET XACT_ABORT ON;

   EXEC sp_log 2, @fn,'00: starting
   @LRAP_data_file:[',@LRAP_data_file,']
   @import_root:   [',@import_root,']
   @log_level:     [',@log_level,']
   @cor_file:      [',@cor_file,']
   @cor_range:     [',@cor_range,']'
   ;

   BEGIN TRY
      -----------------------------------------------------------------------------------
      -- 01: Determine the file type - xlsx or csv (txt)
      -----------------------------------------------------------------------------------
      SELECT @file_type = ext FROM  dbo.fnGetFileDetails(@LRAP_data_file);
      -----------------------------------------------------------------------------------
      -- 02: Clear the applog 
      -----------------------------------------------------------------------------------
      TRUNCATE TABLE Applog;

      -- Disable the staging2 on update trigger
      DISABLE TRIGGER staging2.sp_Staging2_update_trigger ON staging2;
      TRUNCATE TABLE S2UpdateLog;
      TRUNCATE TABLE S2UpdateSummary;

      -----------------------------------------------------------------------------------
      -- 03: Set the log level
      -----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '05: setting minimum logging level to: ', @log_level, ' mode txt:[',@msg,']';
      EXEC sys.sp_set_session_context @key = N'LOG_LEVEL', @value = @log_level;-- POST 4: set the min log level

      --------------------------------------------------------------------------------------
      -- 04: Configure routine call control to avoid multiple calls of single call routines
      --------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '10: calling sp_import_call_register';
      SET @import_file = CONCAT(@import_root, '\','CallRegister.txt');
      EXEC sp_import_CallRegister @import_file;
      EXEC sp_register_call @fn;
      EXEC sp_log 1, @fn, '12: setting context data';

      SET @import_id_cpy = @import_id;

      -----------------------------------------------------------------------------------
      -- 05: Set session ctx vals: fixup count: 0, import_root
      -----------------------------------------------------------------------------------
      EXEC ut.dbo.sp_set_session_context N'fixup count', 0;                    -- POST 1 init fixup cnt to 0
      EXEC ut.dbo.sp_set_session_context_import_root @import_root;             -- POST 2 KEY: 'Import Root'
      EXEC sp_set_session_context_cor_id 0;
      SET @LRAP_data_file = CONCAT(@import_root, NCHAR(92), @LRAP_data_file);

      -----------------------------------------------------------------------------------
      -- 06: Get the import id from the file name
      -----------------------------------------------------------------------------------
      SET @import_id = dbo.fnGetImportIdFromName(@LRAP_data_file);
      EXEC sp_log 1, @fn, '20: @import_id: ',@import_id;
      EXEC sp_assert_not_null @import_id, 'Import id must not be null';

      -----------------------------------------------------------------------------------
      -- 07: Override import_id with @import_id parameter if supplied
      -----------------------------------------------------------------------------------
      IF (@import_id = -1 OR @import_id IS NULL) AND (@LRAP_data_file IS NOT NULL)
         EXEC Ut.dbo.sp_raise_exception 51234, 'Unrecognised file format type for LRAP file:[', @LRAP_data_file, ']';

      IF @import_id_cpy IS NOT NULL
         SET @import_id = @import_id_cpy;

      -----------------------------------------------------------------------------------
      -- 08: Delete bulk import log files
      -----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '25: Deleting bulk import log files, @import_id: ',@import_id;
      EXEC xp_cmdshell 'DEL D:\Logs\PesticideRegisterImportErrors.log.Error.Txt', NO_OUTPUT; -- POST 5: clear the staging import logs
      EXEC xp_cmdshell 'DEL D:\Logs\PesticideRegisterImportErrors.log'          , NO_OUTPUT; -- POST 5: clear the staging import logs

      -----------------------------------------------------------------------------------
      -- 09: Postcondition checks
      -----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '30: Postcondition checks: @import_id must not be NUL and must be > 0, @import_id: [', @import_id,']';
      EXEC Ut.dbo.sp_assert_not_null @import_id,    '@import_id must not be NULL', @ex_num = 58100; 
      EXEC Ut.dbo.sp_assert_gtr_than @import_id, 0, '@import_id must be > 0'     , @ex_num = 58101;

      -- ASSERTION: @import_id id known and > 0
      EXEC sp_set_session_context_import_id @import_id;              -- POST 3: set import id

      -- Validate write back params now so as not to waste time
      SET @cor_file_path = CONCAT(@import_root, '\', @cor_file);

      EXEC sp_write_results_to_cor_file_param_val 
             @cor_file      = @cor_file
            ,@cor_file_path = @cor_file_path
            ,@cor_range     = @cor_range;

      -----------------------------------------------------------------------------------
      -- 10: Completed processing
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'import_id:      ', @import_id;
      EXEC sp_log 2, @fn,'LRAP data file: ', @LRAP_data_file;
   END TRY
   BEGIN CATCH
      EXEC Ut.dbo.sp_log_exception @fn;
      THROW;
   END CATCH
   EXEC sp_log 2, @fn, '99: Completed processing ok, leaving
   @LRAP_data_file:[',@LRAP_data_file,']
   @import_root:   [',@import_root,']
   @log_level:     [',@log_level,']
   @cor_file:      [',@cor_file,']
   @cor_range:     [',@cor_range,']
   @import_id     :[',@import_id,']
   @file_type     :[',@file_type,']'-- 'txt' or 'xlsx'
   ;
END
/*
/*00 init       */EXEC sp__main_import @start_stage = 0, @LRAP_data_file = 'LRAP-221018-230813.xlsx', @LRAP_range= 'LRAP-221018 230813$A:N', @cor_file= 'ImportCorrections 221018 230816-2000.xlsx',@cor_range='Sheet1$A:S', @log_level=1  -- D:\Dev\Repos\Farming_Dev\Data
*/

GO
GO
GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===========================================================================
-- Author:      Terry Watts
-- Create date: 22-OCT-2023
-- Description: fixes up the ChemicalEntryMode link table
--    from the corrected Staging2 table
--
-- PRECONDITIONS:
--    PRE01: Chemical table populated
--    PRE02: EntryModeType table populated
--
-- POSTCONDITIONS:
-- POST01: ChemicalAction table has rows
-- POST02: mancozeb exists and is only contact
-- ===========================================================================
ALTER PROCEDURE [dbo].[sp_pop_chemicalAction]
AS
BEGIN
   SET NOCOUNT OFF;

   DECLARE
     @fn          NVARCHAR(35)   = N'POP_ChemicalAction'
    ,@row_cnt     INT = -1

   BEGIN TRY
      EXEC sp_log 2, @fn, '01: starting, validation chks';
      EXEC sp_register_call @fn;

      ------------------------------------------------------------------
      -- VALIDATION:
      ------------------------------------------------------------------
      -- PRE01: Chemical table populated
      -- PRE02: EntryModeType table populated
      EXEC sp_chk_tbl_populated 'Chemical';
      EXEC sp_chk_tbl_populated 'Action';

      ------------------------------------------------------------------
      -- ASSERTION: precondition validation passed
      ------------------------------------------------------------------
      EXEC sp_log 2, @fn, '05: passed validation chks';

      ------------------------------------------------------------------
      -- Process
      ------------------------------------------------------------------
      EXEC sp_log 2, @fn, '10: Process';

            -- First update the names in the link table
      UPDATE ChemicalAction 
      SET chemical_nm=X.chemical_nm
      ,action_nm = X.action_nm
      FROM
      (
         SELECT c.chemical_nm, a.action_nm, a.action_id, c.chemical_id 
         FROM ChemicalAction ca join Chemical c ON ca.chemical_id = c.chemical_id
         JOIN Action a ON a.action_id=ca.action_id
      ) AS X
      WHERE ChemicalAction.action_id = X.action_id
        AND ChemicalAction.chemical_id = X.chemical_id;

      -- Now merge
      MERGE ChemicalAction as target
      USING
      (
         SELECT c.chemical_id, c.chemical_nm, a.action_nm, a.action_id
         FROM ChemicalActionStaging  cas 
         JOIN Chemical        c  ON c.chemical_nm = cas.chemical_nm
         JOIN [Action] a ON a.action_nm=cas.action_nm
      ) AS S
      ON target.chemical_nm = S.chemical_nm AND target.action_nm = s.action_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  chemical_id,   action_id,   chemical_nm,   action_nm)
         VALUES (s.chemical_id, s.action_id, s.chemical_nm, s.action_nm)
      ;

      SET @row_cnt = @@ROWCOUNT;

      ------------------------------------------------------------------
      -- check postconditions
      ------------------------------------------------------------------
      EXEC sp_log 1, @fn, '20: checking postconditions...';
      -- Chk POST01: ChemicalActionStaging table populated
      -- Chk POST02: mancozeb exists and is only contact
      EXEC sp_chk_tbl_populated 'ChemicalAction';
      SELECT @row_cnt = COUNT(*) FROM ChemicalActionStaging WHERE chemical_nm='Mancozeb';
      EXEC sp_raise_assert @row_cnt, 1, 'Mancozeb should only have 1 entry in ChemicalActionStaging, count: ', @row_cnt, @ex_num=53224, @fn=@fn;
      SELECT @row_cnt = COUNT(*) FROM ChemicalActionStaging WHERE chemical_nm='Mancozeb' AND action_nm='CONTACT';
      EXEC sp_raise_assert @row_cnt, 1, 'Mancozeb mode should be CONTACT in ChemicalActionStaging, count: ', @row_cnt, @ex_num=53224, @fn=@fn;

      ------------------------------------------------------------------
      -- ASSERTION: postcondition validation passed
      ------------------------------------------------------------------
      EXEC sp_log 1, @fn, '25: passed postcondition checks';
      EXEC sp_log 1, @fn, '40: process complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '99: leaving, updated ', @row_cnt, ' rows', @row_count=@row_cnt;
END
/*
EXEC sp_pop_chemicalAction; -- 91 -> 156 -> 332 rows
SELECT * FROM [ChemicalAction];
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =================================================================
-- Author:		 Terry Watts
-- Create date: 08-NOV-2023
-- Description: precondition helper for sp_merge_normalised_tables
-- =================================================================
ALTER PROCEDURE [dbo].[sp_merge_normalised_tables_precondition_hlpr] 
    @id        INT            OUTPUT
   ,@table_nm  NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
   DECLARE 
       @fn        NVARCHAR(30)  = N'MRG_NORM_TBLS'
      ,@msg       NVARCHAR(100)

   SET @msg = CONCAT('PRE', FORMAT(@id, '00'),': checking ',@table_nm);
   EXEC sp_log 2, @fn, @msg; 
   EXEC sp_chk_tbl_populated @table_nm;
   SET @id = @id+1;
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 14-MAR-2024
-- Description: lists unmatched PathogenChemicalStaging pathogens that merge can't handle
--
-- Uses
--   in sp_merge_normalised_tables when the PathogenChemical merge fails due to mismatched pathogen names
-- ======================================================================================================
ALTER View [dbo].[list_unmatched_PathogenChemicalStaging_pathogens_vw]
AS
SELECT DISTINCT TOP 1000 pcs.pathogen_nm
FROM
   PathogenChemicalStaging pcs
   LEFT JOIN Pathogen p      ON p.pathogen_nm      = pcs.pathogen_nm
   LEFT JOIN PathogenType pt ON pt.pathogenType_id = p.pathogenType_id
WHERE 
pt.pathogenType_id IS NULL
ORDER BY pcs.pathogen_nm;
/*
SELECT TOP 50 * FROM list_unmatched_PathogenChemicalStaging_pathogens_vw;
*/

GO
GO
GO
GO
GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 05-MAR-2024
-- Description: separates the manufacturers
--
-- CHANGES:
--
-- ==============================================================================
ALTER VIEW [dbo].[DistributorStaging_vw]
AS
SELECT distributor_name, value as manufacturer_name
FROM DistributorStaging CROSS APPLY string_split(manufacturers, ',');

/*
SELECT * FROM DistributorStaging_vw
*/

GO
GO
GO
GO
GO
GO
GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==================================================================================================================================================
-- Author:      Terry Watts
-- Create date: 19-AUG-2023
-- Description: Merges the normalised staging tables to the associated main normalised tables
--       and do any main table fixup
--
-- REQUIREMENTS:
-- R01: populate the DEL01 set using the PRE01 set of tables
--
-- PRECONDITIONS:
-- PRE01: the following set of staging tables are populated and fixed up
--    PRE01: ActionStaging
--    PRE02: ChemicalStaging
--    PRE03: ChemicalActionStaging
--    PRE04: ChemicalProductStaging
--    PRE05: ChemicalUseStaging
--    PRE06: CompanyStaging
--    PRE07: CropStaging
--    PRE08: CropPathogenStaging
----    PRE09: PathogenStaging
--    PRE10: PathogenChemicalStagng
--    PRE11: PathogenTypeStaging
--    PRE12: PathogenPathogenStaging
--    PRE12: ProductStaging
--    PRE13: ProductCompanyStaging
--    PRE14: ProductUseStaging
--    PRE15: TypeStaging
--    PRE16: UseStaging
--    PRE17: DistributorStaging
--
-- PRE02: import id session setting set or is a parameter
--
-- POSTCONDITIONS
-- DEL01: This is the deliverable set of output tables populated by this routine
-- POST 01: Action table populated
-- POST 02: Chemical table populated
-- POST 03: ChemicalAction table populated
-- POST 04: ChemicalProduct table populated
-- POST 05: ChemicalUse table populated
-- POST 06: Company table populated
-- POST 07: Crop table populated
-- POST 08: CropPathogen table populated
-- POST 09: Distributor table populated
-- POST 10: Pathogen table populated
-- POST 11: PathogenChemical table populated
-- POST 12: PathogenType table populated
-- POST 13: Product table populated
-- POST 14: ProductCompany table populated
-- POST 15: ProductUse table populated
-- POST 16: Type table populated
-- POST 17: Use table populated
-- POST 18: DistributorManufacturer populated
--
-- TESTS:
-- 1. initially empty aLl tables,
--    run routine,
--    check all tables are populated
--
-- CHANGES:
-- 231006: added post condition checks for table population
-- 231008: do any main table fixup: 
--         Update the ProductCompany link table with product nm & id and company nm & id 
-- 231009: fix ChemicalProduct merge: the merge view needs to use ChemicalProductStaging table but supported by main tables linked on names not ids
--         else no rows affected
-- 231024: added sp_pop_chemicalEntryMode to populate the ChemicalEntryMode link table to relate the chemical to its modes of action
-- 231104: added PathogenChemical, removed ChemicalPathogen
-- 231108: added Action,Type and Use table merges
-- ==================================================================================================================================================
ALTER PROCEDURE [dbo].[sp_merge_normalised_tables]
AS
BEGIN
   SET NOCOUNT OFF;

   DECLARE 
       @fn        NVARCHAR(30)  = N'MRG_NORM_TBLS'
      ,@error_msg NVARCHAR(MAX)  = NULL
      ,@file_path NVARCHAR(MAX)
      ,@id        INT = 1

   BEGIN TRY
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'000: starting, running precondition validation checks';
      -----------------------------------------------------------------------------------
      EXEC sp_register_call @fn;

      -----------------------------------------------------------------------------------
      -- Precondition checks
      -----------------------------------------------------------------------------------

      -----------------------------------------------------------------------------------
      -- 02: check preconditions: PRE00: staging tables populated and fixed up
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '005: checking preconditions';
--    PRE01: ActionStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'ActionStaging';
--    PRE02: ChemicalStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'ChemicalStaging';
--    PRE03: ChemicalActionStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'ChemicalActionStaging';
--    PRE04: ChemicalProductStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'ChemicalProductStaging';
--    PRE05: ChemicalUseStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'ChemicalUseStaging';
--    PRE06: CompanyStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'CompanyStaging';
--    PRE07: CropStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'CropStaging';
--    PRE08: CropPathogenStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'CropPathogenStaging';
--    PRE09: PathogenStaging
--      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'PathogenStaging';
--    PRE10: PathogenChemicalStagng
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'PathogenChemicalStaging';
--    PRE11: PathogenTypeStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'PathogenTypeStaging';
--    PRE13: ProductStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'ProductStaging';
--    PRE13: ProductCompanyStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'ProductCompanyStaging';
--    PRE14: ProductUseStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'ProductUseStaging';
--    PRE15: TypeStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'TypeStaging';
--    PRE16: UseStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'UseStaging';
--    PRE17: DistributorStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'DistributorStaging';


      -----------------------------------------------------------------------------------
      --  03: merging main primary tables
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'020: merging main primary tables...';

      -----------------------------------------------------------------------------------
      --  04: Merge Action table
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '030: merging Action table';
      MERGE [Action]        AS target
      USING ActionStaging   AS s
      ON target.action_nm = s.action_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  action_id,   action_nm)
         VALUES (s.action_id, s.action_nm)
      WHEN NOT MATCHED BY SOURCE THEN DELETE
      ;

      -----------------------------------------------------------------------------------
      --  05: Merge Type table
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '040: merging Action table';
      MERGE [Type]        AS target
      USING TypeStaging   AS s
      ON target.type_nm = s.type_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  [type_id],   type_nm)
         VALUES (s.[type_id], s.type_nm)
      WHEN NOT MATCHED BY SOURCE THEN DELETE
      ;

      -----------------------------------------------------------------------------------
      --  06: Merge PathogenType table
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '050: merging PathogenType table';
      MERGE PathogenType          AS target
      USING PathogenTypeStaging   AS s
      ON target.pathogenType_nm = s.pathogenType_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  pathogenType_id,   pathogenType_nm)
         VALUES (s.pathogenType_id, s.pathogenType_nm)
      WHEN NOT MATCHED BY SOURCE THEN DELETE
      ;

/*
      -----------------------------------------------------------------------------------
      --  07: Merge Pathogen table
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '060: merging Pathogen table';
      MERGE Pathogen AS target
      USING 
      (
         SELECT pt.pathogenType_id, ps.pathogen_nm, pt.pathogenType_nm
         FROM PathogenStaging ps
         LEFT JOIN PathogenType pt ON pt.pathogenType_nm = ps.pathogenType_nm
      )  AS s
      ON target.pathogen_nm = s.pathogen_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  pathogen_nm,   pathogenType_id, import_id)
         VALUES (s.pathogen_nm, s.pathogenType_id, 1) -- @import_id
      -- WHEN MATCHED THEN UPDATE SET target.pathogenType_id = S.pathogenType_id  -- should be a 1 off
      WHEN NOT MATCHED BY SOURCE THEN DELETE
      ;
*/
      -----------------------------------------------------------------------------------
      --  08: Merge Chemical table
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '070: merging Chemical table';
      MERGE Chemical          AS target
      USING ChemicalStaging   AS s
      ON target.chemical_nm=s.chemical_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  chemical_nm)
         VALUES (s.chemical_nm)
      WHEN NOT MATCHED BY SOURCE THEN DELETE
         ;

      -----------------------------------------------------------------------------------
      -- 09: Merge Company table
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '080: merging Company table';
      MERGE Company          AS target
      USING CompanyStaging   AS s
      ON target.company_nm = s.company_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  company_nm)
         VALUES (s.company_nm)
      WHEN NOT MATCHED BY SOURCE THEN DELETE
         ;

      -----------------------------------------------------------------------------------
      -- 10: Merge Crop table
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '090: merging Crop table';
      MERGE Crop          AS target
      USING 
      (
         SELECT * FROM CropStaging
      )   AS s
      ON target.crop_nm=s.crop_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  crop_nm)
         VALUES (s.crop_nm)
      WHEN NOT MATCHED BY SOURCE THEN DELETE
         ;

      -----------------------------------------------------------------------------------
      -- 11: Merge Distributor table
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, '100: merging Distributor table';
      MERGE Distributor          AS target
      USING 
      (
        SELECT * FROM DistributorStaging
      ) AS s
      ON target.distributor_name=s.distributor_name
      WHEN NOT MATCHED BY target THEN
         INSERT (  distributor_id,  distributor_name)
         VALUES (s.distributor_id,s.distributor_name)
      WHEN NOT MATCHED BY SOURCE THEN DELETE
         ;

      -----------------------------------------------------------------------------------
      -- 12: Merge Product table
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '110: merging Product table';
      MERGE Product          AS target
      USING ProductStaging   AS s
      ON target.product_nm=s.product_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  product_nm)
         VALUES (s.product_nm)
      WHEN NOT MATCHED BY SOURCE THEN DELETE
         ;

      -- ASSERTION: all the main primary tables contain all the relevant new import data

      -----------------------------------------------------------------------------------
      -- 13: merging main link tables using the standard strategy:
      -----------------------------------------------------------------------------------
      -- Strategy:
      --    Join the staging link table to the 2 respective primary staging tables based on ids
      --    Join the staging tables to their respective main tables based on names
      --    Use the primary main table ids to populate the main link table
      ---------------------------------------------------
      EXEC sp_log 2, @fn,'120: merging main link tables...';

      -----------------------------------------------------------------------------------
      -- 14: Merge CropPathogen table
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '130 merging CropPathogen link table';

      MERGE CropPathogen          AS target
      USING
      (
         SELECT c.crop_nm, p.pathogen_nm, c.crop_id, p.pathogen_id
         FROM
            CropPathogenStaging cps
            LEFT JOIN CropStaging   cs ON cs.crop_nm = cps.crop_nm
            LEFT JOIN Crop          c  ON c. crop_nm = cs .crop_nm
            LEFT JOIN Pathogen      p  ON p .pathogen_nm = cps.pathogen_nm
         WHERE 
                cs.crop_nm IS NOT NULL 
            AND cs.crop_nm <>''
            AND p.pathogen_nm IS NOT NULL
            AND p.pathogen_nm <>''
      )       AS s
      ON target.crop_nm = s.crop_nm AND target.pathogen_nm = s.pathogen_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  crop_id,   pathogen_id,  crop_nm,   pathogen_nm)
         VALUES (s.crop_id, s.pathogen_id,s.crop_nm, s.pathogen_nm)
         ;

      -----------------------------------------------------------------------------------
      -- 15: Merge ChemicalProduct table
      -----------------------------------------------------------------------------------
      -- join ChemicalProductStaging, ChemicalStaging, Chemical, ProductStaging, Product
      EXEC sp_log 2, @fn, '140: merging ChemicalProduct link table';
      MERGE ChemicalProduct AS target
      USING
      (
         SELECT c.chemical_id, p.product_id, c.chemical_nm, p.product_nm
         FROM
         ChemicalProductStaging cps
         LEFT JOIN ChemicalStaging   cs ON cs.chemical_nm = cps.chemical_nm
         LEFT JOIN Chemical          c  ON c. chemical_nm = cs .chemical_nm
         LEFT JOIN ProductStaging    ps ON ps.product_nm  = cps.product_nm
         LEFT JOIN Product           p  ON p. product_nm  = ps .product_nm
      ) AS s
      ON target.chemical_nm = s.chemical_nm AND target.product_nm=s.product_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  chemical_id,   product_id,   chemical_nm,   product_nm)
         VALUES (s.chemical_id, s.product_id, s.chemical_nm, s.product_nm)
     ;

      -----------------------------------------------------------------------------------
      -- 16: Merge ChemicalUse table
      -----------------------------------------------------------------------------------
      -- join ProductUseStaging, ProductStaging, Product,Use
      EXEC sp_log 2, @fn, '150: merging ChemicalUse link table';
      MERGE ChemicalUse          AS target
      USING 
      (
         SELECT c.chemical_id, u.use_id, c.chemical_nm, u.use_nm
         FROM 
         ChemicalUseStaging cus 
         LEFT JOIN ChemicalStaging cs ON cs.chemical_nm = cus.chemical_nm
         LEFT JOIN Chemical c ON c.chemical_nm = cs.chemical_nm
         LEFT JOIN [Use] u ON u.use_nm = cus.use_nm
      ) AS s
      ON target.chemical_nm = s.chemical_nm AND target.use_nm = s.use_nm
      WHEN NOT MATCHED BY target THEN
         INSERT ( chemical_id, use_id, chemical_nm, use_nm)
         VALUES ( chemical_id, use_id, chemical_nm, use_nm)
      ;
      -----------------------------------------------------------------------------------
      --17: Merge PathogenChemical table - needs the pathogen type info 2059 rows
      -----------------------------------------------------------------------------------
      BEGIN TRY
         EXEC sp_log 2, @fn, '160: merging PathogenChemical link table';
         EXEC sp_log 2, @fn, '162: checking PathogenChemical dependencies are populated';
         EXEC sp_chk_tbl_populated 'PathogenChemicalStaging';
         EXEC sp_chk_tbl_populated 'Pathogen';
         EXEC sp_chk_tbl_populated 'Chemical';
         --EXEC sp_chk_tbl_populated 'PathogenPathogenTypeStaging';
         EXEC sp_chk_tbl_populated 'PathogenTypeStaging';
         EXEC sp_chk_tbl_populated 'PathogenType';

         -- Update Pathogen.PathogenType_id and import
         UPDATE Pathogen 
         SET pathogenType_id = pt.pathogenType_id
         FROM Pathogen p JOIN PathogenType pt ON p.pathogenType_nm=pt.pathogenType_nm;

         EXEC sp_log 2, @fn, '164: merging PathogenChemical table';
         /*----------------------------------------------------------------------------------------------------------------
          * If this yields null pathogenType_id which PathogenChemical wont accept then use this view to trace the issues
          * list_unmatched_PathogenChemicalStaging_pathogens_vw
          *----------------------------------------------------------------------------------------------------------------*/
         MERGE PathogenChemical AS target
         USING
         (
            SELECT p.pathogen_id, p.pathogen_nm, c.chemical_id, c.chemical_nm, pt.pathogenType_id 
            FROM 
               PathogenChemicalStaging pcs
               LEFT JOIN Pathogen p ON p.pathogen_nm = pcs.pathogen_nm
               LEFT JOIN Chemical c ON c.chemical_nm = pcs.chemical_nm
               LEFT JOIN PathogenType pt ON pt.pathogenType_id=p.pathogenType_id
         ) AS s
         ON target.pathogen_nm = s.pathogen_nm AND target.chemical_nm = s.chemical_nm
         WHEN NOT MATCHED BY target THEN
            INSERT ( pathogen_id, chemical_id, pathogen_nm, chemical_nm, pathogenType_id)
            VALUES ( pathogen_id, chemical_id, pathogen_nm, chemical_nm, pathogenType_id)
            ;

         EXEC sp_chk_tbl_populated 'PathogenChemical';
      END TRY
      BEGIN CATCH
         EXEC Ut.dbo.sp_log_exception @fn;

         ------------------------------------------------------------------------------------------------------------------
         -- If the  error is trying to insert null pathogen_id into PathogenChemical: then this will help trace the issues
         ------------------------------------------------------------------------------------------------------------------
         SELECT 'MERGE PathogenChemical', pathogen_nm AS [mismatched pathogens] 
         FROM list_unmatched_PathogenChemicalStaging_pathogens_vw;
         THROW;
      END CATCH

      -----------------------------------------------------------------------------------
      -- 18: ProductUse table 
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '170: merging ProductUse link table';
      MERGE ProductUse          AS target
      USING 
      (
         SELECT p.product_id, u.use_id, p.product_nm, u.use_nm FROM 
         ProductUseStaging pus 
         LEFT JOIN ProductStaging ps ON ps.product_nm = pus.product_nm
         LEFT JOIN Product p ON p.product_nm = ps.product_nm
         LEFT JOIN [Use] u ON u.use_nm = pus.use_nm
      ) AS s
      ON target.product_nm = s.product_nm AND target.use_nm = s.use_nm
      WHEN NOT MATCHED BY target THEN
         INSERT ( product_id, use_id, product_nm, use_nm)
         VALUES ( product_id, use_id, product_nm, use_nm)
         ;

      -----------------------------------------------------------------------------------
      -- 19: Update the ProductCompany link table with product nm & id and company nm & id 
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '180: merging ProductCompany link table';

      MERGE ProductCompany as target
      USING
      (
         SELECT p.product_id, c.company_id, p .product_nm, c.company_nm
         FROM ProductCompanyStaging  pcs 
         JOIN ProductStaging ps ON ps.product_nm = pcs.product_nm
         JOIN Product        p  ON p .product_nm = ps.product_nm
         JOIN CompanyStaging cs ON cs.company_nm = pcs.company_nm
         JOIN Company        c  ON c.company_nm  = cs.company_nm
      ) AS S
      ON target.product_nm = S.product_nm AND target.company_nm = s.company_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  product_id,   company_id,   product_nm,   company_nm)
         VALUES (s.product_id, s.company_id, s.product_nm, s.company_nm)
      ;

      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '190: Populating ChemicalAction link table';
      -----------------------------------------------------------------------------------
      EXEC sp_pop_chemicalAction;

      -----------------------------------------------------------------------------------
      -- 20: DistributorManufacturer
      -----------------------------------------------------------------------------------
      MERGE DistributorManufacturer as target
      USING
      (
         SELECT d.distributor_id, c.company_id
         FROM DistributorStaging_vw ds
         JOIN Distributor d ON ds.distributor_name = d.distributor_name
         JOIN Company     c ON c.company_nm  = ds.manufacturer_name
      ) AS S
      ON target.distributor_id = s.distributor_id AND target.manufacturer_id = s.company_id
      WHEN NOT MATCHED BY target THEN
         INSERT (  distributor_id,   manufacturer_id)
         VALUES (s.distributor_id, s.company_id)
      ;

      -----------------------------------------------------------------------------------
      -- 21: do any main table fixup: 
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '200: do any main table fixup: currently none';

      -----------------------------------------------------------------------------------
      -- 22  POSTCONDITION checks
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '210: POSTCONDITION checks...';
      -- POST 01: Chemical table populated
      EXEC dbo.sp_chk_tbl_populated 'Chemical';
      -- POST 02: ChemicalAction table populated
      EXEC dbo.sp_chk_tbl_populated 'ChemicalAction';
      -- POST 03: ChemicalProduct table populated
      EXEC dbo.sp_chk_tbl_populated 'ChemicalProduct';
      -- POST 04: ChemicalUse table populated
      EXEC dbo.sp_chk_tbl_populated 'ChemicalUse';
      -- POST 05 Company table populated
      EXEC dbo.sp_chk_tbl_populated 'Company';
      -- POST 06: Crop table populated
      EXEC dbo.sp_chk_tbl_populated 'Crop';
      -- POST 07: CropPathogen populated
      EXEC dbo.sp_chk_tbl_populated 'CropPathogen';
      -- POST 08: Distributor table populated
      EXEC dbo.sp_chk_tbl_populated 'Distributor';
      -- POST 09: Pathogen table populated
      EXEC dbo.sp_chk_tbl_populated 'Pathogen';
      -- POST 10: PathogenChemical table populated
      EXEC dbo.sp_chk_tbl_populated 'PathogenChemical';
      -- POST 11: PathogenType table populated
      EXEC dbo.sp_chk_tbl_populated 'PathogenType';
      -- POST 12: Product table populated
      EXEC dbo.sp_chk_tbl_populated 'Product';
      -- POST 13: ProductCompany table populated
      EXEC dbo.sp_chk_tbl_populated 'ProductCompany';
      -- POST 14: ProductUse table populated
      EXEC dbo.sp_chk_tbl_populated 'ProductUse';
      -- POST 15: Type table populated
      EXEC dbo.sp_chk_tbl_populated 'Type';
      -- POST 16: Use table populated
      EXEC dbo.sp_chk_tbl_populated 'Use';

      -----------------------------------------------------------------------------------
      -- 23: Completed processing OK
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '220: Completed processing OK';
   END TRY
   BEGIN CATCH
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, '500: Caught exception: ', @error_msg;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '999: leaving: OK';
END
/*
EXEC sp_reset_CallRegister;
EXEC sp_merge_normalised_tables 1
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2024
-- Description: Merge the staging tables to the normalised tables
--
-- PRECONDITIONS: Stage 06 ran ok
--
-- POSTCONDITIONS:
--    POST 01: main normalised_tables updated
-- ==============================================================
ALTER PROCEDURE [dbo].[sp_main_import_stage_08_mrg_mn]
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35)   = 'MAIN_IMPRT_STG_08'

   EXEC sp_log 1, @fn, '00: starting';
   EXEC sp_register_call @fn;

   -----------------------------------------------------------------------------------
   -- Merge the staging tables to the normalised tables
   -----------------------------------------------------------------------------------
   EXEC sp_log 1, @fn, '10: Merge the staging tables to the normalised tables';
   EXEC sp_merge_normalised_tables;

   -----------------------------------------------------------------------------------
   -- POSTCONDITIONS: POST 01: main normalised_tables updated
   -----------------------------------------------------------------------------------
   EXEC sp_log 2, @fn, '90: processing complete';
   EXEC sp_log 1, @fn, '99: leaving OK';
END
/*
   EXEC sp_main_import_stage_08 @import_id;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===============================================================
-- Author:      Terry Watts
-- Create date: 09-JUL-2023
-- Description: Restores Staging2 from Staging3 cache.
-- ===============================================================
ALTER PROCEDURE [dbo].[sp_copy_s3_s2]
AS
BEGIN
   DECLARE @fn NVARCHAR(35)  = N'CPY_S3_S2'
   EXEC sp_log 1, @fn, 'starting'
   SET NOCOUNT OFF;

   TRUNCATE TABLE Staging2;

   INSERT INTO [dbo].[Staging2]
   (
       stg2_id
      ,company
      ,ingredient
      ,product
      ,concentration
      ,formulation_type
      ,uses
      ,toxicity_category
      ,registration
      ,expiry
      ,entry_mode
      ,crops
      ,pathogens
      ,rate
      ,mrl
      ,phi
      ,phi_resolved
      ,reentry_period
      ,comment
    )
    SELECT 
       stg_id
      ,company
      ,ingredient
      ,product
      ,concentration
      ,formulation_type
      ,uses
      ,toxicity_category
      ,registration
      ,expiry
      ,entry_mode
      ,crops
      ,pathogens
      ,rate
      ,mrl
      ,phi
      ,phi_resolved
      ,reentry_period
      ,comment
   FROM Staging3;

   EXEC sp_log 1, @fn, 'leaving ok'
END
/*
EXEC  sp_copy_s3_s2
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =================================================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2024
-- Description: runs detailed post condition checks of any db state
--
-- PRECONDITIONS:
--    none
--
-- POSTCONDITIONS:
-- POST 01: no line feed only line separator
-- POST 02: crop name contains none of the following: (' Beans','  Popcorn)','Banana (Cavendish) (Post- harvest treatment)', 'Banana (Cavendish) as insecticidal soap','Cowpea and other beans','Soybeans & other beans'))
-- POST 03: no apostophe in pathogens
-- POST 04: Pathogen.pathogen_type_id IS NOT NULL
-- POST 05: Pathogen.pathogen_nm does not contain ('Bacterial wilt and','As foot ','Foot ','Golden apple Snails','Ripening')
-- POST 06:
-- POST 07:
-- POST 08:
--
-- STRATEGY:
-- 01: check no Character 10 without Character 13 - i.e. no line feed only line separator- XL data has several of these
-- 02: check no spc or spc in the critical columns: crops, pathogens
-- 03: test no blank spc only or NULL essential data
-- 04: check no Character 10 without Character 13 - line feed only - XL data has several of these
-- 02: check no  spc or spc in the critical columns: crops, pathogens
-- 03: test no blank spc only or NULL essential data

-- 05: Chemicals Table:
-- 05.1: Chlorpyrifos/plastech 20% M/b
-- 05.2: Chlorpyrifos/pyritiline 20 Pe M/b
-- 05.3: Mesotrione,Glyphosate,S-Metachlor

-- 06: ChemPathCrp vw
-- 07: ChemicalProduct_vw
-- 08: ChemicalUse
-- 09: Company Table
-- 10: Crop table
-- 11: Pathogen: 1: pathogen_type_id field is populated, 2: crop_pathogen_vw has the pathogen type info id, nm, 3: nm: 'Bacterial wilt and'
-- 12: Import table
-- 13: ProductChemical_vw
-- 14: Pathogen table
-- 15: Product table
-- 16: ProductUse_vw
-- 17: Type table
-- 18: Use table
--
-- CHANGES:
-- =================================================================
ALTER PROCEDURE [dbo].[sp_main_import_stage_09_post_cks]
AS
BEGIN
   DECLARE
    @fn        NVARCHAR(35)   = 'MAIN_IMPRT_STG_09'
   ,@cnt                INT            = 0
   ,@err_cnt            INT            = 1
   ,@err_msg            NVARCHAR(250)  = NULL
   ,@msg                NVARCHAR(250)  = NULL
   ,@table              NVARCHAR(100)  = NULL
   ,@field_nm           NVARCHAR(100)  = NULL
   ,@value              NVARCHAR(100)  = NULL

   EXEC sp_log 1, @fn, '00: starting';
   EXEC sp_register_call @fn;

   -----------------------------------------------------------------------------------
   -- Perform the post condition checks for all data
   -----------------------------------------------------------------------------------
   -- 1: test are performed in a do while looop - break on first error
   WHILE 1=1
   BEGIN
      -- 01: staging 1 tests
      -- 02: check no Character 10 without Character 13 - line feed only - XL data has several of these
      -- 03: check no extra spaces in the critical columns: crops, pathogens
      -- 04: test no blank spc only or NULL essential data
      -- 05: Chemicals Table:
      -- 05.1: Chlorpyrifos/plastech 20% M/b
      -- 05.2: Chlorpyrifos/pyritiline 20 Pe M/b
      -- 05.3: Mesotrione,Glyphosate,S-Metachlor
      
      -- 06: ChemPathCrp vw:
      -- 07: ChemicalProduct_vw:
      -- 08: ChemicalUse:
      -- 09: Company Table:

      -- 10: Crop table:
      --  Beans	NULL
      --  Popcorn)
      -- Banana (Cavendish) (Post- harvest treatment)
      -- Banana (Cavendish) as insecticidal soap
      -- Corn (Sweet and Popcorn)
      -- Corn (Sweet corn
      -- Field
      -- foot
      EXEC sp_log 2, @fn,'02: POST 02: Crop name contains none of the following';
      If EXISTS (Select 1 from Crop where crop_nm IN (' Beans','  Popcorn)','Banana (Cavendish) (Post- harvest treatment)', 'Banana (Cavendish) as insecticidal soap','Cowpea and other beans','Soybeans & other beans'))
      BEGIN
         SET @msg      = ''
         SET @table    = 'Crop'
         SET @field_nm = 'crop_nm'
         SET @value    = 'has at least one of these values: [ Beans] or [ Popcorn)] or [Banana (Cavendish) (Post- harvest treatment)] or [Banana (Cavendish) as insecticidal soap], [Cowpea and other beans], [Soybeans & other beans]';
         BREAK;
      END

      -- 231019
     EXEC sp_log 2, @fn,'03: POST 03: no apostophe in pathogens';
     IF EXISTS (SELECT 1 FROM Staging2 where pathogens LIKE '''%')
      BEGIN
            SET @msg = '*** Staging2.pathogens: leading apostophe still exists';
            SET @table    = 'Staging2'
            SET @field_nm = 'pathogens'
            SET @value    = '''';
            BREAK;
      END


-- EXEC sp_investigate_s2_crops '% Beans%'
--                         count
-- Cowpea and other beans	30
-- Soybeans & other beans	17
-- SELECT * from staging2 WHERE crops LIKE '%Cowpea and other beans%' -- now rows
-- SELECT * from staging1 WHERE crops LIKE '%Cowpea and other beans%' -- 30 rows
-- Implies the crops list was taken BEFORE the crops data scrub or the main tables already had the bad data? -> ACT: main tables already had the bad data.
     -- [ Popcorn)]
      -- Banana (Cavendish) (Post- harvest treatment)
      -- Banana (Cavendish) as bunch spray
      -- Banana (Cavendish) as disinfectant
      -- Banana (Cavendish) as insecticidal soap
      -- Banana (Cavendish) as tool disinfectant
      -- Corn (Sweet and Popcorn)
      -- Corn (Sweet corn
      -- Corn (Sweet corn)
      -- Field
      -- foot
      -- Grassland -> Grass
      -- Soil and Space Fumigant
      -- Soil fumigant
      -- Soybean
      -- Soybeans
      -- Soybeans & other beans
      -- Soybeans/Mungbeans
      -- Squash
      -- Stored commodities & processed foods
      -- Stored grain

      -- 11: crop_pathogen_vw:  
      -- Test 1: pathogen_type_id field is populated, 
      -- Test 2: crop_pathogen_vw has the pathogen type info id, nm, 
      -- Test 3: nm: 'Bacterial wilt and','As foot ','Foot ','Golden apple Snails','Ripening'  exists  

      -- Test 1: pathogen_type_id field is populated
      EXEC sp_log 2, @fn,'04: POST 04: Pathogen.pathogen_type_id IS NOT NULL';
      SET @cnt= (SELECT COUNT(*) FROM Pathogen where pathogenType_id IS NULL);

      If @cnt > 0
      BEGIN
         SET @msg      = 'Test 11'
         SET @table    = 'Pathogen'
         SET @field_nm = 'pathogen_type_id'
         SET @value    = CONCAT('has ',@cnt, ' NULLs');

         -- Display all Pathogen rows where pathogenType_id is null
         SELECT pathogen_nm FROM Pathogen where pathogenType_id IS NULL;
         BREAK;
      END

      -- Test 2: crop_pathogen_vw has the pathogen type info id, nm
      -- Test 3: nm: 'Bacterial wilt and','As foot ','Foot ','Golden apple Snails','Ripening'  exists  
      EXEC sp_log 2, @fn,'05: Pathogen.pathogen_nm in ''Bacterial wilt and'',''As foot '',''Foot '',''Golden apple Snails'',''Ripening''';
      -- Select * FROM Pathogen WHERE pathogen_nm IN ('Bacterial wilt and','As foot ','Foot ','Golden apple Snails','Ripening');
      If EXISTS (Select 1 FROM Pathogen WHERE pathogen_nm IN ('Bacterial wilt and','As foot ','Foot ','Golden apple Snails','Ripening'))
      BEGIN
         SET @msg      = ''
         SET @table    = 'Pathogen'
         SET @field_nm = 'pathogen_nm'
         SET @value    = 'has at least one of these values: ''Bacterial wilt and'',''As foot '',''Foot '',''Golden apple Snails'',''Ripening''';
         SELECT * FROM Pathogen WHERE pathogen_nm IN ('Bacterial wilt and','As foot ','Foot ','Golden apple Snails','Ripening');
         BREAK;
      END

      -- 12: Import table: 2 rows 
      --    1: "id,company,ingredient,product,concentration,formulation_type,uses,toxicity_category,registration,expiry,entry_mode,crops,pathogens"
      --    2: 230721	'rate, mrl, phi, re-entry_period'

      -- 13: ProductChemical_vw:
      --       duplicate rows:
      -- chemical_nm	product_nm	chemical_id	product_id
      -- Benomyl	Benomax 50 Wp	37	108
      -- Benomyl	Benomex 50 Wp	37	109


      -- 14: Pathogen table:
      -- As foot 
      -- Bacterial wilt and
      -- Cabagge moth
      -- Corn
      -- Foot 
      -- Golden apple Snail, Golden apple Snails
      -- hoppers-> Hoppers
      -- Leaf
      -- Leaf miner,Leafminer
      -- Leaf roller, Leafroller
      -- Pineaple mites -> Pineapple mites
      -- Ripening
      -- Tire 
      -- Tool

      -- 15: Product table:
      -- Choice 10 Sc *
      -- ** Productshould have a company field FK


      -- 16: ProductUse_vw
      -- 17: Type table:
      -- 18: Use table:
      SET @err_cnt = 0;
      EXEC sp_log 2, @fn, '95: completed tests ok, ret: ', @err_cnt;
      BREAK;
   END
   -- IF error
   IF @err_cnt > 0
   BEGIN
      SET @err_msg = CONCAT('*** Error *** :  table: ', @table, ' field: ', @field_nm, ' value: [', @value, ']');
      EXEC sp_log 2, @fn, @err_msg;
      THROW 56821, @err_msg,1;
   END

   EXEC sp_log 2, @fn, '90: processing complete';
   EXEC sp_log 1, @fn, '99: leaving';
END
/*
   EXEC sp_main_import_stage_09;
   EXEC sp_clear_call_register 'SP_MAIN_IMPORT_STAGE_09';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==================================================================================================================================================
-- Author:      Terry Watts
-- Create date: 20-JUNE-2023
-- Description: Main entry point for Importing all 9 100 page files Ph DepAg Registered Pesticides files
-- *** This cleans the staging tables first
-- import root = 'D:\Dev\Repos\<db name>\Data\'; use ut.dbo.fnGetImportRoot() to get it
-- in <import root>\Exports Ph DepAg Registered Pesticides LRAP-221018.pdf\tsvs\ - 9 tsv files
-- or <import root>\Exports Ph DepAg Registered Pesticides LRAP-230721.pdf\      - 1 tsv file
--
-- PARAMETERS:
-- @stage            : coarse granularity progress cursor
-- @start_row (n)    : if set then corrections loop will skip the first n rows
-- @stop_row         : if set then all processing is stoped after this row is procesed
-- @restore_s3_s2    : used to load s2 with a previous s3 cache of S2
-- @log_level        : multi switch parameter currently lonly LOG LEVEL:  is used
-- @LRAP_data_file   : LRAP import data file
-- @corrections_file : the tab separated s2 corrections file
-- @import_id        : int this is the version of the import file: 1 for LRAP-221018
-- @stop_stage       : set this top processing after the specified stage
--
-- Responsibilities:
-- 01. Perform main init
-- 02. Optionally restore S2 from S3 cache then go directly to import corrections
-- 03. Clear out clear out staging and main tables, S1 and S2, then import the static data
-- 04. Import the LRAP register file into S1 and perform basic fixup
-- 05: Fixup S1, copy Staging1 to Staging2
-- 06. Fixup Staging2 using the sp_fixup_s2 stored procedure and not the xls
-- 07: Import the import correction files
-- 08: Perform Spreadsheet based S2 fixup
-- 09: Populate the normalised staging tables
-- 10: Merge the normalised staging tables to the normalised tables
-- 11: Perform postcondition tests
--
-- Process
-- stage
-- 00: Clear the applog, Perform main init, 
-- 00: Optionally restore s2 from S3 cache then go directly to import corrections
-- 01: Clear out staging and main tables, S1 and S2, then import the static data
-- 02: import the LRAP register file into S1 and perform basic fixup
-- 03: fixup S1, copy S1->S2
-- 04: fixup S2 using the sp_fixup_s2 stored procedure and not the xls
-- 05: import the import correction files
-- 06: perform Spreadsheet based S2 fixup, using an importcorrections.xlsx file, cache S2->S3
-- 07: populate the staging tables
-- 08: Merge the staging tables to the normalised tables
-- 09: perform postcondition checks
--
-- CHANGES:
-- 230713: added LOG_LEVEL 0: DEBUG, 1:INFO, 2:WARNING, 3:ERROR
-- 230811: clean import then merge into the main tables, save the import_id as a session setting in import-init
-- 231005: added a check routine: sp_list_useful_table_rows to the comment area
-- 231007: added sp_merge_normalised_tables to update the main tables from this import
-- 231010: added call to sp_import_pathogenInfo to update the Pathogen table pathogen_type field
-- 231013: added a stop (after) stage parameter to facilitate interim testing of the db state
--         added while loop so we can break out easily
--         added temporary checks on existence of '%Cabagge moth%' and '%Golden apple Snails%' - theses should be removed
-- 231014  changed the import tab sep file name to exclude '.tsv' as MS Excel does not allow the use of .tsv or is 1 more step
--         renamed the fixupimport register sp for Staging to:  sp_fixup_s2_using_corrections_file
-- 231014: added a @stop_row parameter to stop the import from the main commandline, changed the order of the parameters
-- 231015: added @stop_stage parameter to stop after stage
-- 231016: changed parameter name: @skip_to -> @start_row for consistent naming
--       : changed call from sp_fixup_import_register to sp_fixup_s2_using_corrections_file as that sp name was changed
--       : added parameter: @stop_row to stop all processing after proccessing this row for testing db state
-- 231019: added Stage 0: truncate the main tables
-- 231029: BUG: Chlorthananil is not systemic -appears that the S2 Entry mode fixup has not run, even when run there are still some contact entries
-- 231031: BUG: Chlorthananil: research: can only import entry modes(actions) iff only 1 ingredient on the S2 row
-- 231031: added import use table
-- 231105: new feature: import multiple correction files
-- 231106: turned auto increment off so SET IDENTITY_INSERT ON/OFF not needed
-- 231108: multiple correction files, @correction_files is now a comma sep list of branches from @import_root
-- 240205: added a cache s2->s3 after the fixup from XL to debug stage 6+ post processing quicker (@restore_s3_s2 works with any stake >=5
-- 240309: moved the tuncate applog to main as we dont get any logging of main import right now
-- 240315: import 1 correction file at a time 
-- 240315: param name change: @import_file -> @LRAP_data_file, @corrections_file -> @cor_file
-- 240315: added optional parameter @cor_range to specifiy the range of the cor file
-- ==================================================================================================================================================
ALTER PROCEDURE [dbo].[sp__main_import]
    @LRAP_data_file     NVARCHAR(500)
   ,@LRAP_range         NVARCHAR(100)  = NULL-- LRAP-221018 230813
   ,@cor_file           NVARCHAR(MAX)  = NULL         -- cor file= correction file
   ,@cor_range          NVARCHAR(1000) = 'ImportCorrections$A:S'
   ,@start_stage        INT            = 0
   ,@stop_stage         INT            = 100
   ,@start_row          INT            = 1
   ,@stop_row           INT            = 100000
   ,@restore_s3_s2      BIT            = 0
   ,@log_level          INT            = 1
   ,@import_id          INT            = NULL
   ,@import_root        NVARCHAR(450)  = 'D:\Dev\Farming\Farming\Data'
AS
BEGIN
   DECLARE
       @fn                 NVARCHAR(35)   = N'MN_IMPRT'
      ,@cnt                INT            = 0
      ,@cor_file_path      NVARCHAR(MAX)  = NULL         -- cor file= correction file
      ,@error_msg          NVARCHAR(500)  = ''
      ,@fixup_cnt          INT            = 0
      ,@first_time         BIT            = 1
      ,@msg                NVARCHAR(500)  = ''
      ,@nl                 NVARCHAR(2)    = NCHAR(13)
      ,@options            INT
      ,@RC                 INT            = 0
      ,@result_msg         NVARCHAR(500)  = ''
      ,@sql                NVARCHAR(MAX)
      ,@stage_id           INT            = 0   -- current stage
      ,@status             INT
      ,@file_type          NCHAR(4)

   -----------------------------------------------------------------------------------
   -- 00: Clear the applog
   -----------------------------------------------------------------------------------
   TRUNCATE TABLE AppLog;

   EXEC sp_log 2, @fn,'00: starting:
LRAP_data_file:[', @LRAP_data_file,']
LRAP_range:    [', @LRAP_range,    ']
cor_file:      [', @cor_file,      ']
cor_range:     [', @cor_range,     ']
start_stage:   [', @start_stage,   ']
stop_stage:    [', @stop_stage,    ']
start_row:     [', @start_row,     ']
stop_row:      [', @stop_row,      ']
restore_s3_s2: [', @restore_s3_s2, ']
log_level:     [', @log_level,     ']
log_level:     [', @log_level,     ']
';

   SET NOCOUNT OFF;
   SET XACT_ABORT ON;

   BEGIN TRY
      SET NOCOUNT OFF;
      SET XACT_ABORT ON;

      WHILE 1=1
      BEGIN
         -------------------------------------------------------------------------------------------
         -- 01. Perform main init; responsibilities:
            -- 01: Determine the file type - xlsx or csv (txt)
            -- 02: Clear the applog 
            -- 03: Set the log level
            -- 04: Configure routine call control to avoid multiple calls of single call routines
            -- 05: Set session ctx vals: fixup count: 0, import_root
            -- 06: Get the import id from the file name
            -- 07: Override import_id with @import_id parameter if supplied
            -- 08: Delete bulk import log files
            -- 09: Postcondition checks
            -- 10: Completed processing
         -------------------------------------------------------------------------------------------
         EXEC sp_log 2, @fn,'Stage 00: Perform main init';

         EXEC sp_main_import_init @LRAP_data_file = @LRAP_data_file OUT
            ,@import_root  = @import_root
            ,@log_level    = @log_level
            ,@cor_file     = @cor_file
            ,@cor_file_path= @cor_file_path OUT
            ,@cor_range    = @cor_range
            ,@import_id    = @import_id     OUT
            ,@file_type    = @file_type     OUT -- 'txt' or 'xlsx'
            ;

         -- *** Register this call only after sp_main_import_init has configured the call register
         EXEC sp_register_call @fn;

         IF @stage_id >= @stop_stage BREAK;

         -------------------------------------------------------------------------------------------------------------------
         -- Stage 00. Optionally restore s2 from S3 cache then go directly to import corrections
         -------------------------------------------------------------------------------------------------------------------
         IF @restore_s3_s2 = 1
         BEGIN
            EXEC sp_log 2, @fn,'Stage 00. restore s2 from S3 cache then go directly to import corrections';
            EXEC sp_copy_s3_s2;
            SET @stage_id = 5; -- go directly to import corrections
         END

         ---------------------------------------------------------------------------------------
         -- Stage 01: clear out staging and main tables, S1 and S2, then import the static data
         ---------------------------------------------------------------------------------------
         --   {1. ActionStaging, 2. UseStaging, 3.Distributor, 4. PathogenTypeStaging, 5. PathogenPathogenTypeStaging, 6. TypeStaging}
         IF @start_stage <= 1
         BEGIN
            EXEC sp_log 2, @fn,'Stage 01: import static data';
            SET @stage_id = 1;
            EXEC sp_main_import_stage_01_imp_sta_dta;
            IF @stage_id >= @stop_stage BREAK;
         END

         -----------------------------------------------------------------------------------
         -- Stage 02: import the LRAP register file into S1 and perform basic fixup
         -----------------------------------------------------------------------------------
         IF @start_stage <= 2
         BEGIN
            EXEC sp_log 2, @fn,'Stage 02: import LRAP';
            SET @stage_id = 2;
            EXEC sp_main_import_stage_02_imp_LRAP @LRAP_data_file, @LRAP_range, @import_id;

            IF @stage_id >= @stop_stage BREAK;
         END

         -----------------------------------------------------------------------------------
         -- Stage 03: fixup S1, copy S1->S2
         -----------------------------------------------------------------------------------
         IF @start_stage <= 3
         BEGIN
            EXEC sp_log 2, @fn,'Stage 03: S1 fixup';
            SET @stage_id = 3;
            EXEC sp_main_import_stage_03_s1_fixup;

            IF @stage_id >= @stop_stage BREAK;
         END

         -----------------------------------------------------------------------------------
         -- Stage 04: fixup S2 using the sp_fixup_s2 stored procedure and not the xls
         -----------------------------------------------------------------------------------
         IF @start_stage <= 4
         BEGIN
            EXEC sp_log 2, @fn,'Stage 04: S2 fixup';
            SET @stage_id = 4;
            EXEC sp_main_import_stage_04_s2_fixup;

            IF @stage_id >= @stop_stage BREAK;
         END

         -----------------------------------------------------------------------------------
         -- Stage 05: import the import correction files
         -----------------------------------------------------------------------------------
         IF @start_stage <= 5
         BEGIN
            EXEC sp_log 2, @fn,'Stage 05: import cor';
            SET @stage_id = 5;
            DECLARE @correction_file_inc_rng NVARCHAR(500);
            SET @correction_file_inc_rng = CONCAT(@cor_file_path, '!', @cor_range);

            EXEC sp_main_import_stage_05_imp_cor
               @import_root            = @import_root
              ,@correction_file_inc_rng= @correction_file_inc_rng;

            IF @stage_id >= @stop_stage BREAK;
         END

         --------------------------------------------------------------------------------------
         -- Stage 06: perform Spreadsheet based S2 fixup, using an importcorrections.xlsx file, cache S2->S3
         --------------------------------------------------------------------------------------
         IF @start_stage <= 6
         BEGIN
            EXEC sp_log 2, @fn,'Stage 06: fixup cor using excel';
            SET @stage_id = 6;

            EXEC @rc = sp_main_import_stage_06_fixup_xl 
                @start_row    = @start_row
               ,@stop_row     = @stop_row
               ,@cor_file_path= @cor_file_path
               ,@cor_range    = @cor_range
               ,@fixup_cnt    = @fixup_cnt OUTPUT;

            IF (@stage_id >= @stop_stage) OR (@rc<> 0) BREAK; -- @rc= 0 means OK, 1 means stop and OK, -1 means error
         END

         -----------------------------------------------------------------------------------
         -- Stage 07: populate the staging tables
         -----------------------------------------------------------------------------------
         IF @start_stage <= 7
         BEGIN
            EXEC sp_log 2, @fn,'Stage 07: pop staging';
            SET @stage_id = 7;
            EXEC sp_main_import_stage_07_pop_stging;

            IF @stage_id >= @stop_stage BREAK;
         END

         -----------------------------------------------------------------------------------
         -- Stage 08: Merge the staging tables to the normalised tables
         -----------------------------------------------------------------------------------
         IF @start_stage <= 8
         BEGIN
            EXEC sp_log 2, @fn,'Stage 08: merge to main';
            SET @stage_id = 8;
            EXEC sp_main_import_stage_08_mrg_mn;

            IF @stage_id>= @stop_stage BREAK;
         END

         -----------------------------------------------------------------------------------
         -- Stage 09: perform postcondition checks
         -----------------------------------------------------------------------------------
         IF @start_stage <= 9
         BEGIN
            EXEC sp_log 2, @fn,'Stage 09: postcondition checks';
            SET @stage_id = 9;
            EXEC sp_main_import_stage_09_post_cks;

            IF @stage_id >= @stop_stage BREAK;
         END

         -----------------------------------------------------------------------------------
         -- Completed processing
         -----------------------------------------------------------------------------------
         EXEC sp_log 2, @fn,'90: completed processing OK';
         BREAK;
         END -- WHILE 1=1 main loop
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn, '@stage_id: ', @stage_id;
      THROW;
   END CATCH

   SET @stage_id = 99; 
   SET @fixup_cnt = Ut.dbo.fnGetSessionContextAsInt(N'fixup count');
   EXEC sp_log 2, @fn, '99: leaving OK, stage: ', @stage_id, ' ret: ', @RC, @row_count=@fixup_cnt;
   RETURN @RC;
END
/*
EXEC sp__main_import
    @LRAP_data_file= 'D:\Dev\Farming\Farming\Data\LRAP-240910.txt'
   ,@cor_file      = NULL         -- cor file= correction file
   ,@cor_range     = 'ImportCorrections$A:S'
   ,@start_stage   = 0
   ,@stop_stage    = 100
   ,@start_row     = 1
   ,@stop_row      = 100000
   ,@restore_s3_s2 = 0
   ,@log_level     = 1
   ,@import_id     = NULL
   ,@import_root   = 'D:\Dev\Farming\Farming\Data'
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 03-APR-2020
-- Description: Inserts a log row in the app log
--
--              Splits into column based on tabs in the the message or 

   -- set @tmp = LEFT(CONCAT(REPLICATE( '  ', @sf), REPLACE(LEFT( @tmp, 500), @NL, '--')), 500);
   -- set @tmp = LEFT(CONCAT( REPLACE(LEFT( @tmp, 500), @NL, '--')), 500);
-- =============================================
ALTER PROCEDURE [dbo].[sp_app_log_display]
          @dir   BIT          = 1 -- ASC
         ,@fn    NVARCHAR(60) = NULL
         ,@level INT          = NULL
AS
BEGIN
   DECLARE
       @sql             NVARCHAR(4000)

   SET @sql = CONCAT(
'SELECT
  id
,[level]
,fn    AS ''fn',   REPLICATE('_',16), '''
,SUBSTRING(msg, 1  , 128) AS ''msg1', REPLICATE('_',50), '''
,SUBSTRING(msg, 129, 128) AS ''msg2', REPLICATE('_',50), '''
,SUBSTRING(msg, 257, 128) AS ''msg3', REPLICATE('_',100), '''
,SUBSTRING(msg, 385, 128) AS ''log4', REPLICATE('_',100), '''
FROM AppLog
', iif(@fn is not NULL OR @level IS NOT NULL, 'WHERE ', '')
, iif(@fn is NULL, '', CONCAT(' fn = ''', @fn, '''')),'
',iif(@level is NULL, '', CONCAT(IIF(@fn is NULL,'', ' AND '),'level = ', @level)),'
ORDER BY ID ', iif(@dir=1, 'ASC','DESC'), ';'
);

   PRINT @sql;

   EXEC (@sql);
END
/*
   EXEC sp_app_log_display 1;
   EXEC sp_app_log_display 1, @fn='sp_assert_not_null_or_empty';
   EXEC sp_app_log_display 1, @level=0;
   EXEC sp_app_log_display 1, @fn='sp_assert_not_null_or_empty', @level=0;
   EXEC tSQLt.RunAll;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      Terry watts
-- Create date: 30-MAR-2020
-- Description: assert the given file exists or throws exception @ex_num* 'the file[<@file>] does not exist', @state
-- * if @ex_num default: 53200, state=1
-- =============================================
ALTER PROCEDURE [dbo].[sp_assert_file_exists]
       @file      NVARCHAR(500)
      ,@msg1      NVARCHAR(200)   = NULL
      ,@msg2      NVARCHAR(200)   = NULL
      ,@msg3      NVARCHAR(200)   = NULL
      ,@msg4      NVARCHAR(200)   = NULL
      ,@msg5      NVARCHAR(200)   = NULL
      ,@msg6      NVARCHAR(200)   = NULL
      ,@msg7      NVARCHAR(200)   = NULL
      ,@msg8      NVARCHAR(200)   = NULL
      ,@msg9      NVARCHAR(200)   = NULL
      ,@msg10     NVARCHAR(200)   = NULL
      ,@msg11     NVARCHAR(200)   = NULL
      ,@msg12     NVARCHAR(200)   = NULL
      ,@msg13     NVARCHAR(200)   = NULL
      ,@msg14     NVARCHAR(200)   = NULL
      ,@msg15     NVARCHAR(200)   = NULL
      ,@msg16     NVARCHAR(200)   = NULL
      ,@msg17     NVARCHAR(200)   = NULL
      ,@msg18     NVARCHAR(200)   = NULL
      ,@msg19     NVARCHAR(200)   = NULL
      ,@msg20     NVARCHAR(200)   = NULL
      ,@ex_num    INT             = 53200
      ,@state     INT             = 1
      ,@fn        NVARCHAR(60)    = N'xxx*'  -- function testing the assertion
AS
BEGIN
   IF dbo.fnFileExists(@file) = 0
   DECLARE
       @fn_       NVARCHAR(35)   = N'ASSERT_FILE_EXISTS'
      ,@msg       NVARCHAR(MAX)

   EXEC sp_log 1, @fn_, '000: checking file [', @file, '] exists';
   IF dbo.fnFileExists( @file) = 0
   BEGIN
      SET @msg = CONCAT('File [',@file,'] does not exist');

      EXEC sp_raise_exception
          @ex_num = @ex_num
         ,@msg1   = @msg
         ,@msg2   = @msg1
         ,@msg3   = @msg2 
         ,@msg4   = @msg3 
         ,@msg5   = @msg4 
         ,@msg6   = @msg5 
         ,@msg7   = @msg6 
         ,@msg8   = @msg7 
         ,@msg9   = @msg8 
         ,@msg10  = @msg9 
         ,@msg11  = @msg10
         ,@msg12  = @msg11
         ,@msg13  = @msg12
         ,@msg14  = @msg13
         ,@msg15  = @msg14
         ,@msg16  = @msg15
         ,@msg17  = @msg16
         ,@msg18  = @msg17
         ,@msg19  = @msg18
         ,@msg20  = @msg19
         ,@state  = @state
      END
END
/*
EXEC sp_assert_file_exists 'non existant file', ' second msg',@fn='test fn', @state=5  -- expect ex: 53200, 'the file [non existant file] does not exist', ' extra detail: none', @state=1, @fn='test fn';
EXEC sp_assert_file_exists 'C:\bin\grep.exe'   -- expect OK
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 27-MAR-2020
-- Description: Raises exception if exp = act
-- =============================================
ALTER PROCEDURE [dbo].[sp_assert_not_equal]
       @a         SQL_VARIANT
      ,@b         SQL_VARIANT
      ,@msg       NVARCHAR(200)   = NULL
      ,@msg2      NVARCHAR(200)   = NULL
      ,@msg3      NVARCHAR(200)   = NULL
      ,@msg4      NVARCHAR(200)   = NULL
      ,@msg5      NVARCHAR(200)   = NULL
      ,@msg6      NVARCHAR(200)   = NULL
      ,@msg7      NVARCHAR(200)   = NULL
      ,@msg8      NVARCHAR(200)   = NULL
      ,@msg9      NVARCHAR(200)   = NULL
      ,@msg10     NVARCHAR(200)   = NULL
      ,@msg11     NVARCHAR(200)   = NULL
      ,@msg12     NVARCHAR(200)   = NULL
      ,@msg13     NVARCHAR(200)   = NULL
      ,@msg14     NVARCHAR(200)   = NULL
      ,@msg15     NVARCHAR(200)   = NULL
      ,@msg16     NVARCHAR(200)   = NULL
      ,@msg17     NVARCHAR(200)   = NULL
      ,@msg18     NVARCHAR(200)   = NULL
      ,@msg19     NVARCHAR(200)   = NULL
      ,@msg20     NVARCHAR(200)   = NULL
      ,@ex_num    INT             = 50001
      ,@state     INT             = 1
AS
BEGIN
   IF dbo.fnChkEquals(@a ,@b) = 1
      EXEC sp_raise_exception
--          @a      = @a
--         ,@b      = @b
          @msg1    = @msg
         ,@msg2   = @msg2
         ,@msg3   = @msg3
         ,@msg4   = @msg4
         ,@msg5   = @msg5
         ,@msg6   = @msg6
         ,@msg7   = @msg7
         ,@msg8   = @msg8
         ,@msg9   = @msg9
         ,@msg10  = @msg10
         ,@msg11  = @msg11
         ,@msg12  = @msg12
         ,@msg13  = @msg13
         ,@msg14  = @msg14
         ,@msg15  = @msg15
         ,@msg16  = @msg16
         ,@msg17  = @msg17
         ,@msg18  = @msg18
         ,@msg19  = @msg19
         ,@msg20  = @msg20
         ,@ex_num = @ex_num
         ,@state  = @state
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_047_sp_assert_not_equal';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

--===========================================================
-- Author:      Terry watts
-- Create date: 18-MAY-2020
-- Description: lists routine details
-- ===========================================================
ALTER VIEW [dbo].[SysRtns_vw]
AS
SELECT TOP 2000
    SCHEMA_NAME([schema_id])              AS schema_nm
   ,[name]                                AS rtn_nm
   ,IIF([type] IN ('P','PC'), 'P', 'F')   AS rtn_ty
   ,dbo.fnTrim([type])                    AS ty_code
   ,[type_desc]                           AS ty_nm
   ,IIF([type] IN ('FS','FT','PC'),1,0)   AS is_clr
   ,is_ms_shipped
   ,DATEFROMPARTS(YEAR(create_date), MONTH(create_date), Day(create_date)) AS created
   ,DATEFROMPARTS(YEAR(modify_date), MONTH(modify_date), Day(modify_date)) AS modified
FROM sys.objects
    WHERE
     [type] IN ('P', 'FN', 'TF', 'IF', 'AF', 'FT', 'IS', 'PC', 'FS')
ORDER BY [schema_nm], [type], [name]
/*
SELECT TOP 500 schema_nm, rtn_nm, ty_code FROM dbo.SysRtns_vw
WHERE ty_code in('FN', 'TF','P')
ORDER BY ty_code, schema_nm, rtn_nm;

SELECT TOP 500 * FROM dbo.SysRtns2_vw;
---------------------------------------------------------------------------------------------------------------------------------
SELECT TOP 500 
   name as rtn_nm
   ,SCHEMA_NAME(schema_id) as schema_nm
   ,[type] as rtn_ty
   ,type_desc
   ,create_date
   ,modify_date
   ,is_ms_shipped
FROM sys.objects
    WHERE
     [type] IN ('P', 'FN', 'TF', 'IF', 'AF', 'FT', 'IS', 'PC', 'FS')
ORDER BY [schema_nm], [type], [name]
---------------------------------------------------------------------------------------------------------------------------------

SELECT DISTINCT ty_code, ty_nm,det_ty_nm FROM  SysRtns_vw;
ty_code	ty_nm
AF	AGGREGATE_FUNCTION
FN	SQL_SCALAR_FUNCTION
FS	CLR_SCALAR_FUNCTION
FT	CLR_TABLE_VALUED_FUNCTION
IF	SQL_INLINE_TABLE_VALUED_FUNCTION
P 	SQL_STORED_PROCEDURE
PC	CLR_STORED_PROCEDURE
TF	SQL_TABLE_VALUED_FUNCTION
PRINT Db_Name();
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===========================================================================================
-- Author:      Terry Watts
-- Create date: 09-MAY-2020
-- Description: This routine checks that the given routine exists
--
-- POST         throws exception if rotine does not exist
--
-- Changes:
-- 10-NOV-2023: changed parameter @fn to @calling_fn as @fn is used to log and also in tests
-- 24-APR-2024: added feature to check if exist or not exist
-- ===========================================================================================
ALTER PROCEDURE [dbo].[sp_assert_rtn_exists]
    @qrn          NVARCHAR(120)
   ,@should_exist BIT            = 1
   ,@msg1         NVARCHAR(200) = NULL
   ,@msg2         NVARCHAR(200) = NULL
   ,@msg3         NVARCHAR(200) = NULL
   ,@msg4         NVARCHAR(200) = NULL
   ,@msg5         NVARCHAR(200) = NULL
   ,@msg6         NVARCHAR(200) = NULL
   ,@msg7         NVARCHAR(200) = NULL
AS
BEGIN
   DECLARE
       @fn     NVARCHAR(35)   = 'sp_assert_rtn_exists'
      ,@schema NVARCHAR(20)
      ,@rtn_nm NVARCHAR(4000)

   EXEC sp_log 1, @fn,'000: starting';

   SELECT
       @schema = schema_nm
      ,@rtn_nm = rtn_nm
   FROM test.fnSplitQualifiedName(@qrn);

   IF EXISTS
   (
      SELECT 1 FROM dbo.sysRtns_vw s
      WHERE schema_nm = @schema and rtn_nm = @rtn_nm
   )
   BEGIN -- rtn does exists
     EXEC sp_log 1, @fn,'005: rtn ',@schema,'.',@rtn_nm, ' exists';
     EXEC sp_assert_equal 1, @should_exist, @qrn, ' 005: should exist - but does not'
             ,@msg1,@msg2,@msg3,@msg4,@msg5,@msg6,@msg7
            ,@ex_num=50001;
        ;

   END
   ELSE
   BEGIN -- rtn does not exist
     EXEC sp_log 1, @fn,'010: ',@schema,'.',@rtn_nm, ' does not exist';
     EXEC sp_assert_equal 0, @should_exist, @qrn, ' 010: should not exist - but does'
            ,@msg1,@msg2,@msg3,@msg4,@msg5,@msg6,@msg7
            ,@ex_num=50002;
   END
END
/*
   EXEC sp_chk_rtn_exists 'dbo.sp_chk_tbl_populated' 
   EXEC sp_chk_rtn_exists 'dbo.sp_chk_tbl_populatedx' 
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ========================================================
-- Author:      Terry Watts
-- Create date: 20-AUG-2023
--
-- Description: imports the Import table
-- RETURNS:
--    0 if OK, else OS error code
--
-- PRECONDITIONS:
--    none
--
-- POSTCONDITIONS:
--   Import table clean populated or error
--
-- Tests:
--
-- ========================================================
ALTER procedure [dbo].[sp_bulk_insert_import]
    @imprt_tsv_file   NVARCHAR(500)
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35)  = N'BLK_INS_IMPORT'
      ,@sql       NVARCHAR(MAX)
      ,@error_msg NVARCHAR(MAX) = NULL
      ,@rc        INT   =-1 
      ;

   EXEC sp_log 1, @fn,'00: starting';

   BEGIN TRY
      EXEC sp_log 2, @fn, '10: deleting bulk import log files'
      EXEC xp_cmdshell 'DEL D:\Logs\ImportImportErrors.log.Error.Txt', NO_OUTPUT; -- POST 5: clear the staging import logs
      EXEC xp_cmdshell 'DEL D:\Logs\ImportImportErrors.log'          , NO_OUTPUT; -- POST 5: clear the staging import logs

      EXEC sp_log 2, @fn, '20: truncating table'
      TRUNCATE TABLE dbo.Import;

      SET @sql = CONCAT(
     'BULK INSERT [dbo].[import] FROM ''', @imprt_tsv_file, '''
      WITH
      (
         FIRSTROW        = 2
        ,ERRORFILE       = ''D:\Logs\ImportImportErrors.log''
        ,FIELDTERMINATOR = ''\t''
        ,ROWTERMINATOR   = ''\n''   
      );
   ');

      EXEC sp_log 2, @fn, '30: running bulk insert cmd'
      EXEC @rc = sp_executesql @sql;
   END TRY
   BEGIN CATCH
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, '40: Caught exception: ', @error_msg;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, 'leaving'
   RETURN @RC;
END
/*
EXEC sp_bulk_insert_Import 'D:\Dev\Repos\Farming\Data\Import.tsv.txt'
SELECT * FROM Import;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:       Terry Watts
-- Create date:  01-AUG-2023
-- Description:  imports the extra data productUse table
--               do this after the main import pops the productUse table
--
-- Info Sources:
--
-- Tests:
-- ======================================================================================================
ALTER PROCEDURE [dbo].[sp_bulk_insert_productUseStaging]
    @imprt_tsv_file   NVARCHAR(500)
AS
BEGIN
   DECLARE
       @fn  NVARCHAR(35)  = N'BLK_IMPRT PROD-USE STGING'
      ,@sql NVARCHAR(MAX)
      ,@error_msg NVARCHAR(MAX) = NULL
      ,@rc  INT    =-1
      ,@import_root NVARCHAR(MAX)  
      ;

   SET NOCOUNT OFF;
   BEGIN TRY
      SET @import_root = Ut.dbo.fnGetImportRoot();
      EXEC sp_log 1, @fn, '01: starting, @import_root:[',@import_root,']';
      EXEC sp_register_call @fn;
      EXEC sp_log 1, @fn, '02: deleting bulk import log files';
      EXEC xp_cmdshell 'DEL D:\Logs\ProductUse.log.Error.Txt', NO_OUTPUT;
      EXEC xp_cmdshell 'DEL D:\Logs\ProductUse.log'          , NO_OUTPUT;

      SET @sql = CONCAT(
   'BULK INSERT [dbo].[ProductUseStaging] FROM ''', @imprt_tsv_file, '''
      WITH
      (
         FIRSTROW        = 4
        ,ERRORFILE       = ''D:\Logs\ProductUse.log''
        ,FIELDTERMINATOR = ''\t''
        ,ROWTERMINATOR   = ''\n''   
        ,FORMATFILE      = ''D:\Dev\Repos\Farming\Data\ProductUse.FMT''
      );
   ');
      
;      PRINT @sql;
      EXEC sp_log 1, @fn, '04: running bulk insert cmd';
      EXEC @rc = sp_executesql @sql;
      EXEC sp_log 1, @fn, '05: completed processing OK';
      SET @rc = 0; -- OK
   END TRY
   BEGIN CATCH
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, '50: Caught exception: ', @error_msg;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '99: leaving OK, RC: ', @rc;
   RETURN @RC;
END
/*
TRUNCATE TABLE productUseStaging;
EXEC sp_bulk_insert_productUseStaging 'D:\Dev\Repos\Farming\Data\ProductUse.tsv'
SELECT * FROM ProductUseStaging;
SELECT * FROM all_vw_with_nulls
*/ 


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON


CREATE PROC [dbo].[sp_chk_comma_replace_staging2_pathogens]
AS
BEGIN
   DECLARE @cnt INT = 0;
   SELECT @cnt = COUNT(*)  FROM staging2 WHERE pathogens LIKE CONCAT('%', NCHAR(44), NCHAR(32), '%');

   IF @cnt > 0
   BEGIN
      SELECT stg2_id, pathogens FROM staging2;
      SELECT stg1_id, pathogens FROM staging1;
      THROW 50132, '**** 1: pathogens still has comma space ****', 1;
   END

   SELECT @cnt = COUNT(*)  FROM staging2 WHERE pathogens LIKE CONCAT('%', NCHAR(32), NCHAR(44), '%')
   IF @cnt > 0 
   BEGIN
      SELECT stg2_id, pathogens FROM staging2;
      THROW 50133, '**** 2: pathogens still has space comma ******', 1;
   END
END

/*
EXEC sp_chk_comma_replace_staging2_pathogens
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ============================================================
-- Author:      Terry Watts
-- Create date: 21-JUN-20223
-- Description: List the Pathogens in order 
--  - use to look for duplicates and misspellings and errors
-- ============================================================
ALTER FUNCTION [dbo].[fnListPathogens2]()
RETURNS 
@t TABLE (id INT, pathogen NVARCHAR(400))
AS
BEGIN
   INSERT INTO @t
   SELECT DISTINCT TOP 1000000
   stg2_id, cs.value AS pathogen 
   FROM Staging2 
   CROSS APPLY string_split(pathogens, ',') cs
   WHERE cs.value <> ''
   ORDER BY pathogen, stg2_id
   RETURN 
END
/*
SELECT id, pathogen from dbo.fnListPathogens2() 
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 24-MAR-2024
-- Description: returns the chnges made to S2 during XL fixup for the given set of ids
--
-- CHANGES:
-- ======================================================================================================
CREATE PROC [dbo].[sp_ListPathogenUpdateLogChangesForS2Ids]
   @s2_ids NVARCHAR(400) -- comma separated list o6 stg2_id
AS
BEGIN
   DECLARE @cmd NVARCHAR(2000)

   IF @s2_ids IS NOT NULL
   BEGIN
   SET @cmd = CONCAT('SELECT s.id, s.fixup_id,row_cnt,search_clause,replace_clause,s1.pathogens as [original], L.stg2_id,L.old_pathogens, L.new_pathogens, s2.crops
   FROM S2UpdateSummary s 
   LEFT JOIN S2Updatelog L ON s.fixup_id=L.fixup_id
   LEFT join Staging2 s2 ON s2.stg2_id = L.stg2_id
   LEFT join Staging1 s1 ON s1.stg1_id = L.stg2_id
   WHERE L.stg2_id IN (', ut.dbo.fnTrim2(SUBSTRING(@s2_ids,1,400), ','),') ORDER BY s.fixup_id, L.stg2_id;');
   END
   ELSE
   SELECT 'No changes found';

   PRINT @cmd;
   EXEC (@cmd);
END
/*
EXEC sp_ListPathogenUpdateLogChangesForS2Ids '7976';
EXEC sp_ListPathogenUpdateLogChangesForS2Ids '7976,5053,7976';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 24-MAR-2024
-- Description: returns the cor ids that effected the changes in the pathogen import XL fixup
--
-- CHANGES:
-- ======================================================================================================
CREATE PROC [dbo].[sp_ListPathogenUpdateLogCorIdsForS2Ids]
   @s2_ids NVARCHAR(400) -- comma separated list o6 stg2_id
AS
BEGIN
   DECLARE @cmd NVARCHAR(2000)

   DROP TABLE IF EXISTS temp;

   IF @s2_ids IS NOT NULL
   BEGIN
      SET @cmd = CONCAT('SELECT * into temp FROM
(
SELECT s.fixup_id,row_cnt
FROM S2UpdateSummary s 
LEFT JOIN S2Updatelog L ON s.fixup_id=L.fixup_id
WHERE L.stg2_id IN (', ut.dbo.fnTrim2(SUBSTRING(@s2_ids,1,400), ','),') 
) AS X'
);

      PRINT @cmd;
      EXEC (@cmd);
      SELECT * FROM temp;
   END
   ELSE
      SELECT 'No changes found';

END
/*
EXEC sp_ListPathogenUpdateLogCorIdsForS2Ids '7976';
EXEC sp_ListPathogenUpdateLogCorIdsForS2Ids '7976,5053,7976';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 24-MAR-2024
-- Description: helper when tracking Cor update issues
--
-- CHANGES:
-- ======================================================================================================
CREATE PROC [dbo].[sp_chk_cor_update]
   @pathogen NVARCHAR(400)
AS
BEGIN
   DECLARE
       @cmd NVARCHAR(2000)
      ,@ids NVARCHAR(4000) -- comma separated list of stg2_id
   -------------------------------------------------------------
   -- get and display the list of S2 rows that have this pathogen
   -------------------------------------------------------------
   SELECT @ids=string_agg(id, ',') FROM dbo.fnListPathogens2() WHERE pathogen = @pathogen;
   PRINT CONCAT( 'S2 ids: ', @ids);

   SELECT @pathogen as pathogen, @ids AS [s2 ids************************************************************************************************************************]
;

   EXEC sp_ListPathogenUpdateLogChangesForS2Ids @ids;
   SELECT pathogen_nm as [pathogen table nm] from Pathogen WHERE pathogen_nm = @pathogen;
   SELECT stg2_id, s1_pathogens as [original s1 id], s2_pathogens as [updated pathogens] 
   FROM s12_vw where s2_pathogens like CONCAT('%',@pathogen,'%') OR s1_pathogens like CONCAT('%',@pathogen,'%');
   SELECT id as [ImportCorrections id], search_clause, replace_clause FROM ImportCorrections WHERE search_clause LIKE CONCAT('%',@pathogen,'%') OR replace_clause LIKE CONCAT('%',@pathogen,'%');
   EXEC sp_ListPathogenUpdateLogCorIdsForS2Ids @ids;
   SELECT stg2_id, s1_pathogens, s2_pathogens, s2_crops  FROM s12_vw where s2_pathogens like CONCAT('%',@pathogen,'%');
END
/*
EXEC sp_chk_cor_update 'Looper';
EXEC sp_ListPathogenUpdateLogChangesForS2Ids '159,159,903,913,914,951'
SELECT * FROM ImportCorrections where id in (162,162,906,916,917,917,954)
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===========================================================================================
-- Author:      Terry Watts
-- Create date: 09-MAY-2020
-- Description: This routine checks that the given routine exists
--
-- POST         throws exception if rotine does not exist
--
-- Changes:
-- 10-NOV-2023: changed parameter @fn to @calling_fn as @fn is used to log and also in tests
-- ===========================================================================================
ALTER PROCEDURE [dbo].[sp_chk_rtn_exists]
       @qrn    NVARCHAR(120)
      ,@fn     NVARCHAR(35)   = 'sp_chk_rtn_exists'

AS
BEGIN
   DECLARE
       @schema NVARCHAR(20)
      ,@rtn_nm NVARCHAR(4000)

   SELECT
       @schema = schema_nm
      ,@rtn_nm = rtn_nm
   FROM ut.test.fnSplitQualifiedName(@qrn);

   IF EXISTS
   (
      SELECT 1 FROM dbo.sysRtns_vw s
      WHERE schema_nm = @schema and rtn_nm = @rtn_nm
   )
   BEGIN
     EXEC sp_log 1, @fn,' ',@schema,'.',@rtn_nm, ' exists: OK';
   END
   ELSE
   BEGIN
      DECLARE @error_msg NVARCHAR(500);
      SET @error_msg = CONCAT('routine [', @schema,'].[', @rtn_nm, '] does not exist');
      EXEC sp_log 4, @fn,' ERROR: ', @error_msg;
      EXEC sp_raise_exception 50001, @error_msg, @state=1, @fn=@fn;
   END
END
/*
   EXEC sp_chk_rtn_exists 'dbo.sp_chk_tbl_populated' 
   EXEC sp_chk_rtn_exists 'dbo.sp_chk_tbl_populatedx' 
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:       Terry Watts
-- Create date:  01-AUG-2022
-- Description:  Checks table counts
-- ======================================================================================================
ALTER PROCEDURE [dbo].[sp_chk_table_count]
    @table  NVARCHAR(60)
   ,@exp    INT
AS
BEGIN
   SET NOCOUNT ON
   DECLARE
       @fn        NVARCHAR(35) ='sp_chk_table_count'
      ,@act       INT
      ,@sql       NVARCHAR(MAX)
      ,@error_msg NVARCHAR(300)
      ,@ok_msg    NVARCHAR(300)

   SET @ok_msg = CONCAT('table: ', ut.dbo.fnPadRight(@table, 20),  ut.dbo.fnPadRight(' exp row count: ', 23-ut.dbo.fnLen(@exp)), @exp);
   SET @sql = CONCAT('SET @act = (SELECT COUNT(*) FROM [', @table, ']);');
   EXEC sp_executesql @sql, N'@sql NVARCHAR(MAX), @act INT OUT', @sql, @act OUT;

   IF  @exp <> @act
   BEGIN
      SET @error_msg = CONCAT('Warning exp/act row count mismatch for table: [', @table, '] exp row count: ', @exp, ' act row count: ', @act); 
      EXEC sp_log 3, @fn, @error_msg;
   END
END
/*
EXEC sp_chk_table_count 'Chemical', 325;
*/

GO
GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ============================================================================================
-- Author:      Terry Watts
-- Create date: 12-FEB-2024
-- Description: helper rtn to check a table does not  contain any items in the given field
--    If it does logs an error and adds to the error table
-- ============================================================================================
ALTER PROCEDURE [dbo].[sp_chk_table_not_contains]
    @table              NVARCHAR(60)
   ,@field_nm           NVARCHAR(50)
   ,@operator           NVARCHAR(30) -- 'LIKE', 'IN', 'IS NULL'
   ,@item_list          NVARCHAR(MAX) = NULL
   ,@err_cnt_total      INT OUT
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
    @fn                 NVARCHAR(35)   = N'CHK_TABLE_NOT_CONTAINS'
   ,@err_cnt            INT            = 0
   ,@err_msg            NVARCHAR(250)  = NULL
   ,@msg                NVARCHAR(250)  = NULL
   ,@sql_phrase         NVARCHAR(MAX)  = NULL
   ,@sql                NVARCHAR(MAX)  = NULL
   ,@value              NVARCHAR(100)  = NULL

   EXEC sp_log 2, @fn,'00: starting';

   -- Validation
   IF @operator NOT IN ('LIKE', 'IN', 'IS NULL')
   BEGIN
      SET @err_msg = CONCAT('sp_chk_table_not_contains bad operator parameter:[',@operator,']');
      THROW 71500, @err_msg, 1;
   END

      SET @sql_phrase = CONCAT( ' FROM [',@table,'] WHERE [',@field_nm,'] ');
   -- -- 'LIKE', 'IN', 'IS NULL'
   IF @operator = 'LIKE'
   BEGIN
      EXEC sp_log 2, @fn,'05: LIKE';
      SET @sql_phrase = CONCAT( @sql_phrase, 'LIKE ''%', @item_list,'%''');
   END
   ELSE IF @operator = 'IN'
   BEGIN
      EXEC sp_log 2, @fn,'10: IN';
      SET @sql_phrase = CONCAT(  @sql_phrase, 'IN (', @item_list,')');
   END
   ELSE --IF IS NULL
   BEGIN
      EXEC sp_log 2, @fn,'15: IS NULL';
      SET @sql_phrase = CONCAT( @sql_phrase, 'IS NULL');
   END

   EXEC sp_log 2, @fn,'20: ';
   SET @sql = CONCAT('SELECT @err_cnt = COUNT(*)', @sql_phrase);
   PRINT @sql;
   EXEC sp_executesql @sql, N'@err_cnt INT OUT', @err_cnt OUT;
   EXEC sp_log 2, @fn,'25: @err_cnt: ',@err_cnt;

   IF @err_cnt > 0
   BEGIN
      IF @operator = 'IS NULL'
         SET @msg = CONCAT('[', @table, '].[', @field_nm, '] has ',@err_cnt,' rows with NULL values');
      ELSE
         SET @msg = CONCAT('[', @table, '].[', @field_nm, '] has ',@err_cnt,' rows with one or more of these values: (', @item_list, ')');

      EXEC sp_log 4, @fn,'30: oops: ', @msg;
      INSERT INTO importErrors ([table],field, msg, cnt) VALUES (@table, @field_nm, @msg, @err_cnt);
      EXEC sp_log 2, @fn,'35: ';
      SET @err_cnt_total = @err_cnt_total + @err_cnt;
   END

   EXEC sp_log 2, @fn, '99: returning, count: ', @err_cnt_total;
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:		  Terry Watts
-- Create date:  02-UG-2023
-- Description:  Compares different LRAP formats
--
-- Process:
--    1. Compare staging 1
--       1.1: compare companies
-- ======================================================================================================
ALTER PROCEDURE [dbo].[sp_compare_formats_221008_230721] 
AS
BEGIN
   DECLARE 
       @fn NVARCHAR(35)='COMP FMTS 221008_230721'
      ,@cnt_221008 INT
      ,@cnt_230721 INT
      ,@msg        NVARCHAR(MAX)
   --SET NOCOUNT ON
   EXEC sp_log 2, @fn, '01 starting'
   EXEC sp_log 2, @fn, '01 comparing s1 company counts'
   SELECT @cnt_221008 = count(*) FROM (SELECT distinct company from staging1_bak_221008) AS X;
   SELECT @cnt_230721 = count(*) FROM (SELECT distinct company from staging1) AS X;

   SET @msg = IIF(@cnt_221008=@cnt_230721, 'same', 'different');
   EXEC sp_log 2, @fn, 's1 company counts: s1 230721: ', @cnt_230721, ' s1 221008: ', @cnt_221008, '  ', @msg;

   SELECT @cnt_221008 = count(*) FROM (SELECT distinct product from staging1_bak_221008) AS X;
   SELECT @cnt_230721 = count(*) FROM (SELECT distinct product from staging1) AS X;
   SET @msg = IIF(@cnt_221008=@cnt_230721, 'same', 'different');
   EXEC sp_log 2, @fn, 's1 product counts: s1 230721: ', @cnt_230721, ' s1 221008: ', @cnt_221008, '  ', @msg;

   SELECT @cnt_221008 = count(*) FROM (SELECT distinct ingredient from staging1_bak_221008) AS X;
   SELECT @cnt_230721 = count(*) FROM (SELECT distinct ingredient from staging1) AS X;
   SET @msg = IIF(@cnt_221008=@cnt_230721, 'same', 'different');
   EXEC sp_log 2, @fn, 's1 ingredient counts: s1 230721: ', @cnt_230721, ' s1 221008: ', @cnt_221008, '  ', @msg;

   SELECT @cnt_221008 = count(*) FROM staging1_bak_221008;
   SELECT @cnt_230721 = count(*) FROM staging1;
   SET @msg = IIF(@cnt_221008=@cnt_230721, 'same', 'different');
   EXEC sp_log 2, @fn, 's1 total counts: s1 230721: ', @cnt_230721, ' s1 221008: ', @cnt_221008, '  ', @msg;

   SELECT * FROM staging1
   SELECT * FROM staging1_bak_221008

   EXEC sp_log 2, @fn, '99 leaving'
END
/*
EXEC sp_compare_formats_221008_230721
*/

GO
GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

-- ==============================================================================
-- Author:		 Terry Watts
-- Create date: 17-JUL-2023
-- Description: copies staging1_bak to staging1.
-- CHANGES:
-- 231103: turned auto increment off so SET IDENTITY_INSERT ON/OFF not needed
-- ==============================================================================
CREATE PROC [dbo].[sp_copy_s1_bak_s1]
AS
BEGIN
   DECLARE
       @fn              NVARCHAR(30)   = 'CPY S1_BAK STG1'

   EXEC sp_log 2, @fn, 'starting';
   TRUNCATE TABLE staging1;
   --SET IDENTITY_INSERT staging1 ON

   INSERT INTO [dbo].[staging1]
   (
       stg1_id
      ,[company]
      ,[ingredient]
      ,[product]
      ,[concentration]
      ,[formulation_type]
      ,[uses]
      ,[toxicity_category]
      ,[registration]
      ,[expiry]
      ,[entry_mode]
      ,[crops]
      ,[pathogens]
      ,rate
      ,mrl
      ,phi
      ,reentry_period
      ,[notes]
   )
   SELECT 
       stg1_id
      ,[company]
      ,[ingredient]
      ,[product]
      ,[concentration]
      ,[formulation_type]
      ,[uses]
      ,[toxicity_category]
      ,[registration]
      ,[expiry]
      ,[entry_mode]
      ,[crops]
      ,[pathogens]
      ,rate
      ,mrl
      ,phi
      ,reentry_period
      ,[notes]
   FROM staging1_bak;

   --SET IDENTITY_INSERT staging1 OFF
   EXEC sp_log 2, @fn, 'leaving';
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

-- ==============================================================================
-- Author:		 Terry Watts
-- Create date: 17-JUL-2023
-- Description: copies staging1 to staging1_bak.
-- CHANGES:
-- 231103: turned auto increment off so SET IDENTITY_INSERT ON/OFF not needed
-- ==============================================================================

CREATE PROC [dbo].[sp_copy_s1_s1_bak]
AS
BEGIN
   DECLARE
       @fn              NVARCHAR(30)   = 'CPY STG1 S1_BAK'

   EXEC sp_log 2, @fn, 'starting';
   TRUNCATE TABLE staging1_bak;
   --SET IDENTITY_INSERT staging1_bak ON

   INSERT INTO [dbo].[staging1_bak]
   (
       stg1_id
      ,[company]
      ,[ingredient]
      ,[product]
      ,[concentration]
      ,[formulation_type]
      ,[uses]
      ,[toxicity_category]
      ,[registration]
      ,[expiry]
      ,[entry_mode]
      ,[crops]
      ,[pathogens]
      ,rate
      ,mrl
      ,phi
      ,reentry_period
      ,[notes]
   )
   SELECT 
       stg1_id
      ,[company]
      ,[ingredient]
      ,[product]
      ,[concentration]
      ,[formulation_type]
      ,[uses]
      ,[toxicity_category]
      ,[registration]
      ,[expiry]
      ,[entry_mode]
      ,[crops]
      ,[pathogens]
      ,rate
      ,mrl
      ,phi
      ,reentry_period
      ,[notes]
   FROM staging1;

  -- SET IDENTITY_INSERT staging1_bak OFF
   EXEC sp_log 2, @fn, 'leaving';
END
/*
EXEC sp_copy_s1_s1_bak
*/

GO
GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =========================================================================================================
-- Author:      Terry Watts
-- Create date: 03-FEB-2024
-- Description: This routine creates or drops the set of tables' FKs dependant on the @table_type parameter.
--
-- Parameters:
--       @table_type: 'main':    main tables not staging tables
--                    'staging': staging tables
--       @mode 1: create keys, 0: drop keys
-- =========================================================================================================
ALTER PROCEDURE [dbo].[sp_crt_FKs]
    @table_type NVARCHAR(60)
   ,@mode       BIT =1
AS
BEGIN
   DECLARE
    @fn                       NVARCHAR(35)   = N'CRT_FKEYS'
   ,@cursor                   CURSOR
   ,@id                       INT   = 0
   ,@fk_nm                    NVARCHAR(60)
   ,@foreign_table_nm         NVARCHAR(60)
   ,@primary_tbl_nm           NVARCHAR(60)
   ,@schema_nm                NVARCHAR(60)
   ,@fk_col_nm                NVARCHAR(60)
   ,@pk_col_nm                NVARCHAR(60)
   ,@unique_constraint_name   NVARCHAR(60)
   ,@ordinal                  INT
   ,@table_type2              NVARCHAR(60)
   ,@msg                      NVARCHAR(1000)
   ,@sql                      NVARCHAR(MAX)

   SET NOCOUNT ON;
   EXEC sp_log 2, @fn,'00: starting: table_type:[', @table_type, '] mode: [', @mode, ']';

   BEGIN TRY
      EXEC sp_log 2, @fn,'01: Starting';

      SET @cursor = CURSOR FOR
         SELECT id, fk_nm, foreign_table_nm, primary_tbl_nm, schema_nm, fk_col_nm, pk_col_nm, unique_constraint_name, ordinal, table_type
         FROM ForeignKey fk LEFT JOIN TableDef td ON fk.foreign_table_nm=td.table_nm
         WHERE table_type = @table_type
         ORDER BY id;

      OPEN @cursor;
      FETCH NEXT FROM @cursor INTO @id, @fk_nm, @foreign_table_nm, @primary_tbl_nm, @schema_nm, @fk_col_nm, @pk_col_nm, @unique_constraint_name, @ordinal, @table_type2;
      EXEC sp_log 1, @fn, '02: @@FETCH_STATUS before first fetch: [', @@FETCH_STATUS, ']';

      WHILE (@@FETCH_STATUS = 0)
      BEGIN
         EXEC sp_log 1, @fn,'
 id:       [', @id,']
,fk_nm:    [', @fk_nm,']
,f_tbl_nm :[', @foreign_table_nm,']
,p_tbl_nm: [', @primary_tbl_nm,']
,schema_nm:[', @schema_nm,']
,fk_col_nm:[', @fk_col_nm,']
,pk_col_nm:[', @pk_col_nm,']
,uq_nm:    [', @unique_constraint_name,']
,ordinal:  [', @ordinal,']
,tbl_ty2:  [', @table_type2,']'
;
         IF @mode = 1 -- CREATE FK
         BEGIN
            SET @sql = CONCAT('ALTER TABLE [',@foreign_table_nm,'] WITH CHECK ADD CONSTRAINT [',@fk_nm,'] FOREIGN KEY(',@fk_col_nm,') REFERENCES [',@primary_tbl_nm,'] (',@pk_col_nm,');');
            SET @msg = 'Creating';
            EXEC( @sql);

            SET @sql = CONCAT('ALTER TABLE [',@foreign_table_nm, '] CHECK CONSTRAINT ',@fk_nm, ';');
         END
         ELSE --  @mode = 0: drop FK
         BEGIN
            SET @msg = 'Dropping';
            SET @sql = CONCAT('ALTER TABLE [',@foreign_table_nm,'] DROP CONSTRAINT IF EXISTS  [',@fk_nm,'];');
         END

         EXEC sp_log 1, @fn, @msg, ' @fk_nm: ',@sql;
         EXEC( @sql);

         FETCH NEXT FROM @cursor INTO @id, @fk_nm, @foreign_table_nm, @primary_tbl_nm, @schema_nm, @fk_col_nm, @pk_col_nm, @unique_constraint_name, @ordinal, @table_type;
      END -- WHILE (@@FETCH_STATUS = 0) OR (@id = 0)

      EXEC sp_log 2, @fn, '07: processing corrections Completed at row: ';
      IF @id = 0 EXEC sp_raise_exception 52417, 'No rows were processed'
      EXEC sp_log 2, @fn, '40: completed processing;'
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '99: leaving, OK';
END
/*
   EXEC sp_crt_FKs 'staging', 0
   EXEC sp_crt_FKs 'staging', 1
   EXEC sp_crt_FKs 'main', 0
   EXEC sp_crt_FKs 'main', 1
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===========================================================
-- Author:      Terry Watts
-- Create date: 25-AUG-2023
-- Description: Creates or drops the main table FKs
-- Paramaters:
--       @mode 1: create fkey, : drop fkey
-- ===========================================================
ALTER PROCEDURE [dbo].[sp_crt_mn_tbl_FKs]
   @mode BIT =1
AS
BEGIN
   SET NOCOUNT ON
   DECLARE
       @fn NVARCHAR(30) = 'CRT_MN_TBL_FKS'

   EXEC sp_log 2, @fn, '01: starting';
   --EXEC sp_register_call @fn;
   EXEC sp_crt_FKs @table_type='main', @mode=@mode;
   EXEC sp_log 2, @fn, '99: leaving OK';
END
/*
EXEC sp_crt_mn_tbl_FKs @mode=1 -- 1=create
EXEC sp_crt_mn_tbl_FKs @mode=0 -- 0=drop
EXEC sp_truncate_main_tables
SELECT * FROM fkeys_vw where fk_nm NOT LIKE 'staging' AND schema_nm <> 'tSQLt'
SELECT * FROM fkeys_vw where fk_nm NOT LIKE 'staging' AND schema_nm <> 'tSQLt'
SELECT * FROM fkeys_vw where fk_nm NOT LIKE 'staging' AND schema_nm <> 'tSQLt'
SELECT * FROM ForeignKeys;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===========================================================
-- Author:		  Terry Watts
-- Create date:  05-NOV-2023
-- Description:  Helper tp create foreign keys
-- ===========================================================
ALTER PROCEDURE [dbo].[sp_crt_mn_tbl_FKs_hlpr]
       @fk_nm  NVARCHAR(100)
      ,@fk_tbl NVARCHAR(100)
      ,@fk_fld NVARCHAR(60)
      ,@pk_tbl NVARCHAR(100)
      ,@pk_fld NVARCHAR(60)
AS
BEGIN
	SET NOCOUNT ON;
   DECLARE 
       @fn        NVARCHAR(30)   = 'CRT_MN_TBL_FKS_HLPR'
      ,@sql       NVARCHAR(MAX)
      ,@rc        INT
      ,@error_msg NVARCHAR(500)

   SET @sql = CONCAT(
'ALTER TABLE [',@fk_tbl,'] WITH CHECK ADD CONSTRAINT ',@fk_nm, ' FOREIGN KEY([',@fk_fld,']) REFERENCES [',@pk_tbl,']([',@pk_fld,']);'); 

   EXEC sp_log 1, @fn, @sql;
   EXEC @rc=sp_executesql @sql;

   IF @rc<> 0
   BEGIN
      SET @error_msg = CONCAT(@fn, '50: failed to create FK, ', @error_msg);
      EXEC sp_log 4, @fn, @error_msg;
      ;THROW 587412, @error_msg, 1;
   END

   SET @sql = CONCAT('ALTER TABLE [',@fk_tbl,'] CHECK CONSTRAINT ',@fk_nm, ';');
   EXEC @rc=sp_executesql @sql;

   IF @rc<> 0
   BEGIN
      --DECLARE @error_msg NVARCHAR(500) = ut.dbo.fnGetErrorMsg();
      SET @error_msg = CONCAT(@fn, '51: ',@fk_nm, ' check failed ', ut.dbo.fnGetErrorMsg());
      EXEC sp_log 4, @fn, @error_msg;
      ;THROW 587413, @error_msg, 1;
   END

END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:     Terry Watts
-- Create date: 24-APR-2024
-- Description:exports a table to a file
-- Preconditions:
-- PRE 01: test.TestDef table populated 
-- Postconditions:                     EX
-- POST 01: the file exists OR EX 63201, 'The output file: [@file_path] does not exist
-- POST 02: write to file OK or  OR EX 63202, ''
-- =============================================
ALTER PROCEDURE [dbo].[sp_export_to_file_TstDef]
   @file_path NVARCHAR(MAX)
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn           NVARCHAR(35)   = N'sp_export_to_file_TstDef'
      ,@ret_code     INT
      ,@file_system  INT
      ,@file_exists_ NVARCHAR(35)
      ,@file_handle  INT
      ,@file_exists  INT
      ,@line_cnt     INT = 0
      ,@line         NVARCHAR(MAX)
      ,@NL           NCHAR(2)=NCHAR(13)+NCHAR(10)

   BEGIN TRY
      EXEC sp_log 2, @fn,'000: starting, params:
file  :[',@file_path,']'
;
      ----------------------------------------------------------------------------------------
      -- Validate preconditions
      ----------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'005: creating Scripting.FileSystemObject';
      EXECUTE @ret_code = sp_OACreate 'Scripting.FileSystemObject' , @file_system OUTPUT;

      IF (@@ERROR|@ret_code > 0 Or @file_system < 0)
      BEGIN
         EXEC sp_log 4, @fn,'010: could not create FileSystemObject';
         RAISERROR ('could not create FileSystemObject',16,1)
      END

      EXECUTE @ret_code = sp_OAMethod @file_system, 'FileExists', @file_exists OUTPUT, @file_path;
      SET @file_exists_ = '@file_exists = ' + CAST(@file_exists as NVARCHAR);
      EXEC sp_log 1, @fn,'015: ',@file_exists_;

      --IF @file_exists = 1
      --   RAISERROR ('file does not exist',16,1)

      --1 = for reading, 2 = for writing (will overwrite contents), 8 = for appending
      EXEC sp_log 1, @fn,'020: creating sql file to write rtn to';
      EXEC @ret_code = sp_OAMethod @file_system , 'OpenTextFile' , @file_handle OUTPUT , @file_path, 2, 1;

      IF (@@ERROR|@ret_code > 0 Or @file_handle < 0)
      BEGIN
         EXEC sp_log 4, @fn,'025: could not create sql file';
         RAISERROR ('could not create sql file',16,1);
      END

      DECLARE row_cursor CURSOR READ_ONLY FOR
         SELECT line FROM test.TstDef;

      EXEC sp_log 1, @fn,'030: opening cursor';
      OPEN row_cursor;
      FETCH NEXT FROM row_cursor INTO @line;

      WHILE (@@fetch_status = 0)
      BEGIN
         SET @line = CONCAT(@line, @NL);
         EXECUTE @ret_code = sp_OAMethod @file_handle , 'Write' , NULL , @line;

         IF (@@ERROR|@ret_code > 0)
         BEGIN
           -- POST 02: write to file OK or  OR EX 63202, ''

            EXEC sp_log 4, @fn,'040: could not write to file: @@ERROR ',@@ERROR,' @ret_code: ', RetCode;
            THROW 63202, 'could not write to file',1;
         END

         SET @line_cnt = @line_cnt + 1;
         FETCH NEXT FROM row_cursor INTO @line
      END

      CLOSE row_cursor
      DEALLOCATE row_cursor
      EXEC sp_log 1, @fn,'050: exported ', @line_cnt, ' procedure lines';

      EXEC @ret_code = sp_OAMethod @file_handle , 'Close' , NULL;

      IF (@@ERROR|@ret_code > 0) RAISERROR ('Could not close file',16,1);

      EXEC sp_OADestroy @file_system;

      --------------------------------------------------------------------------------------
      -- Check post conditions
         --------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'900: checking post conditions...';
      -- POST 01: the file exists OR EX 63201, 'The output file: [@file_path] does not exist
      EXEC sp_assert_file_exists @file_path, 'The output file: [', @file_path, '] does not exist', @ex_num=63201;

      ----------------------------------------------------------------------------------------
      --    Completed processing
      ----------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '10: Completed processing'
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '999 leaving, OK';
END
/*
EXEC tSQLt.Run 'test.test_012_sp_crt_tst_mn_compile';

EXEC tSQLt.RunAll;
*/

GO
GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===================================================
-- Author:		 Terry Watts
-- Create date: 28-JUL-2023
-- Description: sp_fixup  helper
-- ===================================================
ALTER PROCEDURE [dbo].[sp_fixup_jap_chemical_hlpr]
    @search_clause   NVARCHAR(1000)
   ,@replace_clause  NVARCHAR(1000)
   ,@case_sensitive  BIT = 0
AS
BEGIN
   DECLARE
      @fn NVARCHAR(30)=N'FIXUP_CHEMS_HLPR'

   EXEC sp_log 0, @fn, '@search_clause:[', @search_clause, '] @replace_clause:[', @replace_clause,'] cs:', @case_sensitive;

   if @case_sensitive = 1
   BEGIN
      UPDATE japChemical set name = @replace_clause WHERE name LIKE @search_clause COLLATE Latin1_General_BIN; --Latin1_General_CS_AI;
   END
   ELSE
   BEGIN
      UPDATE japChemical set name = @replace_clause WHERE name = @search_clause;
   END
END
/*
EXEC sp_fixup_jap_chemical_hlpr 'Bacillus Amyloliquefaciens', 'Bacillus Amyloliquefaciens D747 Strain'                           , 1;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:		 Terry Watts
-- Create date: 29-JUL-2023
-- Description: fixup the japChemList import
-- =============================================
ALTER PROCEDURE [dbo].[sp_fixup_jap_chemical]
AS
BEGIN
   DECLARE
      @fn NVARCHAR(30)=N'FIXUP_JAP_CHEMS'

   EXEC sp_log 0, @fn, '01: starting';
   EXEC sp_register_call @fn;
   UPDATE japChemical set type= 'HERBICIDE' WHERE name = 'Chlorthal-dimethyl' AND type NOT LIKE 'HERBICIDE'
   EXEC sp_fixup_jap_chemical_hlpr '1,3-dichloropropene', '1,3 Dichloropropene', 1;
   EXEC sp_fixup_jap_chemical_hlpr 'Bensulfuron-methyl',  'Bensulfuron-Methyl'  ,1;
   EXEC sp_fixup_jap_chemical_hlpr 'Kresoxim-methyl',     'Kresoxim-Methyl'     ,1;
   EXEC sp_fixup_jap_chemical_hlpr 'Iminoctadine tris(albesilate)', 'Iminoctadine Tris (albesilate)'
   EXEC sp_log 0, @fn, '99: leaving';
END
/*
EXEC sp_fixup_japChemList
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON


CREATE PROC [dbo].[sp_get_max_col_len_frm_staging2]
AS
BEGIN
   SELECT 
        max(ut.dbo.fnLen(company          )) as company         
      , max(ut.dbo.fnLen(ingredient       )) as ingredient      
      , max(ut.dbo.fnLen(product          )) as product         
      , max(ut.dbo.fnLen(concentration    )) as concentration   
      , max(ut.dbo.fnLen(formulation_type )) as formulation_type
      , max(ut.dbo.fnLen(uses ))             as uses 
      , max(ut.dbo.fnLen(toxicity_category)) as toxicity_category
      , max(ut.dbo.fnLen(registration ))     as registration 
      , max(ut.dbo.fnLen(expiry ))           as expiry 
      , max(ut.dbo.fnLen(entry_mode ))       as entry_mode 
      , max(ut.dbo.fnLen(crops ))            as crops 
      , max(ut.dbo.fnLen(pathogens ))        as pathogens 
      , max(ut.dbo.fnLen(notes ))            as notes 
      , max(ut.dbo.fnLen(Comment ))          as Comment 
   FROM staging2;
END
/*
EXEC sp_get_max_col_len_frm_staging2;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

-- ===============================================================================
-- Author:      Terry Watts
-- Create date: 15-MAR-2024
-- Description: Gets the import id from the file header based on its column names
-- CHANGES:
-- 
-- ===============================================================================
CREATE PROC [dbo].[sp_GetImportIdFromFile]
     @LRAP_data_file NVARCHAR(150)
    ,@import_id      INT OUT
AS
BEGIN
   DECLARE
       @fn              NVARCHAR(30)   = 'GET_IMPRT_ID_FRM_FILE'
      ,@is_xl           BIT;

   EXEC sp_log 2, @fn, 'starting';

   -- Get the header row
   SET @is_xl = Ut.dbo.IsExcel( @LRAP_data_file);
   THROW 59000, 'Implement', 1;
   EXEC sp_log 2, @fn, 'leaving';
END


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==========================================================================================================
-- Author:      Terry Watts
-- Create date: 08-OCT-2023
-- Description: Handles the bulk import of the Actions.txt file
-- It does the following:
-- 1: delete the log files
-- 2: clear the ActionStaging table
-- 3: import the the @imprt_tsv_file into the Action table
-- 4: do any fixup
-- 5: Check postconditions: ActionStaging has rows
--
-- ALGORITHM:
-- Parameter validation
-- Delete the log files if they exist
-- Clear the ActionStaging table
-- Import the file
-- Do any fixup
-- Check postconditions
--
-- PRECONDITIONS:
--    ActionStaging table dependents have been creared
--
-- POSTCONDITIONS:
-- POST01: ActionStaging must have rows
--
-- Called by: sp__main_import_pesticide_register
--
-- TESTS:
--
-- CHANGES:
-- 231103: turned auto increment off so SET IDENTITY_INSERT ON/OFF not needed
-- 240225: import from either tsv or xlsx file
-- ==========================================================================================================
ALTER PROCEDURE [dbo].[sp_import_ActionStaging]
    @import_file     NVARCHAR(500)
   ,@range           NVARCHAR(100)  = N'Sheet1$'  -- for XL: like 'Corrections_221008$A:P' OR 'Corrections_221008$'
   ,@fields          NVARCHAR(4000) = NULL  -- for XL: comma separated list
AS
BEGIN
   DECLARE
       @fn                 NVARCHAR(35)   = N'IMPRT_ActionStaging'
      ,@sql                NVARCHAR(MAX)
      ,@error_msg          NVARCHAR(MAX)  = NULL
      ,@pathogen_row_cnt   INT            = -1
      ,@update_row_cnt     INT            = -1
      ,@null_type_row_cnt  INT            = -1
      ;

   SET NOCOUNT OFF
   BEGIN TRY
      EXEC sp_log 1, @fn, '00: starting, 
@import_root:[',@import_file,']
@range      :[',@range,']
@fields     :[',@fields,']
';

      EXEC sp_register_call @fn;

      ---------------------------------------------------------------------
      -- Parameter validation
      ---------------------------------------------------------------------
      EXEC sp_log 1, @fn, '10: validation';
      EXEC sp_log 1, @fn, '20: deleting bulk import log files: D:\Logs\ActionStagingImport.log and .log.Error.Txt';

      ---------------------------------------------------------------------
      -- Process
      ---------------------------------------------------------------------
      EXEC sp_log 1, @fn, '30: process';

      EXEC sp_bulk_import 
          @import_file   = @import_file
         ,@table         = 'ActionStaging'
         ,@view          = 'Import_ActionStaging_vw'
         ,@range         = @range
         ,@fields        = 'action_id,action_nm'
         ,@clr_first     = 1;

      EXEC sp_log 1, @fn, '40: completed import OK';

      ---------------------------------------------------------------------
      -- fixup
      ---------------------------------------------------------------------
      EXEC sp_log 1, @fn, '50: Fixup';
      EXEC sp_log 1, @fn, '50: Fixup: currently no Fixup';
      -- Remove trailing tabs

      ---------------------------------------------------------------------
      -- Check postconditions
      ---------------------------------------------------------------------
      EXEC sp_log 1, @fn, '80: Check postconditions';
      -- POST01: ActionStaging must have rows
      EXEC sp_chk_tbl_populated 'ActionStaging';

      ---------------------------------------------------------------------
      -- ASSERTION: imported at least 1 row into ActionStaging
      ---------------------------------------------------------------------

      ---------------------------------------------------------------------
      -- Completed processing OK
      ---------------------------------------------------------------------
      EXEC sp_log 1, @fn, '90: completed processing OK';
   END TRY
   BEGIN CATCH
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, '50: Caught exception: ', @error_msg;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '99: leaving, OK';
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_sp_import_ActionStaging';

EXEC sp_import_ActionStaging 'D:\Dev\Repos\Farming\Data\Actions.txt';
SELECT * FROM [ActionStaging] ORDER by action_id;
SELECT * FROM ImportActionStaging_vw
3	Early post-emergent	1
Show errors in the [Action] import....
SELECT * FROM  [Action]   WHERE [type_id] IS NULL;
SELECT * FROM  [Action]   WHERE [type_nm] IS NULL;


      EXEC xp_cmdshell 'DEL D:\Logs\ActionStagingImport.log.Error.Txt', NO_OUTPUT;
      EXEC xp_cmdshell 'DEL D:\Logs\ActionStagingImport.log'          , NO_OUTPUT;

      ---------------------------------------------------------------------
      -- Clear the ActionStaging table
      ---------------------------------------------------------------------
      EXEC sp_log 1, @fn, '40: clearing ActionStaging table';
      DELETE FROM ActionStaging;

      ---------------------------------------------------------------------
      -- Import the file
      ---------------------------------------------------------------------
      EXEC sp_log 1, @fn, '50: Import the file';
      SET @sql = CONCAT(
      'BULK INSERT dbo.ImportActionStaging_vw FROM ''', @imprt_tsv_file, '''
      WITH
      (
         FIRSTROW        = 2
        ,ERRORFILE       = ''D:\Logs\ActionStagingImport.log''
        ,FIELDTERMINATOR = ''\t''
        ,ROWTERMINATOR   = ''\n''   
      );
   ');

      PRINT @sql;
      EXEC sp_log 1, @fn, '60: running bulk insert cmd';
      EXEC sp_executesql @sql;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==========================================================================================================
-- Author:      Terry Watts
-- Create date: 08-OCT-2023
-- Description: Handles the bulk import of theDistributors txt file
-- It does the following:
-- 1: imports the the distributor data into the Distributor,
-- 2: checks the post conditions
--
-- ALGORITHM:
-- Delete the log files if they exist
-- TRUNCATE the table
-- Bulk insert the file
-- Do any fixup
-- Do post condition checks
--
-- PRECONDITIONS:
-- PRE01: none
--
-- POSTCONDITIONS:
-- POST01: Distributor table must have rows
-- POST02: no trailing tabs
-- POST03: double quotes in name or address
--
-- TESTS:
--
-- CHANGES:
-- 240305: imports tsv or xlsx files
--         uses sp_bulk_import now
-- ==========================================================================================================
ALTER PROCEDURE [dbo].[sp_import_distributors]
    @import_file   NVARCHAR(500)
   ,@range         NVARCHAR(100) = 'Distributors$!A:H'
AS
BEGIN
   DECLARE
       @fn                 NVARCHAR(35)   = N'IMPRT_DISTRIBUTORS'
      ,@sql                NVARCHAR(MAX)
      ,@cmd                NVARCHAR(MAX)
      ,@error_file         NVARCHAR(400)  = NULL
      ,@error_msg          NVARCHAR(MAX)  = NULL
      ,@table_nm           NVARCHAR(35)   = 'Distributor'
      ,@rc                 INT            = -1
      ,@import_root        NVARCHAR(MAX)  
      ,@pathogen_row_cnt   INT            = -1
      ,@update_row_cnt     INT            = -1
      ,@null_type_row_cnt  INT            = -1
      ;

   SET NOCOUNT OFF
   BEGIN TRY
      EXEC sp_log 1, @fn, '00: starting, @import_file:[',@import_file,']';

      ----------------------------------------------------------------------------------
      -- Process
      ----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '05:clearing Distributor table';
      DELETE FROM Distributor;

      EXEC sp_log 1, @fn, '10:calling sp_bulk_import';
      EXEC dbo.sp_bulk_import 
          @import_file   = @import_file
         ,@table         = 'DistributorStaging'
         ,@view          = 'import_distributors_vw'
         ,@range         = @range
         ,@clr_first     = 1

      ----------------------------------------------------------------------------------
      -- Do any fixup
      ----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '15: doing fixup'

      -- Remove double quotes from address and trailing tabs from the last column
      UPDATE DistributorStaging
      SET
          distributor_name = Ut.dbo.fnTrim2(distributor_name, '"')   -- double quotes
         ,[address]        = Ut.dbo.fnTrim2([address]       , '"')   -- double quotes
         ,[phone 2]        = Ut.dbo.fnTrim ([phone 2]);              -- trailing tabs

      EXEC sp_log 1, @fn, '15: checking post conditions'

      ----------------------------------------------------------------------------------
      -- Check postconditions
      ----------------------------------------------------------------------------------
      -- POST01: Distributor table must have rows
      EXEC sp_chk_tbl_populated 'DistributorStaging';

      -- POST02: no trailing tabs
      EXEC sp_log 2, @fn, '20: chking for trailing spcs'
      IF EXISTS(SELECT 1 FROM DistributorStaging 
         WHERE 
               [distributor_name] LIKE '%'+NCHAR(09)
            OR  region   LIKE '%'+NCHAR(09)
            OR  province LIKE '%'+NCHAR(09)
            OR [address] LIKE '%'+NCHAR(09)
            OR [phone 1] LIKE '%'+NCHAR(09)
            OR [phone 2] LIKE '%'+NCHAR(09)
         )
         THROW 54871, 'At least 1 DistributorStaging table column has a trailing tab',1;

      -- POST03: double quotes in name or address
      EXEC sp_log 2, @fn, '25: chking for trailing spcs'
      IF EXISTS(SELECT 1 FROM DistributorStaging WHERE [distributor_name] LIKE '"%"'
         )
         THROW 54872, 'DistributorStaging.name has wrapping double quotes',1;

      EXEC sp_log 2, @fn, '30: chking for trailing spcs'
      IF EXISTS(SELECT 1 FROM DistributorStaging WHERE [address] LIKE '"%"')
         THROW 54873, 'DistributorStaging.[address] has wrapping double quotes',1;

      -- chk for null rows
      EXEC sp_log 2, @fn, '35: chking for chk for null fields (region,province,manufacturers)'
      SELECT @null_type_row_cnt = COUNT(*)
      FROM DistributorStaging
      WHERE region         IS NULL
         OR province       IS NULL
         OR [address]      IS NULL
         OR manufacturers  IS NULL

      EXEC sp_log 1, @fn, '40: checking POST02: DistributorStaging table has no rows with a null pathogen_type_id';
      SET @error_msg = CONCAT('15: POST02: DistributorStaging table has ',@null_type_row_cnt,' null rows');
      EXEC Ut.dbo.sp_assert_equal 0, @null_type_row_cnt, @error_msg

      EXEC sp_log 1, @fn, '45: POST CONDITION chks passed';

            ----------------------------------------------------------------------------------
      -- Copy DistributorStaging table to Distributor table
      ----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '50: Copying DistributorStaging tble to Distributor table';

      INSERT INTO Distributor ([distributor_id],[distributor_name],[region],[province],[address],[phone 1],[phone 2]) 
      SELECT [distributor_id],[distributor_name],[region],[province],[address],[phone 1],[phone 2]
      FROM DistributorStaging;
      ----------------------------------------------------------------------------------
      -- Completed processing OK
      ----------------------------------------------------------------------------------
      SET @rc = 0; -- OK
      EXEC sp_log 1, @fn, '95:completed import and fixup OK'
   END TRY
   BEGIN CATCH
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, '50: Caught exception: ', @error_msg;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '99: leaving, RC: ', @rc
   RETURN @RC;
END
/*
EXEC sp_import_distributors 'D:\Dev\Repos\Farming\Data\Distributors.xlsx',--'Distributors$'--'Distributors$!A:H';
SELECT * FROM  Distributor;
SELECT * FROM  Distributor   WHERE name IS NULL OR region is NULL OR province IS NULL OR address IS NULL;
SELECT * FROM Distributor          
WHERE 
   [name]    LIKE '%'+NCHAR(09)
OR  region   LIKE '%'+NCHAR(09)
OR  province LIKE '%'+NCHAR(09)
OR [address] LIKE '%'+NCHAR(09)
OR [phone 1] LIKE '%'+NCHAR(09)
OR [phone 2] LIKE '%'+NCHAR(09)
SELECT * FROM Distributor
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 28-JUL-2023
-- Description: import of register
-- =============================================
ALTER PROCEDURE [dbo].[sp_import_jap_chem]
AS
BEGIN
   DECLARE 
     @fn          NVARCHAR(30)  = N'IMPRT_JAP_CHEM'
    ,@row_count   INT

   EXEC sp_log 2, @fn, '00: starting';
   EXEC sp_register_call @fn;
   TRUNCATE TABLE japChemList;

   INSERT INTO JapChemical (name, [type]) VALUES
    ('1,3-dichloropropene','INSECTICIDE')
   ,('Abamectin','INSECTICIDE')
   ,('Acephate','INSECTICIDE')
   ,('Acequinocyl','INSECTICIDE')
   ,('Acetamiprid','INSECTICIDE')
   ,('Acetic and fatty acid esters of glycerol','INSECTICIDE')
   ,('Acrinathrin','INSECTICIDE')
   ,('Acynonapyr','INSECTICIDE')
   ,('Adoxphyes orana fasciata granulosis virus','INSECTICIDE')
   ,('Afidopyropen','INSECTICIDE')
   ,('Alanycarb','INSECTICIDE')
   ,('Allethrin','INSECTICIDE')
   ,('Aluminium phosphide','INSECTICIDE')
   ,('Amblydromalus limonicus (Garman & McGregor)','INSECTICIDE')
   ,('Amblyseius (Neoseiulus) californicus (McGregor)','INSECTICIDE')
   ,('Amblyseius cucumeris Oudemans','INSECTICIDE')
   ,('Amitraz','INSECTICIDE')
   ,('Aphelinus asychis Walker','INSECTICIDE')
   ,('Aphidius colemani Viereck ','INSECTICIDE')
   ,('Aphidius gifuensis (Ashmead)','INSECTICIDE')
   ,('Bacillus thuringiensis Berliner','INSECTICIDE')
   ,('Beauveria bassiana (Balsamo) Vuillemin','INSECTICIDE')
   ,('Beauveria brongniartii (Sacc.) Petch','INSECTICIDE')
   ,('Benfuracarb','INSECTICIDE')
   ,('Bensultap','INSECTICIDE')
   ,('Benzpyrimoxan','INSECTICIDE')
   ,('Bifenazate','INSECTICIDE')
   ,('Bifenthrin','INSECTICIDE')
   ,('Broflanilide','INSECTICIDE')
   ,('Buprofezin','INSECTICIDE')
   ,('Cadusafos','INSECTICIDE')
   ,('Carbaryl','INSECTICIDE')
   ,('Carbon dioxide','INSECTICIDE')
   ,('Carbosulfan','INSECTICIDE')
   ,('Cartap','INSECTICIDE')
   ,('Chlorantraniliprole','INSECTICIDE')
   ,('Chlorfenapyr','INSECTICIDE')
   ,('Chlorfluazuron','INSECTICIDE')
   ,('Chloropicrin','INSECTICIDE')
   ,('Chlorpyrifos','INSECTICIDE')
   ,('Chromafenozide','INSECTICIDE')
   ,('Chrysoperla carnea Stephens','INSECTICIDE')
   ,('Citric acid esters of mono- and diglycerides of fatty acid','INSECTICIDE')
   ,('Clofentezine','INSECTICIDE')
   ,('Clothianidin','INSECTICIDE')
   ,('Cyanophos','INSECTICIDE')
   ,('Cyantraniliprole','INSECTICIDE')
   ,('Cyclaniliprole','INSECTICIDE')
   ,('Cyenopyrafen','INSECTICIDE')
   ,('Cyflumetofen','INSECTICIDE')
   ,('Cyfluthrin','INSECTICIDE')
   ,('Cyhalothrin','INSECTICIDE')
   ,('Cypermethrin','INSECTICIDE')
   ,('Cyromazine','INSECTICIDE')
   ,('Dacnusa sibirica Telenga','INSECTICIDE')
   ,('Diafenthiuron','INSECTICIDE')
   ,('Diazinon','INSECTICIDE')
   ,('Dienochlor','INSECTICIDE')
   ,('Diflubenzuron','INSECTICIDE')
   ,('Diglyphus isaea (Walker) ','INSECTICIDE')
   ,('Dimethoate','INSECTICIDE')
   ,('Dinotefuran','INSECTICIDE')
   ,('Edible blended oil (Safflower oil, cottonseed oil)','INSECTICIDE')
   ,('Emamectine-benzoate','INSECTICIDE')
   ,('Encarsia formosa Gahan','INSECTICIDE')
   ,('Eretmocerus californicus Rose & Zolnerowich','INSECTICIDE')
   ,('Eretmocerus mundus (Mercet) ','INSECTICIDE')
   ,('Esfenvalerate','INSECTICIDE')
   ,('Ethiprole','INSECTICIDE')
   ,('Etofenprox','INSECTICIDE')
   ,('Etoxazole','INSECTICIDE')
   ,('Fenitrothion','INSECTICIDE')
   ,('Fenobucarb','INSECTICIDE')
   ,('Fenothiocarb','INSECTICIDE')
   ,('Fenpropathrin','INSECTICIDE')
   ,('Fenpyroximate','INSECTICIDE')
   ,('Fenvalerate','INSECTICIDE')
   ,('Ferric phosphate','INSECTICIDE')
   ,('Fipronil','INSECTICIDE')
   ,('Flometoquin','INSECTICIDE')
   ,('Flonicamid','INSECTICIDE')
   ,('Flubendiamide','INSECTICIDE')
   ,('Flucythrinate','INSECTICIDE')
   ,('Fluensulfone','INSECTICIDE')
   ,('Flufenoxuron','INSECTICIDE')
   ,('Flupyradifurone','INSECTICIDE')
   ,('Flupyrimin','INSECTICIDE')
   ,('Fluvalinate','INSECTICIDE')
   ,('Fluxametamide','INSECTICIDE')
   ,('Fosthiazate','INSECTICIDE')
   ,('Franklinothrips vespiformis (Craw ford)','INSECTICIDE')
   ,('Glyceryl caprylate','INSECTICIDE')
   ,('Gynaeseius liturivorus (Ehara)','INSECTICIDE')
   ,('Haplothrips brevitubus (Karny)','INSECTICIDE')
   ,('Harmonia axyridis (Pallas)','INSECTICIDE')
   ,('Hexythiazox','INSECTICIDE')
   ,('Homona magnanima granulosis virus','INSECTICIDE')
   ,('Hydrogen cyanide','INSECTICIDE')
   ,('Hydrogenated starch hydrolysate','INSECTICIDE')
   ,('Hydroxypropyl Distarch Phosphate','INSECTICIDE')
   ,('Imicyafos','INSECTICIDE')
   ,('Imidacloprid','INSECTICIDE')
   ,('Indoxacarb','INSECTICIDE')
   ,('Isoxathion','INSECTICIDE')
   ,('Lepimectin','INSECTICIDE')
   ,('Levamisole hydrochloride','INSECTICIDE')
   ,('Lufenuron','INSECTICIDE')
   ,('Malathion','INSECTICIDE')
   ,('Metaflumizone','INSECTICIDE')
   ,('Metaldehyde','INSECTICIDE')
   ,('Metam','INSECTICIDE')
   ,('Metam-sodium','INSECTICIDE')
   ,('Metarhizium anisopliae (Metschn) Sorokin','INSECTICIDE')
   ,('Methidathion','INSECTICIDE')
   ,('Methomyl','INSECTICIDE')
   ,('Methoxyfenozide','INSECTICIDE')
   ,('Methyl bromide','INSECTICIDE')
   ,('Methyl iodide','INSECTICIDE')
   ,('Methyl isothiocyanate','INSECTICIDE')
   ,('Milbemectin','INSECTICIDE')
   ,('Morantel tartrate','INSECTICIDE')
   ,('Nemadectin','INSECTICIDE')
   ,('Neochrysocharis formosa (Westwood)','INSECTICIDE')
   ,('Nesidiocoris tenuis (Reuter)','INSECTICIDE')
   ,('Nitenpyram','INSECTICIDE')
   ,('Novaluron','INSECTICIDE')
   ,('Octanoic/Decanoic glyceride ','INSECTICIDE')
   ,('Orius strigicollis (Poppius) ','INSECTICIDE')
   ,('Oxamyl','INSECTICIDE')
   ,('Oxazosulfyl ','INSECTICIDE')
   ,('Paecilomyces fumosoroseus (Wize) Brown & Smith','INSECTICIDE')
   ,('Paecilomyces tenuipes (Peck) Samson','INSECTICIDE')
   ,('Pasteuria penetrans','INSECTICIDE')
   ,('Permethrin','INSECTICIDE')
   ,('Petroleum oil','INSECTICIDE')
   ,('Phenthoate','INSECTICIDE')
   ,('Phytoseiulus persimilis Athias-Henriot','INSECTICIDE')
   ,('Polyglycerol esters of fatty acid','INSECTICIDE')
   ,('Profenofos','INSECTICIDE')
   ,('Propargite','INSECTICIDE')
   ,('Propylea japonica (Thunberg)','INSECTICIDE')
   ,('Propylene glycol fatty acid monoester','INSECTICIDE')
   ,('Prothiofos','INSECTICIDE')
   ,('Pyflubumide','INSECTICIDE')
   ,('Pymetrozine','INSECTICIDE')
   ,('Pyrethrins','INSECTICIDE')
   ,('Pyridaben','INSECTICIDE')
   ,('Pyridalyl','INSECTICIDE')
   ,('Pyrifluquinazon','INSECTICIDE')
   ,('Pyrimidifen','INSECTICIDE')
   ,('Pyriproxyfen','INSECTICIDE')
   ,('Rape seed oil','INSECTICIDE')
   ,('Sodium Oleate','INSECTICIDE')
   ,('Sorbitane fatty acid ester','INSECTICIDE')
   ,('Spinetoram','INSECTICIDE')
   ,('Spinosad','INSECTICIDE')
   ,('Spirodiclofen','INSECTICIDE')
   ,('Spiromesifen','INSECTICIDE')
   ,('Spirotetramat','INSECTICIDE')
   ,('Spodoptera litura Nucleopolyhedrovirus','INSECTICIDE')
   ,('Starch','INSECTICIDE')
   ,('Steinernema carpocapsae','INSECTICIDE')
   ,('Steinernema glaseri','INSECTICIDE')
   ,('Sulfoxaflor','INSECTICIDE')
   ,('Sulfuryl fluoride','INSECTICIDE')
   ,('Tebufenozide','INSECTICIDE')
   ,('Tebufenpyrad','INSECTICIDE')
   ,('Teflubenzuron','INSECTICIDE')
   ,('Tefluthrin','INSECTICIDE')
   ,('Tetradifon','INSECTICIDE')
   ,('Tetraniliprole','INSECTICIDE')
   ,('Thiacloprid','INSECTICIDE')
   ,('Thiamethoxam','INSECTICIDE')
   ,('Thiocyclam','INSECTICIDE')
   ,('Thiodicarb','INSECTICIDE')
   ,('Thphlodromips swirskii (Athias-Henriot) ','INSECTICIDE')
   ,('Tolfenpyrad','INSECTICIDE')
   ,('Trichlorfon','INSECTICIDE')
   ,('Triflumezopyrim','INSECTICIDE')
   ,('Ttralomethrin','INSECTICIDE')
   ,('Verticillium lecanii (Zimmerman) Viegas','INSECTICIDE')
   ,('Acibenzolar-S-methyl','FUNGICIDE')
   ,('Ambam','FUNGICIDE')
   ,('Ametoctradin','FUNGICIDE')
   ,('Amisulbrom','FUNGICIDE')
   ,('Azoxystrobin','FUNGICIDE')
   ,('Bacillus amyloliquefaciens','FUNGICIDE')
   ,('Bacillus simplex','FUNGICIDE')
   ,('Bacillus subtilis','FUNGICIDE')
   ,('Benomyl','FUNGICIDE')
   ,('Benthiavalicarb-isopropyl','FUNGICIDE')
   ,('Boscalid','FUNGICIDE')
   ,('Brewed vinegar','FUNGICIDE')
   ,('Calcium polysulfide','FUNGICIDE')
   ,('Captan','FUNGICIDE')
   ,('Chinomethionat','FUNGICIDE')
   ,('Chlorothalonil','FUNGICIDE')
   ,('Coniothyrium minitans Campbell','FUNGICIDE')
   ,('Copper hydroxide ','FUNGICIDE')
   ,('Copper oxychloride','FUNGICIDE')
   ,('Copper sulfate','FUNGICIDE')
   ,('Copper sulfate anhydride','FUNGICIDE')
   ,('Copper sulfate, basic','FUNGICIDE')
   ,('Cyazofamid','FUNGICIDE')
   ,('Cyflufenamid','FUNGICIDE')
   ,('Cymoxanil','FUNGICIDE')
   ,('Cyproconazole','FUNGICIDE')
   ,('Cyprodinil','FUNGICIDE')
   ,('Dazomet','FUNGICIDE')
   ,('DBEDC','FUNGICIDE')
   ,('Dichlobentiazox','FUNGICIDE')
   ,('Diethofencarb','FUNGICIDE')
   ,('Difenoconazole','FUNGICIDE')
   ,('Diflumetorim','FUNGICIDE')
   ,('Dimethomorph','FUNGICIDE')
   ,('Distilled liquid smoke flavouring acetic acid','FUNGICIDE')
   ,('Dithianon','FUNGICIDE')
   ,('Erwinia carotovora subsp. carotovora avirulent strain','FUNGICIDE')
   ,('Ethaboxam','FUNGICIDE')
   ,('Extract of Lentinus edodes mycelia','FUNGICIDE')
   ,('Famoxadone','FUNGICIDE')
   ,('Fenarimol','FUNGICIDE')
   ,('Fenbuconazole','FUNGICIDE')
   ,('Fenhexamid','FUNGICIDE')
   ,('Fenpyrazamine','FUNGICIDE')
   ,('Ferimzone','FUNGICIDE')
   ,('Fluazinam','FUNGICIDE')
   ,('Fludioxonil','FUNGICIDE')
   ,('Fluopicolide','FUNGICIDE')
   ,('Fluopyram','FUNGICIDE')
   ,('Fluoroimide','FUNGICIDE')
   ,('Fluoxastrobin','FUNGICIDE')
   ,('Flusulfamide','FUNGICIDE')
   ,('Flutianil','FUNGICIDE')
   ,('Flutolanil','FUNGICIDE')
   ,('Fluxapyroxad','FUNGICIDE')
   ,('Folpet','FUNGICIDE')
   ,('Fosetyl','FUNGICIDE')
   ,('Fthalide','FUNGICIDE')
   ,('Fumaric acid','FUNGICIDE')
   ,('Furametpyr','FUNGICIDE')
   ,('Glucan extracted from brewing yeast','FUNGICIDE')
   ,('Hexaconazole','FUNGICIDE')
   ,('Hymexazol','FUNGICIDE')
   ,('Hymexazol-potassium ','FUNGICIDE')
   ,('Imibenconazole','FUNGICIDE')
   ,('Iminoctadine triacetate','FUNGICIDE')
   ,('Iminoctadine tris(albesilate) ','FUNGICIDE')
   ,('Inpyrfluxam','FUNGICIDE')
   ,('Ipconazole','FUNGICIDE')
   ,('ipflufenoquin','FUNGICIDE')
   ,('Iprobenfos','FUNGICIDE')
   ,('Iprodione','FUNGICIDE')
   ,('Isofetamid','FUNGICIDE')
   ,('Isoprothiolane','FUNGICIDE')
   ,('Isopyrazam','FUNGICIDE')
   ,('Isotianil','FUNGICIDE')
   ,('Kasugamycin','FUNGICIDE')
   ,('Kresoxim-methyl','FUNGICIDE')
   ,('Lactobacillus Plantarum','FUNGICIDE')
   ,('Mancozeb','FUNGICIDE')
   ,('Mandestrobin','FUNGICIDE')
   ,('Mandipropamid','FUNGICIDE')
   ,('Maneb','FUNGICIDE')
   ,('Mepanipyrim','FUNGICIDE')
   ,('Mepronil','FUNGICIDE')
   ,('Metalaxyl','FUNGICIDE')
   ,('Metalaxyl-M','FUNGICIDE')
   ,('Metyltetraprole','FUNGICIDE')
   ,('Metconazole','FUNGICIDE')
   ,('Metominostrobin','FUNGICIDE')
   ,('Myclobutanil','FUNGICIDE')
   ,('Nonylphenol sulfonic acid copper (II) salt','FUNGICIDE')
   ,('Oxathiapiprolin','FUNGICIDE')
   ,('Oxine-copper','FUNGICIDE')
   ,('Oxolinic acid','FUNGICIDE')
   ,('Oxpoconazole fumarate','FUNGICIDE')
   ,('Oxytetracycline','FUNGICIDE')
   ,('Pefurazoate','FUNGICIDE')
   ,('Pencycuron','FUNGICIDE')
   ,('Penflufen','FUNGICIDE')
   ,('Penthiopyrad','FUNGICIDE')
   ,('Picarbutrazox','FUNGICIDE')
   ,('Picoxystrobin','FUNGICIDE')
   ,('Polyoxins','FUNGICIDE')
   ,('Polyoxorim-zinc','FUNGICIDE')
   ,('Potassium hydrogencarbonate','FUNGICIDE')
   ,('Probenazole','FUNGICIDE')
   ,('Prochloraz','FUNGICIDE')
   ,('Procymidone','FUNGICIDE')
   ,('Propamocarb-hydrochloride','FUNGICIDE')
   ,('Propiconazole','FUNGICIDE')
   ,('Propineb','FUNGICIDE')
   ,('Prothioconazole','FUNGICIDE')
   ,('Pseudomonas fluorescens (Flügge) Migula','FUNGICIDE')
   ,('Pseudomonas rhodesiae Coroler, et al','FUNGICIDE')
   ,('Pydiflumetofen','FUNGICIDE')
   ,('Pyraclostrobin','FUNGICIDE')
   ,('Pyraziflumid','FUNGICIDE')
   ,('Pyribencarb','FUNGICIDE')
   ,('Pyriofenone','FUNGICIDE')
   ,('Pyroquilon','FUNGICIDE')
   ,('Sedaxane','FUNGICIDE')
   ,('Silver','FUNGICIDE')
   ,('Simeconazole','FUNGICIDE')
   ,('Sodium bicarbonate','FUNGICIDE')
   ,('Streptomycin','FUNGICIDE')
   ,('Sulfur','FUNGICIDE')
   ,('Talaromyces flavus (Klöcker) Stolk & Samson','FUNGICIDE')
   ,('Tebuconazole','FUNGICIDE')
   ,('Tebufloquin','FUNGICIDE')
   ,('Tetraconazole','FUNGICIDE')
   ,('Thifluzamide','FUNGICIDE')
   ,('Thiophanate-methyl','FUNGICIDE')
   ,('Thiuram','FUNGICIDE')
   ,('Tiadinil','FUNGICIDE')
   ,('Tolclofos-methyl','FUNGICIDE')
   ,('Tolprocarb','FUNGICIDE')
   ,('Trichoderma atroviride','FUNGICIDE')
   ,('Tricyclazole','FUNGICIDE')
   ,('Trifloxystrobin','FUNGICIDE')
   ,('Triflumizole','FUNGICIDE')
   ,('Triforine','FUNGICIDE')
   ,('Triticonazole','FUNGICIDE')
   ,('Validamycin','FUNGICIDE')
   ,('Variovorax paradoxus','FUNGICIDE')
   ,('Ziram','FUNGICIDE')
   ,('Zucchini yellow mosaic virus attenuated strain ','FUNGICIDE')
   ,('2,4-D-dimethylammonium','HERBICIDE')
   ,('2,4-D-ethyl','HERBICIDE')
   ,('2,4-D-isopropylammonium','HERBICIDE')
   ,('2,4-D-sodium monohydrate','HERBICIDE')
   ,('Alachlor','HERBICIDE')
   ,('Amicarbazone','HERBICIDE')
   ,('Asulam','HERBICIDE')
   ,('Atrazine','HERBICIDE')
   ,('Azimsulfuron','HERBICIDE')
   ,('Benfluralin','HERBICIDE')
   ,('Benfuresate','HERBICIDE')
   ,('Bensulfuron-methyl','HERBICIDE')
   ,('Bentazone-sodium','HERBICIDE')
   ,('Benzobicyclon','HERBICIDE')
   ,('Benzofenap','HERBICIDE')
   ,('Bispyribac-sodium','HERBICIDE')
   ,('Bromacil','HERBICIDE')
   ,('Bromobutide','HERBICIDE')
   ,('Butachlor','HERBICIDE')
   ,('Butamifos','HERBICIDE')
   ,('Cafenstrole','HERBICIDE')
   ,('Carfentrazone-ethyl','HERBICIDE')
   ,('Chloridazon','HERBICIDE')
   ,('Chlorimuron-ethyl','HERBICIDE')
   ,('Chlorphthalim','HERBICIDE')
   ,('Chlorpropham','HERBICIDE')
   ,('Chlorthiamid','HERBICIDE')
   ,('Clethodim','HERBICIDE')
   ,('Clomeprop','HERBICIDE')
   ,('Cumyluron','HERBICIDE')
   ,('Cyanazine','HERBICIDE')
   ,('Cyclopyrimorate','HERBICIDE')
   ,('Cyclosulfamuron','HERBICIDE')
   ,('Cyhalofop-butyl','HERBICIDE')
   ,('Daimuron','HERBICIDE')
   ,('Desmedipham','HERBICIDE')
   ,('Dicamba','HERBICIDE')
   ,('Dicamba-dimethylammonium','HERBICIDE')
   ,('Dicamba-potassium','HERBICIDE')
   ,('Dichlobenil','HERBICIDE')
   ,('Diflufenican','HERBICIDE')
   ,('Dimethametryn','HERBICIDE')
   ,('Dimethenamid','HERBICIDE')
   ,('Dimethenamid-P','HERBICIDE')
   ,('Diquat','HERBICIDE')
   ,('Dithiopyr','HERBICIDE')
   ,('Diuron','HERBICIDE')
   ,('D-Limonene','HERBICIDE')
   ,('Endothal-dipotassium','HERBICIDE')
   ,('Esprocarb','HERBICIDE')
   ,('Ethoxysulfuron','HERBICIDE')
   ,('Etobenzanid','HERBICIDE')
   ,('Fenoxasulfone','HERBICIDE')
   ,('Fenquinotrione','HERBICIDE')
   ,('Fentrazamide','HERBICIDE')
   ,('Flazasulfuron','HERBICIDE')
   ,('Florasulam','HERBICIDE')
   ,('Florpyrauxifen-benzyl','HERBICIDE')
   ,('Fluazifop-P-butyl ','HERBICIDE')
   ,('Flucetosulfuron','HERBICIDE')
   ,('Flufenacet','HERBICIDE')
   ,('Flumioxazin','HERBICIDE')
   ,('Flupoxam','HERBICIDE')
   ,('Flupropanate-sodium','HERBICIDE')
   ,('Fluthiacet-methyl','HERBICIDE')
   ,('Foramsulfuron','HERBICIDE')
   ,('Glufosinate','HERBICIDE')
   ,('Glufosinate-P-sodium','HERBICIDE')
   ,('Glyphosate-ammonium','HERBICIDE')
   ,('Glyphosate-isopropylammonium ','HERBICIDE')
   ,('Glyphosate-potassium','HERBICIDE')
   ,('Glyphosate-sodium','HERBICIDE')
   ,('Halosulfuron-methyl','HERBICIDE')
   ,('Hexazinone','HERBICIDE')
   ,('Imazamox-ammonium','HERBICIDE')
   ,('Imazapyr','HERBICIDE')
   ,('Imazaquin','HERBICIDE')
   ,('Imazosulfuron','HERBICIDE')
   ,('Indanofan','HERBICIDE')
   ,('Indaziflam','HERBICIDE')
   ,('Iodosulfuron-methyl-sodium','HERBICIDE')
   ,('Ioxynil','HERBICIDE')
   ,('Ipfencarbazone','HERBICIDE')
   ,('Isouron','HERBICIDE')
   ,('Isoxaben','HERBICIDE')
   ,('Karbutilate','HERBICIDE')
   ,('Lancotrione sodium','HERBICIDE')
   ,('Lenacil','HERBICIDE')
   ,('Linuron','HERBICIDE')
   ,('MCPA-ethyl','HERBICIDE')
   ,('MCPA-isopropylamine','HERBICIDE')
   ,('MCPA-sodium','HERBICIDE')
   ,('MCPB-ethyl','HERBICIDE')
   ,('Mecoprop-dimethylammonium','HERBICIDE')
   ,('Mecoprop-P-isopropylammonium','HERBICIDE')
   ,('Mecoprop-potassium','HERBICIDE')
   ,('Mecoprop-P-potassium','HERBICIDE')
   ,('Mefenacet','HERBICIDE')
   ,('Mesotrione','HERBICIDE')
   ,('Metamifop','HERBICIDE')
   ,('Metamitron','HERBICIDE')
   ,('Metazosulfuron','HERBICIDE')
   ,('Methiozolin','HERBICIDE')
   ,('Metolachlor','HERBICIDE')
   ,('Metribuzin','HERBICIDE')
   ,('Metsulfuron-methyl','HERBICIDE')
   ,('Napropamide','HERBICIDE')
   ,('Nicosulfuron','HERBICIDE')
   ,('Oryzalin','HERBICIDE')
   ,('Oxadiargyl','HERBICIDE')
   ,('Oxadiazon','HERBICIDE')
   ,('Oxaziclomefone','HERBICIDE')
   ,('Paraquat','HERBICIDE')
   ,('Pelargonic acid','HERBICIDE')
   ,('Pelargonic acid potassium salt','HERBICIDE')
   ,('Pendimethalin','HERBICIDE')
   ,('Penoxsulam','HERBICIDE')
   ,('Pentoxazone','HERBICIDE')
   ,('Phenmedipham','HERBICIDE')
   ,('Pretilachlor','HERBICIDE')
   ,('Prodiamine','HERBICIDE')
   ,('Prometryn','HERBICIDE')
   ,('Propanil','HERBICIDE')
   ,('Propyrisulfuron','HERBICIDE')
   ,('Propyzamide','HERBICIDE')
   ,('Prosulfocarb','HERBICIDE')
   ,('Pyraclonil','HERBICIDE')
   ,('Pyraflufen-ethyl','HERBICIDE')
   ,('Pyrazolynate','HERBICIDE')
   ,('Pyrazosulfuron-ethyl','HERBICIDE')
   ,('Pyrazoxyfen','HERBICIDE')
   ,('Pyributicarb','HERBICIDE')
   ,('Pyriftalid','HERBICIDE')
   ,('Pyriminobac-methyl','HERBICIDE')
   ,('Pyrimisulfan','HERBICIDE')
   ,('Pyroxasulfone','HERBICIDE')
   ,('Quinoclamine','HERBICIDE')
   ,('Quizalofop-ethyl','HERBICIDE')
   ,('Rimsulfuron','HERBICIDE')
   ,('Sethoxydim','HERBICIDE')
   ,('Simazine','HERBICIDE')
   ,('Simetryn','HERBICIDE')
   ,('S-metolachlor','HERBICIDE')
   ,('Sodium chlorate','HERBICIDE')
   ,('Sodium cyanate','HERBICIDE')
   ,('Tebuthiuron','HERBICIDE')
   ,('Tefuryltrione','HERBICIDE')
   ,('Tepraloxydim','HERBICIDE')
   ,('Terbacil','HERBICIDE')
   ,('Thenylchlor','HERBICIDE')
   ,('Thiencarbazone-methyl','HERBICIDE')
   ,('Thifensulfuron-methyl','HERBICIDE')
   ,('Thiobencarb','HERBICIDE')
   ,('Tolpyralate','HERBICIDE')
   ,('Topramezone','HERBICIDE')
   ,('Triafamone','HERBICIDE')
   ,('Triaziflam','HERBICIDE')
   ,('Triclopyr-butoxyethyl ','HERBICIDE')
   ,('Triclopyr-triethylammonium','HERBICIDE')
   ,('Trifloxysulfuron-sodium','HERBICIDE')
   ,('Trifluralin','HERBICIDE')
   ,('1-Methylcyclopropene','PLANT GROWTH REGULATOR')
   ,('1-naphthaleneacetic acid, sodium salt','PLANT GROWTH REGULATOR')
   ,('1-Naphthyl acetamide','PLANT GROWTH REGULATOR')
   ,('4-CPA','PLANT GROWTH REGULATOR')
   ,('Abscisic acid','PLANT GROWTH REGULATOR')
   ,('Benzyl adenine ','PLANT GROWTH REGULATOR')
   ,('Butralin','PLANT GROWTH REGULATOR')
   ,('Calcium chloride','PLANT GROWTH REGULATOR')
   ,('Calcium formate','PLANT GROWTH REGULATOR')
   ,('Calcium peroxide','PLANT GROWTH REGULATOR')
   ,('Calcium sulfate','PLANT GROWTH REGULATOR')
   ,('Chlormequat','PLANT GROWTH REGULATOR')
   ,('Chlorthal-dimethyl','PLANT GROWTH REGULATOR')
   ,('Cholin','PLANT GROWTH REGULATOR')
   ,('Cyanamide','PLANT GROWTH REGULATOR')
   ,('Daminozide','PLANT GROWTH REGULATOR')
   ,('Decyl alcohol','PLANT GROWTH REGULATOR')
   ,('Dichlorprop','PLANT GROWTH REGULATOR')
   ,('Ethephon','PLANT GROWTH REGULATOR')
   ,('Ethychlozate','PLANT GROWTH REGULATOR')
   ,('Extracts from mixed crude drugs','PLANT GROWTH REGULATOR')
   ,('Flurprimidol','PLANT GROWTH REGULATOR')
   ,('Forchlorfenuron','PLANT GROWTH REGULATOR')
   ,('Gibberellin','PLANT GROWTH REGULATOR')
   ,('Indolebutyric acid','PLANT GROWTH REGULATOR')
   ,('Itaconic acid','PLANT GROWTH REGULATOR')
   ,('Maleic hydrazide','PLANT GROWTH REGULATOR')
   ,('Mepiquat chloride','PLANT GROWTH REGULATOR')
   ,('Paclobutrazol','PLANT GROWTH REGULATOR')
   ,('Paraffin','PLANT GROWTH REGULATOR')
   ,('Prohexadione-calcium','PLANT GROWTH REGULATOR')
   ,('Prohydrojasmom','PLANT GROWTH REGULATOR')
   ,('Sorbitan trioleate','PLANT GROWTH REGULATOR')
   ,('Trinexapac-ethyl','PLANT GROWTH REGULATOR')
   ,('Uniconazole-P','PLANT GROWTH REGULATOR')
   ,('Chlorophacinone','RODENTICIDE')
   ,('Diphacinone','RODENTICIDE')
   ,('Warfarin','RODENTICIDE')
   ,('Zinc phosphide','RODENTICIDE')
   ,('Alemalure (pheromone)','OTHERS')
   ,('Armigelure (pheromone)','OTHERS')
   ,('Beetarmylure (pheromone)','OTHERS')
   ,('Bluwelure (pheromone)','OTHERS')
   ,('Calcium carbonate','OTHERS')
   ,('Calcium cyanamide','OTHERS')
   ,('Calcium oxide','OTHERS')
   ,('Cuelure (pheromone)','OTHERS')
   ,('Cossinlure (pheromone)','OTHERS')
   ,('Diamolure (pheromone)','OTHERS')
   ,('Diashilure (pheromone)','OTHERS')
   ,('Fallweblure (pheromone)','OTHERS')
   ,('Infelure (pheromone)','OTHERS')
   ,('Lawculure (pheromone)','OTHERS')
   ,('Litlure (pheromone)','OTHERS')
   ,('Methyl eugenol','OTHERS')
   ,('Okimelanolure (pheromone)','OTHERS')
   ,('Orfralure (pheromone)','OTHERS')
   ,('Peachflure (pheromone)','OTHERS')
   ,('Pirimalure (pheromone)','OTHERS')
   ,('Quercivolure (pheromone)','OTHERS')
   ,('Sakimelamolure (pheromone)','OTHERS')
   ,('Sweet vilure (pheromone)','OTHERS')
   ,('Synanthelure (pheromone)','OTHERS')
   ,('Tortorilure (pheromone)','OTHERS')
   ,('Uwabalure (pheromone)','OTHERS')
   ,('Whole egg powder','OTHERS');

   SET @row_count = @@ROWCOUNT;
   EXEC sp_log 1, @fn, '99: leaving OK, inserted ',@row_count, ' rows';
END
/*
EXEC sp_import_jap_chem
SELECT * FROM JapChemList order by id
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================
-- Author:      Terry Watts
-- Create date: 15-MAR-2024
-- Description:
--    Imports the LRAP data xls file, format spec = 221018
--
-- PRECONDITIONS: 
-- file format spec = 221018
-- S1 and S2 are truncted
--
-- POSTCONDITIONS:
-- POST 01: S1 populated, s2 not
--
-- RESPONSIBILITIES:
-- R01: Clear the S1 and S2 tables
-- R02: Import the LRAP data file
-- R03: assign the import id to new data
--
-- TESTS:
--
-- CHANGES:
-- 
-- ======================================================================================
ALTER PROCEDURE [dbo].[sp_import_LRAP_file_xls_230721]
    @LRAP_data_file  NVARCHAR(150) -- the tab separated LRAP data file
   ,@range           NVARCHAR(100)  = N'Sheet1$'
AS
BEGIN
   DECLARE
    @fn              NVARCHAR(35)   = 'IMPRT_LRAP_FILE_XLS_230721'
   ,@row_cnt         INT

   EXEC sp_log 1, @fn, '00: starting
LRAP_data_file:[',@LRAP_data_file,']
range:         [',@range,']';

   EXEC sp_register_call @fn;

   --------------------------------------------------------------------
   -- Processing start'
   --------------------------------------------------------------------
   SET @range = ut.dbo.fnFixupXlRange(@range);

   ----------------------------------------------------------------------------
   -- 1. import the LRAP register file using the appropriate format importer
   ----------------------------------------------------------------------------
   -- 230721: new format
      EXEC sp_log 2, @fn, '15: import the LRAP register file (221018 fmt)';
      EXEC sp_bulk_import 
          @import_file  = @LRAP_data_file
         ,@table        = 'Staging1'
         ,@range        = @range
         ,@fields       = NULL         -- for XL: comma separated list
         ,@clr_first    = 1            -- if 1 then delete the table contents first
         ,@is_new       = 0            -- if 1 then create the table - this is a double check
         ,@expect_rows  = 1            -- optional @expect_rows to assert has imported rows
         ,@row_cnt      = @row_cnt OUT  -- optional count of imported rows
         ;

   --------------------------------------------------------------------
   -- Processing complete'
   --------------------------------------------------------------------
   EXEC sp_log 2, @fn,'80: processing complete';
END
   EXEC sp_log 1, @fn, '99: leaving';
/*
EXEC sp_import_LRAP_file_xls_230721 'D:\Dev\Repos\Farming\Data\LRAP-231025-231103.xlsx';
SELECT * FROM staging1;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 08-OCT-2023
-- Description: Handles the bulk import of the PathogenType.xlsx/txt file
-- NB this is the STATIC DATA: pathogen types not the dynamic data: pathogenTypeStaging
-- the list of pthogen types - Fungus, insec, mollusc
--
-- ALGORITHM:
--    Delete the log files if they exist
--    TRUNCATE the table
--    Bulk insert the file
--    Check the table is populated
--    Do any fixup
--
-- PRECONDITIONS:
--    PathogenTypeStaging table dependents have been creared
--
-- POSTCONDITIONS:
-- POST01: PathogenTypeStaging populated AND retur= 0 or RC = error code
--
-- CALLED BY: 
--
-- TESTS:
--
-- CHANGES:
-- 231103: turned auto increment off so SET IDENTITY_INSERT ON/OFF not needed
-- 240223: import either tsv or xlsx
-- ==============================================================================
ALTER PROCEDURE [dbo].[sp_import_pathogenTypeStaging]
    @import_file   NVARCHAR(500)
AS
BEGIN
   DECLARE
       @fn  NVARCHAR(35)  = N'IMPRT PATHOGENTYPE STAGING'
      ,@sql NVARCHAR(MAX)
      ,@error_msg NVARCHAR(MAX) = NULL
      ,@import_root NVARCHAR(MAX)
      ;

   SET NOCOUNT OFF
   BEGIN TRY
      SET @import_root = Ut.dbo.fnGetImportRoot();
      EXEC sp_log 1, @fn, '00: starting, @import_file: [',@import_file,']';

      EXEC sp_register_call @fn;
      EXEC sp_log 1, @fn, '05: deleting bulk import log files:  D:\Logs\ImportPathogenType_SD.log and .log.Error.Txt';

      EXEC xp_cmdshell 'DEL D:\Logs\ImportPathogenType.log.Error_SD.Txt', NO_OUTPUT;
      EXEC xp_cmdshell 'DEL D:\Logs\ImportPathogenType_SD.log'          , NO_OUTPUT;

      EXEC sp_log 1, @fn, '10: clearing PathogenTypeStaging table';
      DELETE FROM PathogenTypeStaging;

      -------------------------------------------------------------------------------------------
      -- 240223: import either tsv or xlsx
      -------------------------------------------------------------------------------------------
      IF( CHARINDEX('.xlsx', @import_file) = 0)
      BEGIN
         -- csv file
         EXEC sp_log 1, @fn, '15: importing tsv file';

      SET @sql = CONCAT(
     'BULK INSERT [dbo].[PathogenTypeStaging] FROM ', @import_file, '
      WITH
      (
         FIRSTROW        = 2
        ,ERRORFILE       = ''D:\Logs\ImportPathogenType_SD.log''
        ,FIELDTERMINATOR = ''\t''
        ,ROWTERMINATOR   = ''\n''
      );
   ');
      END
      ELSE
      BEGIN
         -- xlsx file
         EXEC sp_log 1, @fn, '20: importing xlsx file';
         SET @sql = Ut.dbo.fnCrtOpenRowsetSqlForXlsx('PathogenTypeStaging', 'id, Pathogen, [Type]', @import_file, 'PathogenType$', 0);
      END
      --------------------------------- END  240223: import either tsv or xlsx ----------------------

      EXEC sp_log 1, @fn, '25: running import cmd';
      EXEC sp_log 1, @fn, @sql;
      EXEC sp_executesql @sql;
      --EXEC sp_log 1, @fn, '30: completed bulk import cmd OK, recreating relation: FK_Pathogen_PathogenType';

      EXEC sp_log 1, @fn, '35';

      -------------------------------------------------------------------------------
      -- Check post conditions
      -------------------------------------------------------------------------------
      -- Check the table is populated
      EXEC sp_chk_tbl_populated 'PathogenTypeStaging';

      -------------------------------------------------------------------------------
      -- Completed processing OK
      -------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '40: completed processing OK';
   END TRY
   BEGIN CATCH
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, '50: Caught exception: ', @error_msg;
      ALTER TABLE [dbo].[Pathogen]  WITH CHECK ADD  CONSTRAINT [FK_Pathogen_PathogenType] FOREIGN KEY([pathogen_type_id])  REFERENCES [dbo].[PathogenType] ([id]);
      ALTER TABLE [dbo].[Pathogen] CHECK CONSTRAINT [FK_Pathogen_PathogenType];
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '99: leaving OK';
END
/*
EXEC sp_import_pathogenTypeStaging 'D:\Dev\Repos\Farming\Data\PathogenType.txt';
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ========================================================
-- Author:      Terry Watts
-- Create date: 19-JUN-2023
-- Description: imports all the Pesticide Register files
-- 
-- PRECONDITIONS: none
--
-- POSTCONDITIONS:
--    Ready to call the fixup routne
--
-- ERROR HANDLING by exception handling
-- ========================================================
ALTER PROCEDURE [dbo].[sp_import_pesticide_register_221008]
AS
BEGIN
   DECLARE
        @fn          NVARCHAR(35)  = N'BLK_IMPRT_PEST_REG_221008'
       ,@cnt         INT
       ,@rc          INT
       ,@result_msg  NVARCHAR(500)
       ,@import_root NVARCHAR(500)

   exec sp_log 2, @fn, '01 starting';
   EXEC sp_register_call @fn;
   SET @result_msg = '';
   SET @import_root = CONCAT(ut.dbo.fnGetImportRoot(), 'Exports Ph DepAg Registered Pesticides LRAP-221018.pdf\TSVs', NCHAR(92));

   TRUNCATE TABLE dbo.staging1;
   TRUNCATE TABLE dbo.staging2;

   -- Import all files
   EXEC @rc = [dbo].sp_bulk_insert_pesticide_register_221018  'Ph DepAg Registered Pesticides LRAP-221018 001-099.tsv'; IF @RC <> 0 THROW 60000, '[sp_bulk_insert_pesticide_register]: unhandled error', 1;
   EXEC @rc = [dbo].sp_bulk_insert_pesticide_register_221018  'Ph DepAg Registered Pesticides LRAP-221018 100-199.tsv'; IF @RC <> 0 THROW 60000, '[sp_bulk_insert_pesticide_register]: unhandled error', 1;
   EXEC @rc = [dbo].sp_bulk_insert_pesticide_register_221018  'Ph DepAg Registered Pesticides LRAP-221018 200-299.tsv'; IF @RC <> 0 THROW 60000, '[sp_bulk_insert_pesticide_register]: unhandled error', 1;
   EXEC @rc = [dbo].sp_bulk_insert_pesticide_register_221018  'Ph DepAg Registered Pesticides LRAP-221018 300-399.tsv'; IF @RC <> 0 THROW 60000, '[sp_bulk_insert_pesticide_register]: unhandled error', 1;
   EXEC @rc = [dbo].sp_bulk_insert_pesticide_register_221018  'Ph DepAg Registered Pesticides LRAP-221018 400-499.tsv'; IF @RC <> 0 THROW 60000, '[sp_bulk_insert_pesticide_register]: unhandled error', 1;
   EXEC @rc = [dbo].sp_bulk_insert_pesticide_register_221018  'Ph DepAg Registered Pesticides LRAP-221018 500-599.tsv'; IF @RC <> 0 THROW 60000, '[sp_bulk_insert_pesticide_register]: unhandled error', 1;
   EXEC @rc = [dbo].sp_bulk_insert_pesticide_register_221018  'Ph DepAg Registered Pesticides LRAP-221018 600-699.tsv'; IF @RC <> 0 THROW 60000, '[sp_bulk_insert_pesticide_register]: unhandled error', 1;
   EXEC @rc = [dbo].sp_bulk_insert_pesticide_register_221018  'Ph DepAg Registered Pesticides LRAP-221018 700-799.tsv'; IF @RC <> 0 THROW 60000, '[sp_bulk_insert_pesticide_register]: unhandled error', 1;
   EXEC @rc = [dbo].sp_bulk_insert_pesticide_register_221018  'Ph DepAg Registered Pesticides LRAP-221018 800-819.tsv'; IF @RC <> 0 THROW 60000, '[sp_bulk_insert_pesticide_register]: unhandled error', 1;

   SELECT @cnt = count(*) from dbo.staging1;
   PRINT CONCAT('Imported ', @cnt, ' including header rows'); -- 23524 rows currently 20-JUN-2023
   exec sp_log 2, @fn, '99 leaving, ret: ', @rc;
   RETURN @RC;
END

/*
EXEC dbo.[sp_import_Ph DepAg Registered Pesticides LRAP];
SELECT COUNT(*) FROM TEMP WHERE SHT <101
SELECT book, COUNT(*) FROM TEMP GROUP BY book order by book
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==========================================================================================================
-- Author:      Terry Watts
-- Create date: 28-FEB-2024
-- Description: Handles the import of the TableType table
-- It does the following:
-- 1: delete the log files
-- 2: clear the ActionStaging table
-- 3: import the the @imprt_tsv_file into the Action table
-- 4: do any fixup
-- 5: Check postconditions: ActionStaging has rows
--
-- ALGORITHM:
-- Parameter validation
-- Delete the log files if they exist
-- Clear the TableType table
-- Import the file
-- Do any fixup
-- Check postconditions
--
-- PRECONDITIONS:
--    TableType table dependants have been cleared
--
-- POSTCONDITIONS:
-- POST01: TableType must have rows
--
-- Called by: ?? sp_import_static_data
--
-- TESTS:
--
-- CHANGES:
-- ==========================================================================================================
ALTER PROCEDURE [dbo].[sp_import_TableType]
    @import_file     NVARCHAR(500)
   ,@range           NVARCHAR(100)  = N'TableType$A:B'  -- for XL: like 'Table$' OR 'Table$A:B'
AS
BEGIN
   DECLARE
        @fn          NVARCHAR(35)  = N'IMPRT_TBL_TY'

   EXEC sp_log 2, @fn, '01 starting
@import_file:[',@import_file,']
@range      :[',@range      ,']'
;

   EXEC sp_bulk_import 
       @import_file   = @import_file
      ,@table         = 'TableType'
      ,@view          = NULL
      ,@range         = @range
      ,@fields        = 'id,name'
      ,@clr_first     = 1
      ,@is_new        = 0;
END
/*
EXEC sp_import_TableType 'D:\Dev\Repos\Farming\Data\TableDef.xlsx','TableType$A:B';
SELECT * FROM TableType;
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_sp_import_TableType';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==========================================================================================================
-- Author:      Terry Watts
-- Create date: 31-OCT-2023
-- Description: Handles the bulk import of the [use] table
--
-- ALGORITHM:
-- 1: delete the log files if they exist
-- 2: bulk insert the UseStaging file
-- 3: do any fixup
-- 4: Check postconditions: ActionStaging has rows
--
-- PRECONDITIONS:
--   PRE 01: UseStaging table and its dependants have been cleared
--
-- POSTCONDITIONS:
-- POST01: UseStaging table must have rows
-- POST02: ChemicalUse and ProductUse will be truncated
-- TESTS: test.sp_import_use_staging
--
-- CHANGES:
-- 231103: turned auto increment off so SET IDENTITY_INSERT ON/OFF not needed
-- ==========================================================================================================
ALTER PROCEDURE [dbo].[sp_import_UseStaging]
    @imprt_tsv_file   NVARCHAR(500)
AS
BEGIN
   DECLARE
       @fn                 NVARCHAR(35)   = N'IMPRT_UseStaging'
      ,@sql                NVARCHAR(MAX)
      ,@error_msg          NVARCHAR(MAX)  = NULL
      ,@rc                 INT            = -1
      ,@import_root        NVARCHAR(MAX)
      ,@pathogen_row_cnt   INT            = -1
      ,@update_row_cnt     INT            = -1
      ,@null_type_row_cnt  INT            = -1
      ;

   SET NOCOUNT OFF
   BEGIN TRY
      EXEC sp_log 1, @fn, '01: starting, @import_root:[',@import_root,']';
      EXEC sp_register_call @fn;

      ---------------------------------------------------------------------------------
      -- Validation
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '02: validation';

      -- PRE 01: UseStaging table dependants have been cleared
      DELETE FROM UseStaging;
      EXEC sp_chk_tbl_not_populated 'UseStaging';

      ---------------------------------------------------------------------------------
      -- Init
      ---------------------------------------------------------------------------------

      SET @import_root = Ut.dbo.fnGetImportRoot();
      EXEC sp_log 1, @fn, '03: deleting bulk import log files:  D:\Logs\UseStagingImport.log and .log.Error.Txt'

      EXEC xp_cmdshell 'DEL D:\Logs\UseStagingImport.log.Error.Txt', NO_OUTPUT;
      EXEC xp_cmdshell 'DEL D:\Logs\UseStagingImport.log'          , NO_OUTPUT;

      --EXEC sp_log 1, @fn, '02: Clearing the staging tables';
      --EXEC sp_clear_staging_tables;

      ---------------------------------------------------------------------------------
      -- Import
      ---------------------------------------------------------------------------------
      SET @sql = CONCAT(
   'BULK INSERT dbo.Import_UseStaging_vw FROM ''', @imprt_tsv_file, '''
      WITH
      (
         FIRSTROW        = 2
        ,ERRORFILE       = ''D:\Logs\UseStagingImport.log''
        ,FIELDTERMINATOR = ''\t''
        ,ROWTERMINATOR   = ''\n''   
      );
   ');

      PRINT @sql;
      EXEC sp_log 1, @fn, '05: running bulk insert cmd';
      EXEC @rc = sp_executesql @sql;

      IF @rc <> 0 THROW 56874, '06: sp_executesql failed', 1;

      EXEC sp_log 1, @fn, '07: completed bulk import cmd OK';
      -- Do any fixup

      ---------------------------------------------------------------------------------
      -- Postcondition checks
      ---------------------------------------------------------------------------------
      -- POST01: UseStaging must have rows
      EXEC sp_chk_tbl_populated 'UseStaging';

      ---------------------------------------------------------------------------------
      -- Processing completed OK
      ---------------------------------------------------------------------------------
      SET @rc = 0; -- OK
      EXEC sp_log 1, @fn, '95:completed UseStaging import and fixup OK';
   END TRY
   BEGIN CATCH
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, '50: Caught exception: ', @error_msg;
      --SET IDENTITY_INSERT [Use] ON;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '99: leaving OK, RC: ', @rc
   RETURN @RC;
END
/*
EXEC tSQLt.Run 'test.test_sp_import_useStaging';
EXEC sp_import_useStaging 'D:\Dev\Repos\Farming\Data\Use.txt'
SELECT * FROM useStaging;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===================================================================
-- Author:		 Terry Watts
-- Create date: 31-JUL-2023
-- Description: Investigator for chemical name sync
-- ===================================================================
ALTER PROCEDURE [dbo].[sp_investigate_chemical]
   @name NVARCHAR(250)
AS
BEGIN
SELECT distinct name as JapName                    FROM JapChemical  WHERE name        LIKE CONCAT('%',@name,'%');
SELECT distinct chemical_nm                        FROM Chemical     WHERE chemical_nm LIKE CONCAT('%',@name,'%'); 
SELECT distinct ingredient as staging2_name        FROM Staging2     WHERE ingredient  LIKE CONCAT('%',@name,'%');
SELECT distinct ingredient as staging1_name        FROM Staging1     WHERE ingredient  LIKE CONCAT('%',@name,'%');

SELECT 
    stg2_id
   ,ingredient
   ,uses
   ,crops
   ,pathogens
FROM Staging2     
WHERE ingredient  LIKE CONCAT('%',@name,'%');
END
/*
EXEC dbo.sp_investigate_chemical 'Glyphosate%potassium'
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==================================================================
-- Author:		 Terry Watts
-- Create date: 03-AUG-2023
-- Description: returns the different matches and
--    the match counts for the given criteria
--    caller must add THE %_ wild cards as necessary
--
-- Forms a query with the were clause like:
--    where (a [or b][ or c]) ([and not d] [and not e] [and not f])
--
-- CHANGES:
-- 230812: remove book,sht,row as these are no longer used
-- 231006: updated with staging id field name convention change
-- ==================================================================
ALTER PROCEDURE [dbo].[sp_investigate_s2_crops]
    @where_subclause1   NVARCHAR(MAX)                -- must have characters
   ,@where_subclause2   NVARCHAR(MAX)  = NULL
   ,@where_subclause3   NVARCHAR(MAX)  = NULL
   ,@not_clause1        NVARCHAR(MAX)  = NULL
   ,@not_clause2        NVARCHAR(MAX)  = NULL
   ,@not_clause3        NVARCHAR(MAX)  = NULL
   ,@case_sensitve      BIT            = 0 -- case insensitve
   ,@crop               NVARCHAR(30)   = NULL
AS
BEGIN
   DECLARE 
       @fn                       NVARCHAR(35)  = N'INVESTIGATE S2 CROPS'
      ,@sql                      NVARCHAR(MAX)
      ,@where_clause             NVARCHAR(MAX)
      ,@ids                      NVARCHAR(MAX)
      ,@msg                      NVARCHAR(MAX)
      ,@nl                       NVARCHAR(2) = /*NCHAR(0x0a) + */NCHAR(0x0d)
      ,@collate_clause           NVARCHAR(200)
      ,@len                      INT
      ,@len1                     INT
      ,@len2                     INT

   --SET XACT_ABORT ON;

   EXEC sp_log 1, @fn,'01: starting: 
@where_subclause1 : [', @where_subclause1 , ']
@where_subclause2 : [', @where_subclause2 , ']
@where_subclause3 : [', @where_subclause3 , ']
@not_clause1      : [', @not_clause1 , ']
@not_clause2      : [', @not_clause2 , ']
@not_clause3      : [', @not_clause3 , ']
@case_sensitve    : [', @case_sensitve    , ']';

   BEGIN TRY
      -- Tidy parameters  EXEC sp_log 2, @fn,'';
      EXEC sp_log 2, @fn,'02: Tidy parameters';
      SET @where_subclause1= dbo.fnScrubParameter(@where_subclause1);
      SET @where_subclause2= dbo.fnScrubParameter(@where_subclause2);
      SET @where_subclause3= dbo.fnScrubParameter(@where_subclause3);
      SET @not_clause1     = dbo.fnScrubParameter(@not_clause1 );
      SET @not_clause2     = dbo.fnScrubParameter(@not_clause2 );
      SET @not_clause3     = dbo.fnScrubParameter(@not_clause3 );
      SET @collate_clause  = iif(@case_sensitve = 0, 'COLLATE Latin1_General_CI_AI', 'COLLATE Latin1_General_CS_AI');

      -- Validating:
      EXEC sp_log 1, @fn,'03: Validating';
      IF Ut.dbo.fnLen(@where_subclause1) = 0 THROW 53478, 'sp_list_occurence_counts: @where_subclause1 must be specified', 1;

      -- Get max field lens
      EXEC sp_log 1, @fn,'04: Get max field lens';
      SELECT @len1 = MAX(ut.dbo.fnLen(crops))
      FROM
      (
      SELECT DISTINCT [crops]
         FROM [Staging2]
         WHERE crops LIKE @where_clause
      ) R;

      SELECT @len2 = MAX(ut.dbo.fnLen(crops))
      FROM
      (
      SELECT DISTINCT crops
         FROM staging2
         WHERE crops LIKE @where_clause
      ) R;

      SET @len = iif(@len1>@len2,@len1,@len2);

      ------------------------------------------------------------------
      -- Build the where clause:
      ------------------------------------------------------------------
      EXEC sp_log 1, @fn,'05: Build the where clause';
      SET @where_clause = CONCAT( '([#field#] LIKE     ''',  @where_subclause1, ''' ', @collate_clause);
      IF @where_subclause2 IS NOT NULL SET @where_clause = CONCAT(@where_clause,  @nl, '   OR [#field#] LIKE     ''', @where_subclause2, ''' ', @collate_clause);
      IF @where_subclause3 IS NOT NULL SET @where_clause = CONCAT(@where_clause,  @nl, '   OR [#field#] LIKE     ''', @where_subclause3, ''' ', @collate_clause);
   
      -- Close off the OR bracket
      EXEC sp_log 1, @fn,'06: Close off the OR bracket';
      SET @where_clause = CONCAT( @where_clause,' )');
      IF @not_clause1  IS NOT NULL SET @where_clause = CONCAT( @where_clause, @nl, '   AND [#field#] NOT LIKE ''', @not_clause1, ''' ', @collate_clause);
      IF @not_clause2  IS NOT NULL SET @where_clause = CONCAT( @where_clause, @nl, '   AND [#field#] NOT LIKE ''', @not_clause2, ''' ', @collate_clause);
      IF @not_clause2  IS NOT NULL SET @where_clause = CONCAT( @where_clause, @nl, '   AND [#field#] NOT LIKE ''', @not_clause3, ''' ', @collate_clause);
 
      IF @crop IS NOT NULL SET @where_clause = CONCAT( @where_clause, @nl, '   AND crops like ''%', @crop, '%''');
      ------------------------------------------------------------------

      EXEC sp_log 1, @fn,'07: where clause  :', @where_clause;
      EXEC sp_log 1, @fn,'08: creating SQL  : the count sql for the staging 2 table';
      --SET @sql = dbo.fnCrtSqlForListOccurencesOld('staging2', @field, @where_clause);
      EXEC sp_log 2, @fn,'08.1: fnCrtSqlForListOccurences params: (''staging2'', ''crops'' @where_clause:[', @where_clause, '], @len: ',@len, ')';
      SET @sql = dbo.fnCrtSqlForListOccurences('staging2', 'crops', @where_clause, @len);
      EXEC sp_log 1, @fn,'9: executing sql ', @nl, @sql;
      EXEC (@sql);
      EXEC sp_log 1, @fn,'10: executed sql ';
      EXEC sp_log 1, @fn,'11:  creating SQL 2: the count sql for the staging 1 table';

      SET @sql = dbo.fnCrtSqlForListOccurences('staging1', 'crops', @where_clause, @len);
      EXEC sp_log 1, @fn,'12: executing sql 2', @nl, @sql;
      EXEC (@sql);
      EXEC sp_log 1, @fn,'13: executed sql ';
      SET @where_clause = REPLACE(@where_clause, '#field#', 'crops');
      EXEC sp_log 1, @fn,'14: creating SQL 3: agg ids sql, where clause: ', @where_clause;
      -- agg ids
      SET @sql = dbo.fnGetIdsInTablesForCriteriaSql('staging1', 'stg1_id', 'staging2', 'stg2_id', @where_clause);
      EXEC sp_log 1, @fn,'15: executing sql (agg ids)', @nl, @sql;
      EXEC sp_executesql @sql, N'@ids NVARCHAR(MAX) OUT', @ids OUT
      EXEC sp_log 1, @fn,'16: executed sql @ids:(', @ids, ')';

      EXEC sp_log 1, @fn,'17: creating SQL 4: the S12_vew on the ids';
      IF @ids IS not NULL
      BEGIN
         SET @sql = CONCAT(
            'SELECT s2.stg2_id , s1.stg1_id',@nl
            ,', CONCAT(''['',s2.[','crops],'']'') as s2_crops'
            ,', s2.uses as s2_uses'
            ,', s2.ingredient'
            ,', CONCAT(''['',s1.[','crops','],'']'') as s1_crops'
            ,', s1.uses as s1_uses'
            ,', S1.ingredient, s2.notes 
            FROM staging2 S2 
            FULL JOIN staging1 S1 on (S2.stg2_id=s1.stg1_id)
            WHERE s1.stg1_id in (',@ids,')
            AND   s2.stg2_id in (',@ids,')
            ORDER BY S1.stg1_id;');

         EXEC sp_log 1, @fn,'18: executing sql (agg ids)', @nl, @sql;
         EXEC(@sql)
      END
      ELSE
      BEGIN
         EXEC sp_log 1, @fn,'19: No ids were found';
      END
   END TRY
   BEGIN CATCH
      SET @msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn,'20: *** caught exception: ', @msg;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn,'21: leaving OK' 
END
/*
EXEC sp_investigate_s2_crops '%Banana (Cavendish) as bunch spray%'
Cucurbits (Cucumbermelon,squash,
Rice (Direct Seeded PreGerminated)
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==================================================================
-- Author:		 Terry Watts
-- Create date: 05-MaAY-2023
-- Description: returns the different matches and
--    the match counts for the given criteria
--    caller must add THE %_ wild cards as necessary
--
-- Forms a query with the were clause like:
--    where (a [or b][ or c]) ([and not d] [and not e] [and not f])
--
-- CHANGES:
-- 231010: added validation @where_subclause1 must have characters
--         maintainance: fixed breaking changes
-- 231019: general tidyup of commented out code
-- ==================================================================
ALTER PROCEDURE [dbo].[sp_investigate_s2_pathogens]
    @where_subclause1   NVARCHAR(MAX)                -- must have characters
   ,@where_subclause2   NVARCHAR(MAX)  = NULL
   ,@where_subclause3   NVARCHAR(MAX)  = NULL
   ,@not_clause1        NVARCHAR(MAX)  = NULL
   ,@not_clause2        NVARCHAR(MAX)  = NULL
   ,@not_clause3        NVARCHAR(MAX)  = NULL
   ,@case_sensitve      BIT            = 0 -- case insensitve
   ,@crop               NVARCHAR(30)   = NULL
AS
BEGIN
   DECLARE 
       @fn                       NVARCHAR(20)  = N'INV S2 PATHOGENS'
      ,@sql                      NVARCHAR(MAX)
      ,@where_clause             NVARCHAR(MAX)
      ,@ids                      NVARCHAR(MAX)
      ,@msg                      NVARCHAR(MAX)
      ,@nl                       NVARCHAR(2) = /*NCHAR(0x0a) + */NCHAR(0x0d)
      ,@collate_clause           NVARCHAR(200)
      ,@len                      INT
      ,@len1                     INT
      ,@len2                     INT

   --SET XACT_ABORT ON;

   EXEC sp_log 2, @fn,'01: starting: 
@where_subclause1 : [', @where_subclause1 , ']
@where_subclause2 : [', @where_subclause2 , ']
@where_subclause3 : [', @where_subclause3 , ']
@where_subclause1 : [', @where_subclause1 , ']
@where_subclause2 : [', @where_subclause2 , ']
@where_subclause3 : [', @where_subclause3 , ']
@case_sensitve    : [', @case_sensitve    , ']';
--@field            : [', @field            , ']

   BEGIN TRY
      -- VALIDATION:
      -- 231010: added validation @where_subclause1 must have characters
      IF @where_subclause1 IS NULL OR Ut.dbo.fnLen(@where_subclause1) = 0 THROW 52314, '@where_subclause1 must be defined', 1;

      -- Tidy parameters  EXEC sp_log 2, @fn,'';
      EXEC sp_log 2, @fn,'02: Tidy parameters';
      SET @where_subclause1= dbo.fnScrubParameter(@where_subclause1);
      SET @where_subclause2= dbo.fnScrubParameter(@where_subclause2);
      SET @where_subclause3= dbo.fnScrubParameter(@where_subclause3);
      SET @not_clause1     = dbo.fnScrubParameter(@not_clause1 );
      SET @not_clause2     = dbo.fnScrubParameter(@not_clause2 );
      SET @not_clause3     = dbo.fnScrubParameter(@not_clause3 );
      SET @collate_clause  = iif(@case_sensitve = 0, 'COLLATE Latin1_General_CI_AI', 'COLLATE Latin1_General_CS_AI');

      -- Validating:
      EXEC sp_log 2, @fn,'03: Validating';
      IF Ut.dbo.fnLen(@where_subclause1) = 0 THROW 53478, 'sp_list_occurence_counts: @where_subclause1 must be specified', 1;

      SELECT S2.stg2_id as [stg2_id (sub clause 1)], s2.pathogens as s2_pathogens, pathogen as s2_pathogen from dbo.fnListPathogens2() F 
      JOIN staging2 s2 on s2.stg2_id = F.id 
      JOIN staging1 s1 on s1.stg1_id  = S2.stg2_id 
      WHERE pathogen like @where_subclause1;

      If @where_subclause2 IS NOT NULL
         SELECT S2.stg2_id as [stg2_id (sub clause 2)], s2.pathogens as s2_pathogens, pathogen as s2_pathogen from dbo.fnListPathogens2() F 
         JOIN staging2 s2 on s2.stg2_id = F.id 
         JOIN staging1 s1 on s1.stg1_id  = S2.stg2_id 
         WHERE pathogen like @where_subclause2;

      If @where_subclause3 IS NOT NULL
         SELECT S2.stg2_id as [stg2_id (sub clause 3)], s2.pathogens, pathogen from dbo.fnListPathogens2() F 
         JOIN staging2 s2 on s2.stg2_id = F.id 
         JOIN staging1 s1 on s1.stg1_id  = S2.stg2_id 
         WHERE pathogen like @where_subclause3;

      ------------------------------------------------------------------
      -- Build the where clause:
      ------------------------------------------------------------------
      EXEC sp_log 2, @fn,'04: Build the where clause';
      SET @where_clause = CONCAT( '(pathogens LIKE     ''',  @where_subclause1, ''' ', @collate_clause);
      IF @where_subclause2 IS NOT NULL SET @where_clause = CONCAT(@where_clause,  @nl, '   OR pathogens LIKE     ''', @where_subclause2, ''' ', @collate_clause);
      IF @where_subclause3 IS NOT NULL SET @where_clause = CONCAT(@where_clause,  @nl, '   OR pathogens LIKE     ''', @where_subclause3, ''' ', @collate_clause);
   
      -- Close off the OR bracket
      EXEC sp_log 2, @fn,'05: Close off the OR bracket';
      SET @where_clause = CONCAT( @where_clause,' )');
      EXEC sp_log 2, @fn,'05.1: where clause:', @nl, @where_clause;

      IF @not_clause1 IS NOT NULL SET @where_clause = CONCAT( @where_clause, @nl, '   AND pathogens NOT LIKE ''', @not_clause1, ''' ', @collate_clause);
      IF @not_clause2 IS NOT NULL SET @where_clause = CONCAT( @where_clause, @nl, '   AND pathogens NOT LIKE ''', @not_clause2, ''' ', @collate_clause);
      IF @not_clause2 IS NOT NULL SET @where_clause = CONCAT( @where_clause, @nl, '   AND pathogens NOT LIKE ''', @not_clause3, ''' ', @collate_clause);
 
      EXEC sp_log 2, @fn,'05.2: where clause:', @nl, @where_clause;
      IF @crop IS NULL SET @where_clause = CONCAT( @where_clause, @nl, '   AND crops like ''%', @crop, '%''');
      ------------------------------------------------------------------

      EXEC sp_log 2, @fn,'06: where clause:', @nl, @where_clause;

      -- Get max field lens
      EXEC sp_log 2, @fn,'07: Get max field length';
      SET @sql = CONCAT( '  SELECT @len1 = MAX(ut.dbo.fnLen(pathogens))
      FROM
      (
      SELECT DISTINCT pathogens
         FROM staging1
         WHERE ',@where_clause,'
      ) R;'
      );

      EXEC sp_log 2, @fn,'08: executing sql ', @nl, @sql;
      EXEC sp_executesql @sql, N'@len1 INT OUT', @len1 OUT

      SET @sql = CONCAT( ' SELECT @len2 = MAX(ut.dbo.fnLen(pathogens))
      FROM
      (
      SELECT DISTINCT pathogens
         FROM staging2
         WHERE ', @where_clause, '
      ) R;'
      );

      EXEC sp_log 2, @fn,'09: executing sql ', @nl, @sql;
      EXEC sp_executesql @sql, N'@where_clause NVARCHAR(MAX), @len2 INT OUT', @where_clause, @len2 OUT
      SET @len = iif(@len1>@len2,@len1,@len2);
      EXEC sp_log 2, @fn,'10: calling fnCrtSqlForListOccurences(''staging2'')';
      SET @sql = dbo.fnCrtSqlForListOccurences('staging2', 'pathogens', @where_clause, @len);
      EXEC sp_log 2, @fn,'11: executing sql ', @nl, @sql;
      EXEC (@sql);
      EXEC sp_log 2, @fn,'12: executed sql ';

      SET @sql = dbo.fnCrtSqlForListOccurences('staging1', 'pathogens', @where_clause, @len);
      EXEC sp_log 2, @fn,'13: executing sql ', @nl, @sql;
      EXEC (@sql);
      EXEC sp_log 2, @fn,'14: executed sql ';
      -- agg ids
      SET @where_clause = REPLACE(@where_clause, '#field#', 'pathogens');

      SET @sql = dbo.fnGetIdsInTablesForCriteriaSql('staging1', 'stg1_id', 'staging2', 'stg2_id',  @where_clause);
      EXEC sp_log 2, @fn,'15: executing sql (agg ids)', @nl, @sql;
      EXEC sp_executesql @sql, N'@ids NVARCHAR(MAX) OUT', @ids OUT
      EXEC sp_log 2, @fn,'16: executed sql @ids:(', @ids, ')';

      IF @ids IS not NULL
      BEGIN
         SET @sql = CONCAT(
            'SELECT 
    s2.stg2_id , s1.stg1_id 
   , s2.pathogens as s2_pathogens
   , s1.pathogens as s1_pathogens
   , S1.ingredient, S1.crops, s2.notes
FROM staging2 S2 
FULL JOIN staging1 S1 on (S2.stg2_id=s1.stg1_id)
WHERE s1.stg1_id in (',@ids,')
AND   s2.stg2_id in (',@ids,')
ORDER BY S1.stg1_id;');

         EXEC sp_log 2, @fn,'17: executing sql (agg ids)', @nl, @sql;
         EXEC(@sql)
      END
      ELSE
      BEGIN
         EXEC sp_log 2, @fn,'18: No Rows were found in either table for the given criteria';
      END
   END TRY
   BEGIN CATCH
      SET @msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn,'50: *** caught exception: ', @msg;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn,'99: leaving' 
END
/*
EXEC sp_investigate_s2_pathogens 'Worm',@not_clause1=' Worm'
select pathogens from staging2 where stg2_id in (19,64,357,554,588,683,695,895) 
select pathogens from staging1 where stg1_id in (19,64,357,554,588,683,695,895) 
SELECT stg2_id, pathogens from Staging2 where pathogens like '%,worm%'
---------------------------------------
231011-0345:
pathogen_nm
---------------------------------------
As foot 
Cabagge moth
Golden apple Snails
Anthracnose fruit rot leaf spot
Cadelle beetle beetles
Coconut coconut nut rot  
Confused flour beetles
Cotton cotton leafworm
Diamondback moth caterpillar
Egyptian cotton cotton leafworm
Mango mango tip borer
Sugarcane sugarcane white grub
---------------------------------------
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 09-MAr-2024
-- Description: convenient wrapper for fnListApplog
--
-- Parameters:    Mandatory,optional M/O
-- @import_file  [O] the import source file can be a tsv or xlsx file
-- @fnFilter     [O] -- DEFAULT = ALL
-- @msgFilter    [O] -- DEFAULT = ALL
-- @idFilter     [O] -- DEFAULT = ALL
-- @levelFilter  [O] -- DEFAULT = ALL
-- @asc          [O] -- DEFAULT = DESC, 1= ASC, 0=desc
--
-- Preconditions: none
--
-- Postconditions:
-- POST01:
--
-- ======================================================================================================
ALTER PROCEDURE [dbo].[sp_list_AppLog]
    @fnFilter     NVARCHAR(50)   = NULL  -- DEFAULT = ALL
   ,@msgFilter    NVARCHAR(128)  = NULL  -- DEFAULT = ALL
   ,@minIdFilter  INT            = NULL  -- DEFAULT = ALL
   ,@maxIdFilter  INT            = NULL  -- DEFAULT = ALL
   ,@levelFilter  INT            = NULL  -- DEFAULT = ALL
   ,@asc          BIT            = NULL  -- DEFAULT = ASC, 1= ASC, 0=desc
   ,@top          INT            = NULL
AS
BEGIN
   DECLARE
    @fn              NVARCHAR(30)  = N'FIXUP S1 MRL HLPR'
   ,@sql             NVARCHAR(MAX)
   ,@fnFilterClause  NVARCHAR(MAX)

   IF @asc IS NULL SET @asc = 1; -- DEFAULT = ASC
   SELECT @fnFilterClause = CONCAT('''', string_agg(ut.dbo.fnTrim(value), ''','''), '''') from string_split(@fnFilter, ',');

   SET @sql = CONCAT
   (
'SELECT '
, IIF(@top IS NOT NULL, CONCAT('Top ', @top), '')
,'          id
         ,[level]
         ,row_count
         ,fn
         ,[msg                                                                                                                            .]
         ,[msg2                                                                                                                           .]
         ,[msg3                                                                                                                           .]
         ,[msg4                                                                                                                           .]
      FROM applog_vw_', iif(@asc = 1, 'asc', 'desc')
      -- only add these clauses if there is at least on predicate
      -- add 'AND ' if there was a preceding predicate clause
      , IIF(    @fnFilter    IS NULL
            AND @msgFilter   IS NULL
            AND @minIdFilter IS NULL
            AND @maxIdFilter IS NULL
            AND @levelFilter IS NULL, '', CONCAT(NCHAR(13),'WHERE'))

      , iif(@fnFilter    IS NULL, '', CONCAT(NCHAR(13), ' fn IN (' , @fnFilterClause,')'))
      , iif(@msgFilter   IS NULL, '', CONCAT(NCHAR(13),iif(@fnFilter IS NULL, '', 'AND ')
            ,'CONCAT([msg                                                                                                                            .]
                    ,[msg2                                                                                                                           .]) LIKE @msgFilter'))
      , iif(@minIdFilter IS NULL, '', CONCAT(NCHAR(13),iif(@fnFilter IS NULL AND @msgFilter IS NULL, '', 'AND '),' id >= ', @minIdFilter))
      , iif(@maxIdFilter IS NULL, '', CONCAT(NCHAR(13),iif(@fnFilter IS NULL AND @msgFilter IS NULL AND @minIdFilter IS NULL , '', 'AND '),' id <= ', @maxIdFilter))
      , iif(@levelFilter IS NULL, '', CONCAT(NCHAR(13),iif(@fnFilter IS NULL AND @msgFilter IS NULL AND @minIdFilter IS NULL AND @maxIdFilter IS NULL, '', 'AND '), '[level] >= '     , @levelFilter))

      , CONCAT(NCHAR(13),'ORDER BY id ', iif(@asc='1', 'ASC', 'DESC'))
   );

   PRINT @sql;
   EXEC sp_executesql @sql, N'@fnFilter NVARCHAR(50), @msgFilter NVARCHAR(128), @minIdFilter INT, @maxIdFilter INT, @levelFilter INT'
   , @fnFilter, @msgFilter, @minIdFilter,@maxIdFilter, @levelFilter;
END
/*
EXEC tSQLt.Run 'test.test_086_sp_list_AppLog';
EXEC sp_list_AppLog                       -- LIST ALL desc
EXEC sp_list_AppLog 'MN_IMPORT', @asc=1   -- LIST the main import rtn, asc 
EXEC sp_list_AppLog 'MN_IMPORT,POP STG TBLS', @asc=1   -- LIST the main import rtn, asc 
EXEC sp_list_AppLog 'MN_IMPORT,POP STG TBLS', @idFilter = 2000, @asc=1   -- LIST the main import rtn, asc 
EXEC sp_list_AppLog 'MN_IMPORT,POP STG TBLS', @idFilter = 2000, @asc=1   -- LIST the main import rtn, asc 

EXEC sp_list_AppLog        -- LIST ALL 
EXEC sp_list_AppLog        -- LIST ALL 
EXEC sp_list_AppLog        -- LIST ALL 

   SET @sql = CONCAT
   (
'SELECT
          id
         ,fn
         ,CONCAT([msg                                                                                                                            .]
         ,[msg2                                                                                                                           .]) AS msg
         ,[level]
         ,row_count
      FROM applog_vw_', iif(@asc = 1, 'asc', 'desc')
      -- only put where when there is at least on predicate
      , IIF(@fnFilter    IS NULL AND @msgFilter IS NULL AND @idFilter IS NULL AND @levelFilter IS NULL, '', CONCAT(NCHAR(13),'WHERE'))
      , iif(@fnFilter    IS NULL, '', CONCAT(NCHAR(13), ' fn IN (' , @fnFilterClause,')'))
      , iif(@msgFilter   IS NULL, '', CONCAT(NCHAR(13),iif(@fnFilter IS NULL, '', 'AND '),'[msg                                                                                                                            .] LIKE @msgFilter'))
      , iif(@idFilter    IS NULL, '', CONCAT(NCHAR(13),iif(@fnFilter IS NULL AND @msgFilter IS NULL, '', 'AND '),' id >= ', @idFilter))
      , iif(@levelFilter IS NULL, '', CONCAT(NCHAR(13),iif(@fnFilter IS NULL AND @msgFilter IS NULL AND @idFilter IS NULL, '', 'AND '), '[level] >= '     , @levelFilter))
      , CONCAT(NCHAR(13),'ORDER BY id ', iif(@asc='1', 'ASC', 'DESC'))
   );
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =====================================================
-- Author:      Terry Watts
-- Create date: 31-MAR-2024
-- Description: lists all rows for all staging tables
--
-- CHANGES:
-- 231007:removed row limit, added order by clause
-- 231007: added views where ids only
-- =====================================================
ALTER PROCEDURE [dbo].[sp_list_main_table_rows]
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @cmd       NVARCHAR(4000)
      ,@table_nm  NVARCHAR(32) = 'CropStaging' -- ActionStaging,

/*   SET @cmd='SELECT CONCAT(''SELECT * FROM ['',table_nm,'']'') FROM TableDef WHERE table_type=''staging''';
   PRINT @cmd;
   EXEC (@cmd);
   */
   DROP TABLE If EXISTS temp;
   SET @cmd = CONCAT('SELECT '''' AS [',@table_nm, '],* FROM [',@table_nm,']');
   PRINT CONCAT('@cmd:
', @cmd);

   -----------------------------------------------------------------
   SELECT x.cmd INTO temp
   FROM 
   (
      SELECT CONCAT('SELECT '''' AS [',table_nm, '],* FROM [',table_nm,']') as cmd 
      FROM TableDef WHERE table_type='main'
   ) X

   -- SELECT * FROM temp;

   -----------------------------------------------------------------
   DECLARE @cursor CURSOR

   SET @cursor = CURSOR FOR
      SELECT cmd from temp

   OPEN @cursor;
   FETCH NEXT FROM @cursor INTO @cmd;

   WHILE (@@FETCH_STATUS = 0)
   BEGIN
      EXEC(@cmd);
      FETCH NEXT FROM @cursor INTO @cmd;
   END
END
/*
EXEC sp_list_main_table_rows;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

-- ===========================================================================================
-- Author:      Terry Watts
-- Create date: 25-JUNE-2023
-- Description: useful as a search for corrections, lists the crops and the occurrences of the 
--              pathogen_clause in the staging table
-- ===========================================================================================
CREATE PROC [dbo].[sp_list_staging]
   @where_subclause1 NVARCHAR(100), 
   @where_subclause2 NVARCHAR(100)=NULL, 
   @where_subclause3 NVARCHAR(100)=NULL, 
   @and_not_clause1  NVARCHAR(200)=NULL,
   @and_not_clause2  NVARCHAR(200)=NULL,
   @and_not_clause3  NVARCHAR(200)=NULL,
   @top              INT = 100
AS
BEGIN
   DECLARE 
       @sql                      NVARCHAR(MAX)
      ,@select_clause            NVARCHAR(MAX)
      ,@select_distinct_clause   NVARCHAR(MAX)
      ,@from_clause              NVARCHAR(MAX)
      ,@where_clause             NVARCHAR(MAX)
      ,@ids                      NVARCHAR(MAX)
      ,@nl                       NVARCHAR(2) = NCHAR(0x0a) + NCHAR(0x0d)

   SET @select_clause         = CONCAT('SELECT TOP ',@top, ' stg1_id , pathogens as [S1.pathogens                   .], crops as [S1.crops], ingredient as [S1.ingredient]');
   SET @select_distinct_clause= 'SELECT distinct pathogens, crops, ingredient';
   SET @from_clause           = 'FROM staging1'
   SET @where_clause          = CONCAT('WHERE pathogens LIKE ''', @where_subclause1, '''');

   IF @where_subclause2 IS NOT NULL SET @where_clause = CONCAT(@where_clause, ' AND pathogens LIKE '''    , @where_subclause2, '''');
   IF @where_subclause3 IS NOT NULL SET @where_clause = CONCAT(@where_clause, ' AND pathogens LIKE '''    , @where_subclause3, '''');

   IF @and_not_clause1 IS NOT NULL SET @where_clause  = CONCAT(@where_clause, ' AND pathogens NOT LIKE ''', @and_not_clause1 , ''''); 
   IF @and_not_clause2 IS NOT NULL SET @where_clause  = CONCAT(@where_clause, ' AND pathogens NOT LIKE ''', @and_not_clause2 , ''''); 
   IF @and_not_clause3 IS NOT NULL SET @where_clause  = CONCAT(@where_clause, ' and pathogens not like ''', @and_not_clause3 , '''');

   -- distinct pathogens that match filter
   SET @sql = CONCAT(@select_distinct_clause, @nl, @from_clause, @nl, @where_clause);
   PRINT CONCAT('@sql:', @nl, @sql);
   EXEC sp_executesql @sql;

   -- all pathogens that match filter
   SET @sql = CONCAT(@select_clause, @nl, @from_clause, @nl, @where_clause);
   PRINT CONCAT('@sql:', @nl, @sql);
   EXEC sp_executesql @sql;

   -- counts
   SET @sql = CONCAT(
   'SELECT S.pathogens AS [s1.pathogens                                                                  .]
 , Count(s.stg1_id) as [count]
FROM
(
   SELECT DISTINCT pathogens
   FROM staging1 
',   @where_clause, '
) AS A
JOIN STAGING1 as S on A.PATHOGENS = s.PATHOGENS
GROUP BY s.pathogens 
ORDER BY ut.dbo.fnLen(s.pathogens) DESC, S.Pathogens ASC;'
);
   PRINT CONCAT('@sql:', @nl, @sql);
   EXEC sp_executesql @sql;
END
/*
EXEC sp_list_staging
   @where_subclause1 ='toll', 
   @where_subclause2 =NULL, 
   @where_subclause3 =NULL, 
   @and_not_clause1  =NULL,
   @and_not_clause2  =NULL,
   @and_not_clause3  =NULL,
   @top              = 100

*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =====================================================
-- Author:      Terry Watts
-- Create date: 05-OCT-2023
-- Description: lists all rows for all staging tables
--
-- CHANGES:
-- 231007:removed row limit, added order by clause
-- 231007: added views where ids only
-- =====================================================
ALTER PROCEDURE [dbo].[sp_list_staging_table_rows]
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @cmd       NVARCHAR(4000)
      ,@table_nm  NVARCHAR(32) = 'CropStaging' -- ActionStaging,

   DROP TABLE If EXISTS temp;
   SET @cmd = CONCAT('SELECT '''' AS [',@table_nm, '],* FROM [',@table_nm,']');
   PRINT CONCAT('@cmd:
', @cmd);

   -----------------------------------------------------------------
   SELECT x.cmd INTO temp
   FROM 
   (
      SELECT CONCAT('SELECT '''' AS [',table_nm, '],* FROM [',table_nm,']') as cmd 
      FROM TableDef WHERE table_type='staging'
   ) X

   -- SELECT * FROM temp;

   -----------------------------------------------------------------
   DECLARE @cursor CURSOR

   SET @cursor = CURSOR FOR
      SELECT cmd from temp

   OPEN @cursor;
   FETCH NEXT FROM @cursor INTO @cmd;

   WHILE (@@FETCH_STATUS = 0)
   BEGIN
      EXEC(@cmd);
      FETCH NEXT FROM @cursor INTO @cmd;
   END
END
/*
EXEC sp_list_staging_table_rows
SELECT '' AS [ActionStaging],* FROM [ActionStaging]
SELECT '' AS [CropStaging],* FROM [CropStaging]

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   SELECT '01 ActionStaging'                 AS [01 ActionStaging]             , * FROM ActionStaging                       ORDER BY action_nm
   SELECT '02 ChemicalStaging'               AS [02 ChemicalStaging]           , * FROM ChemicalStaging                     ORDER BY chemical_nm
   SELECT '03 ChemicalActionStaging'         AS [03 ChemicalActionStaging]     , * FROM ChemicalActionStaging               ORDER BY chemical_nm, action_nm
   SELECT '04 ChemicalProductStaging'        AS [04 ChemicalProductStaging]    , * FROM ChemicalProductStaging              ORDER BY chemical_nm, product_nm
   SELECT '05 ChemicalUseStaging'            AS [05 ChemicalUseStaging]        , * FROM ChemicalUseStaging                  ORDER BY chemical_nm, use_nm
   SELECT '06 CompanyStaging'                AS [06 CompanyStaging]            , * FROM CompanyStaging                      ORDER BY company_nm
   SELECT '07 CropStaging'                   AS [07 CropStaging]               , * FROM CropStaging                         ORDER BY crop_nm
   SELECT '08 CropPathogenStaging'           AS [08 CropPathogenStaging]       , * FROM CropPathogenStaging                 ORDER BY crop_nm, pathogen_nm
   SELECT '09 PathogenStaging'               AS [09 PathogenStaging]           , * FROM PathogenStaging                     ORDER BY pathogen_nm
   SELECT '10 PathogenChemicalStaging'       AS [10 PathogenChemicalStaging]   , * FROM PathogenChemicalStaging             ORDER BY pathogen_nm, chemical_nm
   SELECT '11 PathogenTypeStaging'           AS [11 PathogenTypeStaging]       , * FROM PathogenTypeStaging                 ORDER BY pathogenType_nm
   SELECT '12 ProductStaging'                AS [13 ProductStaging]            , * FROM ProductStaging                      ORDER BY product_nm
   SELECT '13 ProductUseStaging'             AS [14 ProductUseStaging]         , * FROM ProductUseStaging                   ORDER BY product_nm, use_nm
   SELECT '14 TypeStaging'                   AS [15 TypeStaging]               , * FROM TypeStaging                         ORDER BY type_nm
   SELECT '15 UseStaging'                    AS [16 UseStaging]                , * FROM UseStaging                          ORDER BY use_nm
   SELECT '16 Import'                        AS [17 Import]                    , * FROM Import                              ORDER BY import_nm
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   */

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==================================================================================
-- Author:		 Terry Watts
-- Create date: 15-SEP-2023
-- Description: lists the crops and their associated pathogens from the main tables
--
-- PRECONDITIONS:
-- Dependencies:
--  Pathogen_staging_vw -> Staging2 table
--  PathogenStaging     -> 
--  Crop_staging_vw     -> Staging2 table
--  CropStaging         -> 
-- ==================================================================================
ALTER VIEW [dbo].[crop_pathogen_vw]
AS
SELECT TOP 10000 c.crop_nm, p.pathogen_nm, c.crop_id, p.pathogen_id
FROM Crop c
LEFT JOIN CropPathogen cp ON c.crop_id     = cp.crop_id
LEFT JOIN Pathogen p      ON p.pathogen_id = cp.pathogen_id
ORDER BY crop_nm, pathogen_nm

/*
SELECT TOP 50 * FROM crop_pathogen_vw;
SELECT pathogen_nm FROM Pathogen;
*/    

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==================================================================================
-- Author:		 Terry Watts
-- Create date: 07-OCT-2023
-- Description: lists the products and their associated chemicals from the main tables
--
-- ==================================================================================
ALTER VIEW [dbo].[ProductChemical_vw]
AS
SELECT TOP 100000 c.chemical_nm, p.product_nm, c.chemical_id, p.product_id
FROM ChemicalProduct cp
LEFT JOIN Product  p ON p.product_id  = cp.product_id 
LEFT JOIN Chemical c ON c.chemical_id = cp.chemical_id
ORDER BY product_nm, chemical_nm

/*
SELECT TOP 50 * FROM ProductChemical_vw
*/    

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==================================================================================
-- Author:		 Terry Watts
-- Create date: 07-OCT-2023
-- Description: lists the products and their associated uses from the main tables
-- ==================================================================================
ALTER VIEW [dbo].[ProductUse_vw]
AS
SELECT TOP 100000 p.product_nm, u.use_nm, p.product_id, u.use_id
FROM ProductUse pu
LEFT JOIN Product p ON p.product_id = pu.product_id 
LEFT JOIN [use]   u ON u.use_id     = pu.use_id
ORDER BY product_nm, use_nm

/*
SELECT TOP 200 * FROM ProductUse_vw
SELECT TOP 200 * FROM ProductUse
SELECT TOP 200 * FROM ProductUseStaging
SELECT TOP 200 * FROM ProductUseStaging_vw
SELECT TOP 200 * FROM Product
SELECT TOP 200 * FROM [Use]
*/    

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 20-SEP-2023
-- Description: lists the products and their constituent chemicals  
--              from the staging tables
--
-- CHANGES:
--    231007: uses the main tables now
--    240121: removed import_id
-- ==============================================================================
ALTER VIEW [dbo].[chemical_product_staging_vw]
AS
SELECT TOP 200000 chemical_nm, product_nm
FROM
          ChemicalProductStaging    cp 
--LEFT JOIN ChemicalStaging           ch    ON cp.chemical_id   = ch.chemical_id
--LEFT JOIN ProductStaging            p     ON p.product_id     = cp.product_id
--LEFT join CropPathogenStaging       crpp  ON crpp.pathogen_id = p.product_id
ORDER BY chemical_nm, product_nm

/*
SELECT * FROM chemical_product_staging_vw
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==================================================================================
-- Author:		 Terry Watts
-- Create date: 07-OCT-2023
-- Description: lists the products and their associated chemicals from the main tables
--
-- ==================================================================================
ALTER VIEW [dbo].[ChemicalProduct_vw]
AS
SELECT TOP 100000 c.chemical_nm, p.product_nm, c.chemical_id, p.product_id
FROM ChemicalProduct cp
LEFT JOIN Product  p ON p.product_id  = cp.product_id 
LEFT JOIN Chemical c ON c.chemical_id = cp.chemical_id
ORDER BY chemical_nm, product_nm

/*
SELECT TOP 50 * FROM ChemicalProduct_vw
*/    

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 20-SEP-2023
-- Description: lists pathogens, chemicals and crops the chemical can be used on 
--              from the staging tables
--
-- CHANGES:
--    231007: uses the name fields now
-- ==============================================================================
ALTER VIEW [dbo].[crop_pathogen_chemical_staging_vw]
AS
SELECT TOP 200000 ch.chemical_nm, crp.crop_nm, p.pathogen_nm
FROM 
          PathogenChemicalStaging   pc
LEFT JOIN ChemicalStaging           ch    ON pc.chemical_nm   = ch.chemical_nm
LEFT JOIN PathogenStaging           p     ON p.pathogen_nm    = pc.pathogen_nm
LEFT join CropPathogenStaging       crpp  ON crpp.pathogen_nm = p.pathogen_nm
LEFT join CropStaging               crp   ON crp.crop_nm      = crpp.crop_nm
ORDER BY ch.chemical_nm, crp.crop_nm, p.pathogen_nm

/*
SELECT * FROM CropStaging
SELECT * FROM PathogenStaging
SELECT * FROM ChemicalStaging
SELECT * FROM PathogenChemicalStaging
SELECT * FROM crop_pathogen_chemical_staging_vw
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==================================================================================
-- Author:      Terry Watts
-- Create date: 07-OCT-2023
-- Description: lists the products and their associated uses from the staging tables
-- ==================================================================================
ALTER VIEW [dbo].[ProductUseStaging_vw]
AS
SELECT TOP 100000 product_nm, use_nm
FROM ProductUseStaging pu
ORDER BY product_nm, use_nm

/*
SELECT TOP 200 * FROM ProductUseStaging_vw
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 05-OCT-2023
-- Description: lists the useful tables rows
--
-- CHANGES:
-- 231007:removd row limit, added order by clause
-- 231007: added views where ids only
-- =============================================
ALTER PROCEDURE [dbo].[sp_list_useful_table_rows]
AS
BEGIN
   SET NOCOUNT ON;

   SELECT 'Chemical'                      AS [table/view], * FROM Chemical                            ORDER BY chemical_nm
   SELECT 'ChemicalStaging'               AS [table/view], * FROM ChemicalStaging                     ORDER BY chemical_nm
   SELECT 'CrpPathChem stg vw'            AS [table/view], * FROM crop_pathogen_chemical_staging_vw   ORDER BY crop_nm, pathogen_nm, chemical_nm
   SELECT 'ChemPathCrp vw'                AS [table/view], * FROM chemical_pathogen_crop_vw           ORDER BY chemical_nm, pathogen_nm
   SELECT 'Chemical_Product_Staging_vw'   AS [table/view], * FROM Chemical_Product_Staging_vw         ORDER BY chemical_nm, product_nm
   SELECT 'ChemicalProduct_vw'            AS [table/view], * FROM ChemicalProduct_vw                  ORDER BY chemical_nm, product_nm
   SELECT 'ChemicalProduct_vw'            AS [table/view], * FROM ChemicalUseStaging                  ORDER BY chemical_nm, use_nm
   SELECT 'ChemicalUse'                   AS [table/view], * FROM ChemicalUse                         ORDER BY chemical_nm, use_nm
   SELECT 'CompanyStaging'                AS [table/view], * FROM CompanyStaging                      ORDER BY company_nm
   SELECT 'Company'                       AS [table/view], * FROM Company                             ORDER BY company_nm
   SELECT 'CropStaging'                   AS [table/view], * FROM CropStaging                         ORDER BY crop_nm
   SELECT 'Crop'                          AS [table/view], * FROM Crop                                ORDER BY crop_nm
   SELECT 'crop_pathogen_staging_vw'      AS [table/view], * FROM crop_pathogen_staging_vw            ORDER BY crop_nm, pathogen_nm
   SELECT 'crop_pathogen_vw'              AS [table/view], * FROM crop_pathogen_vw                    ORDER BY crop_nm, pathogen_nm
   SELECT 'Import'                        AS [table/view], * FROM Import                              ORDER BY import_nm
   SELECT 'ProductChemical_vw'            AS [table/view], * FROM ProductChemical_vw                  ORDER BY product_nm, chemical_nm
   SELECT 'PathogenStaging'               AS [table/view], * FROM PathogenStaging                     ORDER BY pathogen_nm
   SELECT 'Pathogen'                      AS [table/view], * FROM Pathogen                            ORDER BY pathogen_nm
   SELECT 'ProductStaging'                AS [table/view], * FROM ProductStaging                      ORDER BY product_nm
   SELECT 'Product'                       AS [table/view], * FROM Product                             ORDER BY product_nm
   SELECT 'ProductUseStaging_vw'          AS [table/view], * FROM ProductUseStaging_vw                ORDER BY product_nm, use_nm
   SELECT 'ProductUse_vw'                 AS [table/view], * FROM ProductUse_vw                       ORDER BY product_nm, use_nm
   SELECT 'Type'                          AS [table/view], * FROM [Type]                              ORDER BY type_nm
   SELECT 'Use'                           AS [table/view], * FROM [Use]                               ORDER BY use_nm
END

/*
EXEC sp_list_useful_table_rows 
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

-- ================================================================
-- Author:		 Terry Watts
-- Create date: 07-JUL-20223
-- Description: Lists the Pathogen sets for the given @where_clause 
--
-- use to look for variations in pathogen naming,
-- misspellings and errors
-- ================================================================
CREATE PROC [dbo].[sp_ListS2PathogensWhere] @where_clause NVARCHAR(500)
AS
BEGIN
DECLARE 
     @sql            NVARCHAR(MAX)
    ,@nl             NVARCHAR(2) = NCHAR(0x0a) + NCHAR(0x0d)

SET @sql = CONCAT(
   'SELECT S.pathogens AS [s1.pathogens                                                                  .]
 , Count(s.stg1_id) as [count]
FROM
(
   SELECT DISTINCT pathogens
   FROM staging1 
   WHERE ',   @where_clause, '
) AS A
JOIN STAGING1 as S on A.PATHOGENS = s.PATHOGENS
GROUP BY s.pathogens 
ORDER BY S.Pathogens ASC;'
);
   PRINT CONCAT('@sql:', @nl, @sql);
   EXEC sp_executesql @sql;
END
/*
    EXEC sp_ListS2PathogensWhere 'Pathogens LIKE ''%(%'' OR Pathogens LIKE ''%)%'''
SELECT * FROM s2vw  WHERE [pathogens] LIKE '%butt mold%' AND [pathogens] NOT LIKE '%Butt molds%' COLLATE Latin1_General_CS_AI;
UPDATE staging2 SET [pathogens] = Replace(pathogens, 'butt mold', 'Butt mold'   COLLATE Latin1_General_CS_AI)    WHERE [pathogens] LIKE '%butt mold%' AND [pathogens] NOT LIKE 'Butt molds' COLLATE Latin1_General_CS_AI;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================
-- Author:      Terry Watts
-- Create date: 19-JUN-2023
-- Description: The main import corrections routine 
--    for the Ph Dep Ag Pesticide register import process
--
-- PROCESS
-- 1. Clean tables and bulk insert to staging table
-- 2: do the fixup the Import_corrections_staging table
-- 3: copy this data to ImportCorrections table
-- 4: display both tables for inspection
--
-- CALLED BY: sp__main_import_Ph DepAg Registered Pesticides LRAP_All_files
-- 
-- FULL Get data and import PROCESS:
-- 1. download the Ph DepAg Registered Pesticides LRAP-221018 001-099.pdf from
-- 2. split it down into 100 page pdfs as is too large for conversion
-- 2.1: by using the pro pdf editor / edit/ Organise pages/select first 100 pages/ right click /Extract  {delete after extract} and OK to R U sure U want to delete pages 1-99
-- 2.2: save: choose a different location like: Ph DepAg Registered Pesticides LRAP-221018 001-099.pdf
-- 2.3: repeat the above steps till no pages left
-- 2.2: then extracted file like Ph DepAg Registered Pesticides LRAP-221018 001-099.tsv
-- 3. export each 100 page section pdf to Excel
-- 4. use Excel to:
-- 4.1 add 2 columns at the start sht, row and populate the sheet no (int) and the row number - 1-30 for each row on the sheet
-- 4.2 export as a tsv
-- 5: replace the singly LF line endings using notepad++:
-- 5.1:  replace ([^\r])\n  with \1
-- 5.2: save (and close) the file to the exports\tsv folder: D:\Data\Biz\Banana Farming\LRAP EXPORTS-221018\TSVs
-- 6: SQL Server
-- 6.1 run EXEC [dbo].[sp_bulk_insert_Ph DepAg Registered Pesticides LRAP] 'D:\Data\Biz\Banana Farming\LRAP EXPORTS-221018\TSVs\Ph DepAg Registered Pesticides LRAP-221018 001-099.tsv'
-- 7. run [dbo].[sp_process Ph DepAg Registered Pesticides LRAP]
--
-- ERROR HANDLING by exception handling
--
-- PRECONDITIONS:
--    none
--
-- POSTCONDITIONS:
--    Ready to process the pesticide register import
--    Clean bulk insert to tble from file
--
-- Tests:
--
--
-- Changes:
--  231105:removed the truncate tables so we can append
--         really this needs splitting up so we can do multiple imports
-- ======================================================================
ALTER PROCEDURE [dbo].[sp_main_import_pesticide_register_corrections_redundant]
    @imprt_tsv_file   NVARCHAR(360)
AS
BEGIN
   DECLARE
       @fn NVARCHAR(35)          = N'IMPRT CORRECTNS FILE'
      ,@rc INT                   = 0 
      ,@error_msg NVARCHAR(500)  = ''

   EXEC sp_log 1, @fn, 'starting';
   EXEC sp_register_call @fn;

   EXEC sp_log 0, @fn, '2: do the fixup the Import_corrections_staging table';

   -- if error throw exception
   EXEC sp_log 1, @fn,  '3: fixing up crctns staging...';
   EXEC @rc = sp_fixup_import_corrections_staging;
   EXEC sp_log 0, @fn, 'sp_fixup_Import_corrections_staging returned ', @rc;

   -- 3: copy this data to ImportCorrections table
   EXEC sp_log 1, @fn, '4: copying staging to corections table...';
   EXEC @rc = sp_copy_corrections_staging_to_mn;
   EXEC sp_log 0, '5: sp_copy_corrections_staging_to_mn returned: ', @rc;

   EXEC sp_log 1, @fn, '99 leaving, @rc: ', @RC;
   RETURN @RC;
END
/*
EXEC sp_main_import_pesticide_register_corrections 'D:\Dev\Repos\Farming\Data\LRAP-221008 Import\ImportCorrections 221018 230816-2000.tsv.txt';
SELECT * FROM ImportCorrectionsStaging;
SELECT * FROM ImportCorrections;
SELECT id, count(id)  from staging1 group by id having count(id)> 1;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==========================================================
-- Author:      Terry Watts
-- Create date: 08-NOV-2023
-- Description: helper for sp_merge_normalised_tables
-- ==========================================================
ALTER PROCEDURE [dbo].[sp_merge_normalised_tables_hlpr]
    @id        INT            OUTPUT
   ,@table_nm  NVARCHAR(50)
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
       @fn        NVARCHAR(30)  = N'MRG_NORM_TBLS'
      ,@msg       NVARCHAR(100)

   SET @msg = CONCAT('PRE', FORMAT(@id, '00'),': checking ',@table_nm);
   EXEC sp_log 2, @fn, @msg; 
   EXEC sp_chk_tbl_populated @table_nm;
   SET @id = @id+1;
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==================================================================================================================================================
-- Author:      Terry Watts
-- Create date: 31-MAR-2024
-- Description: validates sp_merge_normalised_tables postconditions
--       and do any main table fixup
--
-- POSTCONDITIONS
-- DEL01: This is the deliverable set of output tables populated by this routine
-- POST 01: Action table populated
-- POST 02: Chemical table populated
-- POST 03: ChemicalAction table populated
-- POST 04: ChemicalProduct table populated
-- POST 05: ChemicalUse table populated
-- POST 06: Company table populated
-- POST 07: Crop table populated
-- POST 08: CropPathogen table populated
-- POST 09: Distributor table populated
-- POST 10: Pathogen table populated
-- POST 11: PathogenChemical table populated
-- POST 12: PathogenType table populated
-- POST 13: Product table populated
-- POST 14: ProductCompany table populated
-- POST 15: ProductUse table populated
-- POST 16: Type table populated
-- POST 17: Use table populated
-- POST 18: DistributorManufacturer populated
--
-- TESTS:
--
-- CHANGES:
-- ==================================================================================================================================================
ALTER PROCEDURE [dbo].[sp_merge_normalised_tables_val_postconditions]
AS
BEGIN
   SET NOCOUNT OFF;

   DECLARE 
       @fn        NVARCHAR(30)  = N'MRG_NORM_TBLS_VAL_PCS'
      ,@error_msg NVARCHAR(MAX)  = NULL
      ,@file_path NVARCHAR(MAX)
      ,@id        INT = 1

   BEGIN TRY
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'000: starting, running postcondition validation checks';
      -----------------------------------------------------------------------------------
      -----------------------------------------------------------------------------------
      -- 22  POSTCONDITION checks
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '210: POSTCONDITION checks...';
      -- POST 01: Chemical table populated
      EXEC dbo.sp_chk_tbl_populated 'Action';
      EXEC dbo.sp_chk_tbl_populated 'Chemical';
      -- POST 02: ChemicalAction table populated
      EXEC dbo.sp_chk_tbl_populated 'ChemicalAction';
      -- POST 03: ChemicalProduct table populated
      EXEC dbo.sp_chk_tbl_populated 'ChemicalProduct';
      -- POST 04: ChemicalUse table populated
      EXEC dbo.sp_chk_tbl_populated 'ChemicalUse';
      -- POST 05 Company table populated
      EXEC dbo.sp_chk_tbl_populated 'Company';
      -- POST 06: Crop table populated
      EXEC dbo.sp_chk_tbl_populated 'Crop';
      -- POST 07: CropPathogen populated
      EXEC dbo.sp_chk_tbl_populated 'CropPathogen';
      -- POST 08: Distributor table populated
      EXEC dbo.sp_chk_tbl_populated 'Distributor';
      EXEC dbo.sp_chk_tbl_populated 'DistributorManufacturer';
      -- POST 09: Pathogen table populated
      EXEC dbo.sp_chk_tbl_populated 'Pathogen';
      -- POST 10: PathogenChemical table populated
      EXEC dbo.sp_chk_tbl_populated 'PathogenChemical';
      -- POST 11: PathogenType table populated
      EXEC dbo.sp_chk_tbl_populated 'PathogenType';
      -- POST 12: Product table populated
      EXEC dbo.sp_chk_tbl_populated 'Product';
      -- POST 13: ProductCompany table populated
      EXEC dbo.sp_chk_tbl_populated 'ProductCompany';
      -- POST 14: ProductUse table populated
      EXEC dbo.sp_chk_tbl_populated 'ProductUse';
      -- POST 15: Type table populated
      EXEC dbo.sp_chk_tbl_populated 'Type';
      -- POST 16: Use table populated
      EXEC dbo.sp_chk_tbl_populated 'Use';

      -----------------------------------------------------------------------------------
      -- 23: Completed processing OK
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '220: Completed processing OK';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '999: leaving: OK';
END
/*
EXEC sp_reset_CallRegister;
EXEC sp_merge_normalised_tables 1
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==================================================================================================================================================
-- Author:      Terry Watts
-- Create date: 31-MAR-2024
-- Description: validates sp_merge_normalised_tables preconditions
--
-- PRECONDITIONS:
-- the following set of staging tables are populated and fixed up
--    PRE01: ActionStaging
--    PRE02: ChemicalStaging
--    PRE03: ChemicalActionStaging
--    PRE04: ChemicalProductStaging
--    PRE05: ChemicalUseStaging
--    PRE06: CompanyStaging
--    PRE07: CropStaging
--    PRE08: CropPathogenStaging
----    PRE09: PathogenStaging
--    PRE10: PathogenChemicalStagng
--    PRE11: PathogenTypeStaging
--    PRE12: PathogenPathogenStaging
--    PRE12: ProductStaging
--    PRE13: ProductCompanyStaging
--    PRE14: ProductUseStaging
--    PRE15: TypeStaging
--    PRE16: UseStaging
--    PRE17: DistributorStaging
--
-- TESTS:
--
-- CHANGES:
-- ==================================================================================================================================================
ALTER PROCEDURE [dbo].[sp_merge_normalised_tables_val_preconditions]
AS
BEGIN
   SET NOCOUNT OFF;

   DECLARE 
       @fn        NVARCHAR(30)  = N'MRG_NORM_TBLS_VAL_PRE_CONDS'
      ,@error_msg NVARCHAR(MAX)  = NULL
      ,@file_path NVARCHAR(MAX)
      ,@id        INT = 1

   BEGIN TRY
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'000: starting, running postcondition validation checks';
      -----------------------------------------------------------------------------------
      -----------------------------------------------------------------------------------
      -- 22  PRECONDITION checks
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '005: checking preconditions';
--    PRE01: ActionStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'ActionStaging';
--    PRE02: ChemicalStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'ChemicalStaging';
--    PRE03: ChemicalActionStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'ChemicalActionStaging';
--    PRE04: ChemicalProductStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'ChemicalProductStaging';
--    PRE05: ChemicalUseStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'ChemicalUseStaging';
--    PRE06: CompanyStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'CompanyStaging';
--    PRE07: CropStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'CropStaging';
--    PRE08: CropPathogenStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'CropPathogenStaging';
--    PRE09: PathogenStaging
--      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'PathogenStaging';
--    PRE10: PathogenChemicalStagng
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'PathogenChemicalStaging';
--    PRE11: PathogenTypeStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'PathogenTypeStaging';
--    PRE13: ProductStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'ProductStaging';
--    PRE13: ProductCompanyStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'ProductCompanyStaging';
--    PRE14: ProductUseStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'ProductUseStaging';
--    PRE15: TypeStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'TypeStaging';
--    PRE16: UseStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'UseStaging';
--    PRE17: DistributorStaging
      EXEC sp_merge_normalised_tables_precondition_hlpr @id OUTPUT, 'DistributorStaging';
      -----------------------------------------------------------------------------------
      -- 23: Completed processing OK
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '220: Completed processing OK';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '999: leaving: OK';
END
/*
EXEC sp_merge_normalised_tables_val_preconditions
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 01-AUG-2023
-- Description: Populates the product use table from 2 sources:
--              1: once the S2 table is fixed up call this to pop the product use table
--                  from the S2 information using ALL_vw
--              2: add the extra product use data to the product use table from the spreadsheet tsv
--
-- PRECONDITIONS:
--    PRE01: Use table must be populated
--    PRE02: ProductStaging table must be populated
--
-- POSTCONDITIONS:
--    POST01: ProductUse table populated
--
-- ALGORITHM:
--    0: PRECONDITION VALIDATION CHECKS
--    1: TRUNCATE the staging table
--    2: we can pop the Product Use staging table using All_vw
--    --(3: add the extra product use data to the product use table from the spreadsheet tsv ) redundant?  do in code ?
--    4: update ProductUse tbl with the use_id
--    5: update product_id where it is null
--
-- CHANGES:
-- 231006: added parameter: import id NULL optional
-- 231007: removed the bulk import from file
-- 240124: removed import id parameter
--
-- Tests:
-- ======================================================================================================
ALTER PROCEDURE [dbo].[sp_pop_product_use_staging]
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35)   = N'POP PROD USE_STAGING'
      ,@sql       NVARCHAR(MAX)
      ,@error_msg NVARCHAR(MAX)  = NULL
      ,@rc        INT            =-1
      ,@cnt       INT            = 0
      ;

   EXEC sp_log 2, @fn,'01: starting';
   EXEC sp_register_call @fn;

   BEGIN TRY
      -- PRE01: Use and UseStaging tables must be populated
      EXEC sp_chk_tbl_populated 'UseStaging';
      EXEC sp_chk_tbl_populated 'Use';

      -- ASSERTION: precondition checks passed

      EXEC sp_log 2, @fn,'02: truncating ProductUseStaging table';
      TRUNCATE TABLE dbo.ProductUseStaging;

      -- 2: pop the Product Use staging table using all_vw
      EXEC sp_log 1, @fn,'03: populating the ProductUseStaging table from ALL_vw ';
      INSERT INTO ProductUseStaging (product_nm, use_nm)
      SELECT distinct product_nm, use_nm
      FROM ALL_vw
      WHERE product_nm IS NOT NULL AND use_nm IS NOT NULL
      ORDER BY product_nm, use_nm;

      -- Chk POST01: ProductUse table populated
      EXEC sp_chk_tbl_populated 'ProductUseStaging'
   END TRY
   BEGIN CATCH
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, '50: Caught exception: ', @error_msg;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '99: leaving OK';
   RETURN @RC;

END
/*
   EXEC sp_pop_product_use_staging 1
   SELECT * FROM ProductUseStaging;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ============================================================================
-- Author       Terry Watts
-- Create date: 07-FEB-2024
-- Description: registers the routine and sets the limit of the number of calls 
--              to the routine
--
-- CHECKED PRECONDITIONS: PRE 01: @rtn must not be registered already
-- ============================================================================
ALTER PROCEDURE [dbo].[sp_register_rtn]
    @rtn    NVARCHAR(128)
   ,@limit  INT               = 1
AS
BEGIN
   DECLARE
       @fn NVARCHAR(35) = 'REGISTER_RTN'
      ,@error_msg NVARCHAR(500)
      ,@key       NVARCHAR(128)
      ,@count     INT

   EXEC sp_log 1, @fn, 'routine: ', @rtn, ' limit: ', @limit;

   -- @rtn must NOT be registered yet
   IF EXISTS (SELECT 1 FROM SessionContext WHERE rtn = @rtn)
   BEGIN
      UPDATE SessionContext SET limit = @limit;
   END
   ELSE
   BEGIN
      -- PRE 01: @rtn must not already be registered
      SET @error_msg = CONCAT('The routine: ',@rtn, ' has already been registered');
      EXEC sp_log 4, @fn, @error_msg;
      THROW 53947, @error_msg, 1;
   END
END

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

-- ==============================================================
-- Author:		 Terry Watts>
-- Create date: 01-JUL-2023
-- Description: Replace alternative for handling wsp, comma
-- See also dbo.fnReplace(@src, @old, @new)
-- This routine is used to debug dbo.fnReplace(@src, @old, @new)
-- ==============================================================
CREATE PROC [dbo].[sp_replace]
   @src NVARCHAR(MAX), 
   @old NVARCHAR(MAX), 
   @new NVARCHAR(MAX),
   @out NVARCHAR(MAX) OUT
AS
BEGIN
   SET @out = dbo.fnReplace(@src, @old, @new);
   PRINT CONCAT('spReplace: @src:[', @src, '], @old:[', @old, '] @new:[', @new, '] @out:[', @out, ']');
END
/*
DECLARE @out NVARCHAR(MAX);
EXEC sp_replace 'ab ,cde ,def, ghi,jk', ' ,', ',', @out OUT;   
EXEC sp_replace 'ab ,cde ,def, ghi,jk, lmnp', ', ', ',' , @out OUT;   
EXEC sp_replace 'abcdefgh', 'def', 'xyz', @out OUT;   -- abcxyzgh
EXEC sp_replace null, 'cd', 'xyz', @out OUT;          -- null
EXEC sp_replace '', 'cd', 'xyz', @out OUT;           -- ''
EXEC sp_replace 'as', '', 'xyz', @out OUT;           -- 'as'

SELECT dbo.fnReplace('ab ,cde ,def, ghi,jk', ' ,', ',' );   
SELECT dbo.fnReplace('ab ,cde ,def, ghi,jk, lmnp', ', ', ',' );   
SELECT dbo.fnReplace('abcdefgh', 'def', 'xyz' );   -- abcxyzgh
SELECT dbo.fnReplace(null, 'cd', 'xyz' );          -- null
SELECT dbo.fnReplace('', 'cd', 'xyz' );            -- ''
SELECT dbo.fnReplace('as', '', 'xyz' );            -- 'as'
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ============================================================================
-- Author       Terry Watts
-- Create date: 07-FEB-2024
-- Description: resets the count field to  zero in the call register table
--              but leaves the limit field intact
--
-- PRECONDITIONS: none
-- ============================================================================
ALTER PROCEDURE [dbo].[sp_reset_CallRegister]
   @rtn_nm NVARCHAR(50) = NULL
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35) = 'RESET_CALL__REGISTER'
      ,@error_msg NVARCHAR(500)
      ,@key       NVARCHAR(128)
      ,@count     INT

   EXEC sp_log 1, @fn, '00: starting @rtn_nm:[',@rtn_nm,']';
   EXEC sp_log 1, @fn, '10: clearing rows';
   UPDATE CallRegister SET [count] = 0 WHERE @rtn_nm IS NULL OR rtn=@rtn_nm;
   EXEC sp_log 1, @fn, '99: leaving OK';
END
/*
EXEC sp_reset_CallRegister;
EXEC sp_reset_CallRegister 'SP_MAIN_IMPORT_STAGE_8';
SELECT * FROM CallRegister;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:		 TerryWatts
-- Create date: 24-JUN-2023
-- Description: gets the crops for a given pathogen
-- =============================================
ALTER FUNCTION [dbo].[fnRptGetCropsAffectedByPathogen]( @pathogen NVARCHAR(60))
RETURNS 
@t TABLE 
(
   crop     NVARCHAR(60), 
   pathogen NVARCHAR(1000)
)
AS
BEGIN
   INSERT INTO @t (crop, pathogen) 
   SELECT crop_nm, pathogen_nm FROM crop_pathogen_vw where pathogen_nm = @pathogen
   --SELECT DISTINCT CROPS, pathogens from staging2 WHERE Pathogens LIKE CONCAT('%', @pathogen, '%');
	
	RETURN 
END

/*
   SELECT * FROM fnRptGetCropsAffectedByPathogen('Sigatoka');
   SELECT * FROM fnRptGetCropsAffectedByPathogen('hopper') WHERE CROPs LIKE'%Mango%';
   SELECT * FROM crop_pathogen_vw;
   SELECT * FROM chemical_pathogen_crop_staging_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ================================================================
-- Author:		 Terry Watts
-- Create date: 22-OCT-2023
-- Description: Reports the chemicals and products 
--    for a given crop and pathogen
-- ================================================================
ALTER PROCEDURE [dbo].[sp_rpt_get_spray_for_pathogen_crop] 
	 @pathogen  NVARCHAR(50)
	,@crop      NVARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
   SELECT * FROM fnRptGetCropsAffectedByPathogen(@pathogen);
END
/*
   EXEC sp_rpt_get_spray_for_pathogen_crop 'sigatoka'
   SELECT DISTINCT entry_mode FROM Staging2 ORDER BY entry_mode
   SELECT crops, pathogens, ingredient, entry_mode FROM Staging2 ORDER BY entry_mode
   SELECT crops, pathogens, entry_mode, ingredient FROM Staging2 WHERE entry_node = 'Contact/selective'
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 25-NOV-2023
-- Description: sets the log level
-- =============================================
ALTER PROCEDURE [dbo].[sp_set_log_level]
   @level INT
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE @log_level_key NVARCHAR(50) = dbo.fnGetLogLevelKey();
   EXEC sys.sp_set_session_context @key = @log_level_key, @value = @level;
END
/*
EXEC test.sp_crt_tst_rtns 'dbo.sp_set_log_level', 79, 'C';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 08-FEB-2020
-- Description: returns true (1) if table exists else false (0)
-- Parameters:
--    @table_spec <db>.<schema>.<table>
--
-- Returns 1 if exists, 0 otherwuse
-- db default is DB_NAME()
-- schema default is dbo
-- =============================================
ALTER PROCEDURE [dbo].[sp_table_exists]
       @table_spec   NVARCHAR(60)
AS
BEGIN
   DECLARE
       @db        NVARCHAR(20)   = DB_NAME()
      ,@schema    NVARCHAR(20)   = 'dbo'
      ,@table     NVARCHAR(60)
      ,@sql       NVARCHAR(200)
      ,@n         INT
      ,@exists    BIT

   SET @table_spec = REVERSE(@table_spec);
   -- expect table name
   SET @n          = CHARINDEX( '.', @table_spec);
   SET @table      = REVERSE(iif(@n > 0, LEFT(@table_spec, @n-1), @table_spec));

   IF @n > 0
   BEGIN
      -- optional schema
      SET @table_spec = SUBSTRING(@table_spec, @n+1, LEN(@table_spec)-@n);
      SET @n          = CHARINDEX( '.', @table_spec);
      SET @schema     = REVERSE( iif(@n>0, LEFT(@table_spec, @n-1), @table_spec))

      IF @n > 0
      BEGIN
         SET @table_spec = SUBSTRING(@table_spec, @n+1, LEN(@table_spec)-@n);
         SET @db         = iif(@n>0, REVERSE( @table_spec), DB_NAME())
      END
   END

   SET @sql = CONCAT
   (
         'SELECT @exists = CASE 
         WHEN EXISTS (SELECT 1 FROM ', @db,'.INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''',@table,''' AND TABLE_SCHEMA = ''', @schema,''') 
         THEN 1 ELSE 0 END;'
   );

   --PRINT @sql
   EXEC sp_executesql @query=@sql, @params=N'@exists BIT OUT', @exists=@exists OUT
   RETURN @exists;
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_036_spTableExists';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =====================================================================================
-- Author:      Terry Watts
-- Create date: 25-AUG-2023
-- Description: Truncates the main tables
-- Method:
-- Drop the main table FKs
-- Truncate each table
-- Create the main table FKs
--
-- Calls: sp_create_main_table_FKs twice, once to drop the keys, once to recreate them
-- 
-- =====================================================================================
ALTER PROCEDURE [dbo].[sp_truncate_main_tables] 
AS
BEGIN
   SET NOCOUNT ON
   DECLARE
    @fn        NVARCHAR(30)   = 'TRUNC_MN_TBLS'
   ,@cursor                   CURSOR
   ,@id                       INT   = 0
   ,@fk_nm                    NVARCHAR(60)
   ,@foreign_table_nm         NVARCHAR(60)
   ,@primary_tbl_nm           NVARCHAR(60)
   ,@schema_nm                NVARCHAR(60)
   ,@fk_col_nm                NVARCHAR(60)
   ,@pk_col_nm                NVARCHAR(60)
   ,@unique_constraint_name   NVARCHAR(60)
   ,@ordinal                  INT
   ,@ndx                      INT = 0
   ,@table_type2              NVARCHAR(60)
   ,@msg                      NVARCHAR(1000)
   ,@sql                      NVARCHAR(MAX)

   BEGIN TRY
      EXEC sp_log 2, @fn, '00: starting';
      THROW 56214, 'DEPRECATED - DO NOT USE',1;
      EXEC sp_register_call @fn;

      ------------------------------------------------------------------------------------------------
      -- Drop the main table FKs
      ------------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '05: drop FKs, calling sp_crt_mn_tbl_FKs 0';
      EXEC sp_crt_mn_tbl_FKs 0; -- drop FKs
      EXEC sp_log 2, @fn, '10: ret frm sp_crt_mn_tbl_FKs 0';

      ------------------------------------------------------------------------------------------------
      -- Truncate each table
      ------------------------------------------------------------------------------------------------
/*      SET @cursor = CURSOR FOR
         SELECT id, fk_nm, foreign_table_nm, primary_tbl_nm, schema_nm, fk_col_nm, pk_col_nm, unique_constraint_name, ordinal, table_type
         FROM ForeignKey fk LEFT JOIN TableDef td ON fk.foreign_table_nm=td.table_nm
         WHERE table_type = 'Main'
         ORDER BY id;*/
      EXEC sp_log 2, @fn, '15: Truncate table loop: starting';
      SET @cursor = CURSOR FOR
         SELECT DISTINCT foreign_table_nm--, primary_tbl_nm, schema_nm, fk_col_nm, pk_col_nm, unique_constraint_name, ordinal, table_type
         FROM ForeignKey fk LEFT JOIN TableDef td ON fk.foreign_table_nm=td.table_nm
         WHERE table_type = 'Main'
--         ORDER BY id;

      OPEN @cursor;

      --FETCH NEXT FROM @cursor INTO @id, @fk_nm, @foreign_table_nm, @primary_tbl_nm, @schema_nm, @fk_col_nm, @pk_col_nm, @unique_constraint_name, @ordinal, @table_type2;
      FETCH NEXT FROM @cursor INTO @foreign_table_nm;
      EXEC sp_log 1, @fn, '20: @@FETCH_STATUS before first fetch: [', @@FETCH_STATUS, ']';

      WHILE (@@FETCH_STATUS = 0)
      BEGIN
         SET @ndx = @ndx + 1;
         SET @sql = CONCAT('TRUNCATE TABLE [',@foreign_table_nm,']');
         EXEC sp_log 1, @fn, '25: [', @ndx,'] ', @sql;
         EXEC( @sql);
         --FETCH NEXT FROM @cursor INTO @id, @fk_nm, @foreign_table_nm, @primary_tbl_nm, @schema_nm, @fk_col_nm, @pk_col_nm, @unique_constraint_name, @ordinal, @table_type2;
         FETCH NEXT FROM @cursor INTO @foreign_table_nm;
      END

      EXEC sp_log 2, @fn, '30: processing corrections Completed at row: ';
      IF @ndx = 0 EXEC Ut.dbo.sp_raise_exception 52417, 'No rows were processed'
      ------------------------------------------------------------------------------------------------
      -- Recreate the main table FKs
      ------------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '35: recreate FKs, calling sp_crt_mn_tbl_FKs 1'
      EXEC sp_crt_mn_tbl_FKs 1; -- recreate FKs
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      --EXEC sp_crt_mn_tbl_FKs 0; -- recreate FKs drop first if state is inconsistent
      --EXEC sp_crt_mn_tbl_FKs 1; -- recreate FKs
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '99: leaving OK';
END
/*
TRUNCATE TABLE Applog;
EXEC sp_reset_callRegister 'TRUNC_MN_TBLS';
EXEC sp_truncate_main_tables;

EXEC sp_list_AppLog @fnFilter='TRUNC_MN_TBLS,CRT_MN_TBL_FKS,CRT_FKEYS'--,@asc=0
SELECT * FROM fnListFKeysForPrimaryTable('Pathogen')
ALTER TABLE CropPathogenStaging DROP CONSTRAINT FK_CropPathogenStaging_Pathogen
ALTER TABLE PathogenChemicalStaging DROP CONSTRAINT FK_PathogenChemicalStaging_PathogenStaging
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =========================================================
-- Author:      Terry Watts
-- Create date: 29-JUL-2023
-- Description:
-- Adds the type information from the japChemList table
-- Do after jap chemlist and chemical alignment
--  sp_fixup_japChemList and sp_fixup_s2_chems
-- =========================================================
ALTER PROCEDURE [dbo].[sp_update_chemical_typ_frm_jap]
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(30)   = 'UPDATE_CHEM_TYP_FRM_JAP'

   EXEC sp_register_call @fn;
/*   UPDATE  c
   SET c.[type_nm] = j.[type]
   FROM Chemical c JOIN japChemical j ON j.name = c.name
   WHERE c.[type_nm] NOT LIKE j.[type] COLLATE Latin1_General_BIN;

   -- Add in new type info
   UPDATE  c
   SET c.type_id = t.id
   FROM Chemical c JOIN ChemicalType t ON c.type_nm = t.name
   WHERE c.[type_id] <> t.id;
   */
   ;THROW 60000, 'Not implemented',1;
END
/*
EXEC sp_fixup_jap_chemical;
EXEC sp_fixup_s2_chems;
EXEC sp_update_chemical_typ_frm_jap;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:		 Terry Watts
-- Create date: 05-JUL-2023
-- Description: runs the EXP/ACT checks 
--       if mismatch
-- PRECONDITIONS - all inputs valid
-- =============================================
ALTER PROCEDURE [dbo].[sp_update_if_exists_chk_state]
       @rc           INT            = 0
      ,@sql          NVARCHAR(MAX)
--    ,@exp_cnt      INT            
      ,@act_cnt      INT            = NULL
      ,@must_update  BIT            = NULL
      ,@msg          NVARCHAR(500)  OUTPUT
AS
BEGIN
   IF @rc <> 0
   BEGIN
      SET @msg = CONCAT('sp_update caught error ', @rc, ' sql:[', @sql, ']');
      THROW 55555, @msg, 1;
   END   

   -- Check updated if @must_update flag set
   IF (@must_update=1) AND (@act_cnt = 0 )
   BEGIN
      SET @msg = 'ERROR: 0 rows updated but @must_update is TRUE';
      RETURN -1;
   END
   
   RETURN 0;
END
/*

*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:		 Terry Watts
-- Create date: 15-AUG-2023
-- Description: After update trigger
-- =============================================
ALTER PROCEDURE [dbo].[Staging2_after_update_trigger] 
--   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
   DECLARE 
        @fn          NVARCHAR(35) = 'S2_UPDATE_TRIGGER: '
       ,@id          INT
       ,@cnt_new     INT
       ,@cnt_old     INT
       ,@cnt_dif     INT
/*       ,@old_cor_id  INT
--       ,@new_cor_id  INT

--   SET @old_cor_id = dbo.fnGetSessionValueCorId();
   --IF @old_cor_id IS NULL SET @old_cor_id = 0;
--   SET @new_cor_id = (SELECT top 1 cor_id FROM INSERTED);

   --EXEC sp_log 2, @fn,'01: starting: old cor_id: ', @old_cor_id, '  new cor_id [', @new_cor_id, ']';

   IF @new_cor_id <> @old_cor_id
   BEGIN
      -- Set the session context now to avoid duplicate rows
      EXEC sp_set_session_context_cor_id @new_cor_id;
      SELECT @cnt_new = COUNT(*) FROM INSERTED; -- new
      SELECT @cnt_old = COUNT(*) FROM DELETED;  -- old

      SELECT @cnt_dif = COUNT(*) 
      FROM INSERTED i JOIN DELETED d ON i.stg2_id=d.stg2_id 
      WHERE i.pathogens<>d.pathogens;

      --EXEC sp_log 2, @fn, '02 cnt_new: ', @cnt_new, ' @cnt_old: ',@cnt_old, ' @cnt_dif@ ', @cnt_dif;

      --IF @cnt_dif > 0
      --BEGIN
         --EXEC sp_log 2, @fn, '03: logging the update';
         INSERT INTO CorrectionLog (cor_id, stg_id, search_clause, replace_clause, not_clause, old, new, row_cnt)
         SELECT 
            old.stg2_id
           ,new.search_clause
           ,new.replace_clause
           ,new.not_clause
           ,old.pathogens  AS pathogens_old
           ,new.pathogens  AS pathogens_new
           ,@cnt_new
         FROM INSERTED new FULL JOIN DELETED old ON new.stg2_id=old.stg2_id
         WHERE old.pathogens <> new.pathogens
      --END

      -- Flag insertion of problems
   END

   --EXEC sp_log 1, @fn, '99: leaving'
   IF EXISTS (SELECT 1 FROM inserted WHERE pathogens LIKE '%Golden apple snails%') THROW 60000
      , 'S2 update trigger: ''Golden apple snails'' has just been inserted into S2.pathogens',1;
      */
END
/*
SELECT * FROM CorrectionLog
SELECT * FROM Staging2 WHERE pathogens LIKE '%Golden apple Snails%'
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===================================================================================
-- Author:      Terry Watts
-- Create date: 06-JUL-2023
-- Description: Camel cases the first word in each comma separated item provided
-- ===================================================================================
ALTER FUNCTION [dbo].[fnCamelCaseFirstWordsInList]()
RETURNS 
@t TABLE 
(
   value NVARCHAR(MAX)
)
AS
BEGIN
INSERT INTO @t
(value)
SELECT DISTINCT ut.dbo.fnInitialCap( ut.dbo.fnTrim( cs.value)) AS pathogen
   FROM Staging2 
   CROSS APPLY string_split(pathogens, ',') cs
   WHERE  cs.value not in ('', ' ', '\t', '-')
   AND stg2_id <5

   RETURN
END
/*
SELECT * FROM [dbo].[fnCamelCaseFirstWordsInList]()
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ============================================================================================================================
-- Author:      Terry Watts
-- Create date: 09-MAY-2020
-- Description: checks if the routine exists
--
-- POSTCONDITIONS:
-- POST 01: RETURNS if @q_rtn_name exists then [schema_nm, rtn_nm, rtn_ty, ty_code,] , 0 otherwise
-- 
-- Changes 240723: now returns a single row table as above
--
-- Tests: test.test_029_fnChkRtnExists
-- ============================================================================================================================
ALTER FUNCTION [dbo].[fnChkRtnExists]
(
    @q_rtn_name NVARCHAR(120)
)
RETURNS @t TABLE
(
    schema_nm     NVARCHAR(32)
   ,rtn_nm        NVARCHAR(60)
   ,rtn_ty        NCHAR(61)
   ,ty_code       NVARCHAR(25)
   ,is_clr        BIT
)

AS
BEGIN
   DECLARE
       @schema       NVARCHAR(20)
      ,@rtn_nm       NVARCHAR(4000)
      ,@ty_nm        NVARCHAR(20)

   SELECT
       @schema = schema_nm
      ,@rtn_nm = rtn_nm
   FROM test.fnSplitQualifiedName(@q_rtn_name);

   SELECT @ty_nm = ty_nm FROM dbo.sysRtns_vw WHERE schema_nm = @schema and rtn_nm = 'fn_CamelCase';

   INSERT INTO @t 
   (
       schema_nm
      ,rtn_nm   
      ,rtn_ty   
      ,ty_code  
      ,is_clr   
   )
   SELECT  
       schema_nm
      ,rtn_nm   
      ,rtn_ty   
      ,ty_code  
      ,is_clr   
   FROM dbo.sysRtns_vw WHERE schema_nm = @schema and rtn_nm = @rtn_nm;

   RETURN;
END
/*
PRINT 
EXEC tSQLt.Run 'test.test_029_fnChkRtnExists';

SELECT * FROM [dbo].[fnChkRtnExists]('[dbo].[fnClassCreator]');
SELECT * FROM [dbo].[fnChkRtnExists]('[dbo].[fnCompareFloats]');
SELECT * FROM [dbo].[fnChkRtnExists]('sp_close_log');
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==============================================================================
-- Author:		 Terry Watts
-- Create date: 16-AUG-2023
-- Description: displays the import/update audit
--              
-- CHANGES:
--    
-- ==============================================================================
ALTER VIEW [dbo].[audit_vw] AS
SELECT TOP 10000 *
FROM
(
SELECT distinct ids, X.cor_id, old, new, search_clause, replace_clause, not_clause, row_cnt 
FROM
(
SELECT STRING_AGG(stg_id, ',') as ids, cor_id --, old, new, search_clause, replace_clause, not_clause, row_cnt, cor_rnk 
FROM
(
SELECT id, stg_id, cor_id, old, new, search_clause, replace_clause, not_clause, row_cnt
,row_number() over (partition by cor_id order by id) as cor_rnk
FROM  CorrectionLog
) ranks
where cor_rnk<100
group by cor_id --, old, new, search_clause, replace_clause, not_clause, row_cnt, cor_rnk  
) X
JOIN CorrectionLog cl ON X.cor_id = cl.cor_id 
) Y
order by y.cor_id;


/*
SELECT TOP 50 * FROM audit_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===========================================================
-- Author:      Terry Watts
-- Create date: 16-AUG-2023
-- Description: Corrections Audit helper.
--  Use this to track which changes were applied to a reord.
-- ===========================================================
ALTER FUNCTION [dbo].[fnGetAuditForId]( @id INT)
RETURNS @t TABLE 
(
    ids            nvarchar(MAX)  NULL
   ,cor_id         int            NULL
   ,old            nvarchar(250)  NULL
   ,new            nvarchar(250)  NULL
   ,search_clause  nvarchar(250)  NULL
   ,replace_clause nvarchar(150)  NULL
   ,not_clause     nvarchar(150)  NULL
   ,row_cnt        int            NULL
) 
AS
BEGIN

   DECLARE @id_str NVARCHAR(20);
   SET @id_str = CONVERT( int, @id);

   INSERT INTO @t
   (
       ids
      ,cor_id
      ,old
      ,new
      ,search_clause
      ,replace_clause
      ,not_clause
      ,row_cnt
   )
   SELECT 
       ids
      ,cor_id
      ,old
      ,new
      ,search_clause
      ,replace_clause
      ,not_clause
      ,row_cnt
   FROM audit_vw
   WHERE
      ids =@id_str 
      OR ids LIKE CONCAT(@id_str,',%')
      OR ids LIKE CONCAT('%,', @id_str)
      OR ids LIKE CONCAT('%,', @id_str, ',%')

   RETURN;
END
/*
SELECT * FROM audit_vw
-- 23531,13632,6002,15624,2816
SELECT * FROM dbo.fnGetAuditForId(6002)  -- middle, end        11 records
SELECT * FROM dbo.fnGetAuditForId(24305) -- first of many      23 records
SELECT * FROM dbo.fnGetAuditForId(15179) -- singleton or first 6 records
SELECT * FROM dbo.fnGetAuditForId(13324) -- end of many        2 records
SELECT * FROM dbo.fnGetAuditForId(21094) -- first of a pair: [21094,18224}] 17 records 1 pair, rest end of multiple
SELECT * FROM dbo.fnGetAuditForId(18224) -- last of a pair   [21094,18224]  1 record
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry watts
-- Create date: 05-APR-2024
-- Description: gets the output columns from a table function
--
-- Usage SELECT def FROM dbo.[fnGrepSchema]('test', '%name%', '%content filter%') 
-- =============================================
ALTER FUNCTION [dbo].[fnGetFnOutputCols]
(
    @q_rtn_nm     NVARCHAR(60)
)
RETURNS @t TABLE
(
    name          NVARCHAR(50)
   ,ordinal       INT
   ,ty_nm         NVARCHAR(40)
   ,[len]         INT
   ,is_nullable   BIT
)
AS
BEGIN
      INSERT INTO @t (name, ordinal, ty_nm, [len], is_nullable) 
      SELECT name, column_id as ordinal, TYPE_NAME(user_type_id) as ty_nm, max_length, is_nullable
      FROM sys.columns
      WHERE object_id=object_id(@q_rtn_nm)
      ORDER BY column_id;

   RETURN;
END
/*
  SELECT * FROM dbo.fnGetFnOutputCols('test.fnCrtHlprCodeTstSpecificPrms');
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================================
-- Author:      Terry Watts
-- Create date: 17-APR-2024
-- Description: lists the output columns for table functions
-- =============================================================
ALTER VIEW [dbo].[list_tf_output_columns_vw]
AS
SELECT TOP 10000 
   table_schema
   ,TABLE_NAME
   ,COLUMN_NAME
   ,ORDINAL_POSITION
   ,is_nullable
   ,dbo.fnGetFullTypeName(DATA_TYPE, CHARACTER_MAXIMUM_LENGTH) as data_type
   ,IIF(DATA_TYPE IN ('NVARCHAR', 'VARCHAR', 'NCHAR', 'CHAR'), 1, 0) AS is_chr
FROM INFORMATION_SCHEMA.ROUTINE_COLUMNS isc
ORDER BY TABLE_NAME, ORDINAL_POSITION;
/*
SELECT * FROM list_tf_output_columns_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ================================================================================================
-- Author:      Terry watts
-- Create date: 05-APR-2024
-- Description: returns:
--    if @ty_nm is a text array type then returns the full type from a data type + max_len fields
--    else returns @ty_nm on its own.
--
--    This is useful when using sys rtns like sys.columns
--
-- Test:
-- ================================================================================================
ALTER FUNCTION [dbo].[fnGetOutputColumnsForTf]
(
    @schema_nm    NVARCHAR(40)
   ,@rtn_nm       NVARCHAR(60)
)
RETURNS @t TABLE
(
    ordinal       INT
   ,col_nm        NVARCHAR(60)
   ,data_type     NVARCHAR(20)
   ,is_nullable   BIT
   ,is_chr        BIT
)
AS
BEGIN
   INSERT INTO @t(ordinal , col_nm     , data_type, is_nullable, is_chr)
   SELECT ordinal_position, column_name, data_type, iif(is_nullable='YES', 1,0), is_chr
   FROM list_tf_output_columns_vw
   WHERE table_schema = @schema_nm AND table_name = @rtn_nm

   RETURN;
END
/*
  SELECT * FROM dbo.fnGetOutputColumnsForTf('dbo', 'fnClassCreator');
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =========================================================================
-- Author:      Terry Watts
-- Create date: 28-OCT-2023
-- Description: returns pathogens that effect crops
-- Lists the pathogen_is, pathogen_nm, pathogen type name, crop name and id
-- =========================================================================
ALTER VIEW [dbo].[pathogens_by_type_crop_vw]
AS
SELECT  c.crop_nm, p.pathogen_nm, t.pathogenType_nm, cp.crop_id, p.pathogen_id, t.pathogenType_id
FROM        Pathogen p 
LEFT JOIN   PathogenType t  ON p.pathogenType_id = t.pathogenType_id
LEFT JOIN   CropPathogen cp ON cp.pathogen_id    = p.pathogen_id
LEFT JOIN   Crop         c  ON c.crop_id         = cp.crop_id
;
/*
SELECT *
FROM pathogens_by_type_crop_vw
WHERE crop_nm= 'Banana' AND pathogenType_nm = 'Fungus'
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:		 Terry Watts
-- Create date: 28-OCT-2023
-- Description: returns pathogens that effect crops
-- =============================================
ALTER FUNCTION [dbo].[fnGetPathogensByCropAndType]
(
    @crop_nm            NVARCHAR(60)
   ,@pathogen_type_nm   NVARCHAR(60)
)
RETURNS 
@t TABLE
(
    pathogen_nm      NVARCHAR(60)
   ,pathogen_type_nm NVARCHAR(60)
   ,crop_nm          NVARCHAR(60)
   ,pathogen_id      INT
   ,crop_id          INT
)
AS
BEGIN
	INSERT INTO @t(pathogen_nm, crop_nm, crop_id, pathogen_id, pathogen_type_nm)
	SELECT TOP 10000 pathogen_nm, crop_nm, crop_id, pathogen_id, pathogenType_nm
   FROM   pathogens_by_type_crop_vw
   WHERE (crop_nm LIKE @crop_nm OR @crop_nm IS NULL) AND (pathogenType_nm LIKE @pathogen_type_nm OR @pathogen_type_nm IS NULL)
   ORDER BY crop_nm, pathogenType_nm ;
	RETURN 
END
/*
SELECT * from dbo.fnGetPathogensByCropAndType('Banana','Insect');
SELECT * from dbo.fnGetPathogensByCropAndType('Banana',NULL);
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:		 Terry Watts
-- Create date: 08-OCT-2023
-- Description: Lists the diseases for a given crop
--                uses the LIKE command
-- CHANGES:
--
-- =============================================
ALTER FUNCTION [dbo].[fnGetPathogensForCrop]
(
	@crop_nm NVARCHAR(60)
)
RETURNS 
@t TABLE 
(
    crop_nm       NVARCHAR(100)
   ,pathogen_nm   NVARCHAR(100)
   ,pathogen_id   INT
)
AS
BEGIN
	INSERT INTO @t(crop_nm, pathogen_nm, pathogen_id)
   SELECT crop_nm, pathogen_nm, pathogen_id FROM crop_pathogen_vw WHERE crop_nm LIKE @crop_nm;
	
	RETURN 
END
/*
SELECT * FROM dbo.[fnGetPathogensForCrop]('Banana');
SELECT TOP 500 * FROM crop_pathogen_vw
SELECT distinct pathogens FROM Staging2 WHERE crops='Banana' and pathogens like '%grass%'
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ============================================================================================================================
-- Author:      Terry Watts
-- Create date: 11-NOV-2023
-- Description: take off of MS sp_helptext
-- gets the routine definition
--
-- POSTCONDITIONS:
--  POST 01: if successful returns the script
--  POST 02: if not successful returns the appropriate error message along with 
--           the corresponding negatated MS error code as follows:
--    .1: if rtn is not in the current database:                     -15250, 'Error 01: rtn is not in the current database'
--    .2: if rtn does not exist:                                     -15009, 'Error 02: rtn does not exist'
--    .3: if a system object and it is not in MASTER.sys.syscomments -15197, 'Error 03: system-object check failed'
--    .4: if rtn has no script rows:                                 -15197, 'Error 04: rtn has no lines'
--    .5: if rtn has no script rows*:                                -15471, 'Error 05: rtn has no lines*'
-- ============================================================================================================================
ALTER FUNCTION [dbo].[fnGetRtnDef]
(
    @qrn NVARCHAR(120) -- can be [db_nm.][schema_nm.][rtn_nm]
)
RETURNS
@rtnDef TABLE
(
    id   INT
   ,line NVARCHAR(255) --collate catalog_default
)

AS
BEGIN
   DECLARE
       @dbname          SYSNAME
      ,@objid           INT
      ,@BlankSpaceAdded INT
      ,@BasePos         INT
      ,@CurrentPos      INT
      ,@TextLength      INT
      ,@LineId          INT
      ,@AddOnLen        INT
      ,@LFCR            INT --Lengths of line feed carriage return
      ,@DefinedLength   INT
      ,@n               INT

   /* NOTE: Length of @SyscomText is 4000 to replace the length of
   ** text column in syscomments.
   ** lengths on @Line, #CommentText Text column and
   ** value for @DefinedLength are all 255. These need to all have
   ** the same values. 255 was selected in order for the max length
   ** display using down level clients
   */
      ,@SyscomText      NVARCHAR(4000)
      ,@Line            NVARCHAR(255)

   SELECT @DefinedLength = 255
   SELECT @BlankSpaceAdded = 0 --Keeps track of blank spaces at end of lines. Note Len function ignores  trailing blank spaces*/

   -- Make sure the @objname is local to the current database.
   SELECT @dbname = parsename(@qrn, 3); -- 1 = Object name, 2 = Schema name, 3 = Database name, 4 = Server name

   IF @dbname IS NULL
      SELECT @dbname = db_name();
   ELSE IF @dbname <> db_name()
   BEGIN
      -- raiserror(15250,-1,-1);
     INSERT INTO @rtnDef(id, line)  VALUES (-15250, 'Error 01: rtn is not in the current database');
     RETURN;
   END

   -- See if @objname exists.
   SELECT @objid = object_id(@qrn)
   IF (@objid IS NULL)
   BEGIN
     INSERT INTO @rtnDef(id, line)  VALUES (-15009, 'Error 02: rtn does not exist');
     RETURN;
   END

   IF @objid < 0 -- Handle system-objects
   BEGIN
      -- Check count of rows with text data
      IF (SELECT count(*) from MASTER.sys.syscomments WHERE id = @objid AND text IS NOT null) = 0
      BEGIN
         --raiserror(15197,-1,-1,@objname)
         INSERT INTO @rtnDef(id, line)  VALUES (-15197, 'Error 03: system-object check failed');
         RETURN;
      END

      DECLARE ms_crs_syscom CURSOR LOCAL FOR SELECT text FROM master.sys.syscomments WHERE id = @objid
      ORDER BY number, colid FOR READ ONLY
   END
   ELSE
   BEGIN
      -- Find out how many lines of text are coming back,
      -- and return if there are none.
      IF
      (
         SELECT count(*) 
         FROM syscomments c, sysobjects o 
         WHERE ((o.xtype NOT IN ('S', 'U')) AND (o.id = c.id AND o.id = @objid))
      ) = 0
      BEGIN
         --RAISERROR(15197,-1,-1,@objname)
         INSERT INTO @rtnDef(id, line)  VALUES (-15197, 'Error 04: rtn has no lines')
         RETURN;
      END

      IF (SELECT count(*) FROM syscomments WHERE id = @objid AND encrypted = 0) = 0
      BEGIN
         -- RAISERROR(15471,-1,-1,@objname)
         INSERT INTO @rtnDef(id, line)  VALUES (-15471, 'Error 05: rtn has no lines*')
         RETURN;
      END

      DECLARE ms_crs_syscom  CURSOR LOCAL
      FOR SELECT text FROM syscomments WHERE id = @objid AND encrypted = 0
      ORDER BY number, colid
      FOR READ ONLY
   END

   -- ASSERTION: Parameters validated

   -- else get the text
   SELECT @LFCR   = 2;
   SELECT @LineId = 1;
   OPEN ms_crs_syscom;
   FETCH NEXT from ms_crs_syscom into @SyscomText;

   WHILE @@fetch_status >= 0
   BEGIN
      SELECT  @BasePos    = 1;
      SELECT  @CurrentPos = 1;
      SELECT  @TextLength = LEN(@SyscomText);

      WHILE @CurrentPos != 0
      BEGIN
         --Looking for end of line followed by carriage return
         SELECT @CurrentPos = CHARINDEX(CHAR(13)+CHAR(10), @SyscomText, @BasePos);

         --If carriage return found
         IF @CurrentPos != 0
         BEGIN
            -- If new value for @Lines length will be > then set the length 
            -- then insert current contents of @line and proceed.
            WHILE (isnull(LEN(@Line),0) + @BlankSpaceAdded + @CurrentPos - @BasePos + @LFCR) > @DefinedLength
            BEGIN
               SELECT @AddOnLen = @DefinedLength - (ISNULL(LEN(@Line),0) + @BlankSpaceAdded);

               INSERT @rtnDef (id, line) VALUES
               (
                  @LineId
                  ,ISNULL(@Line, N'') + ISNULL(SUBSTRING(@SyscomText, @BasePos, @AddOnLen), N'')
               );

               SELECT
                   @Line            = NULL
                  ,@LineId          = @LineId + 1
                  ,@BasePos         = @BasePos + @AddOnLen
                  ,@BlankSpaceAdded = 0;

            END -- WHILE (isnull(LEN

            SELECT @Line    = ISNULL(@Line, N'') + ISNULL(SUBSTRING(@SyscomText, @BasePos, @CurrentPos-@BasePos + @LFCR), N'')
            SELECT @BasePos = @CurrentPos+2;
            INSERT @rtnDef (id, line) VALUES( @LineId, @Line);
            SELECT @LineId  = @LineId + 1;
            SELECT @Line    = NULL;
         END  -- IF @CurrentPos != 0
         ELSE --else carriage return not found
         BEGIN
            IF @BasePos <= @TextLength
            BEGIN
               --If new value for @Lines length will be > then the defined length
               WHILE (ISNULL(LEN(@Line),0) + @BlankSpaceAdded + @TextLength-@BasePos+1 ) > @DefinedLength
               BEGIN
                  SELECT @AddOnLen = @DefinedLength - (ISNULL(LEN(@Line),0) + @BlankSpaceAdded)
                  INSERT @rtnDef (id, line) VALUES
                  (
                     @LineId
                     ,ISNULL(@Line, N'') + ISNULL(SUBSTRING(@SyscomText, @BasePos, @AddOnLen), N'')
                  );

                  SELECT @Line = NULL, @LineId = @LineId + 1,
                  @BasePos = @BasePos + @AddOnLen, @BlankSpaceAdded = 0
               END

               SELECT @Line = isnull(@Line, N'') + ISNULL(SUBSTRING(@SyscomText, @BasePos, @TextLength-@BasePos+1 ), N'')

               IF LEN(@Line) < @DefinedLength and CHARINDEX(' ', @SyscomText, @TextLength+1 ) > 0
               BEGIN
                  SELECT @Line = @Line + ' ', @BlankSpaceAdded = 1
               END
            END
         END -- -- IF @CurrentPos != 0 ELSE
      END -- WHILE @CurrentPos != 0

      FETCH NEXT FROM ms_crs_syscom INTO @SyscomText
   END -- WHILE @@fetch_status >= 0

   IF @Line IS NOT NULL
      INSERT @rtnDef (id, line) VALUES( @LineId, @Line )

   --SELECT Text FROM CommentText ORDER BY LineId
   CLOSE       ms_crs_syscom;
   DEALLOCATE  ms_crs_syscom;
   --DROP TABLE  #CommentText
   RETURN;-- (0) -- sp_helptext
END
/*
   SELECT * FROM dbo.fnGetRtnDef('dbo.AsFloat');
   EXEC test.sp_crt_tst_rtns 'dbo.fnGetRtnDef'
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ============================================================================================================================
-- Author:      Terry Watts
-- Create date: 09-MAY-2020
-- Description: checks if the routine exists
--
-- POSTCONDITIONS:
-- POST 01: RETURNS if @q_rtn_name exists then [schema_nm, rtn_nm, rtn_ty, ty_code,] , 0 otherwise
-- 
-- Changes 240723: now returns a single row table as above
--
-- Tests: test.test_029_fnChkRtnExists
-- ============================================================================================================================
ALTER FUNCTION [dbo].[fnGetRtnDetails]
(
    @qrn NVARCHAR(120)
)
RETURNS @t TABLE
(
    schema_nm     NVARCHAR(32)
   ,rtn_nm        NVARCHAR(60)
   ,rtn_ty        NCHAR(61)
   ,ty_code       NVARCHAR(25)
   ,is_clr        BIT
)

AS
BEGIN
   DECLARE
       @schema       NVARCHAR(20)
      ,@rtn_nm       NVARCHAR(4000)
      ,@ty_nm        NVARCHAR(20)

   SELECT
       @schema = schema_nm
      ,@rtn_nm = rtn_nm
   FROM test.fnSplitQualifiedName(@qrn);

   SELECT @ty_nm = ty_nm FROM dbo.sysRtns_vw WHERE schema_nm = @schema and rtn_nm = 'fn_CamelCase';

   INSERT INTO @t 
   (
       schema_nm
      ,rtn_nm   
      ,rtn_ty   
      ,ty_code  
      ,is_clr   
   )
   SELECT  
       schema_nm
      ,rtn_nm   
      ,rtn_ty   
      ,ty_code  
      ,is_clr   
   FROM dbo.sysRtns_vw WHERE schema_nm = @schema and rtn_nm = @rtn_nm;

   RETURN;
END
/*
PRINT 
EXEC tSQLt.Run 'test.test_029_fnChkRtnExists';

SELECT * FROM [dbo].[fnGetRtnDetails]('[dbo].[fnDeltaStats]');
SELECT * FROM [dbo].[fnGetRtnDetails]('[dbo].[fnIsCharType]');
SELECT * FROM [dbo].[fnGetRtnDetails]('sp_assert_rtn_exists');
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 09-MAR-2024
-- Description: this view displays the last 20 rows in teh applog in descend order by id (insertion)
--
-- CHANGES:
-- ======================================================================================================
ALTER VIEW [dbo].[applog_vw_asc]
AS
SELECT TOP 1000000
    id
   ,[level]
   ,fn
   ,row_count
   ,SUBSTRING(msg, 1, 128)   AS [msg                                                                                                                            .]
   ,SUBSTRING(msg, 129, 128) AS [msg2                                                                                                                           .]
   ,SUBSTRING(msg, 257, 128) AS [msg3                                                                                                                           .]
   ,SUBSTRING(msg, 385, 128) AS [msg4                                                                                                                           .]
FROM AppLog ORDER BY id ASC;
/*
SELECT * FROM AppLog_vw_asc
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 07-MAR-2024
-- Description: this view displays the last 20 rows in teh applog in descend order by id (insertion)
--
-- CHANGES:
-- ======================================================================================================
ALTER VIEW [dbo].[applog_vw_desc]
AS
SELECT TOP 1000000
    id
   ,[level]
   ,fn
   ,row_count
   ,SUBSTRING(msg, 1, 128)   AS [msg                                                                                                                            .]
   ,SUBSTRING(msg, 129, 128) AS [msg2                                                                                                                           .]
   ,SUBSTRING(msg, 257, 128) AS [msg3                                                                                                                           .]
   ,SUBSTRING(msg, 385, 128) AS [msg4                                                                                                                           .]
FROM AppLog ORDER BY id DESC;
/*
SELECT * FROM AppLog_vw_desc;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ============================================================================================================
-- Author:      Terry Watts
-- Create date: 08-MAR-2024
-- Description: Lists the Applog in descending order - can filter rows by parameter
--
-- Tests: test.test_fnListApplog
--
-- Changes:
-- ===========================================================================================================
ALTER FUNCTION [dbo].[fnListApplog]
(
    @fnFilter     NVARCHAR(50)   -- DEFAULT = ALL
   ,@msgFilter    NVARCHAR(128)  -- DEFAULT = ALL
   ,@idFilter     INT            -- DEFAULT = ALL
   ,@levelFilter  INT            -- DEFAULT = ALL
   ,@asc          BIT            -- DEFAULT = DESC
)
RETURNS @t TABLE
(
    id         INT
   ,fn         NVARCHAR(50)
   ,[msg                                                                                                                            .] NVARCHAR(128)
   ,[msg2                                                                                                                           .] NVARCHAR(128)
   ,[level]    INT
   ,row_count  INT
)
AS
BEGIN
   IF @asc IS NULL SET @asc = 0; -- DEFAULT = DESC

   IF @asc = 1
   BEGIN
      INSERT INTO @t(
          id
         ,fn
         ,[msg                                                                                                                            .]
         ,[msg2                                                                                                                           .]
         ,[level]
         ,row_count)
      SELECT
          id
         ,fn
         ,[msg                                                                                                                            .]
         ,[msg2                                                                                                                           .]
         ,[level]
         ,row_count
      FROM applog_vw_asc
      WHERE
         (fn LIKE @fnFilter       OR @fnFilter    IS NULL)
     AND ([msg                                                                                                                            .] LIKE @msgFilter 
                                  OR @msgFilter   IS NULL)
     AND (id      >= @idFilter    OR @idFilter    IS NULL)
     AND ([level] >= @levelFilter OR @levelFilter IS NULL)
   END
   ELSE
   BEGIN
      INSERT INTO @t(
          id
         ,fn
         ,[msg                                                                                                                            .]
         ,[msg2                                                                                                                           .]
         ,[level]
         ,row_count)
      SELECT
          id
         ,fn
         ,[msg                                                                                                                            .]
         ,[msg2                                                                                                                           .]
         ,[level]
         ,row_count
      FROM applog_vw_desc
      WHERE
         (fn LIKE @fnFilter       OR @fnFilter    IS NULL)
     AND ([msg                                                                                                                            .] LIKE @msgFilter 
                                  OR @msgFilter   IS NULL)
     AND (id      >= @idFilter    OR @idFilter    IS NULL)
     AND ([level] >= @levelFilter OR @levelFilter IS NULL)
   END;

   RETURN;
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_fnListApplog';
--                             fn    msg   id    level
SELECT * FROM dbo.fnListApplog( NULL, NULL, NULL, NULL, 1);
SELECT * FROM dbo.fnListApplog('IMPORT_STATIC_DATA%', NULL, NULL, NULL, 1);
SELECT * FROM dbo.fnListApplog('IMPORT_STATIC_DATA%', '%exception%', NULL, NULL, 1);
SELECT * FROM dbo.fnListApplog('IMPORT_STATIC_DATA%', NULL, NULL, 2);
SELECT * FROM dbo.fnListApplog('MN_IMPORT%', NULL, 260, NULL, 1);
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ================================================================
-- Author:		 Terry Watts
-- Create date: 22-OCT-20223
-- Description: List the individual entry modes and the stg2_id
--          from Staging2             
-- ================================================================
ALTER FUNCTION [dbo].[fnListChemicalActions]()
RETURNS 
@t TABLE (chemical_nm NVARCHAR(100), action_nm NVARCHAR(50))
AS
BEGIN
   INSERT INTO @t(chemical_nm, action_nm)
      SELECT DISTINCT TOP 100000
          i.value  AS ingredient
         , a.value AS [action]
      FROM Staging2 
      CROSS APPLY string_split(ingredient, '+') i
      CROSS APPLY string_split(entry_mode, ',') a
      ORDER BY ingredient, [action]
	RETURN 
END
/*
SELECT distinct chemical_nm from dbo.fnListS2_ChemicalActions(); -- 315 rows
-- WHERE chemical_nm = 'Chlorothalonil';
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===================================================
-- Author:		 Terry Watts
-- Create date: 26-JUL-20223
-- Description: List the Chemicals (Ingredients)
-- ===================================================
ALTER FUNCTION [dbo].[fnListChemicals]()
RETURNS @t TABLE (chemical NVARCHAR(250)) --, [type] NVARCHAR(35))
AS
BEGIN
   INSERT INTO @t
   SELECT DISTINCT TOP 1000
   cs.value AS chemical 
   FROM Staging2 
   CROSS APPLY string_split(ingredient, '+') cs
   WHERE cs.value <> ''
   ORDER BY cs.value;

	RETURN 
END
/*
SELECT chemical FROM dbo.fnListChemicals() --ORDER BY chemical
SELECT distinct ingredient AS chemical FROM Staging2 ORDER BY ingredient
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===========================================================
-- Author:		 Terry Watts
-- Create date: 16-NOV-2023
-- Description: List the Pathogens in order - 
-- from Stging1, 
-- This rtn is like fnListPathogens which operates on Staging2
-- 
-- ===========================================================
ALTER FUNCTION [dbo].[fnListPathogensS1]()
RETURNS 
@t TABLE (pathogen NVARCHAR(400))
AS
BEGIN
   INSERT INTO @t
   SELECT DISTINCT TOP 100000 
   cs.value AS pathogen 
   FROM Staging1 
   CROSS APPLY string_split(pathogens, ',') cs
   WHERE cs.value <> ''
   ORDER BY pathogen;

   RETURN 
END
/*
SELECT pathogen from dbo.fnListPathogensS1()
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =================================================================
-- Author:		 Terry Watts
-- Create date: 19-AUG-20223
-- Description: List the Products in order - 
--  use to help look for duplicates and misspellings and errors
-- =================================================================
ALTER FUNCTION [dbo].[fnListProducts]()
RETURNS 
@t TABLE (pathogen NVARCHAR(250))
AS
BEGIN
   INSERT INTO @t
   SELECT DISTINCT TOP 100000 
   product 
   FROM Staging2 
   ORDER BY product;

	RETURN 
END
/*
SELECT pathogen from dbo.fnListProducts()
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ================================================================
-- Author:		 Terry Watts
-- Create date: 22-OCT-20223
-- Description: List the individual entry modes and the stg2_id
--          from Staging2             
-- ================================================================
ALTER FUNCTION [dbo].[fnListSingleChemicalActions]()
RETURNS 
@t TABLE (chemical_nm NVARCHAR(100), action_nm NVARCHAR(50))
AS
BEGIN
   INSERT INTO @t(chemical_nm, action_nm)
      SELECT DISTINCT TOP 100000
      ingredient, a.value as [action] -- i.value as ingredient, 
      FROM Staging2 
      --CROSS APPLY string_split(ingredient, '+') i
      CROSS APPLY string_split(entry_mode, ',') a
      WHERE ingredient NOT LIKE '%+%'   -- single ingredients only
      ORDER BY ingredient, [action]
	RETURN 
END
/*
SELECT * from dbo.fnListS2_SingleChemicalActions()
WHERE chemical_nm = 'Chlorothalonil';

SELECT DISTINCT
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 20-SEP-2023
-- Description: lists pathogens, chemicals and crops the chemical can be used on
--
-- CHANGES:
-- 231007: uses the main tables now
-- 240129: use names not ids
-- ==============================================================================
ALTER VIEW [dbo].[rpt_chemical_pathogen_crop_vw]
AS
SELECT
    ch.chemical_nm
   ,crop_nm
   ,pc.pathogen_nm
   ,ch.chemical_id
   ,crop_id
   ,pc.pathogen_id
FROM
          Chemical         ch 
LEFT JOIN PathogenChemical pc  ON ch.chemical_nm = pc.chemical_nm
LEFT JOIN Crop_pathogen_vw cpv ON cpv.pathogen_nm = pc.pathogen_nm
/*
SELECT * FROM chemical_pathogen_crop_vw
WHERE crop_nm = 'Banana' AND pathogen_nm='Sigatoka' 
ORDER BY chemical_nm, crop_nm, pathogen_nm
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      TerryWatts
-- Create date: 24-JUN-2023
-- Description: gets the list of chemicals for
--    a given crop and pathogen
-- =============================================
ALTER FUNCTION [dbo].[fnRptGetChemicalForCropPathogen]
(
    @crop      NVARCHAR(60)
   ,@pathogen  NVARCHAR(60)
)
RETURNS
@t TABLE
(
   crop     NVARCHAR(60),
   pathogen NVARCHAR(50),
   chemical NVARCHAR(60)
)
AS
BEGIN
   INSERT INTO @t (crop, pathogen, chemical)
   SELECT crop_nm, pathogen_nm, chemical_nm
   FROM rpt_chemical_pathogen_crop_vw
   WHERE  (pathogen_nm = @pathogen OR @pathogen IS NULL)
      AND (crop_nm     = @crop     OR @crop     IS NULL)

   RETURN
END
/*
SELECT * FROM dbo.fnRptGetChemicalForCropPathogen('Banana','Sigatoka');
SELECT * FROM dbo.fnRptGetChemicalForCropPathogen(NULL, NULL);

SELECT * FROM rpt_chemical_pathogen_crop_vw where pathogen_nm = 'Sigatoka'
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      TerryWatts
-- Create date: 24-JUN-2023
-- Description: gets the list of chemicals for 
--    a given crop and pathogen
-- =============================================
ALTER FUNCTION [dbo].[fnRptGetChemicalForPathogenCrop]
(
    @pathogen  NVARCHAR(60)
   ,@crop      NVARCHAR(60)
)
RETURNS
@t TABLE
(
   crop     NVARCHAR(60),
   pathogen NVARCHAR(50),
   chemical NVARCHAR(60)
)
AS
BEGIN
   INSERT INTO @t (crop, pathogen, chemical)
   SELECT crop_nm, pathogen_nm, chemical_nm
   FROM rpt_chemical_pathogen_crop_vw
   WHERE  (pathogen_nm = @pathogen OR @pathogen  IS NULL)
      AND (crop_nm = @crop OR @crop IS NULL)

   RETURN
END
/*
SELECT * FROM dbo.fnRptGetChemicalForPathogenCrop('Sigatoka', 'Banana');
SELECT * FROM dbo.fnRptGetChemicalForPathogenCrop(NULL, NULL);
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ====================================================
-- Author:      Terry Watts
-- Create date: 28-OCT-2023
-- Description: lists the chemicals and their actions
-- ====================================================
ALTER VIEW [dbo].[ChemicalAction_vw]
AS
SELECT c.chemical_nm, a.action_nm, c.chemical_id, a.action_id
FROM ChemicalAction ca
LEFT JOIN Chemical   c ON c.chemical_id = ca.chemical_id
LEFT JOIN [Action]   a ON a.action_id   = ca.action_id 

/*
SELECT * FROM ChemicalAction_vw
DELETE FROM ChemicalAction_vw
WHERE chemical_nm in ('Azoxystrobin','Allyl Ethoxylate','Chlorothalonil','Mancozeb','Propiconazole')
ORDER BY chemical_nm, action_nm
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==================================================================================
-- Author:      Terry Watts
-- Create date: 28-OCT-2023
-- Description: lists the products and chemicals used in crops against pathogens
--
-- PRECONDITIONS:
-- ==================================================================================
ALTER VIEW [dbo].[rpt_product_chemical_pathogen_crop_vw]
AS
SELECT 
    p.product_nm
   ,cpc.chemical_nm
   ,a.action_nm
   ,crop_nm
   ,pathogen_nm
   ,p.product_id
   ,cp.chemical_id
   ,a.action_id
   ,cpc.crop_id
   ,pathogen_id
FROM        rpt_Chemical_pathogen_crop_vw  cpc
INNER JOIN  ChemicalProduct            cp ON cp.chemical_id = cpc.chemical_id
INNER JOIN  Product                    p  ON p.product_id   = cp.product_id
INNER JOIN  ChemicalAction_vw          ca ON ca.chemical_id = cp.chemical_id
INNER JOIN  [Action]                   a  ON a.action_id    = ca.action_id;
/*
SELECT * FROM rpt_product_chemical_pathogen_crop_vw WHERE crop_nm ='Banana' AND pathogen_nm='Sigatoka' ORDER BY product_nm, chemical_nm, action_nm, crop_nm, pathogen_nm;
SELECT * FROM rpt_product_chemical_pathogen_crop_vw WHERE crop_nm ='Banana' AND pathogen_nm='Fusarium Wilt' ORDER BY product_nm, chemical_nm, action_nm, crop_nm, pathogen_nm;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==================================================================================
-- Author:		 Terry Watts
-- Create date: 09-OCT-2023
-- Description: lists the products and the companies that market them
--
-- CHANGES:
--
-- ==================================================================================
ALTER VIEW [dbo].[ProductCompany_vw]
AS
SELECT TOP 100000 p.product_nm, c.company_nm, p.product_id, c.company_id
FROM ProductCompany pc
JOIN Product  p ON p.product_id  = pc.product_id 
JOIN Company c ON c.company_id   = pc.company_id
ORDER BY p.product_nm, c.company_nm

/*
SELECT TOP 50 * FROM ProductCompany_vw
SELECT product_nm, count(company_id) as cnt_companies
FROM ProductCompany_vw
GROUP BY product_nm
ORDER BY count(company_id) DESC;

*/    

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===========================================================================
-- Author:      Terry Watts
-- Create date: 28-OCT-2023
-- Description: returns the chemicals and products that can be used against
--              the pathogens that effect crops
-- ===========================================================================
ALTER FUNCTION [dbo].[fnRptGetChemicalProductForCropPathogenActionUse]
(
    @crop_nm      NVARCHAR(60)
   ,@pathogen_nm  NVARCHAR(60)
   ,@action_nm    NVARCHAR(60)
   ,@use          NVARCHAR(25)
)
RETURNS
@t TABLE
(
    chemical_nm      NVARCHAR(60)
   ,product_nm       NVARCHAR(60)
   ,company_nm       NVARCHAR(60)
   ,action_nm        NVARCHAR(60)
   ,crop_nm          NVARCHAR(60)
   ,pathogen_nm      NVARCHAR(60)
   ,use_nm           NVARCHAR(25)
   ,product_id       INT
   ,chemical_id      INT
   ,crop_id          INT
   ,pathogen_id      INT
   ,use_id           INT
)
AS
BEGIN
   INSERT INTO @t
            (   chemical_nm,    product_nm, company_nm, action_nm, crop_nm, pathogen_nm,   use_nm,    product_id,    chemical_id, crop_id, pathogen_id,   use_id)
      SELECT cu.chemical_nm, pv.product_nm, company_nm, action_nm, crop_nm, pathogen_nm, u.use_nm, pv.product_id, pv.chemical_id, crop_id, pathogen_id, u.use_id
      FROM   rpt_product_chemical_pathogen_crop_vw pv
      JOIN   ChemicalUse       cu ON cu.chemical_id = pv.chemical_id
      JOIN   [Use]             u  ON u.use_id       = cu.use_id
      JOIN   ProductCompany_vw pcv ON pcv.product_id=pv.product_id
      WHERE 
             (crop_nm     LIKE @crop_nm     OR @crop_nm     IS NULL)
         AND (pathogen_nm LIKE @pathogen_nm OR @pathogen_nm IS NULL)
         AND (action_nm   LIKE @action_nm   OR @action_nm   IS NULL)
         AND (u.use_nm    LIKE @use         OR @use         IS NULL)
     ORDER BY chemical_nm, product_nm, company_nm;

   RETURN;
END
/*
SELECT * from dbo.fnRptGetChemicalProductForCropPathogenActionUse('Banana', 'Thrips', NULL, 'Insecticide');
SELECT * from dbo.fnRptGetChemicalProductForCropPathogenActionUse('Banana', NULL, NULL, 'Insecticide');
SELECT * from dbo.fnRptGetChemicalProductForCropPathogenActionUse('Banana', 'Aphid%', NULL, NULL);
SELECT * from dbo.fnRptGetChemicalProductForCropPathogenActionUse('Banana', 'Sigatoka', 'Sys%', NULL);
SELECT * from dbo.fnRptGetChemicalProductForCropPathogenActionUse('Banana', 'Fusarium Wilt', NULL, NULL);
SELECT * from dbo.fnRptGetChemicalProductForCropPathogenActionUse('Melon', NULL, NULL, NULL);
*/

GO
GO
GO
GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 29-JUL-2023
-- Description: list all view rows with nulls in any of the following columns:
--  use_id, crop_id, pathogen_id, Chemical_id, use_id
--
-- PRECONDITIONS: 
--    Dependencies: staging 2 up to date
-- ======================================================================================================
ALTER VIEW [dbo].[all_vw_with_nulls]
AS
SELECT * FROM ALL_vw 
WHERE product_nm is NULL--product_id is NULL 
   OR use_NM IS NULL 
   OR (crop_NM     IS NULL AND crops <> '-')
   OR (pathogen_NM IS NULL AND pathogens <> '')
   OR chemical_NM  IS NULL 
   OR use_NM       IS NULL
   /*
SELECT * from all_vw_with_nulls --where crop_ID is NULL and CROPS <> '-'
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================================
-- Author:		 Terry Watts
-- Create date: 05-OCT-2023
-- Description: relates the new and old chemical ids based on name match
--              
-- CHANGES:
--    
-- ==============================================================================
ALTER VIEW [dbo].[Chemical_Chemical_staging_vw]
AS
SELECT cs.chemical_nm as new_chemical_nm, c.chemical_nm AS existing_chemical_nm, c.chemical_id as existing_chemical_id
FROM ChemicalStaging cs  LEFT JOIN Chemical c  ON c.chemical_nm = cs.chemical_nm

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================================
-- Author:		 Terry Watts
-- Create date: 05-OCT-2023
-- Description: relates teh new and exisiting product ids
--
-- CHANGES:
--    
-- ==============================================================================
ALTER VIEW [dbo].[Product_Product_staging_vw]
AS
SELECT ps.product_nm as new_product_nm, p.product_nm AS existing_product_nm, p.product_id as existing_product_id
FROM Product p LEFT JOIN ProductStaging ps ON p.product_nm = ps.product_nm;

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 05-OCT-2023
-- Description:
--list the new and old chemical names and ids and product names and ids
--
-- CHANGES:
--    
-- ==============================================================================
ALTER VIEW [dbo].[Chemical_Product_full_vw] AS
SELECT ccsv.existing_chemical_nm, cps.chemical_nm as new_chemical_nm, cps.product_nm as new_product_nm
, ppsv.existing_product_nm as ppsv_existing_product_nm, ppsv.new_product_nm as ppsv_new_product_nm
FROM Chemical_Chemical_staging_vw ccsv 
JOIN ChemicalProductStaging cps ON ccsv.existing_chemical_nm=cps.chemical_nm
JOIN Product_Product_staging_vw ppsv ON ppsv.existing_product_nm = cps.product_nm
;
/*
SELECT TOP 200 * FROM Chemical_Product_full_vw
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ====================================================================================
-- Author:      Terry Watts
-- Create date: 26-MAR-2024
-- Description: lists the chemicals and their aggregated actions on 1 row per chemical
-- ====================================================================================
ALTER VIEW [dbo].[ChemicalActionAgg_vw]
AS
SELECT chemical_nm, string_agg(action_nm,',') as actions
FROM ChemicalAction_vw
GROUP BY chemical_nm

/*
SELECT * FROM ChemicalActionAgg_vw where chemical_nm = '2,4-D Amine'
*/    

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ============================================================================================
-- Author:       Terry Watts
-- Create date:  06-OCT-2023
-- Description:  list the main table and staging table ids and names for th echemicals
--
-- Dependencies: PRECONDITION: ChemicalUse and Use tables popd with the new rows if any 
--
-- CHANGES:
--    240121: removed import_id
-- ============================================================================================
ALTER VIEW [dbo].[ChemicalUse_ChemicalStaging_vw]
AS
SELECT TOP 20000 chemical_nm, use_nm
FROM ChemicalUseStaging cs 
ORDER BY chemical_nm, use_nm;
/*
SELECT * FROM ChemicalUse_ChemicalStaging_vw;
SELECT * FROM ChemicalUseStaging;
SELECT * FROM ChemicalStaging;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==================================================================================
-- Author:      Terry Watts
-- Create date: 04-NOV-2023
-- Description: lists the chemicals and their associated uses from the main tables
-- ==================================================================================
ALTER VIEW [dbo].[ChemicalUse_vw]
AS
SELECT TOP 100000 c.chemical_nm, u.use_nm, c.chemical_id, u.use_id
FROM ChemicalUse cu
LEFT JOIN Chemical c ON c.chemical_id = cu.chemical_id
LEFT JOIN [Use]    u ON u.use_id  = cu.use_id 
ORDER BY chemical_nm, use_nm;

/*
SELECT TOP 50 * FROM ChemicalUse_vw
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===========================================================
-- Author:      Terry Watts
-- Create date: 04-NOV-2023
-- Description: lists the chemicals and their associated uses.
-- ===========================================================
ALTER VIEW [dbo].[ChemicalUses_vw]
AS
SELECT chemical_nm, string_agg(use_nm, ',') as uses
FROM
(
SELECT distinct chemical_nm, use_nm
FROM ChemicalUse
) X
GROUP BY chemical_nm
/*
SELECT * FROM ChemicalUses_vw where chemical_nm Like '%2,4-d%'
ORDER BY chemical_nm;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 14-MAR-2024
-- Description: lists the import corrections act_cnt and results
--
-- PRECONDITIONS: 
-- Dependencies: ImportCorrections pop'd
-- ======================================================================================================
ALTER View [dbo].[Corrections_vw]
AS
SELECT id, results, act_cnt, doit, command, search_clause, not_clause
FROM ImportCorrections;
/*
SELECT TOP 50 * FROM ImportCorrections_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 27-JUL-2023
-- Description: splits the individual crop out of the staging2 crops field
--    filters out empty an - or -- entries
--
-- PRECONDITIONS: Dependencies: Staging2 upto date
--   Dependencies: staging2
--
-- ======================================================================================================
ALTER VIEW [dbo].[crop_staging_vw]
AS
SELECT stg2_id, cs.value as crop FROM staging2 
CROSS Apply string_split(crops, ',') cs WHERE cs.value not in ('', '-','--');

/*
SELECT TOP 50 * FROM crop_staging_vw;
SELECT TOP 50 * FROM CropStaging
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===============================================================================
-- Author:		 Terry Watts
-- Create date: 06-NOV-2023
-- Description: Creates the SQL to cache the test state to the 221018 cache
-- ===============================================================================
ALTER VIEW [dbo].[crt_cache_221018_tables_sql_vw]
AS
SELECT CONCAT('INSERT INTO [',S.TABLE_NAME, '] (',cols,') SELECT ',cols,' FROM ', REPLACE(S.TABLE_NAME, '_221018', '')) AS [sql]
FROM 
(
SELECT TABLE_NAME, CONCAT('[',string_agg(column_name, '], ['),']') as cols--, tcv.table_oid
FROM list_table_columns_vw tcv 
WHERE is_computed = 0
GROUP BY TABLE_NAME--, so.[object_id], so.[name] 
) AS S --ON S.TABLE_NAME = o.[name]
JOIN 
(
  SELECT TABLE_NAME, column_name
  FROM list_table_columns_vw WHERE ORDINAL_POSITION = 1
) AS T ON T.TABLE_NAME = S.TABLE_NAME
WHERE  S.TABLE_NAME LIKE '%221018%'
/*
SELECT * FROM crt_cache_221018_tables_sql_vw
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===============================================================================
-- Author:		 Terry Watts
-- Create date: 06-NOV-2023
-- Description: Creates the SQL to uncache the test state from the 221018 cache
-- ===============================================================================
ALTER VIEW [dbo].[crt_uncache_221018_tables_sql_vw]
AS
SELECT CONCAT('INSERT INTO [',REPLACE(S.TABLE_NAME, '_221018', ''), '] (',cols,') SELECT ',cols,' FROM ', S.TABLE_NAME, ' ORDER BY [', T.COLUMN_NAME,'];') as [sql]
FROM
(
SELECT TABLE_NAME, CONCAT('[',string_agg(column_name, '], ['),']') as cols--, tcv.table_oid
FROM list_table_columns_vw tcv 
WHERE is_computed = 0 AND [type]='U'
GROUP BY TABLE_NAME
) AS S
JOIN 
(
  SELECT TABLE_NAME, column_name
  FROM list_table_columns_vw WHERE ORDINAL_POSITION = 1
) AS T ON T.TABLE_NAME = S.TABLE_NAME
WHERE  S.TABLE_NAME LIKE '%221018%'

/*
SELECT * FROM crt_uncache_221018_tables_sql_vw
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===================================================
-- Author:		 Terry Watts
-- Create date: 21-JUN-20223
-- Description: List the Pathogens in order - use to
--    look for duplicates and misspellings and errors
-- ===================================================
ALTER  VIEW [dbo].[distinct_pathogens_vw] 
AS
   SELECT DISTINCT TOP 100000 cs.value AS pathogen 
   FROM Staging2 
   CROSS APPLY string_split(pathogens, ',') cs
   WHERE cs.value <> ''
   ORDER BY pathogen

/*
 SELECT * FROM distinct_pathogens_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===================================================
-- Author:		 Terry Watts
-- Create date: 17-JUL-20223
-- Description: List the Pathogens in order - use to
--    look for duplicates and misspellings and errors
-- ===================================================
ALTER  VIEW [dbo].[distinct_s1_crop_vw] 
AS
   SELECT DISTINCT TOP 100000 cs.value AS crop 
   FROM Staging1 
   CROSS APPLY string_split(crops, ',') cs
   WHERE cs.value NOT IN ('','-','--')
   ORDER BY crop

/*
SELECT TOP 50 * FROM distinct_s1_crop_vw
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 29-JUL-2023
-- Description: slists the import corractions actions and results
--
-- PRECONDITIONS: Dependencies: Staging2 upto date
--   Dependencies: staging2
-- ======================================================================================================
ALTER View [dbo].[ImportCorrections_vw]
AS
SELECT 
    id,command, doit,must_update, act_cnt, results, search_clause, not_clause, replace_clause,case_sensitive, latin_name
   ,common_name, local_name, alt_names, note_clause, crops, comments
FROM ImportCorrections;
/*
SELECT TOP 50 * FROM ImportCorrections_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 09-JUL-2023
-- Description: lists the import actions that did not affect any rows
-- ======================================================================================================
ALTER VIEW [dbo].[get_non_effective_updates_vw]
AS
SELECT *
FROM ImportCorrections_vw
WHERE
       act_cnt=0 
   AND doit not in ('0', 'skip')
   AND command <> 'SKIP';

/*
SELECT TOP 50 * FROM GetNonEffectiveUpdates_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==========================================================================
-- Author:		 Terry Watts
-- Create date: 28-JUNE-2023
-- Description: lists the inport corrrections table rows that had an error
--              or no row updates occured
-- ==========================================================================
ALTER VIEW [dbo].[ICErrors_Vw]
AS
SELECT * FROM ImportCorrections WHERE act_cnt = 0;

/*
SELECT TOP 50 * FROM ICErrors_Vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 22-OCT-2023
-- Description: this view is used to import the chemical action types
--
-- PRECONDITIONS:
-- none
-- ======================================================================================================
ALTER VIEW [dbo].[Import_Actions_vw]
AS
SELECT action_nm
FROM [ActionStaging];

/*
SELECT * FROM ImportActions_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 07-NOV-2023
-- Description: this view is used to import the actions
--
-- PRECONDITIONS: none
-- ======================================================================================================
ALTER VIEW [dbo].[Import_ActionStaging_vw]
AS
SELECT action_id, action_nm
FROM Actionstaging;

/*
SELECT * FROM ImportActionStaging_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===============================================================
-- Author:      Terry Watts
-- Create date: 20-SEP-2024
-- Description: this view is used to import the call register
--
-- PRECONDITIONS: none
-- ===============================================================
ALTER VIEW [dbo].[Import_CallRegister_vw]
AS
SELECT
       id
      ,rtn
      ,limit

FROM CallRegister;

/*
SELECT * FROM Import_CallRegister_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================
-- Author:      Terry Watts
-- Create date: 29-OCT-2023
-- Description: used to import distributors to the staging table
-- ==============================================================
ALTER VIEW [dbo].[import_distributors_vw]
AS
SELECT  distributor_id, region, province, distributor_name, [address], [phone 1], [phone 2]
FROM    DistributorStaging
;

/*
SELECT * FROM import_distributors_vw
WHERE region= 'Region 11'
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==================================================================================
-- Author:      Terry Watts
-- Create date: 07-OCT-2023
-- Description: lists the products and their associated uses from the main tables
-- ==================================================================================
ALTER VIEW [dbo].[import_ProductUseStaging_vw]
AS
SELECT product_nm, use_nm
FROM ProductUseStaging;
/*
SELECT * FROM import_ProductUseStaging_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 08-MARL-2024
-- Description: this view splits out the individual uses from Staging 2 and the Use table
--
-- PRECONDITIONS: Dependencies:
--                Tables: Staging2, [Use]
--
-- ======================================================================================================
ALTER VIEW [dbo].[Import_TypeStaging_vw]
AS
SELECT [type_id], type_nm
FROM TypeStaging;
/*
SELECT * FROM Import_TypeStaging_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 29-JUL-2023
-- Description: this view splits out the individual uses from Staging 2 and the Use table
--
-- PRECONDITIONS: Dependencies:
--                Tables: Staging2, [Use]
--
-- ======================================================================================================
ALTER VIEW [dbo].[Import_Use_vw]
AS
SELECT u.use_id, u.use_nm
FROM [Use] u;

/*
SELECT TOP 50 * FROM ImportUse_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 07-NOV-2023
-- Description: this view splits out the individual uses from Staging 2 and the Use table
--
-- PRECONDITIONS: Dependencies:
--                Tables: Staging2, [Use]
--             
-- ======================================================================================================
ALTER VIEW [dbo].[Import_UseStaging_vw]
AS
SELECT TOP 1000 use_id, use_nm
FROM UseStaging
ORDER BY use_id;
/*
SELECT TOP 50 * FROM ImportUseStaging_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =====================================================================
-- Author:		 Terry Watts
-- Create date: 27-JUN-20223
-- Description: List the individual chemical (ingredient) from Staging2
-- =====================================================================
ALTER VIEW [dbo].[Ingredient_staging_vw]
AS
   SELECT stg2_id, cs.value as chemical_nm FROM Staging2 
   CROSS Apply string_split(ingredient, '+') cs;

/*
SELECT TOP 50 * FROM Ingredient_staging_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================================================================
-- Author:		Terry Watts
-- Create date: 29-JUL-2023
-- Description: this view lists company, product, ingrediant, cops and pathogens
--    from staging2             
-- ======================================================================================================
ALTER view [dbo].[IngredientCropPathogen_raw_vw]
AS
SELECT stg2_id,company, product,ingredient, crops, pathogens from staging2

/*
SELECT TOP 50 * FROM IngredientCropPathogen_raw_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ============================================================================
-- Author       Terry Watts
-- Create date: 07-FEB-2024
-- Description: List all Registered fn call counts by fn
-- ============================================================================
ALTER view [dbo].[list_call_register_vw]
AS
   SELECT id, rtn, [count], updated FROM dbo.CallRegister;

/*
SELECT * FROM list_call_register_vw  ORDER BY updated;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 04-NOV-2023
-- Description:  lists the dbo views names and create/modify dates
--
-- CHANGES:
-- ==============================================================================
ALTER VIEW [dbo].[list_objects_vw]
AS
SELECT TOP (1000) 
       [name]
      ,[type]
      ,[type_desc]
      ,[create_date]
      ,[modify_date]
    ,[is_ms_shipped]
  FROM sys.objects
  WHERE  [schema_id] =1
  AND [type] IN ('F','FN','IF','P','PK','TF','TR','U','UQ','V')
  ORDER BY [type],[name];

/*
SELECT CONCAT('SELECT TOP 20 ''',name,''' AS ',name,', * FROM ', name ) FROM list_objects_vw WHERE [type]='U' AND name LIKE '%221008'
SELECT CONCAT('SELECT COUNT(*) FROM [',name, '];')  FROM list_objects_vw WHERE [type]='U' AND name NOT like '%221008%' AND name NOT like '%staging%'
AND name NOT IN ('JapChemical','sysdiagrams');

*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================================
-- Author:		 Terry Watts
-- Create date: 05-OCT-2023
-- Description: lists the dbo tables - can be used to generate scripts
-- Can be used to generate scripts             
--
-- CHANGES:
-- ==============================================================================
ALTER VIEW  [dbo].[list_tables_vw]
AS
SELECT top 1000 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE='BASE TABLE' AND TABLE_SCHEMA='dbo' AND TABLE_NAME NOT IN ('JapChemical','ImportCorrectionsStaging_bak','staging1_bak_221008','staging1_bak','staging1', 'staging2'
,'staging2_bak_221008', 'staging3', 'staging4', 'sysdiagrams') 
ORDER BY TABLE_NAME;

/*
SELECT CONCAT('SELECT * FROM ', TABLE_NAME, ';') FROM list_tables_vw WHERE TABLE_NAME like '%_221008'
SELECT * FROM Chemical_221008;
SELECT * FROM ChemicalAction_221008;
SELECT * FROM ChemicalProduct_221008;
SELECT * FROM ChemicalUse_221008;
SELECT * FROM Company_221008;
SELECT * FROM Crop_221008;
SELECT * FROM CropPathogen_221008;
SELECT * FROM Pathogen_221008;
SELECT * FROM PathogenChemical_221008;
SELECT * FROM PathogenType_221008;
SELECT * FROM Product_221008;
SELECT * FROM ProductCompany_221008;
SELECT * FROM ProductUse_221008;
SELECT * FROM S1_221008;
SELECT * FROM S2_221008;


SELECT routine_name, created 
FROM INFORMATION_SCHEMA.ROUTINES
WHERE routine_schema='dbo'
AND 
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
/****** Script for SelectTopNRows command from SSMS  ******/
-- =============================================================
-- Author:      Terry Watts
-- Create date: 28-FEb-2024
-- Description: this view lists all the staging table names
--
-- PRECONDITIONS: none
-- =============================================================
ALTER view [dbo].[list_staging_tables_vw]
AS
SELECT TOP (1000) table_name
  FROM list_tables_vw where table_name like '%staging%';

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================
-- Author:      Terry Watts
-- Create date: 12-NOV-2023
-- Description: returns the parameters
-- e.g. sysobjects xtype code 
-- ======================================================
ALTER VIEW [dbo].[paramsVw]
AS 
SELECT
    OBJECT_NAME(sap.object_id)         AS rtn_nm
   ,sap.object_id                      AS rtn_id
   ,SCHEMA_NAME( schema_id)            AS schema_nm
   ,sap.name                           AS param_nm
   ,parameter_id                       AS ordinal_position
   ,TYPE_NAME(system_type_id)          AS ty_nm
   ,IIF( TYPE_NAME(system_type_id) IN ('VARCHAR', 'NVARCHAR', 'NTEXT')
      ,CONCAT( TYPE_NAME(system_type_id), '('
              ,iif
               ( system_type_id in (167, 231)
                ,iif(max_length= -1, 4000,max_length/2)
                , max_length
               )
              ,')'
             ) -- end concat
      ,TYPE_NAME(system_type_id)
      )          AS ty_nm_full
   ,system_type_id                     AS ty_id
   ,iif
    (
       system_type_id in (231)
      ,max_length/2, max_length
    ) AS ty_len
    , IIF(TYPE_NAME(system_type_id) IN ('VARCHAR', 'NVARCHAR', 'NCHAR','CHAR','NTEXT'), 1, 0) AS is_chr_ty
   ,is_output
   ,is_nullable
   ,has_default_value
   ,default_value
   ,dbo.fnGetTyNmFrmTyCode([type])     AS rtn_ty_nm
   ,[type]                             AS rtn_ty_code
FROM sys.all_parameters sap
     JOIN sys.all_objects so ON sap.object_id=so.object_id;

/*
SELECT * FROM paramsVw WHERE rtn_nm = 'fn_CamelCase';
SELECT * FROM paramsVw WHERE rtn_nm = 'sp_exprt_to_xl_val';
SELECT  * FROM paramsVw where param_nm ='' -- Scalar function, CLR scalar function return value
SELECT TOP 100 * FROM sys.all_parameters sap JOIN sys.all_objects so ON sap.object_id=so.object_id;
SELECT top 10 * FROM sys.sysobjects
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================================================================
-- Author:		 Terry Watts
-- Create date: 29-JUL-2023
-- Description: splits the individual pathogen out of the pathogens column in Staging2 
--
-- PRECONDITIONS: 
-- Dependencies: Staging2 table
-- ======================================================================================================
ALTER VIEW [dbo].[pathogen_staging_vw]
AS
SELECT TOP 100000 stg2_id, cs.value AS pathogen_nm FROM staging2 
CROSS APPLY STRING_SPLIT(pathogens, ',') cs 
WHERE cs.value NOT IN ('')
ORDER BY stg2_id, cs.value
;

/*
SELECT TOP 50 * FROM pathogen_staging_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =================================================================
-- Author:       Terry Watts
-- Create Date: 25-AUG-2023
-- Description: gets the pathogens related to the chemicals for each 
-- =================================================================
ALTER VIEW [dbo].[pathogen_chemical_staging_vw]
AS
SELECT DISTINCT TOP 100000
    p.pathogen_nm
   ,ch.chemical_nm
FROM 
          Staging2 s 
LEFT JOIN Ingredient_staging_vw  i  ON s.stg2_id   = i.stg2_id
LEFT JOIN Pathogen_staging_vw    pv ON pv.stg2_id  = s.stg2_id
LEFT join PathogenStaging        p  ON p.pathogen_nm = pv.pathogen_nm
LEFT join ChemicalStaging        ch ON ch.chemical_nm= i.chemical_nm
ORDER BY pathogen_nm, chemical_nm--, stg2_id;
/*
SELECT TOP 1000 * FROM pathogen_chemical_staging_vw
SELECT * FROM dbo.fnListPathogens()
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================================================================
-- Author:		 Terry Watts
-- Create date: 29-JUL-2023
-- Description: Capitalises the first letter of each pathogen in staging2
--
-- PRECONDITIONS: 
--    Dependencies: staging2 Table
-- ======================================================================================================
ALTER VIEW [dbo].[pathogens_initial_cap_vw]
AS
SELECT stg2_id, STRING_AGG( ut.dbo.fnInitialCap(cs.value), ',') as agPathogens
FROM staging2
CROSS APPLY string_split(pathogens, ',') cs
GROUP BY stg2_id;

/*
SELECT TOP 500 * FROM pathogens_initial_cap_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==================================================================================
-- Author:		 Terry Watts
-- Create date: 09-OCT-2023
-- Description: lists the products and the count of companies that market them
--
-- CHANGES:
--
-- ==================================================================================
ALTER VIEW [dbo].[ProductsCompanyCount_vw]
AS
SELECT TOP 100000 product_nm, product_id, count(company_id) as cnt_companies
FROM ProductCompany_vw
GROUP BY product_nm, product_id
ORDER BY count(company_id) DESC, product_nm ASC;

/*
SELECT TOP 150 * FROM ProductsCompanyCount_vw;

SELECT TOP 50 * FROM ProductCompany_vw;

----------------------------------------------------
SELECT * 
FROM ProductsCompanyCount_vw pcc
JOIN ProductCompany_vw       pc ON  pc.
----------------------------------------------------
SELECT product_nm, count(company_id) as cnt_companies
FROM ProductCompany_vw
GROUP BY product_nm
ORDER BY count(company_id) DESC, product_nm ASC;

*/    

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ================================================================================================
-- Author:		 Terry Watts
-- Create date: 09-OCT-2023
-- Description: lists the products and the companies and count of companies that market them
--
-- CHANGES:
--
-- ================================================================================================
ALTER VIEW [dbo].[ProductsCompanyAndCompanyCount_vw]
AS
SELECT TOP 100000 pc.product_nm, pc.product_id, pcc.cnt_companies, pc.company_nm
FROM ProductsCompanyCount_vw pcc
JOIN ProductCompany_vw       pc ON  pc.product_id=pcc.product_id
ORDER BY pc.product_nm ASC, pc.company_nm ASC;


/*
SELECT * FROM ProductsCompanyAndCompanyCount_vw ORDER BY cnt_companies DESC, product_nm ASC, company_nm ASC;


*/    

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================================
-- Author:		 Terry Watts
-- Create date: 27-JUN-20223
-- Description: used for teh bulk import of 221008 fmt imports
-- =============================================================
ALTER VIEW [dbo].[RegisteredPesticideImport_221018_vw]
AS
SELECT 
       stg1_id
      ,company
      ,ingredient
      ,product
      ,concentration
      ,formulation_type
      ,[uses]
      ,toxicity_category
      ,registration
      ,expiry
      ,entry_mode
      ,crops
      ,pathogens
      ,import_nm
  FROM [dbo].[staging1];

/*
SELECT TOP 50 * FROM RegisteredPesticideImport_221018_vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==============================================================
-- Author:		Terry Watts
-- Create date: 29-JUL-2023
-- Description: this view is used in the bulk insert operation 
--    of 230721 format imports
-- ==============================================================
ALTER VIEW [dbo].[RegisteredPesticideImport_230721_vw]
AS
SELECT 
       stg1_id
      ,[company]
      ,[ingredient]
      ,[product]
      ,[concentration]
      ,[formulation_type]
      ,[uses]
      ,[toxicity_category]
      ,[registration]
      ,[expiry]
      ,[entry_mode]
      ,[crops]
      ,[pathogens]
      ,rate-- as [RECOMMENDED RATE]
      ,mrl
      ,phi
      ,reentry_period
  FROM [dbo].[staging1];

/*
SELECT TOP 50 * FROM RegisteredPesticideImport_230721_vw;
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================================================================
-- Author:		 Terry Watts
-- Create date: 29-JUL-2023
-- Description: this view compares staging1 and 2
--
-- ======================================================================================================
ALTER VIEW [dbo].[S12_Crop_diff_vw]
AS
SELECT sb.stg1_id, sb.crops as sb_crops, s1.crops as s1_crops 
FROM staging1_bak sb FULL JOIN staging1 s1 ON sb.stg1_id=s1.stg1_id;

/*
SELECT TOP 50 * FROM S12_Crop_diff_vw;
*/


GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===================================================
-- Author:		 Terry Watts
-- Create date: 07-JUL-20223
-- Description: List the id,  Pathogens in id order 
-- ===================================================
ALTER  VIEW [dbo].[s2vw] 
AS
   SELECT stg2_id, pathogens
   FROM Staging2 

/*
SELECT TOP  50 * FROM s2vw;
*/

GO
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 29-JUL-2023
-- Description: this view splits out the individual uses from Staging 2 and the Use table
--
-- PRECONDITIONS: Dependencies:
--                Tables: Staging2, [Use]
-- ======================================================================================================
ALTER VIEW [dbo].[Use_staging2_vw]
AS
SELECT distinct TOP 20000 use_nm
FROM all_vw s
ORDER BY use_nm
/*
SELECT TOP 50 * FROM Use_staging2_vw;
*/

GO
/*

----------------------------------------------------------------------------------------------------
Summary:

Datbases              :   0 items items
Schemas               :   0 items items
Tables                :   0 items items
Procedures            : 157 items items
Functions             :  86 items items
Views                 :   0 items items
Table Types           :   0 items items
Wanted Items          : 407 items items
Consisidered Entities : 407 items items
Different Databases   :  28 items items
Duplicate Dependencies:   2 items items
System Objects        :  10 items items
Unresolved Entities   :   7 items items
Unwanted Types        :   1 items items
Bad bin               :   0 items items

*/
