SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================================
-- Author:      Terry Watts
-- Create date: 03-MAY-2024
-- Description: 
-- Creates the helper decl bloc for the  core params as follows:
-- DECLARE
--     @fn          VARCHAR(35) = N'hlpr_093_sp_class_creator'
--    ,@act_row_cnt INT
--    ,@act_ex_num  INT
--    ,@act_ex_msg  VARCHAR(500)
--    ,@error_msg   VARCHAR(1000)
--
-- Preconditions: Test.RtnDetails and Test.ParamDetails pop'd
--
-- Postconditions: return table with the CoreParams
--
-- Called by: test.fnCrtHlprCodeDecl
-- ==================================================================================
CREATE FUNCTION [test].[fnCrtHlprCodeDeclCoreParams]()
RETURNS @t TABLE
(
    id    INT IDENTITY(1,1)
   ,line  VARCHAR(500)
)
AS
BEGIN
   DECLARE
    @tab1               NCHAR(3) = '   '
   ,@tab2               NCHAR(6) = '      '
   ,@rtn_ty_code        VARCHAR(2)
   ,@ad_stp             BIT
   ,@max_prm_len        INT
   ,@tst_proc_hlpr_nm   VARCHAR(60)
    SELECT
       @tst_proc_hlpr_nm= hlpr_rtn_nm
      ,@ad_stp          = ad_stp
      ,@rtn_ty_code     = rtn_ty_code
      ,@max_prm_len     = max_prm_len +10
    FROM test.RtnDetails
   IF @ad_stp = 1
      INSERT INTO @t (line) VALUES
      (CONCAT(@tab1, '-- fnCrtHlprCodeDeclCoreParams'))
   INSERT INTO @t (line) VALUES
       (CONCAT(@tab1, 'DECLARE'))
      ,(CONCAT(@tab1, dbo.fnPadRight(' @fn'        , @max_prm_len+2), 'VARCHAR(35)', '    = N''',@tst_proc_hlpr_nm, ''''))
      ,(CONCAT(@tab1, dbo.fnPadRight(',@error_msg' , @max_prm_len+2), 'VARCHAR(1000)'))
   --IF @rtn_ty_code = 'P'
   -- INSERT INTO @t (line) VALUES (CONCAT(@tab1, dbo.fnPadRight(',@act_RC', @max_prm_len+1), ' INT'))
   RETURN;
END
/*
SELECT * FROM test.fnCrtHlprCodeDeclCoreParams();
EXEC test.sp_get_rtn_details 'dbo].AsInt', @display_tables = 1;
SELECT * FROM test.RtnDetails;
*/
GO

