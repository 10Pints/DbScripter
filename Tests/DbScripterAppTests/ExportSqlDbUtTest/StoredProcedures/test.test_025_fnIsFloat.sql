SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================
-- Author:      Terry Watts
-- Create date: 05-JAN-2021
-- Description: Tests the fnIsFloat routine
-- ===============================================
CREATE PROCEDURE [test].[test_025_fnIsFloat]
AS
BEGIN
   DECLARE
       @fn_num    NVARCHAR(3)    = N'025'
      ,@fn        NVARCHAR(4)
      ,@int       INT            = 1
      ,@f         FLOAT          = -1.023
      ,@r         REAL           = -11.023
      ,@n         NUMERIC        = 5.06
      ,@m         MONEY          = 21.56
   SET NOCOUNT ON
   EXEC ut.test.sp_tst_mn_st 'test 025 fnIsFloat'
   BEGIN TRY
      WHILE 1 = 1
      BEGIN
         EXEC test.hlpr_025_fnIsFloat @test_num = 1, @v = '1',  @exp = 0
         EXEC test.hlpr_025_fnIsFloat @test_num = 2, @v = @int, @exp = 0
         EXEC test.hlpr_025_fnIsFloat @test_num = 3, @v = @f,   @exp = 1
         EXEC test.hlpr_025_fnIsFloat @test_num = 4, @v = @r,   @exp = 1
         EXEC test.hlpr_025_fnIsFloat @test_num = 5, @v = @n,   @exp = 1
         EXEC test.hlpr_025_fnIsFloat @test_num = 6, @v = @m,   @exp = 0
         BREAK;  -- Do once loop
      END -- WHILE 1 = 1
      EXEC ut.test.sp_tst_mn_cls;
   END TRY
   BEGIN CATCH
      EXEC ut.test.sp_tst_mn_hndl_ex;
   END CATCH
END
/*
exec tSQLt.Run 'test.test_025_fnIsFloat';
*/
GO

