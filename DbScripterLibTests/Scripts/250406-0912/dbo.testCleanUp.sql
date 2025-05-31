SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===============================================================================
-- Author:      Terry Watts
-- Create date: 29-APR-2024
-- Description: used this to cleanup after a test when the test is annotated with
-- --[@tSQLt:NoTransaction]('test.testCleanUp')
--
-- POSTCONDITIONS: RETURNS
-- POST 01: 
-- ===============================================================================
ALTER   PROCEDURE [dbo].[testCleanUp]
AS
BEGIN
   DECLARE 
    @fn        VARCHAR(35)   = 'sp_crt_tst_rtns'
   PRINT'dbo.testCleanUp: 000: Performing No transaction cleanup    nothing to do'
  --Undo anything that happened in the test
  --RAISERROR('TODO',16,10);
--  EXEC sp_log 2, @fn, '999: done'
END


GO
