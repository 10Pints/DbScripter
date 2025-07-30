SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================================
-- Author:      Terry Watts
-- Create date: 03-MAY-2024
-- Description: 
-- Creates the helper decl bloc for the  core params as follows:
-- DECLARE
--     @fn          NVARCHAR(35) = N'hlpr_093_sp_class_creator'
--    ,@act_row_cnt INT
--    ,@act_ex_num  INT
--    ,@act_ex_msg  NVARCHAR(500)
--    ,@error_msg   NVARCHAR(1000)
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
   ,line  NVARCHAR(500)
)
AS
BEGIN
   DECLARE
     @tab1              NCHAR(3) = '   '
    ,@tab2              NCHAR(6) = '      '
    ,@ad_stp            BIT
    ,@max_prm_len       INT
    ,@tst_proc_hlpr_nm  NVARCHAR(60)
    SELECT
       @tst_proc_hlpr_nm = hlpr_rtn_nm
      ,@ad_stp           = ad_stp
      ,@max_prm_len      = max_prm_len +4
    FROM test.RtnDetails
   IF @ad_stp = 1
      INSERT INTO @t (line) VALUES
      (CONCAT(@tab1, '-- fnCrtHlprCodeDeclCoreParams'))
   INSERT INTO @t (line) VALUES
       (CONCAT(@tab1, 'DECLARE'))
      ,(CONCAT(@tab2, dbo.fnPadRight(' @fn'        , @max_prm_len), 'NVARCHAR(35)', ' = N''',@tst_proc_hlpr_nm, ''''))
      ,(CONCAT(@tab2, dbo.fnPadRight(',@error_msg' , @max_prm_len), 'NVARCHAR(1000)'))
   RETURN;
END
/*
SELECT * FROM test.fnCrtHlprCodeDeclCoreParams();
EXEC test.sp_get_rtn_details 'dbo].AsInt', @display_tables = 1;
SELECT * FROM test.RtnDetails;
*/
GO

