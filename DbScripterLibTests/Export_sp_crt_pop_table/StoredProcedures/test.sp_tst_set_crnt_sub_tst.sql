SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =================================================================
-- Author:      Terry watts
-- Create date: 03-DEC-2024
-- Description: sets the current sub test id
-- Tests:       test_049_SetGetCrntTstValue
-- =================================================================
CREATE PROCEDURE [test].[sp_tst_set_crnt_sub_tst] @sub_tst VARCHAR(100)
AS
BEGIN
   DECLARE
      @fn   VARCHAR(35) = 'sp_tst_set_crnt_sub_tst'
     ,@key  VARCHAR(40) = test.fnGetCrntSubTstKey();
   ;

   EXEC sp_log 0, @fn, 'starting, @sub_tst:[',@sub_tst,']';
   EXEC sp_set_session_context @key, @sub_tst;
END
/*
EXEC tSQLt.Run 'test.test_049_SetGetCrntTstValue'
EXEC tSQLt.RunAll
*/


GO
