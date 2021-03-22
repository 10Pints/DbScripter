SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 18-JAN-2020
-- Description: returns int if float or null if not
-- =============================================
CREATE FUNCTION [dbo].[AsFloat](@v NVARCHAR(12))
RETURNS INT
AS
BEGIN
   return TRY_CONVERT(float, @v)
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 18-JAN-2020
-- Description: returns int if int or null if not
-- =============================================
CREATE FUNCTION [dbo].[AsInt](@v NVARCHAR(12))
RETURNS INT
AS
BEGIN
	return TRY_CONVERT(int, @v)
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 24-OCT-2019
-- Description: CamelCase seps = {<spc>, ' -}
--=============================================
CREATE FUNCTION [dbo].[fnCamelCase](@str NVARCHAR(200))
RETURNS NVARCHAR(4000) AS
BEGIN
    DECLARE
     @res       NVARCHAR(200)
    ,@tmp       NVARCHAR(2000)
    ,@n         INT
    ,@FirstLen  INT
    ,@SEP       NVARCHAR(1)
    ,@len       INT = DATALENGTH(@str)
    ,@ndx       INT = 1
    ,@c         NVARCHAR(1)
    ,@seps      NVARCHAR(10) = ' -'''
    -- Init Set flag to true
    ,@flag      BIT     = 1 -- SET

    IF @str IS NULL OR Len(@str) = 0
        return @str

    -- Make all charactesrs lower case
    SET @str = LOWER(dbo.fnTrim(@str))

    -- For each character in string
    WHILE @ndx < @len
    BEGIN
        SET @c = SUBSTRING(@str, @ndx, 1)
        SET @ndx = @ndx + 1;

        -- Is character a separator?
        IF CharIndex(@c, @seps, 1) >0
        BEGIN
            -- Set the flag true
            SET @flag = 1
        END
        ELSE
        BEGIN
            -- ASSERTION: if here then we have a non seperator character

            -- Is flag set?
            IF @flag = 1
            BEGIN
                -- make uppercase
                SET @c = UPPER(@c)
                -- Set the flag false
                SET @flag = 0
            END
        END -- end if else

        SET @res = CONCAT(@res, @c);
    END  -- WHILE

    RETURN @res;
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 18-DEC-2019
-- Description: case sensitive compare helper function
-- Returns:     1 if match false 0
-- =============================================
CREATE FUNCTION [dbo].[fnCaseSensistiveCompare]
(
             @expected                  NVARCHAR(100)
            ,@actual                    NVARCHAR(100)
)
RETURNS BIT
AS
BEGIN
    DECLARE
              @exp                      VARBINARY(40)
             ,@act                      VARBINARY(40)
             ,@res                      bit  = 0
             ,@exp_is_null              bit  = 0
             ,@act_is_null              bit  = 0

    IF (@expected IS NULL)
        SET @exp_is_null = 1

    IF (@actual IS NULL)
        SET @act_is_null = 1

    IF (@exp_is_null = 1) AND (@act_is_null = 1)
        RETURN 1

    IF ( dbo.fnLEN(@expected) = 0) AND ( dbo.fnLEN(@actual) = 0)
        RETURN 1

    SET @exp = CONVERT(VARBINARY(250), @expected)
    SET @act = CONVERT(VARBINARY(250), @actual)

    IF (@exp = 0x) AND (@act = 0x)
    BEGIN
        SET @res = 1
    END
    ELSE
    BEGIN
        IF @exp = @act
            SET @res = 1
        ELSE
            SET @res = 0
    END

    -- ASSERTION @res is never NULL
    RETURN @res
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 27-DEC-2019
-- Description: Checks if a table exists
-- Returns      1 if exists, 0 otherwise
-- default schema: dbo
-- =============================================
CREATE FUNCTION [dbo].[fnCheckTableExists]
(
     @table NVARCHAR(100)
    ,@schema NVARCHAR(100) = NULL
)
RETURNS bit
AS
BEGIN
    DECLARE @ret BIT

    IF @schema IS NULL
        SET @schema = 'dbo'

    SELECT @ret = CASE WHEN
    EXISTS
    (
        SELECT 1 FROM INFORMATION_SCHEMA.TABLES
        WHERE   TABLE_TYPE='BASE TABLE'
            AND TABLE_NAME      = @table
            AND TABLE_SCHEMA    = @schema
    ) THEN 1
    ELSE 0
    END;

    RETURN @ret
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 27-DEC-2019
-- Description: Checks if a view exists
-- Returns      1 if exists, 0 otherwise
-- default schema: dbo
-- =============================================
CREATE FUNCTION [dbo].[fnCheckViewExists]
(
     @table NVARCHAR(100)
    ,@schema NVARCHAR(100) = NULL
)
RETURNS bit
AS
BEGIN
    DECLARE @ret BIT

    IF @schema IS NULL
        SET @schema = 'dbo'

    SELECT @ret = CASE WHEN
    EXISTS
    (
        SELECT 1 FROM INFORMATION_SCHEMA.VIEWS
        WHERE   TABLE_NAME      = @table
            AND TABLE_SCHEMA    = @schema
    ) THEN 1
    ELSE 0
    END;

    RETURN @ret
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =========================================================
-- Author:      Terry Watts
-- Create date: 05-JAN-2021
-- Description: function to compare values - includes an
--              approx equal check for floating point types
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

   -- if both are floating point types
   IF (dbo.[fnIsFloat](@a) = 1) AND (dbo.[fnIsFloat](@b) = 1)
      RETURN dbo.[fnCompareFloats](CONVERT(float, @a), CONVERT(float, @b));

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
GO

SET QUOTED_IDENTIFIER ON
GO

-- =====================================================================
-- Author:      Terry Watts
-- Create date: 09-MAY-2020
-- Description: This routine checks that the given routine exists
--
-- POST         returns true if routine exists, false otherwise
-- =====================================================================
CREATE FUNCTION [dbo].[fnChkRtnExists]
(
        @schema   NVARCHAR(20)
       ,@rtn_nm   NVARCHAR(4000)
)
RETURNS BIT
AS
BEGIN
   DECLARE
      @NL      NVARCHAR(2)    = NCHAR(13) + NCHAR(10)
     ,@sql     NVARCHAR(2000)
     ,@ret     BIT = 0

   IF EXISTS (SELECT 1 FROM dbo.sysRoutinesView WHERE [schema] = @schema and [name] = @rtn_nm)
      SET @ret = 1;

   RETURN @ret;
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 13-JAN-2020
-- Description: compares 2 strings character by character case sensitve
-- RETURNS  0 if MATCH
--          index of the first mismatch character
-- =============================================
CREATE FUNCTION [dbo].[fnCompare]
(
             @s1                        VARCHAR(8000)
            ,@s2                        VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
    DECLARE 
             @i                         INT = 0
            ,@len1                      INT = dbo.fnLEN(@s1)
            ,@len2                      INT = dbo.fnLEN(@s2)
            ,@len_min                   INT

    Set @len_min = dbo.fnMin(@len1, @len2)

    if (@s1 IS NULL) AND (@s2 IS NULL)
        RETURN 0

    if ((@s1 IS NULL) AND (@s2 IS NOT NULL)) OR ((@s1 IS NOT NULL) AND (@s2 IS NULL))
        RETURN 1

    -- Do a character by character comparison of the common characters
    --  in each string before comparing the lengths to find first mismatch
    WHILE @i <= @len_min
    BEGIN
        IF ASCII( SUBSTRING(@s1, @i, 1)) <> ASCII( SUBSTRING(@s2, @i, 1))
            RETURN @i;

        SET @i = @i + 1
    END

    -- Assertion character match on the common string - so return the min len
    if @len1 <> @len2
        RETURN dbo.fnMin(@len1, @len2) + 1

    RETURN 0;
END
GO

SET ANSI_NULLS ON
GO

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
CREATE FUNCTION [dbo].[fnCompareFloats](@a FLOAT, @b FLOAT)
RETURNS INT
AS
BEGIN
   RETURN
      [dbo].[fnCompareFloats2](@a, @b, 0.00001);
END

/*
-- Test
DECLARE    @a        FLOAT
         , @b        FLOAT
         , @epsilon  FLOAT
         , @res      BIT;

SET @res = [dbo].[fnCompareFloats](0.1, 0.1)
EXEC dbo.sp_assert_equals @res, 1
SET @res = [dbo].[fnCompareFloats](0.10001, 0.1)
EXEC dbo.sp_assert_equals @res, 1
SET @res = [dbo].[fnCompareFloats](0.1, 0.10001)
EXEC dbo.sp_assert_equals @res, 1

-- Fail tests
SET @res = [dbo].[fnCompareFloats](0.1, 0.100011)
EXEC dbo.sp_assert_equals @res, 0

SET @res = [dbo].[fnCompareFloats](0.100011, 0.1)
EXEC dbo.sp_assert_equals @res, 0
*/
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ============================================================
-- Author:      Terry Watts
-- Create date: 04-JAN-2021
-- Description: determines if 2 floats are approximately equal
-- Returns    : 1 if a significantly gtr than b
--              0 if a = b with the signifcance of epsilon 
--             -1 if a significantly less than b within +/- Epsilon, 0 otherwise
-- ============================================================
CREATE FUNCTION [dbo].[fnCompareFloats2](@a FLOAT, @b FLOAT, @epsilon FLOAT)
RETURNS INT
AS
BEGIN
   DECLARE   @v      FLOAT
            ,@res    INT

   SET @v   = abs(@a - @b);
   
   if(@v < @epsilon)
      RETURN 0  -- a = b with the signifcance of epsilon

   -- ASSERTION  a is not signifcantly equal to b

   SET @v   = round(@v, 7);

   SET @res = IIF( @v<@epsilon, 1, 0);
   RETURN @res;
END

/*
-- Test
DECLARE    @a        FLOAT
         , @b        FLOAT
         , @epsilon  FLOAT
         , @res      BIT;

SET @res = [dbo].[fnCompareFloats2](0.1, 0.1, 0.00001)
EXEC dbo.sp_assert_equals @res, 1
SET @res = [dbo].[fnCompareFloats2](0.10001, 0.1, 0.00001)
EXEC dbo.sp_assert_equals @res, 1
SET @res = [dbo].[fnCompareFloats2](0.1, 0.10001, 0.00001)
EXEC dbo.sp_assert_equals @res, 1

-- Fail tests
SET @res = [dbo].[fnCompareFloats2](0.1, 0.100011, 0.00001)
EXEC dbo.sp_assert_equals @res, 0

SET @res = [dbo].[fnCompareFloats2](0.100011, 0.1, 0.00001)
EXEC dbo.sp_assert_equals @res, 0
*/


GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2021
-- Description: determines if the string contains whitespace
--
-- whitespace is: 
-- (NCHAR(9), NCHAR(10), NCHAR(11), NCHAR(12), NCHAR(13), NCHAR(14), NCHAR(32), NCHAR(160))
--
-- RETURNS: 1 if string contains whitspace, 0 otherwise
-- =============================================
CREATE FUNCTION [dbo].[fnContainsWhitespace]( @s NVARCHAR(4000)) 
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
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 19-JAN-2020
-- Description: Counts the lines in a block of text
-- =============================================
CREATE FUNCTION [dbo].[fnCountLines](@txt NVARCHAR(4000) )
RETURNS INT
AS
BEGIN
    -- Declare the return variable here
    DECLARE 
             @NL                        NVARCHAR(2)     = NCHAR(13)+NCHAR(10)
            ,@ln_num                    INT             = 0
            ,@len                       INT             = LEN(@txt)
            ,@ln_end                    INT             = -1

    IF(@txt IS NULL) OR (@len = 0)
        return 0;

    -- If the text does not end in a NL append one
    IF SUBSTRING(@txt, @len-2,2) <> @NL
        SET @txt = CONCAT(@txt, @NL)

    -- Iterate the text taking line by line
    -- foreach line
    WHILE ( @ln_end < @len)
    BEGIN
        -- ASSERTION at the beginning of the Line
        -- Get  the start and end pos
        --SET @ln_start = @ln_end + 2
        SET @ln_end   = CHARINDEX(@NL, @txt, @ln_end + 2)

        -- If no more lines
        IF @ln_end = 0
            BREAK;

        -- Increment the line counter
        SET @ln_num = @ln_num + 1
    END

    return @ln_num
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =========================================================================================
-- Author:      Terry Watts
-- Create date: 13-JAN-2020
-- Description: returns a partial SQL script to create a table
-- for use with fnReplaceTabsAndReformat(x,y)
--
-- Parameters:
--    @qlfd_rtn_nm: <db>.<schema>.<rtn>
-- RETURNS: like
--
--  IF NOT EXISTS (SELECT * FROM sysobjects WHERE name=[',@table_nm,'] and xtype=''U'')
--      CREATE TABLE [dbo].[',@table_nm,']
--      (
--          [txt] [NVARCHAR](MAX) NULL,
--          [id] [INT] IDENTITY(1,1) NOT NULL,
--          CONSTRAINT [PK_tmp_rfr2] PRIMARY KEY CLUSTERED ([id] ASC )
--       );
--
--  TRUNCATE TABLE ',@table_nm, @NL
--  ,'INSERT INTO tmp_rfr EXEC SP_helptext @name ',@NL
--  ,'SELECT '
--
-- Dependencies: none
--
-- PRECONDITIONS:
-- 1.  the database that the table is in must be the current database
-- 2.  @qlfd_rtn_nm must be a qualified name: like schema.spname
/*
DROP FUNCTION [dbo].[fnCreateRoutineLinesTableAndPopulateScript]
CREATE  ALTER
*/
-- =============================================
CREATE FUNCTION [dbo].[fnCreateRoutineLinesTableAndPopulateScript]
(
       @qlfd_rtn_nm  NVARCHAR(50)
      ,@tbl_nm       NVARCHAR(50)
)
RETURNS NVARCHAR(4000)
AS
BEGIN
   DECLARE
       @sql          NVARCHAR(4000)
      ,@NL           NVARCHAR(2)    = NCHAR(13)+NCHAR(10)
      ,@db           NVARCHAR(20)
      ,@ndx          INT

   SET @ndx = CHARINDEX( '.', @qlfd_rtn_nm)
   SET @db  = SUBSTRING( @qlfd_rtn_nm, 1, CHARINDEX( '.', @qlfd_rtn_nm, @ndx) -1);

   SET @sql = CONCAT('IF NOT EXISTS (SELECT * FROM ',@db,'.dbo.sysobjects WHERE name=''', @tbl_nm, ''' and xtype=''U'')
   CREATE TABLE [',@db,'].[dbo].[', @tbl_nm, ']
   (
      [txt] [NVARCHAR](MAX) NULL,
      [id] [INT] IDENTITY(1,1) NOT NULL,
      CONSTRAINT [PK_', @tbl_nm, '] PRIMARY KEY CLUSTERED ([id] ASC )
   );

TRUNCATE TABLE [',@db,'].[dbo].[', @tbl_nm, ']
INSERT   INTO  [',@db,'].[dbo].[', @tbl_nm, ']
EXEC SP_helptext ''', @qlfd_rtn_nm, '''', @NL, @NL
,'SELECT ')

   RETURN @sql;
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 26-JAN-2020
-- Description: increments @pos until a non whitespace charactes found
-- Returns:     1 based index of the first non space character in @txt from index @pos
--              or 0 if not found
-- =============================================
CREATE FUNCTION [dbo].[fnEatWhitespace](@txt NVARCHAR(MAX), @pos INT)
RETURNS INT
AS
BEGIN
   DECLARE
       @len    INT
      ,@c      NCHAR(1)

   -- 0 based
   SET @len = dbo.fnLen(@txt)

   IF (@txt IS NULL) OR (@len = 0)
   BEGIN
      RETURN 1;
   END

   IF (@pos IS NULL) OR (@pos < 0)
      SET @pos = 0;

   -- Remove any whitespace
   WHILE @pos <= @len
   BEGIN
      SET @c = SUBSTRING(@txt, @pos, 1);

      IF dbo.fnIsWhitespace( @c) = 0
         BREAK;

      SET @pos = @pos + 1
   END

   RETURN @pos
   END

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnFileExists](@path varchar(512))
RETURNS BIT
AS
BEGIN
     DECLARE @result INT
     EXEC master.dbo.xp_fileexist @path, @result OUTPUT
     RETURN cast(@result as bit)
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 27-JAN-2020
-- Description: Finds one of a set of comma sepretd search items in string s
-- Returns:     The 1 based index if found or 0
-- =============================================
CREATE FUNCTION [dbo].[fnFindOneOf]( @items NVARCHAR(500), @s  NVARCHAR(500), @sep NCHAR = ',')
RETURNS INT
AS
BEGIN
    DECLARE @rc INT = 0
    DECLARE @item  NVARCHAR(500)

    IF @sep IS NULL SET @sep =  ','

    SELECT TOP 1 @rc = CHARINDEX(@item, @s) From [dbo].[fnSplit](@items, @sep)
    WHERE CHARINDEX(@item, @s) <> 0
    RETURN @rc
END

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnFolderExists](@path varchar(512))
RETURNS BIT
AS
BEGIN
     DECLARE @result INT
     RETURN dbo.fnFileExists (@path + '\nul')
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry watts
-- Create date: 28-DEC-2019
-- Description:Returns a date formatted as dd-MMM-YYYY
-- =============================================
CREATE FUNCTION [dbo].[fnFormatDate]
(
    @date DATE
)
RETURNS NVARCHAR(12)
AS
BEGIN
    RETURN CONCAT( format (DAY(@date), '0#'), '-', UPPER(Convert(char(3), @date, 0)), '-', YEAR(@date))
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 09-JAN-2020
-- Description: List parameters - 
--
-- Example usge:
-- INPUT:
--              @workbook_path             NVARCHAR(260)
--             ,@range                     NVARCHAR(50)            -- can be a range or a sheet
--             ,@select_cols               NVARCHAR(2000)          -- select column names for the insert to the table: can apply functions to the columns at this point
--             ,@xl_cols                   NVARCHAR(2000) = ''*''  -- XL column names: can be *
--             ,@extension                 NVARCHAR(50)   = ''''   -- e.g. ''HDR=NO;IMEX=1''
--             ,@whereClause               NVARCHAR(2000) =''      -- Where clause like "WHERE province <> ''"  or ""
--
-- OUTPUT
--     EXEC sp_log @fn, 'starting '
--             ,'@msg              =[', @msg              ,']', @NL 
--             ,'@table_nm         =[', @table_nm         ,']', @NL 
--             ,'@folder           =[', @folder           ,']', @NL 
--             ,'@workbook_nm      =[', @workbook_nm      ,']', @NL 
--             ,'@sheet_nm         =[', @sheet_nm         ,']', @NL 
--             ,'@view_nm          =[', @view_nm          ,']', @NL 
--             ,'@filter           =[', @filter           ,']', @NL 
--             ,'@create_timestamp =[', @create_timestamp ,']', @NL 
--             ,'@max_rows         =[', @max_rows         ,']', @NL 
-- =============================================
CREATE FUNCTION [dbo].[fnFormatParams] (@params NVARCHAR(4000) )
RETURNS @t TABLE(id INT, stpos INT, endpos INT, sz INT, item NVARCHAR(200))
AS
BEGIN
    WITH Split(id, stpos, endpos, sz)
    AS
    (
        SELECT
            1 as id
            ,CHARINDEX('@', @params)                                        AS stpos
            ,CHARINDEX(' ', @params, CHARINDEX('@', @params))               AS endpos
            ,CHARINDEX(' ', @params, CHARINDEX('@', @params))               AS sz
        UNION ALL
        SELECT 
                id + 1 as id
            ,CHARINDEX('@', @params, endpos+1)                              AS stpos
            ,CHARINDEX(' ', @params, CHARINDEX('@', @params, endpos+1)+1)   AS endpos
            ,CHARINDEX(' ', @params, CHARINDEX('@', @params, endpos+1))-CHARINDEX(' ', @params, CHARINDEX('@', @params, endpos+1)+1)   AS sz
        FROM Split
        WHERE CHARINDEX(',', @params, endpos+1) > 1
    )
    , LenFld (szm)
    AS
    (
        SELECT MAX( sz) FROM Split
    )

    INSERT INTO  @t (id, stpos, endpos, sz, item) 
    (
        SELECT 
                id
            ,stpos, endpos, sz
            ,CONCAT
            ( 
                    '            ,'''
                , substring(@params,stpos, endpos-stpos)
                ,'=['', '
                , substring(@params,stpos, endpos-stpos)
                ,','']''',', @NL'
            )  AS item
        FROM Split,LenFld
        UNION
        SELECT 999999, 0,0,0,''
    )

    RETURN;
END
/*
EXEC dbo.sp_reformat_routine '[fnGetDisplayParamsString]'
*/
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry watts
-- Create date: 17-MAR-2020
-- Description: Returns today's date formatted as dd-MMM-YYYY
-- =============================================
CREATE FUNCTION [dbo].[fnFormatTodaysDate]()
RETURNS NVARCHAR(12)
AS
BEGIN
    RETURN [dbo].[fnFormatDate]( CONVERT(DATE, GETDATE(), 0));
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Terry Watts
-- Create date: 24-DEC-2019
-- Description:	produces a comma separated list of column names from a table or view
-- =============================================
CREATE FUNCTION [dbo].[fnGetColumnNames] 
(
	@table_or_view NVARCHAR(80)
)
RETURNS NVARCHAR(2000)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @columns NVARCHAR(2000)

	-- Get the data from a view if supplied, else the raw table data
	SELECT @columns = CONCAT(@columns,',', column_name) -- + column_name
	FROM   INFORMATION_SCHEMA.COLUMNS
	WHERE  table_name = @table_or_view

	-- Remove the first comma
	RETURN SUBSTRING(@columns, 2, LEN(@columns)-1)
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      TERRY WATTS
-- Create date: SEP-2019
-- Description: Creates an error message based on the current exception
-- =============================================
CREATE FUNCTION [dbo].[fnGetErrorMsg]() 
RETURNS NVARCHAR(3000)
AS
BEGIN
   RETURN 
      CONCAT
      (
          'Error ', ERROR_NUMBER()
         ,iif
         ( 
            ERROR_NUMBER() >=0, 
            CONCAT( ' MSG: ', 
            ERROR_MESSAGE()), ''
         )
         , ' Ln: ', ERROR_LINE()
         , ' st: ', ERROR_STATE()
      );
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 28-DEC-2019
-- Description: List Function details of all the functions
-- =============================================
CREATE FUNCTION [dbo].[fnGetFunctionDetails]
(
             @like                      NVARCHAR(50)    = '%'
            ,@not_like                  NVARCHAR(50)    = ''
            ,@schema                    NVARCHAR(30)    = 'dbo'
)
RETURNS TABLE
AS
RETURN
    (
        SELECT * FROM dbo.fnGetRoutineDetails('F', @like, @not_like, @schema)
    )
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =========================================================================
-- Author:      Terry Watts
-- Create date: 10-MAY-2012
-- Description: returns the substring in sql starting at pos until new line 
--              or 100 chars max, or the remaining string whichever is the 
--              the shortest
-- =========================================================================
CREATE FUNCTION [dbo].[fnGetLine]( @sql NVARCHAR(MAX), @pos INT)
RETURNS NVARCHAR(100)
AS
BEGIN
   RETURN dbo.fnGetLine2(@sql, @pos, 100)
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =========================================================================
-- Author:      Terry Watts
-- Create date: 10-MAY-2012
-- Description: returns the substring in sql starting at pos until 
--              depending on @req_len
--              if 0  then to the new line or if NL not found then, or the remaining string
--              if -1 then teh entire string from and includng @pos
--
-- Called by dbo.fnGetLine
--
-- Tests:
-- =========================================================================
CREATE FUNCTION [dbo].[fnGetLine2]( @sql NVARCHAR(MAX), @pos INT, @req_len INT = 0)
RETURNS NVARCHAR(4000)
AS
BEGIN
   DECLARE
    @len             INT         = 0 
   ,@ln_end          INT
   ,@NL              NVARCHAR(2) = NCHAR(13) + NCHAR(10)

   SET @len = LEN(@sql) - @pos + 1;

   IF @len<1
      SET @len = 1;

   SET @ln_end = CHARINDEX(@NL, @sql, @pos);

   SET @req_len =
      CASE
         WHEN @req_len IS NULL OR @req_len = 0
            THEN IIF( @ln_end <> 0, @ln_end-@pos, 100)
         WHEN @req_len = -1
            THEN @len
         ELSE @req_len
         END;

   RETURN CONCAT('[', SUBSTRING(@sql, @pos, @req_len), ']');
END

/*
Print dbo.fnGetLine2('1234567890asd'+NCHAR(13) + NCHAR(10)+'fghjkl', 3,2)
Print dbo.fnGetLine2('1234567890asd'+NCHAR(13) + NCHAR(10)+'fghjkl', 3,0)
*/
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 15-JAN-2020
-- Description: returns standard NL char(s)
-- =============================================
CREATE FUNCTION [dbo].[fnGetNL]()
RETURNS NVARCHAR(2)
AS
BEGIN
    RETURN NCHAR(13)+NCHAR(10)
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================================
-- Author:      Terry Watts
-- Create date: 27-MAY-2020
-- Description: gets the n-th substring in str separated by sep
--              1 based numbering but [0] and [1] return 
--                the first element in the sequence
-- =============================================================
CREATE FUNCTION [dbo].[fnGetNthSubstring]
(
    @str    NVARCHAR(4000)
   ,@sep    NVARCHAR(100)
   ,@n      INT
)
RETURNS NVARCHAR(4000)
AS
BEGIN
   DECLARE 
      @s       NVARCHAR(4000) = @str
     ,@sub     NVARCHAR(4000)
     ,@s1      NVARCHAR(4000)
     ,@s2      NVARCHAR(4000)
     ,@ndx     INT    = 1
     ,@p1      INT    = 0
     ,@p2      INT    = 0
     ,@len     INT    = 0

   SET @p1  = CHARINDEX(@sep, @s);

   IF @p1 = 0
      SET @p1 = LEN(@s)+1;

   SET @s1 = SUBSTRING(@s,   1, @p1-1);
   SET @len = @p1-1;

   IF @ndx < @n
   BEGIN
      -- Recursive SUBSTRING(@s, @p1+len(@sep), len(@s)-@p1);
      SET @p2 =  @p1+len(@sep);
      SET @s2   = SUBSTRING(@s, @p2, len(@s)-@p2+1);
      SET @sub  = [dbo].[fnGetNthSubstring](@s2, @sep, @n-1);
   END
   ELSE
   BEGIN
      -- End case
      SET @sub  = SUBSTRING(@s, 1, @len);-- Len(@sep)
   END

   RETURN @sub
END

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 12-SEP-2019
-- Description: returns the sql clause to open the rowset to the set of colmns provided
--              wraps the openrowset for excel to make it easier to use
--
-- RETURNS a sql substring that can be used to open a rowset to an Excel range
--
-- R01: If @ext is not supplied then is defaulted to 'HDR=YES;IMEX=1'
-- R02: Makes sure a $ exists in the range - appending one if not to the end
-- R03: If the columns are not specified use * to get all columns
-- =============================================
CREATE FUNCTION [dbo].[fnGetOpenRowSetXL_SQL]
(
       @wrkbk     NVARCHAR(260)
      ,@range     NVARCHAR(50)   = 'Sheet1$'
      ,@xl_cols   NVARCHAR(2000) = NULL --'*'        -- select XL column names: can be *
      ,@ext       NVARCHAR(50)   = NULL       -- default: 'HDR=NO;IMEX=1'
)
RETURNS NVARCHAR(4000)
AS
BEGIN
   DECLARE
       @sql       NVARCHAR(4000)
      ,@NL        NVARCHAR(2)    = NCHAR(13) + NCHAR(10)

      -- Defaults: 
      -- @xl_cols = '*'
      if @xl_cols IS NULL SET @xl_cols = '*';

   -- Checks the file exists, returns NULL if not
   --IF dbo.fnFileExists(@wrkbk) = 0
    --  return NULL

   -- If @ext is not supplied then is defaulted to 'HDR=YES;IMEX=1'
   IF @ext IS NULL
      SET @ext = 'HDR=YES;IMEX=1'

   -- Makes sure a $ exists in the range - appending one if not to the end
   IF CHARINDEX('$', @range, 1) = 0
      SET @range = CONCAT(@range, '$');

   SET @sql = CONCAT('OPENROWSET ( ''Microsoft.ACE.OLEDB.12.0'','     ,@NL   -- OPENROWSET ( 'Microsoft.ACE.OLEDB.12.0',
      ,'''Excel 12.0;',@ext,' Database=', @wrkbk, ''',' ,@NL   -- 'Database=C:\Public\R02.xlsx',
      ,'''SELECT ', @xl_cols                                          ,@NL   -- SELECT id,   Region, Province, City, bgy, pop_2015
      ,'FROM [',@range, ']'' )' );

   RETURN @sql;
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Terry Watts
-- Create date: 28-DEC-2019
-- Description:	List Procedure details
-- =============================================
CREATE FUNCTION [dbo].[fnGetProcedureDetails]
(
       @like      NVARCHAR(50)   = '%'
      ,@not_like  NVARCHAR(50)   = ''
      ,@schema    NVARCHAR(30)   = 'dbo'
)
RETURNS TABLE 
AS
RETURN 
   (
      SELECT * FROM dbo.fnGetRoutineDetails('P', @like, @not_like, @schema)
   )

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 28-DEC-2019
-- Description: List routine details of all the functions
-- =============================================
CREATE FUNCTION [dbo].[fnGetRoutineDetails]
(
       @type      NVARCHAR(30)   = ''
      ,@like      NVARCHAR(50)   = '%'
      ,@not_like  NVARCHAR(50)   = ''
      ,@schema    NVARCHAR(30)   = 'dbo'
)
RETURNS TABLE
AS
RETURN
   (SELECT TOP 2000 ROUTINE_SCHEMA, ROUTINE_NAME, ROUTINE_TYPE, dbo.fnFormatDate(CREATED) AS CREATED, dbo.fnFormatDate(LAST_ALTERED) AS LAST_ALTERED
   FROM INFORMATION_SCHEMA.ROUTINES s
   WHERE
           ROUTINE_TYPE     LIKE CONCAT(@type, '%')
       AND ROUTINE_SCHEMA   LIKE @schema
       AND ROUTINE_NAME     LIKE @like
       AND ROUTINE_NAME NOT LIKE @not_like
   ORDER BY ROUTINE_NAME)
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 28-DEC-2019
-- Description: List routine details of all the functions
-- =============================================
CREATE FUNCTION [dbo].[fnGetRoutineDetails2]
(
    @type      NVARCHAR(30)   = '%'
   ,@rtn_nm    NVARCHAR(50)   = '%'
   ,@not_like  NVARCHAR(50)   = NULL
   ,@schema    NVARCHAR(30)   = 'dbo'
)
RETURNS @t TABLE
(
  ROUTINE_SCHEMA  NVARCHAR(256)
, ROUTINE_NAME    NVARCHAR(256)
, ROUTINE_TYPE    NVARCHAR(40)
, CREATED         DATETIME
, LAST_ALTERED    DATETIME
)
AS
BEGIN
   IF @not_like IS NOT NULL
   BEGIN
      INSERT INTO @t (ROUTINE_SCHEMA, ROUTINE_NAME, ROUTINE_TYPE, CREATED, LAST_ALTERED)
         SELECT TOP 2000 ROUTINE_SCHEMA, ROUTINE_NAME, ROUTINE_TYPE, dbo.fnFormatDate(CREATED) AS CREATED, dbo.fnFormatDate(LAST_ALTERED) AS LAST_ALTERED
         FROM INFORMATION_SCHEMA.ROUTINES s
         WHERE
                 ROUTINE_TYPE     LIKE @type
             AND ROUTINE_SCHEMA   LIKE @schema
             AND ROUTINE_NAME     LIKE @rtn_nm
             AND ROUTINE_NAME NOT LIKE @not_like
         ORDER BY ROUTINE_NAME;
   END
   ELSE
   BEGIN
      INSERT INTO @t (ROUTINE_SCHEMA, ROUTINE_NAME, ROUTINE_TYPE, CREATED, LAST_ALTERED)
         SELECT TOP 2000 ROUTINE_SCHEMA, ROUTINE_NAME, ROUTINE_TYPE, dbo.fnFormatDate(CREATED) AS CREATED, dbo.fnFormatDate(LAST_ALTERED) AS LAST_ALTERED
         FROM INFORMATION_SCHEMA.ROUTINES s
         WHERE
                 ROUTINE_TYPE     LIKE @type
             AND ROUTINE_SCHEMA   LIKE @schema
             AND ROUTINE_NAME     LIKE @rtn_nm
         ORDER BY ROUTINE_NAME;
   END

   RETURN
END

/*
SELECT * FROM dbo.fnGetRoutineDetails2(@type      NVARCHAR(30)   = ''
   ,@like      NVARCHAR(50)   = '%'
   ,@not_like  NVARCHAR(50)   = NULL
   ,@schema    NVARCHAR(30)   = 'dbo'
)


SELECT TOP 20 ROUTINE_SCHEMA, ROUTINE_NAME, ROUTINE_TYPE, dbo.fnFormatDate(CREATED) AS CREATED, dbo.fnFormatDate(LAST_ALTERED) AS LAST_ALTERED
   INTO  asdf
   FROM INFORMATION_SCHEMA.ROUTINES s

*/
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ======================================================
-- Author:      Terry Watts
-- Create date: 25-MAY-2020
-- Description: Get session context as int - default = 0
-- RETURNS      will return an INT even 
--          if no key/value pressent in teh session map
-- ======================================================
CREATE FUNCTION [dbo].[fnGetSessionContextAsInt](@key NVARCHAR(100))
RETURNS INT
BEGIN
   DECLARE     @v INT
   SET @v = CONVERT(INT,  SESSION_CONTEXT(@key));

   IF @v  IS NULL
      SET @v = 0;

   RETURN @v;
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ====================================================
-- Author:      Terry Watts
-- Create date: 16-OCT-2019
-- Description: Creates a timestamp like 191229-2245
-- Format:      <YYMMDD-HHMM>
-- Notes:       If the supplied date time is NULL then
--              uses the current date and time
-- TESTED 200619, T03
-- ====================================================
CREATE FUNCTION [dbo].[fnGetTimestamp](@dt SMALLDATETIME)
RETURNS NVARCHAR(12)
AS
BEGIN
   -- Declare the return variable here
   DECLARE @timestamp  NVARCHAR(30)

   IF @dt IS NULL
      SET @dt = GetDate();

   SET @timestamp = CONCAT(CONVERT( NVARCHAR, @dt, 12),'-', CONVERT(NVARCHAR, @dt, 108), ':', '');
   SET @timestamp = CONCAT(LEFT(@timestamp, 7),SUBSTRING(@timestamp,8,2),SUBSTRING(@timestamp,11,2));
   RETURN @timestamp
END

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===================================================
-- Author:      Terry Watts
-- Create date: 31-JAN-2021
-- Description: returns the week start date (Sunday)
-- ===================================================
CREATE FUNCTION [dbo].[fnGetWeekStartDate](@d Date)
RETURNS DATE
AS
BEGIN
   if @d IS NULL SET @d = GetDate();

   RETURN Cast(DATEADD(dd, -(DATEPART(WEEKDAY, @d)-1), DATEADD(dd, DATEDIFF(dd, 0, @d), 0)) AS DATE);
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 09-SEP-2019
-- Description: 
-- RETURNS: sql to select columns from an open rowset to and Excel range (or worksheet) 
--  or NULL if XL file not found
-- =============================================
CREATE FUNCTION [dbo].[fnGetXLOpenRowsetSelectSql]
(
             @workbook_path             NVARCHAR(260)
            ,@range                     NVARCHAR(50)            -- can be a range or a sheet
            ,@select_cols               NVARCHAR(2000)          -- select column names for the insert to the table: can apply functions to the columns at this point
            ,@xl_cols                   NVARCHAR(2000) = '*'    -- XL column names: can be *
            ,@extension                 NVARCHAR(50)   = ''     -- e.g. 'HDR=NO;IMEX=1'
            ,@where_clause              NVARCHAR(2000) =''      -- Where clause like "WHERE province <> ''"  or ""
)
RETURNS NVARCHAR(4000)
AS
BEGIN
    DECLARE
             @sql                       NVARCHAR(4000)
            ,@open_rowset_clause        NVARCHAR(MAX)
            ,@NL                        NVARCHAR(2)     = NCHAR(13)+NCHAR(10)

    -- Get the open rowset SQL 
    SET @open_rowset_clause = UT.dbo.fnGetOpenRowSetXL_SQL(@workbook_path, @range, @xl_cols, @extension)

    -- Return NULL if XL workbook file not found
    IF @open_rowset_clause IS NULL
        RETURN NULL

    -- Create the selct<cols> from the open rowset clause 
    SET @sql = CONCAT('SELECT ', @select_cols, CHAR(10), 'FROM ', @open_rowset_clause, ' ',@where_clause);       -- Where clause like "WHERE province <> ''
    -- return sql to select columns from an open rowset to and Excel range 
    RETURN @sql
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry watts
-- Create date: 18-MAY-2020
-- Description: lists routine definitions in rows 
-- overcoming the 4000 char limit of dbo.SysRoutinesView
-- or any method based on INFORMATION_SCHEMA.ROUTINES
--
-- Usage SELECT def FROM dbo.[fnGrepSchema]('test', '%name%', '%content filter%') 
-- =============================================
CREATE FUNCTION [dbo].[fnGrepSchema]
(
       @schema_filter  NVARCHAR(20)
      ,@name_filter    NVARCHAR(50)
      ,@content_filter  NVARCHAR(500)
)
RETURNS @T TABLE
(
    rtn_name      NVARCHAR(100)
   ,[schema]      NVARCHAR(20)
   ,[type_desc]   NVARCHAR(30)
   ,seq           INT
   ,[len]         INT
   ,create_date   DATE
   ,def           NVARCHAR(4000)
)
AS
BEGIN
   IF @content_filter IS NULL
   BEGIN
      INSERT INTO @t (rtn_name, [schema], [type_desc], seq, [len] ,create_date, def) 
      SELECT          [name], [schema], [type_desc], seq, [len], create_date, def
      FROM [dbo].[sysroutinesview2]
      WHERE [schema] LIKE @schema_filter AND [name] LIKE @name_filter
      ORDER BY [name], seq;
   END
   ELSE
   BEGIN
      INSERT INTO @t (rtn_name, [schema], [type_desc], seq, [len] ,create_date, def) 
      SELECT          [name],   [schema], [type_desc], seq, [len], create_date, def
      FROM [dbo].[sysroutinesview2]
      WHERE [schema] LIKE @schema_filter AND [name] LIKE @name_filter AND def like @content_filter
      ORDER BY [name], seq;
   END

   RETURN;
END


/*
  SELECT def FROM dbo.fnGrepSchema('test', '%name%', '%content filter%') 
*/
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ====================================================================
-- Author:      Terry Watts
-- Create date: 01-FEB-2021
-- Description: determines if a sql_variant is of type binary
-- ====================================================================
CREATE FUNCTION [dbo].[fnIsBinary](@v SQL_VARIANT)
RETURNS BIT
AS
BEGIN
   DECLARE @type SQL_VARIANT
   DECLARE @ty   NVARCHAR(500)
   SELECT @type = SQL_VARIANT_PROPERTY(@v, 'BaseType');
   SET @ty = CONVERT(NVARCHAR(500), @type);

   RETURN
      CASE 
         WHEN @ty = 'binary'       THEN  1
         WHEN @ty = 'varbinary'      THEN  1
         ELSE                          0
         END;
END

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ====================================================================
-- Author:      Terry Watts
-- Create date: 01-FEB-2021
-- Description: determines if a sql_variant is of type BIT
-- ====================================================================
CREATE FUNCTION [dbo].[fnIsBool](@v SQL_VARIANT)
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
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:       Terry Watts
-- Create date:  06-FEB-2020
-- Description:  Returns true if a character type
-- =============================================
CREATE FUNCTION [dbo].[fnIsCharType]
(
             @type                      NVARCHAR(15)
)
RETURNS BIT
AS
BEGIN
    DECLARE 
             @rc                        BIT
            ,@n                         INT

            -- Trim possible appended (num)
    SET @n = CHARINDEX('(', @type)

    IF @n > 0
        SET @type = SUBSTRING( @type, 1, @n-1)

    SET @rc = CASE
                WHEN @type = 'CHAR'     THEN 1
                WHEN @type = 'NCHAR'    THEN 1
                WHEN @type = 'VARCHAR'  THEN 1
                WHEN @type = 'NVARCHAR' THEN 1

                ELSE 0
              END

    RETURN @rc

END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ====================================================================
-- Author:      Terry Watts
-- Create date: 01-FEB-2021
-- Description: determines if a sql_variant is an
-- integral type: {int, smallint, tinyint, bigint, money, smallmoney}
-- ====================================================================
CREATE FUNCTION [dbo].[fnIsDateTime](@v SQL_VARIANT)
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
GO

SET QUOTED_IDENTIFIER ON
GO

-- ================================================
-- Author:      Terry Watts
-- Create date: 04-JAN-2021
-- Description: determines if a sql_variant is an
-- approximate type: {float, real or numeric}
-- test: [test].[t 025 fnIsFloat]
-- ================================================
CREATE FUNCTION [dbo].[fnIsFloat](@v SQL_VARIANT)
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
GO

SET QUOTED_IDENTIFIER ON
GO

-- ====================================================================
-- Author:      Terry Watts
-- Create date: 01-FEB-2021
-- Description: determines if a sql_variant is of type GUID
-- ====================================================================
CREATE FUNCTION [dbo].[fnIsGuid](@v SQL_VARIANT)
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
GO

SET QUOTED_IDENTIFIER ON
GO

-- ====================================================================
-- Author:      Terry Watts
-- Create date: 01-FEB-2021
-- Description: determines if a sql_variant is an
-- integral type: {int, smallint, tinyint, bigint, money, smallmoney}
-- test: [test].[t 025 fnIsFloat]
-- ====================================================================
CREATE FUNCTION [dbo].[fnIsInt]( @v SQL_VARIANT)
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
GO

SET QUOTED_IDENTIFIER ON
GO

-- =========================================================
-- Author:      Terry Watts
-- Create date: 05-JAN-2021
-- Description: function to compare values
--
-- DROP FUNCTION dbo.fnLessThan
-- CREATE ALTER
-- =========================================================
CREATE FUNCTION [dbo].[fnIsLessThan]( @a SQL_VARIANT, @b SQL_VARIANT)
RETURNS BIT
AS
BEGIN
   DECLARE 
       @aTxt   NVARCHAR(1000)
      ,@bTxt   NVARCHAR(1000)
      ,@typeA  NVARCHAR(1000)
      ,@typeB  NVARCHAR(1000)
      ,@ret    INT
      ,@x INT

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

   -- if both are floating point types
   IF (dbo.fnIsFloat(@a) = 1) AND (dbo.fnIsFloat(@b) = 1)
      RETURN iif(dbo.[fnCompareFloats](CONVERT(float, @a), CONVERT(float, @b)) < 0, 1, 0);

   -- if both are floating point types
   IF (dbo.fnIsString(@a) = 1) AND (dbo.fnIsString(@b) = 1)
   BEGIN
      -- HANDLE as String
      SET @aTxt = CONVERT(NVARCHAR(4000), @a);
      SET @bTxt = CONVERT(NVARCHAR(4000), @b);

      RETURN iif(@aTxt < @bTxt, 1, 0);
   END

   -- if both are Date time types
   IF (dbo.fnIsDateTime(@a) = 1) AND (dbo.fnIsDateTime(@b) = 1)
   BEGIN
      -- HANDLE as String
      DECLARE @aDt DATETIME
             ,@bDt DATETIME

      SET @aDt = CONVERT(DATETIME, @a);
      SET @bDt = CONVERT(DATETIME, @b);

      RETURN iif(@aDt < @bDt, 1, 0);
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
         RETURN iif(@aInt<@bInt, 1, 0);
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
      RETURN iif(@aFlt<@bFlt, 1, 0);
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
GO

SET QUOTED_IDENTIFIER ON
GO


-- ========================================================
-- Author:      Terry Watts
-- Create date: 29-MAR-2020
-- Description: returns 1 if character is a number
-- Excluding .+-E
-- ========================================================
CREATE FUNCTION [dbo].[fnIsNumber]( @c NVARCHAR(1) )
RETURNS BIT
AS
BEGIN
    DECLARE @v INT
    SET @v = ASCII(@c);

    RETURN iif (((@v >= 48) AND (@v<=57)), 1, 0);
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 17-JAN-2020
-- determines if a ROUTINE is used ny another routine
-- i.e. it exists in the  definition of another routine
-- =============================================
CREATE FUNCTION [dbo].[fnIsRoutineUsed]
(
    @name NVARCHAR(100)
)
RETURNS TABLE 
AS
RETURN 
(
    SELECT * 
    FROM dbo.SysRoutinesView2 
    WHERE 
        [def] like CONCAT('%',@name, '%' ) 
        AND [name] <> @name
)
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ====================================================================
-- Author:      Terry Watts
-- Create date: 01-FEB-2021
-- Description: determines if a sql_variant is of type string
-- ====================================================================
CREATE FUNCTION [dbo].[fnIsString](@v SQL_VARIANT)
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
GO

SET QUOTED_IDENTIFIER ON
GO

-- ========================================================
-- Author:      Terry Watts
-- Create date: 29-MAR-2020
-- Description: returns 1 if character is text or a number
--  @A-Z, a=z, 0-9, _
-- ========================================================
CREATE FUNCTION [dbo].[fnIsText]( @c NVARCHAR(1) )
RETURNS BIT
AS
BEGIN
    DECLARE @v INT;
    SET @v = ASCII(@c);

    RETURN 
        CASE
            WHEN dbo.fnIsNumber( @c) =   1      THEN 1
            WHEN (((@v >= 64) AND (@v<= 90)))   THEN 1
            WHEN (((@v >= 97) AND (@v<=122)))   THEN 1  -- a-z
            WHEN @v = 95                        THEN 1
            ELSE                                     0
        END;
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 13-JAN-2020
-- Description: determines if a character is whitespace
--
-- whitespace is: 
-- (NCHAR(9), NCHAR(10), NCHAR(11), NCHAR(12), NCHAR(13), NCHAR(14), NCHAR(32), NCHAR(160))
--
-- RETURNS: 1 if is whitspace, 0 otherwise
-- =============================================
CREATE FUNCTION [dbo].[fnIsWhitespace]( @t NCHAR) 
RETURNS BIT
AS
BEGIN
    DECLARE 
             @i       BIT

    SET @i = CASE WHEN  @t IN (NCHAR(9), NCHAR(10), NCHAR(11), NCHAR(12), NCHAR(13), NCHAR(14), NCHAR(32), NCHAR(160)) THEN 1 ELSE 0 END
    RETURN @i
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 08-JAN-2020
-- Description: fnLen deals with the trailing spaces bug in Len
-- =============================================
CREATE FUNCTION [dbo].[fnLen]( @v VARCHAR(8000))
RETURNS NVARCHAR(MAX)
AS
BEGIN
	RETURN Len(@v+'x')-1;
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create FUNCTION [dbo].[fnMax] (@p1 INT, @p2 INT)
RETURNS INT
AS
BEGIN
    RETURN CASE WHEN @p1 > @p2 THEN @p1 ELSE @p2 END 
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 13-JAN-2020
-- Description: returns the minimum of 2 values, 
--              but if one is  NULL then returns that value
--              ** This is NOT the same logic as dbo.fnMinNotZero
-- =============================================
CREATE FUNCTION [dbo].[fnMin] (@p1 INT, @p2 INT)
RETURNS INT
AS
BEGIN
   RETURN
      CASE 
         WHEN @p1 IS NULL THEN @p1
         WHEN @p2 IS NULL THEN @p2
         WHEN @p1 < @p2   THEN @p1 
                           ELSE @p2 
      END 
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 31-JAN-2020
-- Description: returns the minimum of 2 values, 
--              but if one is NULL or 0 then returns the other value
--              ** This is NOT the same logic as dbo.fnMin
-- =============================================
CREATE FUNCTION [dbo].[fnMinNotZero](@p1 INT, @p2 INT)
RETURNS INT
AS
BEGIN
    RETURN
        CASE 
            WHEN @p1 = 0 THEN @p2
            WHEN @p2 = 0 THEN @p1
            WHEN @p1 IS NULL THEN @p2
            WHEN @p2 IS NULL THEN @p1
            WHEN @p1 < @p2   THEN @p1 
                             ELSE @p2 
        END 

END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 22-MAR-2020
-- Description: Pads Left
-- =============================================    
CREATE FUNCTION [dbo].[fnPadLeft]( @s NVARCHAR(500), @width INT)
RETURNS NVARCHAR (4000)
AS
BEGIN
    RETURN dbo.fnPadLeft2(@s, @width, ' ');
END

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================    
-- Author:      Terry Watts
-- Create date: 22-MAR-2020
-- Description: Pads Left
-- =============================================    
CREATE FUNCTION [dbo].[fnPadLeft2]( @s NVARCHAR(500), @width INT, @pad NVARCHAR(1)=' ')
RETURNS NVARCHAR (1000)
AS
BEGIN
    DECLARE 
         @ret  NVARCHAR(1000)
        ,@len INT = LEN(@s)

    RETURN iif(@len < @width
      , RIGHT( CONCAT( REPLICATE( @pad, @width-@len), @s), @width)
      , RIGHT(@s, @width))
END


/*
PRINT CONCAT('[', dbo.fnPadLeft2(NULL, 12, 'x'),']')
PRINT CONCAT('[', dbo.fnPadLeft2('', 12, 'x'),']')
PRINT CONCAT('[', dbo.fnPadLeft2('asdfg', 12, 'x'),']')
PRINT CONCAT('[', dbo.fnPadLeft2('asdfg', 3, 'x'),']')
*/
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================    
-- Author:  Terry Watts
-- Create date: 04-OCT-2019
-- Description: Pads Right
-- =============================================    
CREATE FUNCTION [dbo].[fnPadRight]( @s NVARCHAR(500), @width INT)
RETURNS NVARCHAR (1000)
AS
BEGIN
    RETURN dbo.fnPadRight2( @s, @width, ' ' )
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================    
-- Author:  Terry Watts
-- Create date: 13-MAR-2020
-- Description: Pads Right with specified padding character
-- =============================================    
CREATE FUNCTION [dbo].[fnPadRight2]
(
    @s      NVARCHAR(500)
   ,@width  INT
   ,@pad    NVARCHAR(1)
)
RETURNS NVARCHAR (1000)
AS
BEGIN
   DECLARE 
      @ret  NVARCHAR(1000)
      ,@len INT = LEN(@s)

   RETURN iif(@len < @width,  LEFT( CONCAT( @s, REPLICATE( @pad, @width-@len)), @width), LEFT(@s, @width))
END
GO

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
             @v                         NVARCHAR(20)
            ,@len                       INT
            ,@pad_char                  CHAR
)
RETURNS NVARCHAR(200)
BEGIN
    -- Declare the return variable here
    DECLARE 
             @n                         INT
            ,@test_num_flt              FLOAT
            ,@tmp                       NVARCHAR(30)

    --  if null -   change to '' then pad
    IF @v IS NULL SET @v = ''

    --  if ''       return padding only
    IF LEN(@v) = 0
        RETURN dbo.fnPadLeft2(@v, @len, @pad_char)

    --  if INT      return normal pad
    --  if FLOAT    retrun pad of the int part + defimal places
    --  otherwise   pad as normal
    SET @n = dbo.AsInt(@v)

    -- If a pure int then pad the int part and append the decimal part
    IF @n IS NOT NULL
        RETURN dbo.fnPadLeft2( CONVERT(NVARCHAR(20), @n), @len, @pad_char)

    SET @test_num_flt = dbo.AsFloat(@v)

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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================
-- Author:      Terry Watts
-- Create date: 20-MAY-2020
-- Description: Pads left shorthand version
-- dbo.fnpL( , )
-- ===========================================
create FUNCTION [dbo].[fnpL]( @s NVARCHAR(500), @width INT)
RETURNS NVARCHAR (4000)
AS
BEGIN
    RETURN [dbo].[fnPadLeft]( @s, @width);
END

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================================
-- Author:      Terry Watts
-- Create date: 13-JAN-2020
-- Description: replaces CREAET (Routien) with ALTER (Routine)
-- for use with fnReplaceTabsAndReformat(x,y)
-- =============================================================
CREATE FUNCTION [dbo].[fnReplaceCreateWithAlter]( @sql NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    RETURN REPLACE(REPLACE(@sql, 'CREATE PROCEDURE', 'ALTER PROCEDURE'), 'CREATE FUNCTION', 'ALTER FUNCTION')
END


GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE FUNCTION [dbo].[fnReplaceTabsAndReformat](@sql_snippet [nvarchar](4000), @tab_size [int])
RETURNS [nvarchar](4000) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [ClrFunctions].[ClrFunctions.ClrFunctions].[ReplaceTabsAndReformat_V3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 08-JAN-2020
-- Description: REmoves specific characters from the right end of a string
-- =============================================
CREATE FUNCTION [dbo].[fnRTrim]
(
     @str NVARCHAR(MAX)
)
RETURNS  NVARCHAR(MAX)
AS
BEGIN
    DECLARE  @chars_to_trim NVARCHAR(20)
            ,@char          NCHAR
            ,@ndx           INT
            ,@len           INT

    SET @chars_to_trim = CONCAT( NCHAR(9), NCHAR(10), NCHAR(13), NCHAR(32), NCHAR(160))

    IF (@str IS NULL ) OR (LEN(@str) = 0)
        RETURN @str;

    SET @len  = LEN(@str + 'x') - 1
    SET @char = RIGHT(@str, 1)
    SET @ndx  = CHARINDEX ( @char, @chars_to_trim )

    WHILE @ndx > 0
    BEGIN
        SET @str  = LEFT( @str , @len-1);
        SET @len  = LEN(@str + 'x') - 1

        IF @len = 0
            BREAK;

        SET @char = RIGHT(@str, 1);
        SET @ndx  = CHARINDEX ( @char, @chars_to_trim )
    END

    RETURN @str
END

/*
--------------------------------------------------------------------------------------------------
PRINT CONCAT('[',dbo.fnRTrim( CONCAT('  Some text ', NChar(160))), ']')
--------------------------------------------------------------------------------------------------
EXEC tSQLt.Run 'test.[test 028 RTrim]'
EXEC test.[test 028 RTrim]

EXEC tSQLt.RunAll

--------------------------------------------------------------------------------------------------
PRINT CONCAT('[',dbo.fnRTrim( CONCAT('  Some text', NChar(160))), ']')
--------------------------------------------------------------------------------------------------

--DROP FUNCTION [dbo].[fnRTrim]
*/
/*
    SET @inp = CONCAT(  Some text', NChar(160));
    SET @exp  = '  Some text';
*/


/*
--------------------------------------------------------------------------------------------------
PRINT CONCAT('[',dbo.fnRTrim( CONCAT('  Some text ', NChar(160))), ']')
--------------------------------------------------------------------------------------------------
EXEC tSQLt.Run 'test.[test 028 RTrim]'
EXEC test.[test 028 RTrim]

EXEC tSQLt.RunAll

--------------------------------------------------------------------------------------------------
PRINT CONCAT('[',dbo.fnRTrim( CONCAT('  Some text', NChar(160))), ']')
--------------------------------------------------------------------------------------------------

--DROP FUNCTION [dbo].[fnRTrim]
*/
/*
    SET @inp = CONCAT(  Some text', NChar(160));
    SET @exp  = '  Some text';
*/
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 09-DEC-2019
-- Description: splits a string of items separated
-- by a character into a list (table)
-- the lines include a NL if one existed in source code
-- if max(st)=Len(txt) -> there was a trailing NL
-- (on the last row)
-- =============================================
CREATE FUNCTION [dbo].[fnSplit]
(
   @string     NVARCHAR(4000),
   @delimiter  NVARCHAR(2) = ','
)
RETURNS TABLE
AS
RETURN
(
   WITH Split(stpos,endpos)
   AS
   (
      SELECT
         1 AS stpos,       CHARINDEX(@Delimiter, @string) AS endpos
      UNION ALL
         SELECT endpos+1,  iif(CHARINDEX(@Delimiter, @string, endpos+1)> 0, CHARINDEX(@Delimiter, @string, endpos+1), len(@string)+1)
         FROM Split
     WHERE endpos < len(@string)
   )

  -- SELECT * FROM Split

   SELECT 
    'id'     = ROW_NUMBER() OVER (ORDER BY (SELECT 1)), 'st' = stpos, 'end' = endpos
   ,'Line'   = iif(stpos<> 0  AND [endpos] <> 0, SUBSTRING( @string, stpos, iif([endpos] = 0, len(@string), [endpos])-stpos), NULL)
   ,'has_nl' = iif(stpos = LEN(@string), 0, 1)
   FROM Split
   WHERE endpos IS NOT NULL AND endpos <> 0
)


/*
EXEC [test].[test 006 fnSplit];

SELECT * FROM [dbo].[fnSplit]( 'A,BCD', ',');
*/
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 11-JUN-2020
-- Description: 
-- =============================================
CREATE FUNCTION [dbo].[fnSplitSchemaAndRtnName]
(
   @full_nm    NVARCHAR(100)
)
RETURNS @t TABLE([schema] NVARCHAR(20), [rtn_nm] NVARCHAR(60))
AS
BEGIN
   IF ((@full_nm IS NULL) OR (CHARINDEX('.', @full_nm) = 0))
      INSERT INTO @t ([schema], [rtn_nm]) VALUES(NULL, NULL)
   ELSE
      INSERT INTO @t ([schema], [rtn_nm])
      SELECT SUBSTRING(@full_nm, 1, CHARINDEX('.', @full_nm)-1)                AS [schema]
            ,SUBSTRING(@full_nm,    CHARINDEX('.', @full_nm)+1, LEN(@full_nm)) AS [rtn_nm]

    RETURN;
END

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ===========================================================================
-- Author:      Terry Watts
-- Create date: 01-JUN-2020
-- Description: returns a list of matching routines from the current database
-- ===========================================================================
CREATE FUNCTION [dbo].[fnSysRtnCfg]
(
    @schema    NVARCHAR(20) = NULL
   ,@name      NVARCHAR(60) = NULL
   ,@ty_code   NVARCHAR(60) = NULL
)
RETURNS @t TABLE
(
    [id]       INT IDENTITY(1,1) NOT NULL
   ,[name]     NVARCHAR(60)
   ,[schema]   NVARCHAR(20)
   ,[db]       NVARCHAR(20)
   ,ty_nm      NVARCHAR(50)
   ,ty_code    NVARCHAR(70)
   ,[type_id]  INT
   ,created    DATE
   ,modified   DATE
)
BEGIN
   DECLARE 
      @test_num           NVARCHAR(60)

   if @name IS NULL
      SET @name = '%'

   if @schema IS NULL
      SET @schema = '%'

   if @ty_code IS NULL
      SET @ty_code = '%'

   INSERT INTO @T(  [name], [schema], [db],      ty_nm, ty_code, [type_id],created, modified)
   SELECT TOP 1000  [name], [schema], [db_name], ty_nm, ty_code
      ,iif(ty_code='P',  1 -- SQL_STORED_PROCEDURE
      ,iif(ty_code='PC', 5 -- CLR_STORED_PROCEDURE
      ,iif(ty_code='FN', 2 -- SQL_SCALAR_FUNCTION
      ,iif(ty_code='TF', 3 -- SQL_TABLE_VALUED_FUNCTION
      ,iif(ty_code='IF', 4 -- SQL_INLINE_TABLE_VALUED_FUNCTION
      , -1                 -- error
      )))))
      ,created, modified
      FROM [dbo].[SysRoutinesView]   WHERE
       [schema] LIKE @schema
   AND [name]   LIKE @name
   AND ty_code  LIKE @ty_code
   ORDER BY [schema], ty_code, [name]


RETURN;
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:      Terry watts
-- Create date: 18-MAY-2020
-- Description: lists routine definitions in rows 
-- overcoming the 4000 char limit of dbo.SysRoutinesView
-- or any method based on INFORMATION_SCHEMA.ROUTINES
-- =============================================
CREATE FUNCTION [dbo].[fnSysRtnDef]
(
       @schema NVARCHAR(20)
      ,@name   NVARCHAR(50)
)
RETURNS @T TABLE
(
    [name]        NVARCHAR(100)
   ,[schema]      NVARCHAR(20)
   ,[type_desc]   NVARCHAR(30)
   ,seq           INT
   ,[len]         INT
   ,create_date   DATE
   ,def           NVARCHAR(4000)
)
AS
BEGIN
   INSERT INTO @t ([name], [schema], [type_desc], seq, [len] ,create_date, def) 
   SELECT          [name], [schema], [type_desc], seq, [len], create_date, def
   FROM [dbo].[sysroutinesview2]
   WHERE [schema] = @schema AND [name] LIKE @name
   ORDER BY [name], seq;

   RETURN;
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 08-FEB-2020
-- Description: returns true (1) if table exxists else false (0)
-- schema default is dbo
-- =============================================
create FUNCTION [dbo].[fnTableExists](@table_spec NVARCHAR(60))
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
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Terry Watts
-- Create date: 10-OCT-219
-- Description:	Trims leading and trailing whitesace including the normally untrimmable CHAR(160)
-- =============================================
CREATE FUNCTION [dbo].[fnTrim]( @str NVARCHAR(4000)
)
RETURNS NVARCHAR(4000)
AS
BEGIN
    IF ((@str IS NULL) OR (dbo.fnLen(@str) = 0))
        return @str

    -- Left trim
    WHILE(( LEFT(@str, 1) IN (' ', CHAR(9), CHAR(10), CHAR(13), CHAR(32), CHAR(160))) AND (dbo.fnLen(@str) >0))
        SET @str = Substring(@str, 2, dbo.fnLen(@str)-1)

    -- Right trim: reverse and use LTrim
    SET @str = Reverse(@str)

    -- Left trim
    WHILE(( LEFT(@str, 1) IN (' ', CHAR(9), CHAR(10), CHAR(13), CHAR(32), CHAR(160))) AND (dbo.fnLen(@str) >0))
        SET @str = Substring(@str, 2, dbo.fnLen(@str)-1)

    -- Return the result of the function
    RETURN Reverse(@str)
    return @str;
END

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 03-JUN-2020
-- Description: returns the session data key 
--    for the test passed count for this fn
-- =============================================
CREATE FUNCTION [dbo].[GetTestPassedKey]( @fn NVARCHAR(30))
RETURNS NVARCHAR(50)
AS
BEGIN
   RETURN CONCAT(@fn, N' tests passed')
END

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry watts
-- Create date: 27-APR-2020
-- Description: Renames a column in a table
-- =============================================
create PROCEDURE [dbo].[sp_add_col]
         @table_name        NVARCHAR(60)
        ,@col_nm            NVARCHAR(60)
        ,@col_ty            NVARCHAR(60)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE 
         @sql               NVARCHAR(MAX)

    SET @sql = CONCAT('IF NOT EXISTS (Select 1 FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = ''', @table_name,''' 
    AND COLUMN_NAME  = ''', @col_nm, ''')
    ALTER TABLE [', @table_name, '] ADD [',@col_nm,'] ',@col_ty,';');

    PRINT @sql;
    EXEC sp_executesql @sql;
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Alter Procedure sp_app_log_display

-- =============================================
-- Author:      Terry Watts
-- Create date: 03-APR-2020
-- Description: Inserts a log row in the app log
--
--              Splits into column based on tabs in the the message or 

    -- set @tmp = LEFT(CONCAT(REPLICATE( '  ', @sf), REPLACE(LEFT( @tmp, 500), @NL, '--')), 500);
    -- set @tmp = LEFT(CONCAT( REPLACE(LEFT( @tmp, 500), @NL, '--')), 500);
-- =============================================
CREATE PROCEDURE [dbo].[sp_app_log_display]
             @dir   BIT     = 1 -- ASC
AS
BEGIN
   DECLARE
       @fn              NVARCHAR(30)   = 'H001'
      ,@sql             NVARCHAR(4000)

   SET @sql = CONCAT(
'        SELECT
          id
         ,sf
         ,hit
         ,LEFT(CONCAT(fn, REPLICATE( ''  '', sf)), 50)
                AS ''fn',   REPLICATE('_',16), '''
         ,log1  AS ''log1', REPLICATE('_',50), '''
         ,log2  AS ''log2', REPLICATE('_',50), '''
         ,log3  AS ''log3', REPLICATE('_',100), '''
        FROM AppLog 
        ORDER BY ID ', iif(@dir=1, 'ASC','DESC'), ';'
        );

   EXEC sp_executesql @sql;
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 03-APR-2020
-- Description: Inserts a log row in the app log
--              logs a VARCHAR(800000 full mesage and also spits it down into column dispal max chunks
--              The Grid display has a column width limit of 128 characters
--              Splits into column based on tabs in the the message or 
-- =============================================
CREATE PROCEDURE [dbo].[sp_app_log_insert]
             @fn                        NVARCHAR(100)
            ,@msg                       VARCHAR(MAX)
            ,@sf                        INT = 0
            ,@hit                       INT = 0
AS
BEGIN
    DECLARE
            @msg1                       NVARCHAR(128)
           ,@msg2                       NVARCHAR(128)
           ,@msg3                       NVARCHAR(128)
           ,@len                        INT     = LEN(@msg)
           ,@ndx1                       INT     = 0
           ,@ndx2                       INT     = 0
           ,@n                          INT
           ,@TAB                        NCHAR(1) = NCHAR(9)

    -- Check if there are any tabs first
    SET @ndx1 = CHARINDEX( @TAB, @msg, 0);
    SET @ndx2 = iif( @ndx1>0, CHARINDEX(@TAB, @msg, @ndx1 + 1), 0);

    IF @ndx1 = 0
        SET @ndx1 = iif(@len<=128, @len, 128)

    IF @ndx2 = 0
        SET @ndx2 = iif(@len<=256, 
                    iif(@len<=@ndx1, 0, @len),
                        256)

    SET @msg1 = SUBSTRING(@msg, 1 , @ndx1);
    SET @n = @ndx2- @ndx1 + 1;

    IF @n >0
      SET @msg2 = iif(@ndx2 > 0,   SUBSTRING(@msg, @ndx1,@n), '');

    SET @n = @len - @ndx2 + 1;

    IF @n >0
      SET @msg3 = iif(@len  > 256, SUBSTRING(@msg, @ndx2, @n), '');

    INSERT INTO AppLog ( fn,  sf,  hit,  msg,  log1,  log2,  log3)
    VALUES                 (@fn, @sf, @hit, @msg, @msg1, @msg2, @msg3);
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Alter Procedure sp_assert_equal
-- =============================================
-- Author:      Terry watts
-- Create date: 21-JAN-2020
-- Description: 1 line check null or mismatch and throw message
--              ASSUMES data types are the same
-- =============================================
CREATE PROCEDURE [dbo].[sp_assert_equal] 
       @a         SQL_VARIANT
      ,@b         SQL_VARIANT
      ,@ex_num    INT             = 50001
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
      ,@state     INT             = 1
      ,@fn        NVARCHAR(60)    = N'*'
      ,@sf        INT             = 0
AS
BEGIN
   IF dbo.fnChkEquals(@a ,@b) = 0
      EXEC sp_raise_assert @a, @b, @ex_num, @fn, @msg, @msg2, @msg3, @msg4, @msg5, @msg6, @msg7, @msg8, @msg9, @msg10, @state, N'ASRT EQL', @sf
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Create Procedure sp_assert_gtr_than
-- =============================================
-- Author:      Terry Watts
-- Create date: 27-MAR-2020
-- Description: asserts that a is greater than b
--              raises an exception if not
-- DROP PROCEDURE [dbo].[sp_assert_gtr_than]
-- CREATE ALTER
-- =============================================
CREATE PROCEDURE [dbo].[sp_assert_gtr_than]
       @a         SQL_VARIANT
      ,@b         SQL_VARIANT
      ,@ex_num    INT            = 53502
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
      ,@state     INT            = 1
      ,@fn        NVARCHAR(60)   = N'*'
      ,@sf        INT            = 0
AS
BEGIN
   DECLARE 
       @aType  NVARCHAR(20) = CONVERT(NVARCHAR(20), SQL_VARIANT_PROPERTY(@a, 'BaseType'))
      ,@bType  NVARCHAR(20) = CONVERT(NVARCHAR(20), SQL_VARIANT_PROPERTY(@b, 'BaseType'))
      ,@aTxt   NVARCHAR(100)= CONVERT(NVARCHAR(20), @a)
      ,@bTxt   NVARCHAR(100)= CONVERT(NVARCHAR(20), @b)
      ,@msg0    NVARCHAR(1000)

/*   PRINT CONCAT(
      '@a: ', @aTxt, ' : ', @aType
   , ' @b: ', @bTxt, ' : ', @bType
   );*/

   IF dbo.fnChkEquals(@a ,@b) = 1
   BEGIN
      SET @msg0 = CONCAT(@aTxt, ' is not greater than (==) ', @bTxt, ' ', @msg)
      EXEC sp_raise_assert @a, @b, @ex_num, @fn, @msg0, @msg2, @msg3, @msg4, @msg5, @msg6, @msg7, @msg8, @msg9, @msg10, @state, N'ASRT GTR THN', @sf;
   END

   IF dbo.fnIsLessThan(@b, @a) = 1
      RETURN 1;

   -- ASSERTION: if here then mismatch
  SET @msg0 = CONCAT(@aTxt, ' is not greater than ', @bTxt, ' ', @msg)
  EXEC sp_raise_assert @a, @b, @ex_num, @fn, @msg0, @msg2, @msg3, @msg4, @msg5, @msg6, @msg7, @msg8, @msg9, @msg10, @state, N'ASRT GTR THN', @sf
END

/*
   EXEC [dbo].[sp_assert_gtr_than] 3,2  exp ok
   EXEC [dbo].[sp_assert_gtr_than] 2,2  exp ex
   EXEC [dbo].[sp_assert_gtr_than] 2,3  exp ex
*/
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Alter Procedure sp_assert_gtr_than_or_equal
-- Create Procedure sp_assert_gtr_than_or_equals
-- =============================================
-- Author:      Terry Watts
-- Create date: 08-APR-2020
-- Description: Raises exception if a is less than b
-- =============================================
CREATE PROCEDURE [dbo].[sp_assert_gtr_than_or_equal]
       @a         SQL_VARIANT
      ,@b         SQL_VARIANT
      ,@ex_num    INT            = 53503
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
      ,@state     INT            = 1
      ,@fn        NVARCHAR(60)   = N'*'
      ,@sf        INT            = 0
AS
BEGIN
   IF dbo.fnIsLessThan(@a ,@b) = 0
      RETURN 0;

   -- ASSERTION: if here then mismatch
   EXEC sp_raise_assert @a, @a, @ex_num, @fn, @msg, @msg2, @msg3, @msg4, @msg5, @msg6, @msg7, @msg8, @msg9, @msg10, @state, N'ASRT GTR THN OR EQL', @sf
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Create Procedure sp_assert_less_than
-- ========================================================
-- Author:      Terry Watts
-- Create date: 27-MAR-2020
-- Description: Raises exception if a is not less than b
--              or if Either is NULL
-- ========================================================
CREATE PROCEDURE [dbo].[sp_assert_less_than]
       @a         SQL_VARIANT
      ,@b         SQL_VARIANT
      ,@ex_num    INT             = 53503
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
      ,@state     INT            = 1
      ,@fn        NVARCHAR(60)   = N'*'
      ,@sf        INT            = 0
AS
BEGIN
   IF dbo.fnIsLessThan(@a ,@b) = 1
      RETURN 0;

   -- ASSERTION: if here then mismatch
   EXEC sp_raise_assert @a, @b, @ex_num, @fn, @msg, @msg2, @msg3, @msg4, @msg5, @msg6, @msg7, @msg8, @msg9, @msg10, @state, N'ASRT LESS THAN', @sf
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Alter Procedure sp_assert_less_than_or_equal
-- Create Procedure sp_assert_less_than_or_equals
-- =============================================
-- Author:      Terry Watts
-- Create date: 27-MAR-2020
-- Description: Raises exception if a is not <= b
-- =============================================
CREATE PROCEDURE [dbo].[sp_assert_less_than_or_equal]
       @a         SQL_VARIANT
      ,@b         SQL_VARIANT
      ,@ex_num    INT            = 50001
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
      ,@state     INT            = 1
      ,@fn        NVARCHAR(60)   = N'*'
      ,@sf        INT            = 0
AS
BEGIN
   IF dbo.fnIsLessThan(@a ,@b) = 1
      RETURN 0;

   IF dbo.fnChkEquals(@a ,@b) = 1
      RETURN 0;

   -- ASSERTION: if here then mismatch
   EXEC sp_raise_assert @a, @b, @ex_num, @fn, @msg, @msg2, @msg3, @msg4, @msg5, @msg6, @msg7, @msg8, @msg9, @msg10, @state, N'ASRT LESS THN OR EQL', @sf
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 09-JUN-2020
-- Description: Raises exception if @a is empty
-- =============================================
CREATE PROCEDURE [dbo].[sp_assert_not_empty]
       @a         SQL_VARIANT
      ,@ex_num    INT            = 50003
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
      ,@state     INT            = 1
      ,@fn        NVARCHAR(60)   = N'*'
      ,@sf        INT            = 0
AS
BEGIN
   IF (@a <> '')
      RETURN 0;

   -- ASSERTION: if here then mismatch
   EXEC sp_raise_assert @a, '', @ex_num, @fn, @msg, @msg2, @msg3, @msg4, @msg5, @msg6, @msg7, @msg8, @msg9, @msg10, @state, N'ASRT NOT NULL', @sf
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 27-MAR-2020
-- Description: Raises exception if exp = act
-- =============================================
CREATE PROCEDURE [dbo].[sp_assert_not_equal]
       @a         SQL_VARIANT
      ,@b         SQL_VARIANT
      ,@ex_num    INT             = 50002
      ,@msg       NVARCHAR(200)   = ''
      ,@msg2      NVARCHAR(200)  = NULL
      ,@msg3      NVARCHAR(200)  = NULL
      ,@msg4      NVARCHAR(200)  = NULL
      ,@msg5      NVARCHAR(200)  = NULL
      ,@msg6      NVARCHAR(200)  = NULL
      ,@msg7      NVARCHAR(200)  = NULL
      ,@msg8      NVARCHAR(200)  = NULL
      ,@msg9      NVARCHAR(200)  = NULL
      ,@msg10     NVARCHAR(200)  = NULL
      ,@state     INT             = 1
      ,@fn        NVARCHAR(60)    = N'*'
      ,@sf        INT             = 0
AS
BEGIN
   IF dbo.fnChkEquals(@a ,@b) = 1
      EXEC sp_raise_assert @a, @b, @ex_num, @fn, @msg, @msg2, @msg3, @msg4, @msg5, @msg6, @msg7, @msg8, @msg9, @msg10, @state, N'ASRT EQL', @sf
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 27-MAR-2020
-- Description: Raises exception if @a is NULL
-- =============================================
CREATE PROCEDURE [dbo].[sp_assert_not_null]
       @a         SQL_VARIANT
      ,@ex_num    INT            = 50003
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
      ,@state     INT            = 1
      ,@fn        NVARCHAR(60)   = N'*'
      ,@sf        INT            = 0
AS
BEGIN
   IF (@a IS NOT NULL)
      RETURN 0;

   -- ASSERTION: if here then mismatch
   EXEC sp_raise_assert @a, '', @ex_num, @fn, @msg, @msg2, @msg3, @msg4, @msg5, @msg6, @msg7, @msg8, @msg9, @msg10, @state, N'ASRT NOT NULL', @sf
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 27-MAR-2020
-- Description: Raises exception if @a is null or empty
-- =============================================
CREATE PROCEDURE [dbo].[sp_assert_not_null_or_empty]
       @a         SQL_VARIANT
      ,@ex_num    INT            = 50004
      ,@msg       NVARCHAR(200)   = NULL
      ,@msg2      NVARCHAR(200)  = NULL
      ,@msg3      NVARCHAR(200)  = NULL
      ,@msg4      NVARCHAR(200)  = NULL
      ,@msg5      NVARCHAR(200)  = NULL
      ,@msg6      NVARCHAR(200)  = NULL
      ,@msg7      NVARCHAR(200)  = NULL
      ,@msg8      NVARCHAR(200)  = NULL
      ,@msg9      NVARCHAR(200)  = NULL
      ,@msg10     NVARCHAR(200)  = NULL
      ,@state     INT            = 1
      ,@st_empty  INT            = NULL
      ,@fn        NVARCHAR(60)   = N'*'
      ,@sf        INT            = 0
AS
BEGIN
   IF @st_empty IS NULL
      SET @st_empty = @state + 1;

   EXEC [dbo].[sp_assert_not_null]
       @a   ,@ex_num,@msg
      ,@msg2,@msg3  ,@msg4
      ,@msg5,@msg6  ,@msg7
      ,@msg8,@msg9  ,@msg10
      ,@state,@fn,@sf

   EXEC [dbo].[sp_assert_not_empty]
       @a   ,@ex_num,@msg
      ,@msg2,@msg3  ,@msg4
      ,@msg5,@msg6  ,@msg7
      ,@msg8,@msg9  ,@msg10
      ,@st_empty,@fn,@sf

   RETURN 0;
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 09-JUN-2020
-- Description: Raises exception if @a is null or zero
--              this is meant for ints or floats
-- =============================================
CREATE PROCEDURE [dbo].[sp_assert_not_null_or_zero]
       @a         INT
      ,@ex_num    INT            = 50004
      ,@msg       NVARCHAR(200)   = NULL
      ,@msg2      NVARCHAR(200)  = NULL
      ,@msg3      NVARCHAR(200)  = NULL
      ,@msg4      NVARCHAR(200)  = NULL
      ,@msg5      NVARCHAR(200)  = NULL
      ,@msg6      NVARCHAR(200)  = NULL
      ,@msg7      NVARCHAR(200)  = NULL
      ,@msg8      NVARCHAR(200)  = NULL
      ,@msg9      NVARCHAR(200)  = NULL
      ,@msg10     NVARCHAR(200)  = NULL
      ,@state     INT            = 1
      ,@st_empty  INT            = NULL
      ,@fn        NVARCHAR(60)   = N'*'
      ,@sf        INT            = 0
AS
BEGIN
   IF @st_empty IS NULL
      SET @st_empty = @state

   EXEC [dbo].[sp_assert_not_null]
       @a   , @ex_num, @msg
      ,@msg2, @msg3  , @msg4
      ,@msg5, @msg6  , @msg7
      ,@msg8, @msg9  , @msg10
      ,@state
      ,@fn   ,@sf

   EXEC [dbo].[sp_assert_not_zero]
       @a   , @ex_num, @msg
      ,@msg2, @msg3  , @msg4
      ,@msg5, @msg6  , @msg7
      ,@msg8, @msg9  , @msg10
      ,@st_empty
      ,@fn   ,@sf

   RETURN 0;
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 09-JUN-2020
-- Description: Raises exception if @a is 0
-- =============================================
CREATE PROCEDURE [dbo].[sp_assert_not_zero]
       @a         INT
      ,@ex_num    INT            = 50003
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
      ,@state     INT            = 1
      ,@fn        NVARCHAR(60)   = N'*'
      ,@sf        INT            = 0
AS
BEGIN
   IF (@a <> 0)
      RETURN 0;

   -- ASSERTION: if here then mismatch
   EXEC sp_raise_assert @a, '', @ex_num, @fn, @msg, @msg2, @msg3, @msg4, @msg5, @msg6, @msg7, @msg8, @msg9, @msg10, @state, N'ASRT NOT ZERO', @sf
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry watts
-- Create date: 27-APR-2020
-- Description: Changes a column type in a table if necessary
-- =============================================
CREATE PROCEDURE [dbo].[sp_change_col_type]
         @table_name        NVARCHAR(60)
        ,@col_nm            NVARCHAR(60)
        ,@col_ty            NVARCHAR(60)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE 
         @sql               NVARCHAR(MAX)

    SET @sql = CONCAT('IF EXISTS (Select 1 FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = ''', @table_name,''' 
    AND COLUMN_NAME  = ''', @col_nm, '''
    AND DATA_TYPE <> ''',@col_ty,''')
    ALTER TABLE [', @table_name, '] ALTER COLUMN [',@col_nm,'] ',@col_ty,';');

    PRINT @sql;
    EXEC sp_executesql @sql;
END

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 27-DEC-2019
-- Description: Checks if an object depends on another object
-- =============================================
CREATE  PROCEDURE [dbo].[sp_check_depends_on]
     @parent        NVARCHAR(100)
    ,@child         NVARCHAR(100)
AS
BEGIN
    DECLARE
             @res   INT
            ,@sql   NVARCHAR(MAX)

    --IF NOT EXISTS (SELECT * FROM SYSOBJECTS WHERE name='tmptble' AND xtype='U')  
    CREATE TABLE #tmptble
    (
         [NAME]     NVARCHAR(100)
        ,[TYPE]     NVARCHAR(100)
    )

    --DELETE FROM #tmptble;
    SET @sql = CONCAT('INSERT INTO #tmptble EXEC [dbo].[sp_they_depend_on_me] ''', @parent, '''')
    PRINT @sql;
    EXEC sp_executesql @sql

    SELECT * FROM #tmptble WHERE [name] = @child

    SELECT @res = CASE WHEN
    EXISTS
    (
        SELECT 1 FROM #tmptble
        WHERE [name] = @child
    ) THEN 1
    ELSE 0
    END;

    RETURN @res
END
/*
EXEC sp_depends 'dbo.REgion'
SELECT * FROM DM_SQL_REFERENCED_ENTITIES
SELECT referencing_schema_name, referencing_entity_name,
referencing_id, referencing_class_desc, is_caller_dependent
FROM sys.dm_sql_referencing_entities ('YourObject', 'OBJECT');

EXEC sp_helptext 'sys.dm_sql_referenced_entities'
SELECT * FROM sys.dm_sql_referenced_entities('dbo.PersonView', N'OBJECT') WHERE referenced_minor_name IS NULL

DECLARE @rc INT
EXEC @rc = [sp_check_depends_on] 'Region', 'RegionView'
PRINT @rc

EXEC [sp_check_depends_on] 'City'
EXEC sp_they_depend_on_me 'Region'
DECLARE @objid INT = 776389835
select @objid = object_id('sp_export_type')  
PRINT @objid
*/
 
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 09-MAY-2020
-- Description: This routine checks that the given routine exists
--
-- POST         throws exception if rotine does not exist
-- =============================================
creATE PROCEDURE [dbo].[sp_chk_rtn_exists]
       @schema   NVARCHAR(20)
      ,@rtn_nm   NVARCHAR(4000)
      ,@ex_num   INT            = 50000
      ,@ex_state INT            = 1
      ,@fn       NVARCHAR(35)   = N'CHK_RTN_EXISTS'
AS
BEGIN
   DECLARE
       @NL       NVARCHAR(2)    = NCHAR(13) + NCHAR(10)
      ,@sql      NVARCHAR(2000)

   IF NOT EXISTS 
   (
      SELECT 1 FROM dbo.sysRoutinesView
      WHERE [schema] = @schema and [name] = @rtn_nm
   )
   BEGIN
      DECLARE @TMP NVARCHAR(500);
      SET @TMP = CONCAT('routine [', @schema,'].[', @rtn_nm, '] does not exist in the database');
      EXEC sp_raise_exception @ex_code = @ex_num, @msg = @tmp, @state=@ex_state, @fn=@fn
   END
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================================
-- Author:      Terry Watts
-- Create date: 14-JUL-2020
-- Description: returns non 0 @schema_id if database exists,
-- false otherwise
-- =============================================================
CREATE PROCEDURE [dbo].[sp_database_exists] 
       @db_nm           NVARCHAR(40)
AS
BEGIN
   DECLARE
      @db_id    INT = 0

   EXEC @db_id = dbo.sp_get_database_id @db_nm
   RETURN @db_id;
END

/*
DECLARE @schema_id    INT
EXEC @schema_id = dbo.sp_database_exists  'ut';
PRINT @schema_id
*/
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 26-OCT-2019
-- Description: Creates an Excel xls file as a TSV
-- N.B.: It needs to be loaded by Excel to actual make a .xls formatted file, however
-- Excel will open a CSV or TSV as an Excel file with a warning prompt
--
-- Process:
--  Validate parameters
--      Mandatory parameters
--          table name
--          folder
--
--  set paramter defaults as needed
--      file name       <table>.xlsx
--      sheet_name:     <table>
--      view:           <table>View
--      timestamp:      <current time and date> Fprmat YYMMDD-HHmm
-- =============================================
CREATE PROCEDURE [dbo].[sp_export_to_excel]
             @table_nm                  NVARCHAR(50)
            ,@folder                    NVARCHAR(260)
            ,@workbook_nm               NVARCHAR(260)   = NULL
            ,@sheet_nm                  NVARCHAR(50)    = NULL
            ,@view_nm                   NVARCHAR(50)    = NULL
            ,@filter                    NVARCHAR(MAX)   = NULL
            ,@create_timestamp          bit             = 1
            ,@max_rows                  INT             = NULL
AS
BEGIN 

    DECLARE --                          41              =   61                          : '- 27 chars
             @fn                        NVARCHAR(30)    =   'EXPORT TO EXCEL            : ' 
            ,@Line                      NVARCHAR(102)   =  CONCAT(REPLICATE('-', 100), NCHAR(13), NCHAR(10))
            ,@sql                       NVARCHAR(MAX)

            ,@backslash                 NCHAR            = NCHAR(92)
            ,@columns                   NVARCHAR(MAX)
            ,@error_msg                 NVARCHAR(200)
            ,@ndx                       INT
            ,@openRowSetSql             NVARCHAR(MAX)
            ,@rc                        INT
            ,@server_name               NVARCHAR(100)
            ,@timestamp                 NVARCHAR(30)
            ,@xls_file_path             NVARCHAR(260)

    EXEC sp_log @fn,  'starting'

    -- Validate
    EXEC @rc = sp_export_to_excel_validate 
                         @table_nm      = @table_nm
                        ,@folder        = @folder
                        ,@workbook_nm   = @workbook_nm  OUT
                        ,@sheet_nm      = @sheet_nm     OUT
                        ,@view_nm       = @view_nm      OUT
                        ,@error_msg     = @error_msg    OUT

    IF @rc = 0
    BEGIN
        ;THROW 50306, @error_msg, 1
    END

    SET @ndx = CHARINDEX('.xls', @workbook_nm)

    IF @ndx > 0
        SET @workbook_nm = SUBSTRING(@workbook_nm, 1, @ndx-1)

    IF @create_timestamp = 1
    BEGIN
        -- timestamp= <current time and date> Format YYMMDD-HHmm
        SET @xls_file_path = CONCAT(@folder, @backslash, @workbook_nm, ' ', dbo.fnGetTimestamp(), '.xlsx')
    END
    ELSE
    BEGIN
        SET @xls_file_path = CONCAT(@folder, @backslash, @workbook_nm, '.xlsx')
    END

    -- Create an .xlsx file containing the column header
    SET @columns = dbo.fnGetColumnNames(@view_nm)
    PRINT @columns
    SET @sql = CONCAT('EXEC master..xp_cmdshell ''CreateExcelFile.exe  "', @xls_file_path, '" "', @sheet_nm, '" "', @columns, '" ''');
    PRINT @sql
    EXEC (@sql)

    EXEC @openRowSetSql = dbo.fnGetOpenRowSet @xls_file_path, @sheet_nm

    -- Add in the TOP n rows clause if specified
    SET @sql = CASE 
                WHEN @max_rows IS NULL 
                    THEN CONCAT('INSERT INTO ', @openRowSetSql, ' SELECT ',                   @columns, ' FROM ', @view_nm)
                    ELSE CONCAT('INSERT INTO ', @openRowSetSql, ' SELECT TOP ',@max_rows,' ', @columns, ' FROM ', @view_nm)
                END

    -- Add in the filter and order by clause if specified
    IF @filter IS NOT NULL
        SET @sql = CONCAT(@sql,' ', @filter)

    PRINT @sql
    EXEC (@sql)
    
    EXEC master..sp_log @fn,  'done'
END

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
EXEC dbo.sp_reformat_routine 'sp_export_to_excel_validate'
*/


-- =============================================
-- Author:      Terry Watts
-- Create date: 27-DEC-2019
-- Description: validaes and corrects procedure sp_export_to_excel parameters
--  Validate parameters
--      Mandatory parameters
--          table name
--          folder
--
--  set paramter defaults as needed
--      file name       <table>.xlsx            set if NULL or empty
--      sheet_name:     <table>                 set if NULL or empty
--      view:           <table>View             set if NULL or empty
--      timestamp:      <current time and date> set if NULL Format YYMMDD-HHmm
--
-- returns  1 if OK
--          0 if FATAL
-- =============================================
CREATE PROCEDURE [dbo].[sp_export_to_excel_validate]
             @table_nm                  NVARCHAR(50)
            ,@folder                    NVARCHAR(260)
            ,@workbook_nm               NVARCHAR(260)   OUTPUT
            ,@sheet_nm                  NVARCHAR(50)    OUTPUT
            ,@view_nm                   NVARCHAR(50)    OUTPUT
            ,@error_msg                 NVARCHAR(200)   OUTPUT
AS
BEGIN
    DECLARE             --                                  '                            : '
              @fn                       NVARCHAR(30)    =   'EXPORT TO EXCEL VALIDATE    : '

    EXEC sp_log @fn,  'starting'

    -- Validation

    IF @table_nm IS NULL OR LEN(@table_nm)=0
    BEGIN
        SET @error_msg = 'table must be specified'
        RETURN 0
    END

    IF dbo.fnCheckTableExists(@table_nm, 'dbo') = 0
    BEGIN
        SET @error_msg = 'unknown table'
        RETURN 0
    END

    IF @folder IS NULL OR LEN(@folder)=0
    BEGIN
        SET @error_msg = 'folder must be specified'
        RETURN 0
    END

    -- set paramter defaults as needed
    -- file name = <table>.xlsx
    IF @workbook_nm IS NULL OR LEN(@workbook_nm)=0
        SET @workbook_nm = CONCAT(@table_nm, '.xlsx');

    -- view: = <table>View
    IF @view_nm IS NULL OR LEN(@view_nm)=0
        SET @view_nm = CONCAT(@table_nm, 'View');

    IF dbo.fnCheckViewExists(@view_nm, 'dbo') = 0
    BEGIN
        SET @error_msg = CONCAT('unknown view: [', @view_nm, ']')
        RETURN 0
    END

    -- @sheet_nm = <table>
    IF @sheet_nm IS NULL OR LEN(@view_nm)=0
        SET @sheet_nm = @table_nm;

    EXEC master..sp_log @fn,  'done'
    RETURN 1 -- OK
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Create Procedure sp_exprt_to_xl


-- =============================================
-- Author:      Terry Watts
-- Create date: 26-OCT-2019
-- Description: Creates an Excel xls file as a TSV
-- N.B.: It needs to be loaded by Excel to actual make a .xls formatted file, however
-- Excel will open a CSV or TSV as an Excel file with a warning prompt
--
-- Process:
--  Validate parameters
--      Mandatory parameters
--          table name
--          folder
--
--  set paramter defaults as needed
--      file name       <table>.xlsx
--      sheet_name:     <table>
--      view:           <table>View
--      timestamp:      <current time and date> Fprmat YYMMDD-HHmm
-- =============================================
CREATE PROCEDURE [dbo].[sp_exprt_to_xl]
       @tbl_nm       NVARCHAR(50)
      ,@folder       NVARCHAR(260)
      ,@wrkbk_nm     NVARCHAR(260)  = NULL
      ,@sht_nm       NVARCHAR(50)   = NULL
      ,@vw_nm        NVARCHAR(50)   = NULL
      ,@filter       NVARCHAR(MAX)  = NULL
      ,@crt_tmstmp   BIT            = 1
      ,@max_rows     INT            = NULL
AS
BEGIN 

   DECLARE
       @fn           NVARCHAR(30)   = 'EXPRT TO XL'
      ,@Line         NVARCHAR(102)  =  CONCAT(REPLICATE('-', 100), NCHAR(13), NCHAR(10))
      ,@sql          NVARCHAR(MAX)
      ,@backslash    NCHAR          = NCHAR(92)
      ,@columns      NVARCHAR(MAX)
      ,@err_msg      NVARCHAR(200)
      ,@ndx          INT
      ,@opnRwStSql   NVARCHAR(MAX)
      ,@rc           INT
      ,@srvr_nm      NVARCHAR(100)
      ,@tmstmp       NVARCHAR(30)
      ,@xl_fle_pth   NVARCHAR(260)

   EXEC sp_log @fn,  'starting'

   -- Validate
   EXEC @rc = dbo.sp_exprt_to_xl_val 
          @tbl_nm     = @tbl_nm
         ,@folder     = @folder
         ,@wrkbk_nm   = @wrkbk_nm OUT
         ,@sht_nm     = @sht_nm   OUT
         ,@vw_nm    = @vw_nm  OUT
         ,@err_msg    = @err_msg  OUT

   IF @rc = 0
   BEGIN
      ;THROW 50306, @err_msg, 1
   END

   SET @ndx = CHARINDEX('.xls', @wrkbk_nm)

   IF @ndx > 0
      SET @wrkbk_nm = SUBSTRING(@wrkbk_nm, 1, @ndx-1)

   IF @crt_tmstmp = 1
   BEGIN
      -- timestamp= <current time and date> Format YYMMDD-HHmm
      SET @xl_fle_pth = CONCAT(@folder, @backslash, @wrkbk_nm, ' ', ut.dbo.fnGetTimestamp(NULL), '.xlsx')
   END
   ELSE
   BEGIN
      SET @xl_fle_pth = CONCAT(@folder, @backslash, @wrkbk_nm, '.xlsx')
   END

   -- Create an .xlsx file containing the column header
   SET @columns = ut.dbo.fnGetColumnNames(@vw_nm)
   PRINT @columns
   SET @sql = CONCAT('EXEC master..xp_cmdshell ''CreateExcelFile.exe  "', @xl_fle_pth, '" "', @sht_nm, '" "', @columns, '" ''');
   PRINT @sql
   EXEC (@sql)

   EXEC @opnRwStSql = ut.dbo.fnGetOpenRowSetXL_SQL @xl_fle_pth, @sht_nm

   -- Add in the TOP n rows clause if specified
   SET @sql = CASE 
               WHEN @max_rows IS NULL 
                  THEN CONCAT('INSERT INTO ', @opnRwStSql, ' SELECT ',                   @columns, ' FROM ', @vw_nm)
                  ELSE CONCAT('INSERT INTO ', @opnRwStSql, ' SELECT TOP ',@max_rows,' ', @columns, ' FROM ', @vw_nm)
               END

   -- Add in the filter and order by clause if specified
   IF @filter IS NOT NULL
      SET @sql = CONCAT(@sql,' ', @filter)

   PRINT @sql
   EXEC (@sql)

   EXEC sp_log @fn,  'done'
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:      Terry Watts
-- Create date: 27-DEC-2019
-- Description: validaes and corrects procedure sp_export_to_excel parameters
--  Validate parameters
--      Mandatory parameters
--          table name
--          folder
--
--  set paramter defaults as needed
--      file name       <table>.xlsx            set if NULL or empty
--      sheet_name:     <table>                 set if NULL or empty
--      view:           <table>View             set if NULL or empty
--      timestamp:      <current time and date> set if NULL Format YYMMDD-HHmm
--
-- POSTCONDITIONS
-- returns  1 if OK
--            if error throw exception 50102with msg
-- =============================================
CREATE PROCEDURE [dbo].[sp_exprt_to_xl_val]
       @tbl_nm    NVARCHAR(50)
      ,@folder    NVARCHAR(260)
      ,@wrkbk_nm  NVARCHAR(260)  OUTPUT
      ,@sht_nm    NVARCHAR(50)   OUTPUT
      ,@vw_nm     NVARCHAR(50)   OUTPUT
AS
BEGIN
   DECLARE             --                                  '                            : '
       @fn        NVARCHAR(30)   =   'EXPORT TO EXCEL VALIDATE    : '
      ,@err_msg   NVARCHAR(200)

   EXEC sp_log @fn,  'starting'

   WHILE 1=1
   BEGIN
      -- Validation
      IF @tbl_nm IS NULL OR LEN(@tbl_nm)=0
      BEGIN
         SET @err_msg = 'table must be specified'
         BREAK;
      END

      IF ut.dbo.fnCheckTableExists(@tbl_nm, 'dbo') = 0
      BEGIN
         SET @err_msg = 'unknown table'
         BREAK;
      END

      IF @folder IS NULL OR LEN(@folder)=0
      BEGIN
         SET @err_msg = 'folder must be specified'
         BREAK;
      END

      -- set paramter defaults as needed
      -- file name = <table>.xlsx
      IF @wrkbk_nm IS NULL OR LEN(@wrkbk_nm)=0
         SET @wrkbk_nm = CONCAT(@tbl_nm, '.xlsx');

      -- view: = <table>View
      IF @vw_nm IS NULL OR LEN(@vw_nm)=0
         SET @vw_nm = CONCAT(@tbl_nm, 'View');

      IF ut.dbo.fnCheckViewExists(@vw_nm, 'dbo') = 0
      BEGIN
         SET @err_msg = CONCAT('unknown view: [', @vw_nm, ']')
         BREAK;
      END

      -- @sht_nm = <table>
      IF @sht_nm IS NULL OR LEN(@vw_nm)=0
         SET @sht_nm = @tbl_nm;
   END

   -- If error throw exception 50102with msg
   IF @err_msg IS NOT NULL
      THROW 50102, @err_msg, 1
 
   EXEC sp_log @fn,  'done'
   RETURN 1 -- OK
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 09-FEB-2020
-- Description: Returns the count from a table or query - in @table_nm
-- =============================================
CREATE PROCEDURE [dbo].[sp_get_count]
            @table_nm                   NVARCHAR(60)
AS
BEGIN
    DECLARE @count                      INT
           ,@sql                        NVARCHAR(500)

    SET @sql = CONCAT('SELECT @count = COUNT(*) FROM ', @table_nm)
    EXECUTE sp_executesql @Query=@sql, @Params = N'@count INT OUTPUT', @count = @count OUTPUT;
    RETURN @count
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===============================================================
-- Author:      Terry Watts
-- Create date: 14-JUL-2020
-- Description: returns datbase id if datbase exists, 0 otherwise
-- ===============================================================
CREATE  PROCEDURE dbo.sp_get_database_id
       @db           NVARCHAR(40)
AS
BEGIN
   DECLARE
       @schema_id    INT

   SET NOCOUNT ON;
   SET @schema_id = DB_ID();
   --PRINT @schema_id;
   RETURN @schema_id;
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      TERRY WATTS
-- Create date: 18-APR-2020
-- Description: Creates an error message based on the current exception
--              and returns the full error message and its components (ex msg ex num, ex st, ex_ln)
-- =============================================
CREATE PROCEDURE [dbo].[sp_get_error_msg]
             @ex_num                   INT            = NULL   OUT
            ,@full_msg                 NVARCHAR(MAX)           OUT
            ,@ex_st                    INT            = NULL   OUT
            ,@ex_ln                    INT            = NULL   OUT
            ,@ex_msg                   NVARCHAR(MAX)  = NULL   OUT
AS
BEGIN
   SET @ex_num = ERROR_NUMBER ();
   SET @ex_msg = ERROR_MESSAGE();
   SET @ex_st  = ERROR_STATE  ();
   SET @ex_ln  = ERROR_LINE   ();

   SET @full_msg = CONCAT
      (
         'Exception '
         ,@ex_num
         ,', ',    @ex_msg
         ,' st: ', @ex_st
         ,' Ln: ', @ex_ln
      );
END

/*
EXEC sp_get_error_msg @ex_num OUT, @full_msg OUT, @ex_st OUT, @ex_ln OUT, @ex_msg OUT
*/

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Create Procedure sp_get_excel_data
-- =============================================
-- Author:      Terry Watts
-- Create date: <Create Date, ,>
-- Description: Returns SQL to execute to open an excel sheet
-- =============================================
CREATE PROCEDURE [dbo].[sp_get_excel_data]
             @xls_workbook              NVARCHAR(260)
            ,@sheet                     NVARCHAR(50)    = 'Sheet1'  -- Could spec a range e.g.: Sheet1$A2:AK
            ,@select_cols               NVARCHAR(2000)  = '*'       -- select column names for the insert to the table: can apply functions to the columns at this point
            ,@xl_cols                   NVARCHAR(2000)  = '*'       -- XL column names: can be *
            ,@whereClause               NVARCHAR(2000)  =''         -- Where clause like "WHERE province <> ''"  or ""
            ,@extension                 NVARCHAR(50)    = ''        -- e.g. HDR=NO;IMEX=1
            ,@sql                       NVARCHAR(4000)      OUTPUT  -- the sql to execute
AS
BEGIN
    SET @sql = CONCAT('SELECT ', @select_cols, CHAR(10), 'FROM ', dbo.fnGetOpenRowSetXL_SQL(@xls_workbook, @sheet, @xl_cols, @extension));                                                    -- Where clause like "WHERE province <> ''
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Wattsw
-- Create date: 28-DEC-2019
-- Description: List function details of all the functions
-- =============================================
CREATE PROCEDURE [dbo].[sp_get_function_details]
             @schema                    NVARCHAR(30)    = 'dbo'
            ,@like                      NVARCHAR(50)    = '%'
            ,@not_like                  NVARCHAR(50)    = ''
AS
BEGIN
    SELECT * FROM dbo.fnGetFunctionDetails( @like, @not_like ,@schema)
END

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Create Procedure sp_get_get_open_rowset

-- =============================================
-- Author:      Terry Watts
-- Create date: 12-JAN-2020
-- Description: wraps the openrowset for excel to make it easier to use
--
-- checks the file exists, exception if not throws exception 52587, 'invalid workbook file path', 1
--
-- returns a sql substring that can be used to open a rowset to an Excel range
-- LIKE OPENROWSET ( 'Micro' ... @extension,' Database=', @workbook_path SELECT ', @xl_cols 
-- =============================================
CREATE PROCEDURE [dbo].[sp_get_get_open_rowset]
       @workbook_path   NVARCHAR(260)
      ,@sheet           NVARCHAR(50)   = 'Sheet1$'
      ,@xl_cols         NVARCHAR(2000) = '*'        -- select XL column names: can be *
      ,@extension       NVARCHAR(50)   = NULL       -- default: 'HDR=NO;IMEX=1'
      ,@open_clause     NVARCHAR(MAX)   OUT
AS
BEGIN
   -- check path exists
   SET @open_clause = dbo.fnGetOpenRowSetXL_SQL
   (
       @workbook_path
      ,@sheet
      ,@xl_cols
      ,@extension
   )

   IF @open_clause IS NULL
      THROW 52587, 'invalid workbook file path', 1
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 18-JAN-2020
-- Description: Returns the 1 based line number for the offset into a string 
--              containing lines (ending in /r/n)

-- Method:
-- If the text does not end in a NL append one
-- Iterate the text taking line by line
-- foreach line
-- get  the start and end pos
-- if end is > required offset 
-- calculate the line column offset from the line staart and the and the required offset
-- return the line offset, column offfset and line end
-- =============================================
CREATE PROCEDURE [dbo].[sp_get_line_num] 
             @txt                       NVARCHAR(4000)
            ,@offset                    INT
            ,@ln_num                    INT OUT
            ,@ln_start                  INT OUT -- points to the furst characer in the line after NL
            ,@ln_end                    INT OUT
            ,@col                       INT OUT -- column is the offset in line (from line start pos)
AS
BEGIN
    DECLARE --                          41              =   61                          : '- 27 chars
             @fn                        NVARCHAR(30)    =   'TST HLP GEN                : '
            ,@NL                        NVARCHAR(2)     =   NCHAR(13)+NCHAR(10)
            ,@tmp                       NVARCHAR(1000)
            ,@len                       INT = LEN(@txt)

    SET @ln_num      = -1
    SET @ln_start    = -1
    SET @ln_end      = -1
    SET @col         = -1

    IF (@txt IS NULL) OR (@len = 0) OR (@offset < 0) OR (@offset > @len)
        RETURN 

    -- ASSERTION: if here then a valid offset
    SET @tmp = SUBSTRING(@txt, @len-2,2)

    -- If the text does not end in a NL append one
    IF SUBSTRING(@tmp, @len-2,2) <> @NL
        SET @txt = CONCAT(@txt, @NL)

    SET @ln_start   = 1
    SET @ln_num     = 1

    -- Iterate the text taking line by line
    -- foreach line
    WHILE ( @ln_end < @len)
    BEGIN
        -- ASSERTION at the beginning of the Line
        -- Get  the start and end pos
        SET @ln_start = @ln_end + 2
        SET @ln_end   = CHARINDEX(@NL, @txt, @ln_start)

        -- If no more lines
        IF @ln_end = 0
            BREAK;

        -- If end is > required offset 
        IF @ln_end > @offset
        BEGIN
            -- Calculate the column offset from the line staart and the and the required offset
            -- Return the line offset, column offfset and line end
            -- subtract the line start from the required offset
            -- dont error on values less than 1 just return the start pos - this is for test purposes
            SET @col = dbo.fnMax((@offset - @ln_start) + 1, 1)
            RETURN
        END

        -- Increment the line counter
        SET @ln_num   = @ln_num + 1
    END

    -- IF not found
    SET @ln_num     = -1;
    SET @ln_start   = -1;
    SET @ln_end     = -1
    SET @col        = -1
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================================
-- Author:      Terry Watts
-- Create date: 14-JUL-2020
-- Description: returns schema id if schema exists, 0 otherwise
-- =============================================================
CREATE PROCEDURE dbo.sp_get_schema_id
       @db           NVARCHAR(40)
      ,@schema       NVARCHAR(20)
AS
BEGIN
   DECLARE
       @sql          NVARCHAR(4000)
      ,@schema_id    INT

   SET NOCOUNT ON;
   SET @sql = CONCAT(N'SELECT @schema_id = schema_id FROM [',@db,'].sys.schemas WHERE [name] = ''', @schema, '''');
   --PRINT @sql;
   EXEC sp_executesql @query=@sql, @params=N'@schema_id INT OUT', @schema_id=@schema_id OUT;

   IF @schema_id IS NULL SET @schema_id = 0;
   --PRINT @schema_id;
   RETURN @schema_id;
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.sp_get_table_schema @table NVARCHAR(100), @schema NVARCHAR(100) = 'dbo', @db NVARCHAR(100) = NULL
AS
BEGIN
   DECLARE
       @sql    NVARCHAR(4000)
      ,@NL     NVARCHAR(2)       = NCHAR(13) + NCHAR(10)

   DROP TABLE IF EXISTS dbo.table_schema
   CREATE TABLE dbo.table_schema(COLUMN_NAME NVARCHAR(60), DATA_TYPE NVARCHAR(20), CHAR_LEN INT, IS_NULLABLE NVARCHAR(3), ORDINAL INT);

   IF @db IS NULL SET @db = DB_NAME();

   SET @SQL = CONCAT('INSERT INTO dbo.table_schema (COLUMN_NAME, DATA_TYPE, CHAR_LEN, IS_NULLABLE, ORDINAL ) ', @NL
   ,'SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE, ORDINAL_POSITION ', @NL
   ,'FROM ', @db,'.INFORMATION_SCHEMA.COLUMNS ', @NL
   ,'WHERE ',@NL
   ,'   TABLE_SCHEMA   = ''', @schema, ''' AND',@NL
   ,'   TABLE_NAME = ''', @table, ''' ',@NL
   ,'ORDER BY ORDINAL_POSITION;');

   PRINT @SQL;
   EXEC sp_executesql @SQL, N'@SQL';
   SELECT * FROM dbo.table_schema;
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Create Procedure sp_get_xl_range
-- =============================================
-- Author:      Terry Watts
-- Create date: 29-OCT-2019
-- Description: gets the range in an excel worksheet
-- =============================================
CREATE PROCEDURE [dbo].[sp_get_xl_range]
             @workbook_path             NVARCHAR(260)
            ,@sheet                     NVARCHAR(25)        =   'Sheet1'
            ,@num_rows                  INT             OUTPUT
AS
BEGIN
    DECLARE --                          41              =   61                          : '- 27 chars
             @fn                        NVARCHAR(30)    = 'GETXLRNG                     : '
            ,@error_msg                 NVARCHAR(500)
            ,@sql                       NVARCHAR(4000)
            ,@range                     NVARCHAR(50)
            ,@openRowSetSql             NVARCHAR(2000)

    BEGIN TRY
        DROP TABLE IF EXISTS tmpTbl
        SET @range = CONCAT(@sheet,'$', 'A1:AK3')
        SET @openRowSetSql = dbo.fnGetOpenRowSetXL_SQL(@workbook_path, @range, '*', 'HDR=NO;IMEX=1')
        SET @sql = CONCAT('SELECT * INTO tmpTbl FROM ', @openRowSetSql);

        EXEC sp_executesql @sql;
        SET @num_rows = (SELECT Top 1 F1 FROM tmpTbl)

    END TRY
    BEGIN CATCH
        SET @error_msg = dbo.fnGetErrorMsg();
        EXEC sp_log @fn,  'Error: ', @error_msg
    END CATCH
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Terry Watts
-- Create date: 08-JAN-2020
-- Description:	sp depends fix
-- original sig: create procedure sys.sp_depends  --- 1996/08/09 16:51  
-- =============================================
create PROCEDURE [dbo].[sp_i_depend_on_them] 
@objname nvarchar(776)  -- the object we want to check  
AS
BEGIN
  
declare @objid int   -- the id of the object we want  
declare @found_some bit   -- flag for dependencies found  
declare @dbname sysname  
  
  
--  Make sure the @objname is local to the current database.  
  
select @dbname = parsename(@objname,3)  
  
if @dbname is not null and @dbname <> db_name()  
 begin  
  raiserror(15250,-1,-1)  
  return (1)  
 end  
  
--  See if @objname exists.  
select @objid = object_id(@objname)  
if @objid is null  
 begin  
  select @dbname = db_name()  
  raiserror(15009,-1,-1,@objname,@dbname)  
  return (1)  
 end  
  
--  Initialize @found_some to indicate that we haven't seen any dependencies.  
select @found_some = 0  
  
set nocount on  
  
--  Print out the particulars about the local dependencies.  
if exists (select *  
  from sysdepends  
   where id = @objid)  
begin  
 raiserror(15459,-1,-1)  
 select   'name' = (s6.name+ '.' + o1.name),  
    type = substring(v2.name, 5, 66)  -- spt_values.name is nvarchar(70)  
--    updated = substring(u4.name, 1, 7),  
--    selected = substring(w5.name, 1, 8),  
--             'column' = col_name(d3.depid, d3.depnumber)  
  from  sys.objects  o1  
   ,master.dbo.spt_values v2  
   ,sysdepends  d3  
   ,master.dbo.spt_values u4  
   ,master.dbo.spt_values w5 --11667  
   ,sys.schemas  s6  
  where  o1.object_id = d3.depid  
  and  o1.type = substring(v2.name,1,2) collate catalog_default and v2.type = 'O9T'  
  and  u4.type = 'B' and u4.number = d3.resultobj  
  and  w5.type = 'B' and w5.number = d3.readobj|d3.selall  
  and  d3.id = @objid  
  and  o1.schema_id = s6.schema_id  
  and deptype < 2  
  
 select @found_some = 1  
end  

set nocount off  
  
return (0) -- sp_depends  
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===================================================
-- Author:      Terry Watts
-- Create date: 22-MAR-2020
-- Description: Logs to output and to the AppLog table
-- ===================================================
CREATE PROCEDURE [dbo].[sp_log]
 @fn     NVARCHAR(150) 
,@msg00  NVARCHAR(4000) = '' ,@msg01  NVARCHAR(4000) = '' ,@msg02  NVARCHAR(4000) = '' ,@msg03  NVARCHAR(4000) = '' ,@msg04  NVARCHAR(4000) = '' ,@msg05  NVARCHAR(4000) = '' ,@msg06  NVARCHAR(4000) = '' ,@msg07  NVARCHAR(4000) = '' ,@msg08  NVARCHAR(4000) = '' ,@msg09  NVARCHAR(4000) = ''
,@msg10  NVARCHAR(4000) = '' ,@msg11  NVARCHAR(4000) = '' ,@msg12  NVARCHAR(4000) = '' ,@msg13  NVARCHAR(4000) = '' ,@msg14  NVARCHAR(4000) = '' ,@msg15  NVARCHAR(4000) = '' ,@msg16  NVARCHAR(4000) = '' ,@msg17  NVARCHAR(4000) = '' ,@msg18  NVARCHAR(4000) = '' ,@msg19  NVARCHAR(4000) = ''
,@msg20  NVARCHAR(4000) = '' ,@msg21  NVARCHAR(4000) = '' ,@msg22  NVARCHAR(4000) = '' ,@msg23  NVARCHAR(4000) = '' ,@msg24  NVARCHAR(4000) = '' ,@msg25  NVARCHAR(4000) = '' ,@msg26  NVARCHAR(4000) = '' ,@msg27  NVARCHAR(4000) = '' ,@msg28  NVARCHAR(4000) = '' ,@msg29  NVARCHAR(4000) = ''
,@msg30  NVARCHAR(4000) = '' ,@msg31  NVARCHAR(4000) = '' ,@msg32  NVARCHAR(4000) = '' ,@msg33  NVARCHAR(4000) = '' ,@msg34  NVARCHAR(4000) = '' ,@msg35  NVARCHAR(4000) = '' ,@msg36  NVARCHAR(4000) = '' ,@msg37  NVARCHAR(4000) = '' ,@msg38  NVARCHAR(4000) = '' ,@msg39  NVARCHAR(4000) = ''
,@msg40  NVARCHAR(4000) = '' ,@msg41  NVARCHAR(4000) = '' ,@msg42  NVARCHAR(4000) = '' ,@msg43  NVARCHAR(4000) = '' ,@msg44  NVARCHAR(4000) = '' ,@msg45  NVARCHAR(4000) = '' ,@msg46  NVARCHAR(4000) = '' ,@msg47  NVARCHAR(4000) = '' ,@msg48  NVARCHAR(4000) = '' ,@msg49  NVARCHAR(4000) = ''
,@msg50  NVARCHAR(4000) = '' ,@msg51  NVARCHAR(4000) = '' ,@msg52  NVARCHAR(4000) = '' ,@msg53  NVARCHAR(4000) = '' ,@msg54  NVARCHAR(4000) = '' ,@msg55  NVARCHAR(4000) = '' ,@msg56  NVARCHAR(4000) = '' ,@msg57  NVARCHAR(4000) = '' ,@msg58  NVARCHAR(4000) = '' ,@msg59  NVARCHAR(4000) = ''
,@msg60  NVARCHAR(4000) = '' ,@msg61  NVARCHAR(4000) = '' ,@msg62  NVARCHAR(4000) = '' ,@msg63  NVARCHAR(4000) = '' ,@msg64  NVARCHAR(4000) = '' ,@msg65  NVARCHAR(4000) = '' ,@msg66  NVARCHAR(4000) = '' ,@msg67  NVARCHAR(4000) = '' ,@msg68  NVARCHAR(4000) = '' ,@msg69  NVARCHAR(4000) = ''
,@msg70  NVARCHAR(4000) = '' ,@msg71  NVARCHAR(4000) = '' ,@msg72  NVARCHAR(4000) = '' ,@msg73  NVARCHAR(4000) = '' ,@msg74  NVARCHAR(4000) = '' ,@msg75  NVARCHAR(4000) = '' ,@msg76  NVARCHAR(4000) = '' ,@msg77  NVARCHAR(4000) = '' ,@msg78  NVARCHAR(4000) = '' ,@msg79  NVARCHAR(4000) = ''
,@msg80  NVARCHAR(4000) = '' ,@msg81  NVARCHAR(4000) = '' ,@msg82  NVARCHAR(4000) = '' ,@msg83  NVARCHAR(4000) = '' ,@msg84  NVARCHAR(4000) = '' ,@msg85  NVARCHAR(4000) = '' ,@msg86  NVARCHAR(4000) = '' ,@msg87  NVARCHAR(4000) = '' ,@msg88  NVARCHAR(4000) = '' ,@msg89  NVARCHAR(4000) = ''
,@msg90  NVARCHAR(4000) = '' ,@msg91  NVARCHAR(4000) = '' ,@msg92  NVARCHAR(4000) = '' ,@msg93  NVARCHAR(4000) = '' ,@msg94  NVARCHAR(4000) = '' ,@msg95  NVARCHAR(4000) = '' ,@msg96  NVARCHAR(4000) = '' ,@msg97  NVARCHAR(4000) = '' ,@msg98  NVARCHAR(4000) = '' ,@msg99  NVARCHAR(4000) = ''
,@msg100 NVARCHAR(4000) = '' ,@msg101 NVARCHAR(4000) = '' ,@msg102 NVARCHAR(4000) = '' ,@msg103 NVARCHAR(4000) = '' ,@msg104 NVARCHAR(4000) = '' ,@msg105 NVARCHAR(4000) = '' ,@msg106 NVARCHAR(4000) = '' ,@msg107 NVARCHAR(4000) = '' ,@msg108 NVARCHAR(4000) = '' ,@msg109 NVARCHAR(4000) = ''
,@msg110 NVARCHAR(4000) = '' ,@msg111 NVARCHAR(4000) = '' ,@msg112 NVARCHAR(4000) = '' ,@msg113 NVARCHAR(4000) = '' ,@msg114 NVARCHAR(4000) = '' ,@msg115 NVARCHAR(4000) = '' ,@msg116 NVARCHAR(4000) = '' ,@msg117 NVARCHAR(4000) = '' ,@msg118 NVARCHAR(4000) = '' ,@msg119 NVARCHAR(4000) = ''
,@msg120 NVARCHAR(4000) = '' ,@msg121 NVARCHAR(4000) = '' ,@msg122 NVARCHAR(4000) = '' ,@msg123 NVARCHAR(4000) = '' ,@msg124 NVARCHAR(4000) = '' ,@msg125 NVARCHAR(4000) = '' ,@msg126 NVARCHAR(4000) = '' ,@msg127 NVARCHAR(4000) = '' ,@msg128 NVARCHAR(4000) = '' ,@msg129 NVARCHAR(4000) = ''
,@msg130 NVARCHAR(4000) = '' ,@msg131 NVARCHAR(4000) = '' ,@msg132 NVARCHAR(4000) = '' ,@msg133 NVARCHAR(4000) = '' ,@msg134 NVARCHAR(4000) = '' ,@msg135 NVARCHAR(4000) = '' ,@msg136 NVARCHAR(4000) = '' ,@msg137 NVARCHAR(4000) = '' ,@msg138 NVARCHAR(4000) = '' ,@msg139 NVARCHAR(4000) = ''
,@msg140 NVARCHAR(4000) = '' ,@msg141 NVARCHAR(4000) = '' ,@msg142 NVARCHAR(4000) = '' ,@msg143 NVARCHAR(4000) = '' ,@msg144 NVARCHAR(4000) = '' ,@msg145 NVARCHAR(4000) = '' ,@msg146 NVARCHAR(4000) = '' ,@msg147 NVARCHAR(4000) = '' ,@msg148 NVARCHAR(4000) = '' ,@msg149 NVARCHAR(4000) = ''
,@msg150 NVARCHAR(4000) = '' ,@msg151 NVARCHAR(4000) = '' ,@msg152 NVARCHAR(4000) = '' ,@msg153 NVARCHAR(4000) = '' ,@msg154 NVARCHAR(4000) = '' ,@msg155 NVARCHAR(4000) = '' ,@msg156 NVARCHAR(4000) = '' ,@msg157 NVARCHAR(4000) = '' ,@msg158 NVARCHAR(4000) = '' ,@msg159 NVARCHAR(4000) = ''
,@msg160 NVARCHAR(4000) = '' ,@msg161 NVARCHAR(4000) = '' ,@msg162 NVARCHAR(4000) = '' ,@msg163 NVARCHAR(4000) = '' ,@msg164 NVARCHAR(4000) = '' ,@msg165 NVARCHAR(4000) = '' ,@msg166 NVARCHAR(4000) = '' ,@msg167 NVARCHAR(4000) = '' ,@msg168 NVARCHAR(4000) = '' ,@msg169 NVARCHAR(4000) = ''
,@msg170 NVARCHAR(4000) = '' ,@msg171 NVARCHAR(4000) = '' ,@msg172 NVARCHAR(4000) = '' ,@msg173 NVARCHAR(4000) = '' ,@msg174 NVARCHAR(4000) = '' ,@msg175 NVARCHAR(4000) = '' ,@msg176 NVARCHAR(4000) = '' ,@msg177 NVARCHAR(4000) = '' ,@msg178 NVARCHAR(4000) = '' ,@msg179 NVARCHAR(4000) = ''
,@msg180 NVARCHAR(4000) = '' ,@msg181 NVARCHAR(4000) = '' ,@msg182 NVARCHAR(4000) = '' ,@msg183 NVARCHAR(4000) = '' ,@msg184 NVARCHAR(4000) = '' ,@msg185 NVARCHAR(4000) = '' ,@msg186 NVARCHAR(4000) = '' ,@msg187 NVARCHAR(4000) = '' ,@msg188 NVARCHAR(4000) = '' ,@msg189 NVARCHAR(4000) = ''
,@msg190 NVARCHAR(4000) = '' ,@msg191 NVARCHAR(4000) = '' ,@msg192 NVARCHAR(4000) = '' ,@msg193 NVARCHAR(4000) = '' ,@msg194 NVARCHAR(4000) = '' ,@msg195 NVARCHAR(4000) = '' ,@msg196 NVARCHAR(4000) = '' ,@msg197 NVARCHAR(4000) = '' ,@msg198 NVARCHAR(4000) = '' ,@msg199 NVARCHAR(4000) = ''
,@sf        INT = 0
,@hit       INT = 0 OUT
,@force     BIT = 0
,@dont_pad  BIT = 0
,@pad       INT = 20
AS
BEGIN
   DECLARE
      @tmp                       NVARCHAR(4000)
     ,@NL                        NVARCHAR(2)     = CHAR(13) + CHAR(10)
     ,@is_logging                INT
     ,@brk_count                 INT

   BEGIN TRY
   SET @tmp = CONCAT
   (
       @msg00  ,@msg01  ,@msg02  ,@msg03  ,@msg04  ,@msg05  ,@msg06  ,@msg07  ,@msg08  ,@msg09  ,@msg10  ,@msg11  ,@msg12  ,@msg13  ,@msg14  ,@msg15  ,@msg16  ,@msg17  ,@msg18  ,@msg19
      ,@msg20  ,@msg21  ,@msg22  ,@msg23  ,@msg24  ,@msg25  ,@msg26  ,@msg27  ,@msg28  ,@msg29  ,@msg30  ,@msg31  ,@msg32  ,@msg33  ,@msg34  ,@msg35  ,@msg36  ,@msg37  ,@msg38  ,@msg39
      ,@msg40  ,@msg41  ,@msg42  ,@msg43  ,@msg44  ,@msg45  ,@msg46  ,@msg47  ,@msg48  ,@msg49  ,@msg50  ,@msg51  ,@msg52  ,@msg53  ,@msg54  ,@msg55  ,@msg56  ,@msg57  ,@msg58  ,@msg59
      ,@msg60  ,@msg61  ,@msg62  ,@msg63  ,@msg64  ,@msg65  ,@msg66  ,@msg67  ,@msg68  ,@msg69  ,@msg70  ,@msg71  ,@msg72  ,@msg73  ,@msg74  ,@msg75  ,@msg76  ,@msg77  ,@msg78  ,@msg79
      ,@msg80  ,@msg81  ,@msg82  ,@msg83  ,@msg84  ,@msg85  ,@msg86  ,@msg87  ,@msg88  ,@msg89  ,@msg90  ,@msg91  ,@msg92  ,@msg93  ,@msg94  ,@msg95  ,@msg96  ,@msg97  ,@msg98  ,@msg99
      ,@msg100 ,@msg101 ,@msg102 ,@msg103 ,@msg104 ,@msg105 ,@msg106 ,@msg107 ,@msg108 ,@msg109 ,@msg110 ,@msg111 ,@msg112 ,@msg113 ,@msg114 ,@msg115 ,@msg116 ,@msg117 ,@msg118 ,@msg119
      ,@msg120 ,@msg121 ,@msg122 ,@msg123 ,@msg124 ,@msg125 ,@msg126 ,@msg127 ,@msg128 ,@msg129 ,@msg130 ,@msg131 ,@msg132 ,@msg133 ,@msg134 ,@msg135 ,@msg136 ,@msg137 ,@msg138 ,@msg139
      ,@msg140 ,@msg141 ,@msg142 ,@msg143 ,@msg144 ,@msg145 ,@msg146 ,@msg147 ,@msg148 ,@msg149 ,@msg150 ,@msg151 ,@msg152 ,@msg153 ,@msg154 ,@msg155 ,@msg156 ,@msg157 ,@msg158 ,@msg159
      ,@msg160 ,@msg161 ,@msg162 ,@msg163 ,@msg164 ,@msg165 ,@msg166 ,@msg167 ,@msg168 ,@msg169 ,@msg170 ,@msg171 ,@msg172 ,@msg173 ,@msg174 ,@msg175 ,@msg176 ,@msg177 ,@msg178 ,@msg179
      ,@msg180 ,@msg181 ,@msg182 ,@msg183 ,@msg184 ,@msg185 ,@msg186 ,@msg187 ,@msg188 ,@msg189 ,@msg190 ,@msg191 ,@msg192 ,@msg193 ,@msg194 ,@msg195 ,@msg196 ,@msg197 ,@msg198 ,@msg199
   );

   -- Only log to output if required
   SET @is_logging = CONVERT(INT, SESSION_CONTEXT(@fn));

   IF @is_logging IS NULL
    SET @is_logging = 0;

   -- If fn is specified and  if required then make it the standard length
   IF ((@fn IS NOT NULL) AND (LEN(@fn)>0) AND (@dont_pad = 0))
      SET @fn = CONCAT(dbo.fnPadRight(@fn, @pad), ': ');

   -- Always log to log table
   EXEC sp_app_log_insert @fn = @fn, @msg = @tmp, @sf = @sf, @hit=@hit

   -- check break
   SET @brk_count = CONVERT(INT, SESSION_CONTEXT(N'break point'));

   IF ((@brk_count IS NOT NULL) AND (@brk_count = @hit))
   BEGIN
      PRINT CONCAT('Breakpoint hit: ',@brk_count);
   END

   SET @hit = @hit + 1

   IF ((@is_logging <> 0) OR (@force = 1))
      PRINT CONCAT(@fn, @tmp);
   END TRY
   BEGIN CATCH
      PRINT dbo.fnGetErrorMsg();
      THROW;
   END CATCH
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ==================================================================
-- Author:      Terry Watts
-- Create date: 28-MAR-2020
-- Description: standard error handling:
--              get the exception message, log messages
-- ==================================================================
CREATE PROCEDURE [dbo].[sp_log_exception]
       @fn        NVARCHAR(1000)
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
      ,@ex_msg    NVARCHAR(1000) = NULL OUT
      ,@sf        INT            = 1
AS
BEGIN
   DECLARE 
        @NL       NVARCHAR(2)    =  NCHAR(13) + NCHAR(10)
       ,@msg      NVARCHAR(500)

   SET @ex_msg = dbo.fnGetErrorMsg();

   SET @msg = 
      CONCAT
      (
          @msg01--iif(@msg01 IS NOT NULL, CONCAT(' ', @msg01 ), '')
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
         ,' '
         ,@ex_msg
         ,@NL
         ,@NL
      );

   EXEC sp_log @fn, @msg, @sf=@sf,@force=1
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===================================================================
-- Author:      Terry Watts
-- Create date: 13-MAY-2020
-- Description: Logs the current part of a string, defined by pos
--
-- Called by:
--    testing and debugging as needed
--
-- Tests: ????
--
-- ===================================================================
CREATE PROCEDURE [dbo].[sp_log_line]
    @stage     NVARCHAR(100)
   ,@sql       NVARCHAR(4000)
   ,@pos       INT
   ,@Line      NVARCHAR(4000) OUT
   ,@fn        NVARCHAR(40)
   ,@force     BIT            = 0
   ,@all       BIT            = 0
   ,@sf        INT            = 1
AS
BEGIN
DECLARE
    @NL        NVARCHAR(2)    = NCHAR(13) + NCHAR(10)

   SET NOCOUNT ON;
   SET @Line = 
      CONCAT
      (
          'POS:', @pos, @NL
         ,'SQL:', IIF( @all <> 0, @sql, dbo.fnGetLine( @sql, @pos))
         ,']'
      );

   EXEC sp_log 'UT.LGLN: ', @fn, ' Stage ', @stage, @NL, @Line, @dont_pad=1,@force=@force,@sf=@sf
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===================================================================
-- Author:      Terry Watts
-- Create date: 01-JUL-2020
-- Description: simple Log of the current part of a string, defined by pos
--
-- Called by:
--    testing and debugging as needed
--
-- Tests: ????
--
-- ===================================================================
CREATE PROCEDURE [dbo].[sp_log_line2]
    @sql       NVARCHAR(4000)
   ,@pos       INT
   ,@len       INT            = -1
   ,@Line      NVARCHAR(MAX)  OUT -- [IN/OUT]
   ,@fn        NVARCHAR(40)   = N'sp_log_line2'
   ,@force     BIT            = 0
   ,@sf        INT            = 1
AS
BEGIN
DECLARE
    @NL        NVARCHAR(2)    = NCHAR(13) + NCHAR(10)

   IF @len = -1
      SET @len = IIF(@sql IS NOT NULL, Len(@sql), 0);

   SET @Line = CONCAT(' SUBSTRING( @sql, ',@pos, ',', @len,') = ',dbo.fnGetLine2( @sql, @pos, @len));
   EXEC sp_log @fn, @Line, @dont_pad=1,@force=@force,@sf=@sf
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =================================================================
-- Author:      Terry Watts
-- Create date: 31-MAY-2020
-- Description: creates the message and raises the assertion
--    assuming in a fail state (i.e. check already done and failed)
-- =================================================================
CREATE PROCEDURE [dbo].[sp_raise_assert]
       @a         SQL_VARIANT
      ,@b         SQL_VARIANT
      ,@ex_num    INT
      ,@fn        NVARCHAR(60)
      ,@msg       NVARCHAR(200)
      ,@msg2      NVARCHAR(200)
      ,@msg3      NVARCHAR(200)
      ,@msg4      NVARCHAR(200)
      ,@msg5      NVARCHAR(200)
      ,@msg6      NVARCHAR(200)
      ,@msg7      NVARCHAR(200)
      ,@msg8      NVARCHAR(200)
      ,@msg9      NVARCHAR(200)
      ,@msg10     NVARCHAR(200)
      ,@state     INT
      ,@fnT       NVARCHAR(60)
      ,@sf        INT

AS
BEGIN
   DECLARE
       @txt       NVARCHAR(200)
      ,@NL        NVARCHAR(4) = dbo.fnGetNL();

   --IF dbo.fnGetSessionContextAsInt(N'DISPLAY_ASSERT') <> 0
   SET @txt = CONCAT( @fn, ': ', @fnT, N' fired: '
                      ,@msg, @msg2, @msg3, @msg4, @msg5,@msg6, @msg7, @msg8, @msg9,@msg10
                      ,@NL,N'  a:[', CONVERT(NVARCHAR(MAX), @a), N']'
                      ,@NL,N'  b:[', CONVERT(NVARCHAR(MAX), @b), N']');

   EXEC sp_raise_exception @ex_num, @txt, @state = @state, @fn = @fn, @sf = @sf
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 25-MAR-2020
-- Description: Raises an exception
--              Ensures @state is positive
-- =============================================
CREATE PROCEDURE [dbo].[sp_raise_exception]
       @ex_code   INT             = 53000
      ,@msg       NVARCHAR(1000)
      ,@msg2      NVARCHAR(1000)   = NULL
      ,@msg3      NVARCHAR(1000)   = NULL
      ,@state     INT              = 1
      ,@fn        NVARCHAR(60)     = '*'
      ,@sf        INT              = 0
AS
BEGIN
   DECLARE
       --@fn2       NVARCHAR(60)     = 'RAISE EXCTPN'
      @tmp       NVARCHAR(4000)
      ,@ex_code2  INT

   SET @ex_code2 = @ex_code;

   SET @tmp = 
      CONCAT
      (
          @msg
         ,iif(@msg2 IS NOT NULL, ' ', ''), iif(@msg2 IS NOT NULL, @msg2, '')
         ,iif(@msg3 IS NOT NULL, ' ', ''), iif(@msg3 IS NOT NULL, @msg3, '')
      );

   -- if ex code < 50000 message and raise to a valid number
   IF @ex_code < 50000
   BEGIN
      SET @ex_code2 = @ex_code + 50000;

      EXEC sp_log @fn, 'WARNING: supplied @ex_code is too low ', @ex_code, ' msg:', @tmp,' state: ', @state
         ,' changing @ex_code to ', @ex_code2, @sf=@sf,@force=1;
   END

   -- Cannot send negative state so invert
   IF @state < 0
      SET @state = 0 - @state;

   --EXEC sp_log @fn, 'E', @ex_code2, '.', @state, ': ', @tmp, @sf=@sf,@force=1;
   THROW @ex_code2, @msg, @state;
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ========================================================
-- Author:      Terry Watts
-- Create date: 07-JAN-2020
-- Description: produces a set of reformatted rows
-- from a routine (stored procedure or function in which
-- the tabs are replaced by the correct number of spaces.
-- ========================================================
CREATE PROCEDURE [dbo].[sp_reformat_rtn]
       @qlfd_rtn_nm  NVARCHAR(100)
      ,@tab_sz       INT = 3
AS
BEGIN
   DECLARE
       @sql NVARCHAR(4000)
      ,@NL  NVARCHAR(2)   = NCHAR(13)+NCHAR(10)

   SET @sql = CONCAT( [dbo].[fnCreateRoutineLinesTableAndPopulateScript]( @qlfd_rtn_nm, 'tmp_rfr') 
    ,'ut.dbo.fnRTrim(ut.dbo.fnReplaceCreateWithAlter(ut.dbo.fnReplaceTabsAndReformat(txt, ', @tab_sz, '))) 
    FROM tmp_rfr ORDER BY id;');

   PRINT CONCAT('SQL:', @NL, @sql);
   EXEC sp_executesql @sql
END
/*
   exec [dbo].[sp_reformat_rtn] 'sp_assert_gtr_than_or_equals'
*/
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry watts
-- Create date: 27-APR-2020
-- Description: Renames a column in a table
-- =============================================
CREATE PROCEDURE [dbo].[sp_rename_cols]
         @table_name        NVARCHAR(60)
        ,@old_col_nm        NVARCHAR(60)
        ,@new_col_nm        NVARCHAR(60)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE 
         @sql               NVARCHAR(MAX)

    SET @sql = CONCAT('IF EXISTS (Select 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = ''',@table_name,'''  
    AND COLUMN_NAME = ''', @old_col_nm, ''')
    EXEC sp_rename ''',@table_name,'.',@old_col_nm,''', ''', @new_col_nm, ''',''COLUMN''');

    PRINT @sql;
    EXEC sp_executesql @sql;
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 21-JUN-2020
-- Description: Creates a script to rename procedures
-- and references in a sql file
-- =============================================
CREATE PROCEDURE [dbo].[sp_rename_rtns]
       @file_pth  NVARCHAR(500)
      ,@schema    NVARCHAR(20)
      ,@nm_fltr   NVARCHAR(100)
      ,@tgt       NVARCHAR(500) = NULL
      ,@rep       NVARCHAR(500) = NULL
      ,@switches  NVARCHAR(50)  = NULL
AS
BEGIN
   DECLARE
       @sql       NVARCHAR(MAX)

   -- change the encoding to UTF-8
   --SELECT * FROM dbo.[fnSysRtnsVw]('test %', 'test', NULL)
   --SET @SQL = 
   SET @sql = CONCAT('SELECT CONCAT(''FART "', @file_pth, '" "', @tgt,'" "', @rep, '" -V -n ', @switches, ''') 
   AS cmd__________________________________________________________________________________________________________________________
   FROM dbo.[fnSysRtnsVw](''',@nm_fltr,''',''', @schema, ''',NULL)
   ORDER BY [name];
   ');

   PRINT @SQL;
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================================
-- Author:      Terry Watts
-- Create date: 14-JUL-2020
-- Description: returns non 0 @schema_id if schema exists, 
-- false otherwise
-- =============================================================
CREATE PROCEDURE [dbo].[sp_schema_exists] 
       @db           NVARCHAR(40)
      ,@schema       NVARCHAR(20)
AS
BEGIN
   DECLARE
      @schema_id    INT

   EXEC @schema_id = dbo.sp_get_schema_id @db, @schema
   RETURN @schema_id;
END

/*
DECLARE @schema_id    INT
EXEC @schema_id = dbo.sp_get_schema_id  'ut', 'test';
PRINT @schema_id
*/
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 16-MAR-2020
-- Description: Drop all the SQLTreeO extended properties
-- for testing
-- =============================================
CREATE PROCEDURE [dbo].[sp_sqltreeo_drop_folders] 
AS
BEGIN
    DECLARE
             @cursor        CURSOR
            ,@name          NVARCHAR(100)
            ,@value         NVARCHAR(500)
    
    BEGIN TRY
        SET @cursor = CURSOR FAST_FORWARD FOR SELECT name, value FROM dbo.SQLTreeOConfig;
        OPEN @cursor;
        FETCH NEXT FROM @cursor INTO @name, @value

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- add the dynamic folder if it does not alreaady exist
            IF EXISTS (SELECT 1 FROM TEMPDB.sys.extended_properties WHERE name = @name)
                EXEC TEMPDB.sys.sp_dropextendedproperty @name;

        FETCH NEXT FROM @cursor INTO @name, @value;
        END
    END TRY
    BEGIN CATCH

        CLOSE @cursor;
    END CATCH
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- =============================================
-- Author:      Terry Watts
-- Create date: 14-MAY-2020
-- Description: repopulates the SQLTreeOConfig table and rereshes folders
-- =============================================
CREATE PROCEDURE [dbo].[sp_sqltreeo_repopulate_table]
AS
BEGIN
TRUNCATE TABLE SQLTreeOConfig;
INSERT INTO SQLTreeOConfig (name, value) VALUES
 ('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~ScalarValuedFunction|~dbo','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">dbo.%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~ScalarValuedFunction|~test','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~ScalarValuedFunction|~tsqlt','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">tsqlt.%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~StoredProcedure|~_tests 000-099','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.test 0%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~StoredProcedure|~_tests 100-199','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.test 1%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~StoredProcedure|~_tests 200-299','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.test 2%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~StoredProcedure|~dbo','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">dbo.%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~StoredProcedure|~test helpers 000-099','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.helper T0%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~StoredProcedure|~test helpers 100-199','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.helper T1%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~StoredProcedure|~test helpers 200-299','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.helper T2%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~StoredProcedure|~test support','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.sp_tst%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~StoredProcedure|~tsqlt','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">tsqlt.%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~Table|~dbo','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">dbo.%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~Table|~test','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~Table|~tsqlt','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">tsqlt.%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~TableValuedFunction|~dbo','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">dbo.%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~TableValuedFunction|~test','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~TableValuedFunction|~tsqlt','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">tsqlt.%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~View|~dbo','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">dbo.%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~View|~test','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~View|~tSQLt','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">tSQLt.%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('Dian','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">Dian</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~Global|~Database|~Dian','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">Dian%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~StoredProcedure|~test setup','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.test_setup%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~Covid|~Table|~Hopkins','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">dbo.Hopkins%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~StoredProcedure|~test_close','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.test_close %</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~StoredProcedure|~test_setup','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.test_setup%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~StoredProcedure|~test 000-099','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.test 0%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~StoredProcedure|~test 100-199','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.test 1%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~StoredProcedure|~test 200-299','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.test 2%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>');


END

/*

EXEC sp_sqltreeo_restore_folders
SELECT * FROM SQLTreeOConfig;
*/
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 16-MAR-2020
-- Description: Resyores the SQLTreeO folders
--    by repopulating the extended properties
-- =============================================
CREATE PROCEDURE [dbo].[sp_sqltreeo_restore_folders] 
AS
BEGIN
   DECLARE
       @cursor CURSOR
      ,@name   NVARCHAR(100)
      ,@value  NVARCHAR(500)

   BEGIN TRY
      SET @cursor = CURSOR FAST_FORWARD FOR SELECT name, value FROM ut.dbo.SQLTreeOConfig;
      OPEN @cursor;
      FETCH NEXT FROM @cursor INTO @name, @value

      WHILE @@FETCH_STATUS = 0
      BEGIN
         -- add the dynamic folder if it does not alreaady exist
         IF NOT EXISTS (SELECT 1 FROM TEMPDB.sys.extended_properties WHERE name = @name)
            EXEC TEMPDB.sys.sp_addextendedproperty @name = @name, @value = @value;

      FETCH NEXT FROM @cursor INTO @name, @value;
      END
   END TRY
   BEGIN CATCH
   END CATCH

   CLOSE @cursor;
END

/*
EXEC [dbo].[sp_sqltreeo_restore_folders] 
*/
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =====================================================
-- Author:      Terry Watts
-- Create date: 16-MAR-2020
-- Description: refreshes the SQLTreeOConfig table
--    with the SQLTreeO extended properties.
--    Does a full merge add, update and delete
--    use when additions or changes to the dyn folders
-- ERROR CODES: none
-- =====================================================
CREATE PROCEDURE [dbo].[sp_sqltreeo_update_folder_cfg_table]
AS
BEGIN
   DECLARE
        @fn          NVARCHAR(20)   = N'POP_TST_CFG'
       ,@old_count   INT

   EXEC sp_log @fn, 'starting'
   SELECT @old_count = COUNT(*) FROM dbo.SQLTreeOConfig
-- Create a temporary table to hold the updated or inserted values
-- from the OUTPUT clause.

   IF NOT EXISTS (SELECT 1 FROM [INFORMATION_SCHEMA].[TABLES] 
      WHERE table_name = 'SqlTreeoTempTable')
         CREATE TABLE SqlTreeoTempTable
         (
            [action]       NVARCHAR(20),
            inserted_nm    NVARCHAR(1000),
            inserted_val   NVARCHAR(1000),
            deleted_nm     NVARCHAR(1000),
            deleted_val    NVARCHAR(1000),
         );

   IF NOT EXISTS (SELECT 1 FROM [INFORMATION_SCHEMA].[TABLES] 
      WHERE table_name = 'SqlTreeoStatsTable')
         CREATE TABLE dbo.SqlTreeoStatsTable(
            updated  int NULL,
            inserted int NULL,
            deleted  int NULL
         );

   TRUNCATE TABLE SqlTreeoTempTable;
   TRUNCATE TABLE SqlTreeoStatsTable;

   MERGE dbo.SQLTreeOConfig c--(name, value)
   USING
   (
      SELECT name, CONVERT(NVARCHAR(500),[value]) as [value]
      FROM tempDB.sys.extended_properties
   ) h ON c.[name] = h.[name]
   WHEN MATCHED AND h.[value] <> c.[value] THEN UPDATE 
      SET [name] = h.[name], c.[value] = h.[value]
   WHEN NOT MATCHED THEN INSERT ([name], [value])
      VALUES (h.[name], h.[value])
   WHEN NOT MATCHED BY SOURCE 
      THEN DELETE
   OUTPUT $action, inserted.[name] as inserted_nm, inserted.[value] as inserted_val
         ,deleted.name as deleted_nm, deleted.value as deleted_val INTO SqlTreeoTempTable;

   -- stats
   SELECT * FROM SqlTreeoTempTable;

   INSERT INTO SqlTreeoStatsTable ( updated, inserted, deleted)
      SELECT A.updated AS updated, b.inserted as inserted, c.deleted as deleted
      FROM 
       (SELECT count(*) AS updated  FROM SqlTreeoTempTable WHERE [action] = 'UPDATE') A
      ,(SELECT count(*) AS inserted FROM SqlTreeoTempTable WHERE [action] = 'INSERT') B
      ,(SELECT count(*) AS deleted  FROM SqlTreeoTempTable WHERE [action] = 'DELETE') C

   EXEC sp_log @fn, 'leaving'
END

/*
SELECT count(*) FROM SQLTreeOConfig
EXEC [dbo].[sp_sqltreeo_update_folder_cfg_table]
SELECT count(*) FROM SQLTreeOConfig
*/
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =========================================================================
-- Author:      Terry Watts
-- Create date: 01-JUN-2020
-- Description: returns a list of matching routines from the given database
-- =========================================================================
CREATE PROCEDURE [dbo].[sp_sys_rtn_vw]
    @db        NVARCHAR(40)
   ,@schema    NVARCHAR(20)   = NULL
   ,@name      NVARCHAR(60)   = NULL
   ,@ty_code   NVARCHAR(20)   = NULL
   ,@top       INT            = NULL
   ,@sf        INT            = 1
AS
BEGIN
   DECLARE 
       @fn     NVARCHAR(20)   = N'UT.SYS_RTNS_VW'
      ,@NL     NVARCHAR(2)    = NCHAR(13) + NCHAR(10)
      ,@sql    NVARCHAR(MAX)

   EXEC sp_log @fn, 'starting',@sf=@sf
   SET @schema    = iif(@schema  IS NULL, '%', @schema);
   SET @name      = iif(@name    IS NULL, '%', @name);
   SET @ty_code   = iif(@ty_code IS NULL, '%', @ty_code);

   if @top IS NULL
      SET @top = 2000

   SET @sql = CONCAT(
'SELECT TOP ', @top,'
     ''',@db,''' as db_name
    ,OBJECT_SCHEMA_NAME(object_id, db_id(''',@db,'''))        AS [schema]
    ,[name]
    ,[type]                               AS type_code
    ,[type_desc]                          AS type_nm
    ,iif([type] IN(''P'',''PC''), 1, 2)   AS type_id
    ,ut.dbo.fnFormatDate(create_date)     AS created
    ,ut.dbo.fnFormatDate(modify_date)     AS modified
FROM ', @db, '.sys.objects
    WHERE
     [type] IN (''P'', ''FN'', ''TF'', ''IF'', ''AF'', ''FT'', ''IS'', ''PC'', ''FS'')
     AND name LIKE ''', @name,'''
ORDER BY [schema], [type], [name];');

   EXEC sp_log @fn, 'sp_sys_rtns_vw sql:',@NL,@NL, @sql,@NL,@NL,@sf=@sf
   EXECUTE sp_executesql @sql
   EXEC sp_log @fn, 'leaving',@sf=@sf
END

/*
EXEC sp_set_session_context N'TREND_RPT_PP'     , 1
EXEC ut.[dbo].[sp_sys_rtn_vw]
    @db        = 'tg'
   ,@schema    = 'dbo'
   ,@name      = NULL
   ,@ty_code   = NULL
   ,@top       = 15
   ,@sf        =  1

EXEC ut.[dbo].[sp_sys_rtns_vw]
    @db        = 'ut'
   ,@schema    = 'dbo'
   ,@name      = NULL
   ,@ty_code   = NULL
   ,@top       = 15
   ,@sf        =  1
*/
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 08-FEB-2020
-- Description: returns true (1) if table exists else false (0)
-- Parameters:
--    @table_spec <db>.<schema>.<table>
--
-- db default is DB_NAME()
-- schema default is dbo
-- =============================================
CREATE PROCEDURE dbo.sp_table_exists
       @table_spec   NVARCHAR(60)
      ,@exists       BIT   OUT
AS
BEGIN
   DECLARE
       @db        NVARCHAR(20)   = DB_NAME()
      ,@schema    NVARCHAR(20)   = 'dbo'
      ,@table     NVARCHAR(60)
      ,@sql       NVARCHAR(200)
      ,@n         INT

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
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Create Procedure sp_write_file
-- ===================================================================
-- Author:       Terry Watts
-- Create date:  12-MAY-2020
-- Description:  returns the parameters string for the tested routine
-- Lookout for file permissions soft failure
-- ===================================================================
CREATE PROC [dbo].[sp_write_file]
            @text                      VARCHAR(8000),
            @file                      VARCHAR(500),
            @overwrite                 BIT = 1
AS
BEGIN
   DECLARE   @fn           NVARCHAR(100) = 'WRITE_FILE'
            ,@ex_msg       NVARCHAR(500)
            ,@hr           INT

   BEGIN TRY
   -- ACTIVATE XP_CMDSHELL
/*      EXEC @hr = sp_configure 'show advanced options', 1;
      EXEC dbo.sp_assert_equals 0, @hr, 50001, 'sp_configure show adv failed'
      RECONFIGURE;
      EXEC @hr = sp_configure 'Ole Automation Procedures', 1;
      EXEC dbo.sp_assert_equals 0, @hr, 50002, 'sp_configure OLE failed'
      RECONFIGURE;
   */
      SET NOCOUNT ON
      DECLARE @query        VARCHAR(8000)

      DECLARE @OLE INT
      DECLARE @FileID INT
      EXECUTE  @hr = sp_OACreate  'Scripting.FileSystemObject', @OLE OUT
         EXEC dbo.sp_assert_equal 0, @hr, 50003, 'Scripting.FileSystemObject failed'

      BEGIN TRY
         EXECUTE @hr = sp_OAMethod  @OLE, 50004,    'DeleteFile', @file
         END TRY
         BEGIN CATCH
            SET @ex_msg = dbo.fnGetErrorMsg()
            EXEC sp_log 'Caught exception deleting file:[', @file,'] ex: ',@ex_msg
         END CATCH

         EXECUTE @hr = sp_OAMethod  @OLE, 'OpenTextFile', @FileID OUT, @file, 2--, 1
         EXEC dbo.sp_assert_equal 0, @hr, 50005, 'sp_OAMethod  @OLE, OpenTextFile failed'
         EXECUTE @hr = sp_OAMethod  @FileID, 'WriteLine', Null, @text
         EXEC dbo.sp_assert_equal 0, @hr, 50006, 'sp_OAMethod  @FileID, WriteLine failed'
         EXECUTE @hr = sp_OADestroy @FileID
         EXEC dbo.sp_assert_equal 0, @hr, 50007, 'sp_OADestroy @FileID failed'
         EXECUTE @hr = sp_OADestroy @OLE
         EXEC dbo.sp_assert_equal 0, @hr, 50007, 'sp_OADestroy OLE failed'

         /*
         -- Step 3: Disable Ole Automation Procedures
         EXEC @hr = sp_configure 'show advanced options', 1;
         RECONFIGURE;
         EXEC dbo.sp_assert_equals 0, @hr, 50009, 'Ole Auto close show adv failed'
         EXEC @hr = sp_configure 'Ole Automation Procedures', 0;
         EXEC dbo.sp_assert_equals 0, @hr, 50010, 'Ole Auto close failed'
         RECONFIGURE;
         */
      END TRY
      BEGIN CATCH
         SET @ex_msg = dbo.fnGetErrorMsg()
         EXEC sp_log 'Caught exception writing to file:[', @file,'] ex: ',@ex_msg;
         THROW;
      END CATCH

END
/*ALTER PROC [dbo].[sp_write_file2]
            @text                      VARCHAR(8000),
            @file_path                 VARCHAR(500),
            @overwrite                 BIT = 1
AS
BEGIN
   DECLARE   @fn                       NVARCHAR(100) = 'WRITE_FILE'
            ,@ex_msg                   NVARCHAR(500)
            ,@query                    VARCHAR(8000)
            ,@Stage                    NVARCHAR(100)
            ,@hr                       INT
            ,@success                  INT
            ,@file_exists              INT
            ,@fso                      INT
            ,@FileID                   INT

   BEGIN TRY
      SET NOCOUNT ON
   -- ACTIVATE XP_CMDSHELL
      SET @Stage = ' 1: sp_config shw adv opt'
      EXEC @hr = sp_configure 'show advanced options', 1;
      PRINT CONCAT(@Stage, CONVERT(VARCHAR, @hr))
      EXEC dbo.sp_assert_equals 0, @hr, 50001, 'sp_configure show adv failed'
      RECONFIGURE;

      SET @Stage = ' 2: sp_config Ole Auto'
      EXEC @hr = sp_configure 'Ole Automation Procedures', 1;
      PRINT CONCAT(@Stage, CONVERT(VARCHAR, @hr))
      EXEC dbo.sp_assert_equals 0, @hr, 50002, 'sp_configure @fso failed'
      RECONFIGURE;

      SET @Stage = ' 3: sp_OACreate FSO'
      EXEC @hr = sp_OACreate  'Scripting.FileSystemObject', @fso OUT
      PRINT CONCAT(@Stage, CONVERT(VARCHAR, @hr))
      EXEC dbo.sp_assert_equals 0, @hr, 50003, 'Create Scripting.FileSystemObject failed'

      -- Wrap with quotes if need be

      IF ((CHARINDEX( ' ', @file_path) <> 0) AND (CHARINDEX( '''', @file_path) = 0))
         SET @file_path = CONCAT('''', @file_path, '''');

      -- -2146828236 800A0034 Bad file name or file number
      EXEC @hr = sp_OAMethod @fso, 'FileExists', @file_exists out, @file_path
      SET @Stage = CONCAT(' 4: FileExists:[', @file_path, '] ');
      PRINT CONCAT('Check if FileExists:', @file_exists);
      EXEC dbo.sp_assert_equals 0, @hr, 50004, 'sp_configure show adv failed'
--*
      IF @file_exists <> 0
      BEGIN
         SET @Stage = CONCAT(' 5: Del File:[', @file_path, '] ');
         EXEC @hr = sp_OAMethod  @fso, @success OUT, 'DeleteFile', @file_path
         PRINT CONCAT(@Stage, CONVERT(VARCHAR, @hr))
         EXEC dbo.sp_assert_equals 0, @hr, 50005, 'sp_configure show adv failed'
      END
-- 8
      SET @Stage = CONCAT(' 6: OpnTxtFile:', @file_path);
--      EXEC @hr = sp_OAMethod  @fso, 'OpenTextFile', @FileID OUT, @file_path, 2, 1
--      EXEC @hr = sp_OAMethod  @OLE, 'OpenTextFile', @FileID OUT, @file, 2--, 1
    --EXEC @hr = sp_OAMethod  @fso, 'CreateTextFile', @FileID OUT, @file_path, 1
      EXEC @hr = sp_OAMethod  @fso, 'OpenTextFile', @FileID OUT, @file_path, 1
      PRINT CONCAT(@Stage, CONVERT(VARCHAR, @hr))
      EXEC dbo.sp_assert_equals 0, @hr, 50006, 'sp_OAMethod  @OLE, OpenTextFile failed'

      SET @Stage = ' 7: OAMethod WriteLine'
      EXEC @hr = sp_OAMethod  @FileID, 'WriteLine', @success OUT, @text
      PRINT CONCAT(@Stage, CONVERT(VARCHAR, @hr))
      EXEC dbo.sp_assert_equals 0, @hr, 50007, 'sp_OAMethod  @FileID, WriteLine failed'

      SET @Stage = ' 8: OADestroy F'
      EXEC @hr = sp_OADestroy @FileID
      PRINT CONCAT(@Stage, CONVERT(VARCHAR, @hr))
      EXEC dbo.sp_assert_equals 0, @hr, 50008, 'sp_OADestroy @FileID failed'

      SET @Stage = ' 9: '
      EXEC @hr = sp_OADestroy @fso
      PRINT CONCAT(@Stage, CONVERT(VARCHAR, @hr))
      EXEC dbo.sp_assert_equals 0, @hr, 50009, 'sp_OADestroy @fso failed'

      -- Step 3: Disable Ole Automation Procedures
      SET @Stage = '10: '
      EXEC @hr = sp_configure 'show advanced options', 1;
      PRINT CONCAT(@Stage, CONVERT(VARCHAR, @hr))
      EXEC dbo.sp_assert_equals 0, @hr, 50010, 'sp_OADestroy OLE failed'

      RECONFIGURE;

      SET @Stage = '11'
      EXEC @hr = sp_configure 'Ole Automation Procedures', 0;
      PRINT CONCAT(@Stage, CONVERT(VARCHAR, @hr))
      EXEC dbo.sp_assert_equals 0, @hr, 50011, 'Ole Auto close failed'
      RECONFIGURE;
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn, '12: Caught exception writing to file:[', @file_path, '] @Stage: ',@Stage, ' ex: ',@ex_msg, @ex_msg=@ex_msg OUT;
      PRINT @ex_msg;
      THROW;
   END CATCH

   SET @Stage = '13 - Leaving ok'
   PRINT @Stage
END
*/

/*
EXEC sp_write_file2 'asdf', 'C:\temp\Fred2.txt'
*/
GO

