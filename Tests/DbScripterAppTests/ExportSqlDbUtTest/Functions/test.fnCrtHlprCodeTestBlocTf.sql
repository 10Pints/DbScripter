SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================================================
-- Author:      Terry Watts
-- Create date: 16-Apr-2024
-- Description: creates the test bloc for a table function
--
-- Preconditions: Test.ParamDetails pop'd
--
-- Postconditions:
--
-- Algoritm
-- Iterate the params and create lines like
-- if @exp_x IS NOT NULL EXEC tSQLt.AssertEquals @exp_x, @act_y, 'x';
--
-- Keys: CRT-HC-TST-BLOC-TF
-- ==============================================================================================
CREATE FUNCTION [test].[fnCrtHlprCodeTestBlocTf]
(
   @ad_stp BIT
)
RETURNS @t TABLE 
(
    id    INT
   ,line  NVARCHAR(500)
)
AS
BEGIN
   DECLARE
    @tab                NVARCHAR(3) = '   '
   IF @ad_stp = 1
   INSERT INTO @t (line) VALUES
   (CONCAT(@tab,@tab, IIF(@ad_stp = 1 ,'-- fnCrtHlprCodeTestBlocTf', '')));
   -- Iterate the exp params
   INSERT INTO @t (line)
   SELECT test.fnCrtHlprCodeTestExpParam(param_nm)
   FROM test.ParamDetails
   WHERE tst_ty = 'EXP';
   RETURN;
END
/*
EXEC test.sp_get_rtn_details 'dbo.fnGetRtnDef';
SELECT * FROM test.fnCrtHlprCodeTestBlocTf(1)
EXEC tSQLt.Run 'test.test_086_sp_crt_tst_hlpr_script';
EXEC tSQLt.RunAll;
*/
GO

