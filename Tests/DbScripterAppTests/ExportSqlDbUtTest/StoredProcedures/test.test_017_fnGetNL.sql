SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Create Procedure test 017 fnGetNL
-- =============================================
-- Author:      Terry Watts
-- Create date: 17-JAN-2020
-- Description: Tests the fnGetNL routine
-- =============================================
CREATE PROCEDURE [test].[test_017_fnGetNL]
AS
BEGIN
   DECLARE
       @test_fn      NVARCHAR(80)   = N'test 017 fnGetNL'
      ,@exp          NVARCHAR(2)    = NCHAR(13)+NCHAR(10)
      ,@act          NVARCHAR(20)   = NCHAR(13)+NCHAR(10)
   EXEC ut.test.sp_tst_mn_st @test_fn 
   BEGIN TRY
      WHILE 1 = 1
      BEGIN
      -- Populate the IN/OUT params
      -- Run test specific setup
      -- Call the tested routine
         SET @act = dbo.fnGetNL();
         -- Test the expected values if specified
         IF @exp IS NOT NULL EXEC [test].[sp_tst_gen_chk] N'01', @exp, @act, 'oops'
         EXEC ut.test.sp_tst_mn_cls;
         BREAK;
      END
   END TRY
   BEGIN CATCH
      EXEC ut.test.sp_tst_mn_hndl_ex;
   END CATCH
END
/*
EXEC [test].[test 017 fnGetNL]
EXEC tSQLt.Run 'test.test 017 fnGetNL'
EXEC tSQLt.RunAll
*/
GO

