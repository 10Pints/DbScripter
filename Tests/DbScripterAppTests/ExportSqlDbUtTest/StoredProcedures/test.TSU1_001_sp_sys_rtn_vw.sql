SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================
-- Author:      Terry Watts
-- Create date: 01-JUN-2020`  
-- Description: 1 off Setup routine for t001_sp_sys_rtns_vw tests
-- ======================================================================
CREATE PROCEDURE [test].[TSU1_001_sp_sys_rtn_vw]
       @test_fn   NVARCHAR(30)    -- test function name [IN]
      ,@log       BIT         = 0 --                    [IN]
AS
BEGIN
   EXEC UT.test.sp_tst_mn_st
       @test_fn   = @test_fn         -- the test   function name
      ,@log       = @log
   EXEC sp_set_session_context N'TSU1 001'         , 0;
      -- Create a tmp test output table
      IF [dbo].[fnTableExists](N'dbo.temp_sys_rtn_vw') = 0
         CREATE TABLE temp_sys_rtn_vw
         (
             [id]             INT IDENTITY(1,1)
            ,[db]             NVARCHAR(40)
            ,[schema]         NVARCHAR(20)
            ,[name]           NVARCHAR(70)
            ,[ty_code]        NVARCHAR(20)
            ,[type_id]        INT
            ,[ty_nm]          NVARCHAR(120)
            ,created          DATE
            ,modified         DATE
         );
END
/*
EXEC test.[test 001 sp_sys_rtn_vw]
EXEC tSQLt.Run 'test.test 001 sp_sys_rtn_vw'
EXEC tSQLt.RunAll
*/
GO

