SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================================================
-- Author:      Terry Watts
-- Create date: 16-Apr-2024
-- Description: creates the test bloc for a procedure
--
-- Preconditions: Test.ParamDetails pop'd
--
-- Postconditions:
-- Returns: @rtnDef
-- Post 01:
--
-- Keys: CRT-HC-TST-BLOC-SP
-- ==============================================================================================
CREATE FUNCTION [test].[fnCrtHlprCodeTestBlocSp]
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
   SELECT @ad_stp = ad_stp FROM test.RtnDetails;
   INSERT INTO @t (line) VALUES
    (CONCAT(@tab,@tab,IIF(@ad_stp = 1 ,'-- fnCrtHlprCodeTestBlocSp', '')))
   ;
   -- Iterate the exp params
   INSERT INTO @t (line)
   SELECT test.fnCrtHlprCodeTestExpParam(param_nm)
   FROM test.ParamDetails
   WHERE tst_ty = 'EXP';
   RETURN;
END
/*
EXEC tSQLt.Run 'test.test_086_sp_crt_tst_hlpr_script';
SELECT * FROM test.fnCrtHlprCodeTestBlocSp(1)
EXEC tSQLt.RunAll;
*/
GO

