SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================================
-- Author:      Terry Watts
-- Create date: 03-MAY-2024
-- Description: 
-- Creates the helper decl bloc for the act params output by teh teted rtn like:
--   ,@act_row_cnt     INT
--   ,@act_file_path   VARCHAR(4000)            -- comma separated
--   ,@act_range       VARCHAR(4000)            -- comma separated
--
-- Preconditions: Test.RtnDetails and Test.ParamDetails pop'd
--
-- Postconditions: return table with the CoreParams
--
-- Called by: test.fnCrtHlprCodeDecl
-- ==================================================================================
CREATE FUNCTION [test].[fnCrtHlprCodeDeclActParams]()
RETURNS @t TABLE
(
    id    INT IDENTITY(1,1)
   ,line  VARCHAR(500)
)
AS
BEGIN
   DECLARE
       @tab1           NCHAR(3) = '   '
      ,@tab2           NCHAR(6) = '      '
      ,@rtn_ty_code    VARCHAR(2)
      ,@sc_fn_ret_ty   VARCHAR(20)
      ,@ad_stp         BIT
      ,@max_prm_len    INT
      ;
    SELECT
       @rtn_ty_code  = rtn_ty_code
      ,@ad_stp       = ad_stp
      ,@sc_fn_ret_ty = sc_fn_ret_ty
      ,@max_prm_len  = max_prm_len + 5
   FROM test.RtnDetails;
   IF @ad_stp = 1
      INSERT INTO @t (line) VALUES
      (CONCAT(@tab1, '-- fnCrtHlprCodeDeclActParams'))
      ;
   -- IF a Procedure declare any act out params and set to exp params initially
   INSERT INTO @t (line)
   SELECT
       CONCAT
         (
             @tab1, ',@act_', dbo.fnPadRight(param_nm, @max_prm_len), ' ', dbo.fnPadRight(UPPER(type_nm), 15)
             -- 241219: only assign the expected value if it is an out param, else assing NULL
          --  ,iif( , CONCAT(' = @exp_', param_nm), '')
         )
   FROM test.ParamDetails
   WHERE tst_ty='EXP' AND is_output = 0;
   ;
   -- 241217: this duplicates @act_row_cnt ?? removed - need to test against FN, TF
   -- Add the output cols as act
   IF @rtn_ty_code = 'P'
   BEGIN
      INSERT INTO @t (line)
      SELECT
          CONCAT(@tab1, ',@act_', dbo.fnPadRight(param_nm, @max_prm_len), ' ', dbo.fnPadRight(UPPER(type_nm), 15), ' = @exp_', param_nm)
      FROM test.ParamDetails
      WHERE is_output = 1
      ;
   END
   IF @rtn_ty_code = 'FN'
   BEGIN
      INSERT INTO @t (line)
      SELECT
          CONCAT(@tab1, ',@act_', dbo.fnPadRight(param_nm, @max_prm_len), ' ', dbo.fnPadRight(UPPER(type_nm), 15), ' = @exp_', param_nm)
      FROM test.ParamDetails
      WHERE is_output = 1
      ;
   END
   RETURN;
END
/*
SELECT * FROM test.fnCrtHlprCodeDeclActParams();
SELECT * FROM test.ParamDetails;
EXEC tSQLt.RunAll;
*/
GO

