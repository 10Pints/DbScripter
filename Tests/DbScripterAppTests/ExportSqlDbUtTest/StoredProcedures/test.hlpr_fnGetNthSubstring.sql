SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [test].[hlpr_fnGetNthSubstring]
    @inp       NVARCHAR(3000)
   ,@sep       NVARCHAR(10)
   ,@n         INT
   ,@exp       NVARCHAR(3000)
   ,@subtest   NVARCHAR(50) = '1'
AS
BEGIN
   DECLARE
       @act    NVARCHAR(3000)
      ,@fn     NVARCHAR(30)   = N'HLPR_FNGETNTHSUBSTRING'
   EXEC sp_log @fn, '1.',@subtest,': starting @inp:',@inp,' @sep:', @sep,' @n: ',@n, ' @exp:', @exp, ''
   SET @act = ut.dbo.fnGetNthSubstring(@inp, @sep, @n);
   PRINT CONCAT('INP:', @inp, ' exp:', @exp,' act:', @act, '');
   EXEC tSQLt.AssertEquals @exp, @act
   EXEC sp_log @fn, '1.',@subtest,' PASSED'
END
GO

