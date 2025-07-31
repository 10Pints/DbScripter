SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [test].[hlpr_061_spGetNthSubstring]
    @tst_num   NVARCHAR(50) = '1'
   ,@inp       NVARCHAR(3000)
   ,@sep       NVARCHAR(10)
   ,@n         INT
   ,@exp       NVARCHAR(3000)
AS
BEGIN
   DECLARE
       @act    NVARCHAR(3000)
      ,@fn     NVARCHAR(35)   = N'hlpr_061_spGetNthSubstring'
   EXEC test.sp_tst_hlpr_st @fn, @tst_num;
   EXEC sp_log 1, @fn, 'Test ',@tst_num,': starting @inp:[',@inp,'] @sep:[', @sep,'] @n: ',@n, ' @exp:[', @exp, ']'
   EXEC ut.dbo.sp_GetNthSubstring @inp, @sep, @n, @act OUT;
   PRINT CONCAT('INP:[', @inp, '] exp:[', @exp,'] act:[', @act, ']');
   EXEC tSQLt.AssertEquals @exp, @act
   EXEC test.sp_tst_hlpr_hndl_success;
END
/*
tSQLt.RunAll
tSQLt.Run 'test.test_061_spGetNthSubstring'
*/
GO

