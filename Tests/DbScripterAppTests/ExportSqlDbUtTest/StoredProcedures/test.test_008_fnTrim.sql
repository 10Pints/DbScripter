SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 27-DEC-2019
-- Description: Tests the helper procedure  sp_export_to_excel_validate
-- used by sp_export_to_excel helper sp_export_to_excel_validate
-- DROP PROCEDURE [test].[test 026 fnCheckTableExists]
-- =============================================
CREATE PROCEDURE [test].[test_008_fnTrim]
AS
BEGIN
   DECLARE
       @fn_num    NVARCHAR(3)    = N'008'
      ,@fn        NVARCHAR(4)
      ,@char13    NVARCHAR(1)    = NCHAR(13)
      ,@str       NVARCHAR(50)   = '  Some text  '
      ,@inp       NVARCHAR(50)
      ,@exp       NVARCHAR(50)
      ,@ret       NVARCHAR(50)
   SET NOCOUNT ON
   EXEC ut.test.sp_tst_mn_st N'test 008 fnTrRim'
   BEGIN TRY
      WHILE 1 = 1
      BEGIN
         --                    T#     inp      exp       msg
         EXEC test.hlpr_008_fnTrim '005',' ', ''    , 'single space (len(spc) test '
            ,@exp_ex_num = null
            ,@exp_ex_msg = null
            ,@exp_ex_st  = null
         EXEC test.hlpr_008_fnTrim '001', NULL,    NULL  , 'null test '
            ,@exp_ex_num = null
            ,@exp_ex_msg = null
            ,@exp_ex_st  = null
         EXEC test.hlpr_008_fnTrim '002', '',      ''    , 'empty test '
            ,@exp_ex_num = null
            ,@exp_ex_msg = null
            ,@exp_ex_st  = null
         EXEC test.hlpr_008_fnTrim '003', @char13, ''    , 'char(13) test '
            ,@exp_ex_num = null
            ,@exp_ex_msg = null
            ,@exp_ex_st  = null
         SET @inp = CONCAT(@str, NChar(160));
         EXEC test.hlpr_008_fnTrim '004', @inp,'Some text', 'Some text test '
            ,@exp_ex_num = null
            ,@exp_ex_msg = null
            ,@exp_ex_st  = null
         BREAK;  -- Do once loop
      END -- WHILE 1 = 1
      EXEC ut.test.sp_tst_mn_cls;
   END TRY
   BEGIN CATCH
      EXEC ut.test.sp_tst_mn_hndl_ex;
   END CATCH
END
/*
EXEC tSQLt.Run 'test.test_008_fnTrim'
EXEC tSQLt.RunAll
*/
GO

