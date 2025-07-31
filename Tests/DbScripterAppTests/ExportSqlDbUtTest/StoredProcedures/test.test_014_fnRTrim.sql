SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 08-JAN-2020
-- Description: Tests the helper procedure  sp_export_to_excel_validate
-- used by sp_export_to_excel helper sp_export_to_excel_validate
-- =============================================
CREATE PROCEDURE [test].[test_014_fnRTrim]
AS
BEGIN
   DECLARE
       @tested_fn NVARCHAR(80)   = N'test 014 fnRTrim'
      ,@char13    NVARCHAR(1)    = NCHAR(13)
      ,@str       NVARCHAR(50)   = '  Some text  '
      ,@inp       NVARCHAR(50)
      ,@exp       NVARCHAR(50)
      ,@ret       NVARCHAR(50)
   EXEC ut.test.sp_tst_mn_st @tested_fn
   BEGIN TRY
      WHILE 1 = 1
      BEGIN
         --                    T#     inp      exp       msg
         EXEC test.hlpr_014_fnRTrim '001', NULL,    NULL
         EXEC test.hlpr_014_fnRTrim '002', '',      ''
         EXEC test.hlpr_014_fnRTrim '003', @char13, ''
         SET @inp = CONCAT(@str, NChar(160));
         SET @exp  = '  Some text';
         EXEC test.hlpr_014_fnRTrim '004', @inp, '  Some text'
         BREAK;  -- Do once loop
      END -- WHILE 1 = 1
      EXEC ut.test.sp_tst_mn_cls;
   END TRY
   BEGIN CATCH
      EXEC ut.test.sp_tst_mn_hndl_ex;
   END CATCH
END
/*
EXEC tSQLt.RunAll
EXEC tSQLt.Run 'test.test_014_fnRTrim'
*/
GO

