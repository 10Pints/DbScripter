SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================================================
-- Author:      Terry Watts
-- Create date: 18-Apr-2024
-- Description: creates the detailed test bloc dependant on the rtn type
--
-- Preconditions: Test.RtnDetails and Test.ParamDetails pop'd
--
-- Postconditions:
-- Returns: lines of detailed test
--
-- Method:
-- delegate to a specific rtn based on rtn type
--
-- Keys: CRT-HC-SP-TST-BLOC
-- ==============================================================================================
CREATE FUNCTION [test].[fnCrtHlprCodeTestBloc](@rtn_ty_code NVARCHAR(2), @ad_stp BIT)
RETURNS @t TABLE 
(
    id    INT IDENTITY(1,1)
   ,line  NVARCHAR(500)
)
AS
BEGIN
   DECLARE
    @tab                NVARCHAR(3) = '   '
   ,@tst_proc_hlpr_nm   NVARCHAR(60)
   ,@detld_rtn_ty_code  NVARCHAR(2)
   ,@qrn                NVARCHAR(100)
   ,@sc_fn_ret_ty       NVARCHAR(50)
      IF @ad_stp = 1
         INSERT INTO @t (line) VALUES
         (CONCAT(@tab,@tab,'-- Tests:', IIF(@ad_stp = 1 ,'-- fnCrtHlprCodeTestBloc', '')))
   IF @rtn_ty_code = 'SP'
      INSERT INTO @t (line)
      SELECT line FROM test.fnCrtHlprCodeTestBlocSp(@ad_stp);
   IF @rtn_ty_code IN ('F', 'FN')
      INSERT INTO @t (line)
      SELECT line FROM test.fnCrtHlprCodeTestBlocFn(@ad_stp);
   IF @rtn_ty_code = 'TF'
      INSERT INTO @t (line)
      SELECT line FROM test.fnCrtHlprCodeTestBlocTF(@ad_stp);
   RETURN;
END
/*
EXEC tSQLt.Run 'test.test_086_sp_crt_tst_hlpr_script';
SELECT * FROM test.fnCrtHlprCodeTestBloc('SP', 1)
SELECT * FROM test.fnCrtHlprCodeTestBloc('F', 1)
SELECT * FROM test.fnCrtHlprCodeTestBloc('TF', 1)
SELECT * FROM test.RtnDetails;
*/
GO

