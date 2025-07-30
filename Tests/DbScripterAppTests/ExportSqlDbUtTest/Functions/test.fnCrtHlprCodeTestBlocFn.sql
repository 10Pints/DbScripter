SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================================================
-- Author:      Terry Watts
-- Create date: 16-Apr-2024
-- Description: creates the test bloc for a scalar function
--
-- Preconditions: Test.ParamDetails pop'd
--
-- Postconditions:
-- Returns: @rtnDef
-- Post 01:
--
-- Keys: CRT-HC-TST-BLOC-SP
-- ==============================================================================================
CREATE FUNCTION [test].[fnCrtHlprCodeTestBlocFn]
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
   INSERT INTO @t (line) VALUES
    (CONCAT(@tab,@tab, IIF(@ad_stp = 1 ,'-- [fnCrtHlprCodeTestBlocFn]', '')))
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
SELECT * FROM test.fnCrtHlprCodeTestBlocFn(1)
EXEC tSQLt.RunAll;
*/
GO

