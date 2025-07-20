SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE PROCEDURE [tSQLt].[AssertEquals]
    @exp          SQL_VARIANT
   ,@act          SQL_VARIANT
   ,@unit_tst     VARCHAR(30)  = NULL
   ,@msg1         VARCHAR(MAX) = NULL
   ,@msg2         VARCHAR(MAX) = NULL
   ,@msg3         VARCHAR(MAX) = NULL
   ,@msg4         VARCHAR(MAX) = NULL
   ,@msg5         VARCHAR(MAX) = NULL
   ,@msg6         VARCHAR(MAX) = NULL
   ,@msg7         VARCHAR(MAX) = NULL
   ,@detailed_tst BIT           = 0   -- detailed comparison
   ,@cs_sens_cmp  BIT           = 0
AS
BEGIN
   DECLARE
    @fn        VARCHAR(35) = N'tSQLt.AssertEquals'
   ,@nl        VARCHAR(2)= CHAR(13) + CHAR(10)
   ,@test_msg  VARCHAR(500)
   ,@error_msg VARCHAR(MAX)
   ,@exp_str   VARCHAR(MAX)
   ,@act_str   VARCHAR(MAX)
   ,@line      VARCHAR(180)  =REPLICATE(N'*', 180)
   ,@Msg       VARCHAR(MAX)
   ,@subtest   VARCHAR(200)
   ,@testFn    VARCHAR(100)
   ,@testNum   VARCHAR(100)
   ,@testTd    VARCHAR(100)
   ;

   SET @testNum = test.fnGetCrntTstNum()
   SET @subtest = test.fnGetCrntTstNum2() -- The 3 digit numeric part of the subtest name
   SET @testTd  = CONCAT(@testNum,'.', @subtest,'.',@unit_tst);
   SET @exp_str = ISNULL(CONVERT( VARCHAR(MAX), @exp), 'NULL');
   SET @act_str = ISNULL(CONVERT( VARCHAR(MAX), @act), 'NULL');
   IF @subtest IS NULL SET @subtest = '<UNSPECIFIED>'

   SET @test_msg = 
   CONCAT
   (
       @testTd
      ,iif(@msg1 IS NULL, '', CONCAT(' ',@msg1))
      ,iif(@msg2 IS NULL, '', CONCAT(' ',@msg2))
      ,iif(@msg3 IS NULL, '', CONCAT(' ',@msg3))
      ,iif(@msg4 IS NULL, '', CONCAT(' ',@msg4))
      ,iif(@msg5 IS NULL, '', CONCAT(' ',@msg5))
      ,iif(@msg6 IS NULL, '', CONCAT(' ',@msg6))
      ,iif(@msg7 IS NULL, '', CONCAT(' ',@msg7))
   );

   IF @act IS NULL AND @exp IS NULL
   BEGIN
       -----------------------------------------------------
       -- Assertion: NULL NULL pass
       -----------------------------------------------------
      EXEC sp_log 1, @fn, '010: ',@test_msg, ' NULL NULL cmp passed'
      RETURN 0;
   END

   IF @cs_sens_cmp = 1
   BEGIN
      IF 1 = dbo.fnCaseSensistiveCompare(@exp_str, @act_str)
      BEGIN
         EXEC sp_log 1, @fn, '020: case sensistive compare ',@test_msg, ' passed'
      RETURN 0;
      END
      -- ASSERTION case sensistive compare failed
       EXEC sp_log 3, @fn, '030: case sensistive compare failed'
   END
   ELSE
   IF ((@exp = @act))
   BEGIN
       -----------------------------------------------------
       -- Assertion: if here then passed
       -----------------------------------------------------
      EXEC sp_log 1, @fn, '040: ',@test_msg, ' passed'
      RETURN 0;
   END

   -----------------------------------------------------
   -- Assertion: if here then failed
   -----------------------------------------------------

   EXEC sp_log 3, @fn, '050: ',@test_msg, ' failed'
   SET @testFn  = test.fnGetCrntTstFn();
   SET @testNum = test.fnGetCrntTstNum();

   IF @detailed_tst = 1
   BEGIN
      EXEC sp_log 1, @fn, '060: detailed string comparison'
      IF @exp_str <> @act_str EXEC sp_log 4, @fn,'040: string comparison mismatch';

      DECLARE
          @lenExp    INT = dbo.fnLen(@exp_str)
         ,@lenAct    INT = dbo.fnLen(@act_str)
         ,@bin_mtch  INT = dbo.fnCaseSensistiveCompare(@exp_str, @act_str)

      EXEC sp_log 1, @fn,
      '050: @lenExp   : ', @lenExp, @NL,
      '060: @lenAct   : ', @lenAct, @NL,
      '070: binary Cmp: ', @bin_mtch, ' (1 = match)', @NL
      ;

      EXEC sp_log 1, @fn,'070: calling sp_fnCompareStrings: a:@exp_str:[', @exp_str, '], b:@act_str:[',@act_str,']';
      EXEC sp_fnCompareStrings @exp_str, @act_str;
      EXEC sp_log 1, @fn,'080: ret frm sp_fnCompareStrings';
   END -- detailed test

/*   SELECT @Msg = CONCAT
   (
      'failed, Exp/Act '
      ,@NL,'<', @exp_str,'>'
      ,@NL,'<', @act_str,'>'
      ,@NL
   );
*/
   SET @error_msg = 
      CONCAT
      (
          @msg1
         ,iif(@msg1 IS NULL,'',' ')
         ,@msg2
         ,iif(dbo.fnLen(@exp_str) < 4000,
             CONCAT(@NL, 'exp: <', @exp_str,'>,', @NL,'act: <', @act_str,'>')
            ,CONCAT(@NL, 'exp: <', SUBSTRING(@exp_str, 1, 4000),'>,', @NL,'act: <', SUBSTRING(@act_str, 1 , 4000),'>'))
         --, ' '
      );

   PRINT CONCAT( @NL, @line, @NL);
   EXEC sp_log 4, @fn,'900: ', @testTd, ' failed ', @error_msg
   PRINT CONCAT( @line, @NL);
   EXEC tSQLt.Fail @error_msg;--, @Msg;
END;

GO
