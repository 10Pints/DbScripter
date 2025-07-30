SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [tSQLt].[AssertIsSubString]
    @a    NVARCHAR(4000)
   ,@b    NVARCHAR(4000)
   ,@msg1 NVARCHAR(2000) = NULL
   ,@msg2 NVARCHAR(2000) = NULL
   ,@msg3 NVARCHAR(2000) = NULL
   ,@msg4 NVARCHAR(2000) = NULL
AS
BEGIN
   DECLARE
    @fn        NVARCHAR(35)  = N'AssertIsSubString'
   ,@error_msg NVARCHAR(MAX)
   ,@Msg       NVARCHAR(MAX)
   ,@nl        NCHAR(2)      = NCHAR(13)+CHAR(10)
   ,@subtest   NVARCHAR(200) = test.fnGetCrntSubTst()
   PRINT N'AssertIsSubString starting';
   PRINT CONCAT(@fn, ' loglevel: ', dbo.fnGetLogLevel());
   EXEC sp_log 1, @fn, '000: starting', @nl
, '@a:[', @a, ']', @nl
, '@b:[', @b, ']';
   IF ((@a = @b) OR (@a IS NULL AND @b IS NULL) OR (CHARINDEX(@a, @b) > 0))
   BEGIN
      EXEC sp_log 1, @fn, '010: OK passed'
      RETURN 0;
   END
    -----------------------------------------------------
    -- Assertion: ERROR: a is not a substring of b
    -----------------------------------------------------
   DECLARE
    @line      NVARCHAR(100) =REPLICATE(N'*', 100)
   ,@testFn    NVARCHAR(100)
   ,@testNum   NVARCHAR(100)
   SET @testFn  = test.fnGetCrntTstFn();
   SET @testNum = test.fnGetCrntTstNum();
   SELECT @Msg = CONCAT
    (
       'Failed, Exp/Act '
       ,@NL,'<', @a,'>'
       ,@NL,'<', @b,'>'
       ,@NL
    );
   SET @msg = 
      CONCAT
      (
        test.fnGetCrntTstFn(), '.', test.fnGetCrntSubTst()
       , @msg1
       ,iif(@msg1 IS NULL, '', CONCAT(' ', @msg2))
       ,iif(@msg2 IS NULL, '', CONCAT(' ', @msg3))
       ,iif(@msg3 IS NULL, '', CONCAT(' ', @msg4))
       );
   SELECT @Msg = CONCAT
                 (
                   @nl, '@a:<', ISNULL(@a, 'NULL'), '>'
                  ,@nl, ' is not in'
                  ,@nl, '@b:<', ISNULL(@b, 'NULL'), '>'
                  ,@nl
                 );
--*********************************************************************************************
   PRINT CONCAT( @NL, @line);
   EXEC sp_log 4, @fn,'**** ', @testFn, '.', @testNum, '.', @subtest, '. failed ****', @Msg;
   PRINT CONCAT( @line, @NL);
--*********************************************************************************************
    EXEC tSQLt.Fail '**** ', @testFn, '.', @testNum, '.', @subtest, '. failed ****', @Msg;
END;
GO

