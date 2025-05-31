SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================================================
-- Author:      Terry Watts
-- Create date: 19-NOV-2024
-- Description: function to compare 2 strings
-- Returns TABLE with 3 rows,[A as chars, B as chars, A as ascii codes, B as ASCII codes]
-- Stops at first mismatch
--
-- Tests: test_037_fnCompareStrings
-- ======================================================================================
ALTER   FUNCTION [dbo].[fnCompareStrings]( @a VARCHAR(MAX), @b VARCHAR(MAX))
RETURNS @t TABLE
(
    A             VARCHAR(MAX) -- STRING characters             for A
   ,B             VARCHAR(MAX) -- STRING characters             for B
   ,SA            VARCHAR(MAX) -- STRING characters             for A
   ,SB            VARCHAR(MAX) -- STRING characters             for B
   ,CA            VARCHAR(MAX) -- SEQ ASCII codes formattd 00N  for A
   ,CB            VARCHAR(MAX) -- SEQ ASCII codes formattd 00N  for B
   ,msg           VARCHAR(MAX) -- match results
   ,[match]       BIT
   ,status_msg    VARCHAR(120)
   ,code          INT
   ,ndx           INT
   ,[log]         VARCHAR(MAX)
)
AS
BEGIN
   DECLARE
       @fn           VARCHAR(35) = N'sp_fnCompareStrings'
      ,@charA        CHAR
      ,@charB        CHAR
      ,@asciA        CHAR(3)
      ,@asciB        CHAR(3)
      ,@CA           VARCHAR(MAX) -- Ascii codes in hex/spx
      ,@CB           VARCHAR(MAX) -- Ascii codes in hex/spc
      ,@SA           VARCHAR(MAX) -- Characters matching Ascii codes/spx
      ,@SB           VARCHAR(MAX) -- Characters matching Ascii codes/spx
      ,@first_time   BIT = 1
      ,@i            INT
      ,@lenMax       INT
      ,@lenA         INT
      ,@lenB         INT
      ,@match        BIT = 1
      ,@msg          VARCHAR(MAX)
      ,@nl           VARCHAR(2) = CHAR(13) + CHAR(10)
      ,@status_msg   VARCHAR(50)
      ,@code         INT
      ,@log          VARCHAR(MAX)
      ,@params       VARCHAR(MAX)
   ;

   WHILE(1=1)
   BEGIN
      SET @params = CONCAT
      (
'a:[', iif(@a IS NULL, '<NULL>', iif( LEN(@a)=0,'<empty string>',@a)), ']', @nl,
'b:[', iif(@a IS NULL, '<NULL>', iif( LEN(@b)=0,'<empty string>',@b)), ']', @nl
      );

      IF (@a IS NULL OR @b IS NULL) -- But not both
      BEGIN
         -----------------------------------------------------------------
         -- ASSERTION: @a IS NULL OR @b IS NULL may be both
         -----------------------------------------------------------------

         IF(@a IS NULL AND @b IS NULL)
         BEGIN
            SELECT
                @msg   = 'both a or b are NULL'
               ,@match = 1
               ,@status_msg= 'OK'
               ,@code  = 1
            ;

            BREAK;
         END

      ------------------------------------------------------
      -- ASSERTION: one or other input is null but not both
      ------------------------------------------------------
         SELECT
             @msg       = 'one of a or b is NULL but not both '
            ,@match     = 0
            ,@status_msg= 'OK'
            ,@code      = 2 -- 'one of a or b is NULL but not both '

         BREAK;
      END

      -----------------------------------------------------------------
      -- ASSERTION: both are not null
      -----------------------------------------------------------------
      SET @lenA = dbo.fnLen(@a);
      SET @lenB = dbo.fnLen(@b);

      -- Check length of both strings <=1000 (need 4 chars per char compared
      SET @lenMax = dbo.fnMax(@lenA, @lenb);

      IF @lenA <> @lenb
      BEGIN
         SELECT
             @msg       = CONCAT('strings differ in length a: ', @lenA, ' b: ', @lenb)
            ,@match     = 0
            ,@status_msg= 'OK'
            ,@code      = 5 -- length mismatch
      END

      IF @lenA > 1000 OR @lenB > 2666
      BEGIN
         SELECT
             @msg       = 'a or b is too long to store the results of a detailed comparison, it has more than 2666 characters whih means the formatted output is more than MAX size of string'
            ,@match     = 0
            ,@status_msg= 'TOO LONG TO STORE DETAILED RESULTS'
            ,@code      = -1 -- one of a or b is too long to compare
      END

      -----------------------------------------------------------------
      -- ASSERTION: No previous check failed, strings are same length
      -----------------------------------------------------------------

      SET @i = 0;

      WHILE(@i<=@lenMax)
      BEGIN
         SET @charA = iif(@i<=@lenA, SUBSTRING(@a, @i,1), '_');
         SET @charB = iif(@i<=@lenB, SUBSTRING(@b, @i,1), '_');

         SET @asciA = iif(@i<=@lenA, FORMAT(ASCII(@charA), 'x2'), '  ')
         SET @asciB = iif(@i<=@lenB, FORMAT(ASCII(@charB), 'x2'), 'xx')

      -----------------------------------------------------------------
      -- Only do the HEX thing if have room to store result
      -----------------------------------------------------------------
         if(@i < 2667)
         BEGIN
            SET @CA = CONCAT(@CA, ' ', @asciA);
            SET @CB = CONCAT(@CB, ' ', @asciB);

            
            SET @SA = CONCAT(@SA,
            CASE
               WHEN @charA = CHAR(09) THEN '\t'
               WHEN @charA = CHAR(13) THEN '\r'
               WHEN @charA = CHAR(10) THEN '\n'
               ELSE @charA
            END
            )
            ;

            SET @SB = CONCAT(@SB,
            CASE
               WHEN @charB = CHAR(09) THEN '\t'
               WHEN @charB = CHAR(13) THEN '\r'
               WHEN @charB = CHAR(10) THEN '\n'
               ELSE @charB
            END
            );
         END

         SET @i = @i + 1;

         IF @asciA <> @asciB
         BEGIN
            SELECT 
                @msg       = CONCAT('mismatch at pos: ', @i, ' @lenMax: ',@lenMax,' char: [',@charA,']/[',@charB,'], ASCII: [',@asciA,']/[',@asciB,']')
               ,@code      = 4
               ,@status_msg= 'OK'
               ,@code      = 5 -- length mismatch

            IF @first_time = 1
            BEGIN
               SET @first_time = 0;
               SET @match      = 0;
            END
         END
      END

      -----------------------------------------------------------------
      -- ASSERTION: if here match already set
      -----------------------------------------------------------------
      SELECT
          @msg       = 'strings match'
         ,@status_msg= 'OK'
         ,@code      = 0 -- match

      BREAK;
   END -- while 1=1 main do loop

   -----------------------------------------------------------------
   -- ASSERTION: @a, @b, @CA, @CB, @msg ARE SET
   -----------------------------------------------------------------
   INSERT INTO @t( A,  B,  SA,  SB,  CA,  CB,  msg, [match], status_msg,  code, ndx)
   VALUES        (@a, @b, @SA, @SB, @CA, @CB, @msg, @match, @status_msg, @code, @i );
   RETURN;
END
/*
SELECT * FROM dbo.fnCompareStrings('abc','abcd')
EXEC tSQLt.Run 'test.test_037_sp_fnCompareStrings';
EXEC tSQLt.Run 'test.test_018_fnCrtUpdateSql';
*/


GO
