SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry watts
-- Create date: 04-FEB-2021
-- Description: Accessor
-- Tests: test_049_SetGetCrntTstValue
-- =============================================
CREATE PROCEDURE [test].[sp_tst_set_crnt_tst_1_off_setup_fn] @val VARCHAR(80)
AS
BEGIN
   DECLARE
      @fn   VARCHAR(35) = 'sp_tst_set_crnt_1_off_setup_fn'
     ,@key  NVARCHAR(40)= test.fnGetCrntTst1OffSetupFnKey()
     ;
   EXEC sp_log 0, @fn, 'starting, @val:[',@val,']';
   EXEC sp_set_session_context @key, @val;
END
/*
EXEC tSQLt.Run 'test.test_049_SetGetCrntTstValue'
EXEC tSQLt.RunAll
*/
GO

