SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [test].[hlpr_033_fnPadRight] 
    @test_num  NVARCHAR(20)
   ,@inp       NVARCHAR(1000)
   ,@pad_num   INT
   ,@exp_len   INT
AS
BEGIN
   DECLARE 
       @fn           NVARCHAR(35) = 'hlpr_026_fnChkEquals'
      ,@act     NVARCHAR(1000)
      ,@act_len INT 
   SET @act = dbo.fnPadRight(@inp, 25);
   SET @act_len = dbo.fnLen(@act);
   PRINT CONCAT('@test_num: ',@test_num, ' @exp len: ', @exp_len, ' act len:', @act_len);
   PRINT CONCAT('inp:',@inp, '')
   PRINT CONCAT('act:',@act, '')
   EXEC tSQLt.assertEquals @act_len, @exp_len;
END
/*
EXEC tSQLt.RunAll
EXEC tSQLt.Run 'test.test_033_fnPadRight'
*/
GO

