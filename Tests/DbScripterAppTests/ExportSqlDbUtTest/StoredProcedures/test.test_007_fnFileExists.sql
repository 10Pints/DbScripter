SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 17-JAN-2020
-- Description: Tests the fnFileExists routine
-- =============================================
CREATE PROCEDURE [test].[test_007_fnFileExists]
AS
BEGIN
   DECLARE
       @test_fn      NVARCHAR(60)   = N'test 007 fnFileExists'
      ,@NL           NVARCHAR(2)    =  NCHAR(13)+NCHAR(10)
      ,@act          SQL_VARIANT
   SET NOCOUNT ON
   EXEC UT.test.sp_tst_mn_st @test_fn;
   WHILE 1 = 1
   BEGIN
   -- Call the helper routine
      EXEC test.hlpr_007_fnFileExists
          @test_num   = '001'
         ,@inp_file   = NULL
         ,@exp        = 0
      ;
      EXEC test.hlpr_007_fnFileExists
          @test_num   = '002'
         ,@inp_file   = ''
         ,@exp        = 0
      ;
      EXEC test.hlpr_007_fnFileExists
          @test_num   = '003: read only hidden exe'
         ,@inp_file   = 'D:\Dev\Ut\Tests\test_007_fnFileExists\7za.exe'
         ,@exp        = 1
      ;
      EXEC test.hlpr_007_fnFileExists
          @test_num   = '004: read only json file'
         ,@inp_file   = 'D:\Dev\Ut\Tests\test_007_fnFileExists\appsettings.json'
         ,@exp        = 1
      ;
      EXEC test.hlpr_007_fnFileExists
          @test_num   = '005: normal dat file'
         ,@inp_file   = 'D:\Dev\Ut\Tests\test_007_fnFileExists\excludes.dat'
         ,@exp        = 1
      ;
      BREAK;  -- Do once loop
   END -- WHILE 1 = 1
   EXEC ut.test.sp_tst_mn_cls;
END
/*
EXEC tSQLt.Run 'test.test_007_fnFileExists';
EXEC tSQLt.RunAll;
*/
GO

