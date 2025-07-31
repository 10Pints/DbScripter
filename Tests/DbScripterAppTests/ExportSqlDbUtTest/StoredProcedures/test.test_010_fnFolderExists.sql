SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 17-JAN-2020
-- Description: Tests the fnFolderExists routine
-- =============================================
CREATE PROCEDURE [test].[test_010_fnFolderExists]
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(60)   = N'fnFolderExists'
      ,@fn_num       NVARCHAR(3)    = N'010'
      ,@act          SQL_VARIANT
   EXEC ut.test.sp_tst_mn_st @fn
   BEGIN TRY
      WHILE 1 = 1
      BEGIN
         EXEC test.hlpr_010_fnFolderExists
       @test_num     = '001'
      ,@folder       = 'Non existent'
      ,@exp          = 0
      ,@exp_ex_num   = NULL
      ,@exp_ex_msg   = NULL
      ,@exp_ex_st    = NULL
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
EXEC tSQLt.Run 'test.test_010_fnFolderExists'
*/
GO

