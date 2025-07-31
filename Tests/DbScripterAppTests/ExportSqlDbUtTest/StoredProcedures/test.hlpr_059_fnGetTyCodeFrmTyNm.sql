SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      21-Nov-2023
-- Description:      test helper rtn for the fnGetTyCodeFrmTyNm rtn being tested
-- Tested rtn desc:
--  returns the type name from the type code  
--e.g. sysobjects xtype code   
--
-- Tested rtn params: 
--    @ty_name  NVARCHAR(2),
--
-- returns NVARCHAR(30)
--========================================================================================
CREATE PROCEDURE [test].[hlpr_059_fnGetTyCodeFrmTyNm]
   @ty_name  NVARCHAR(30),
   @exp_res  NVARCHAR(2)   = NULL,
   @exp_ex   BIT           = 0,
   @subtest  NVARCHAR(100)
AS
BEGIN
   DECLARE
       @fn                NVARCHAR(35)   = N'hlpr_059_fnGetTyCodeFrmTyNm'
      ,@v                 NVARCHAR(30) -- bug type only not len
   EXEC sp_log 2, @fn, '01: starting, 
@subtest:[', @subtest,']
@ty_name:[', @ty_name,']
@exp_res:[', @exp_res,']
@exp_ex :[', @exp_ex, ']'
;
---- SETUP:
   -- <TBD>
---- RUN tested rtn:
   EXEC sp_log 1, @fn, '04: running tested rtn: SET @v = dbo.fnGetTyCodeFrmTyNm( @ty_name);';
   IF @exp_ex = 1
   BEGIN
      BEGIN TRY
         -- Expect an exception here
         EXEC sp_log 2, @fn, '05: Expect an exception here';
         SET @v = dbo.fnGetTyCodeFrmTyNm( @ty_name);
         EXEC sp_log 4, @fn, '06: oops! Expected an exception here';
         THROW 51000, ' Expected an exception but none were thrown', 1;
      END TRY
      BEGIN CATCH
         EXEC sp_log 2, @fn, '07: caught expected exception';
      END CATCH
   END -- IF @exp_ex = 1
   ELSE
   BEGIN
      -- Do not expect an exception here
         EXEC sp_log 2, @fn, '08: Calling tested rtn: do not expect an exception now';
         SET @v = dbo.fnGetTyCodeFrmTyNm( @ty_name);
         EXEC sp_log 2, @fn, '09: Returned from tested rtn: no exception thrown';
   END -- ELSE -IF @exp_ex = 1
---- TEST:
   EXEC sp_log 2, @fn, '10: running tests...';
   IF @exp_res IS NOT NULL EXEC tSQLt.AssertEquals @exp_res, @v, 'fn return value does not match @exp_res'
   -- <TBD>
   EXEC sp_log 2, @fn, '11: all tests ran OK';
---- CLEANUP:
   -- <TBD>
   EXEC sp_log 2, @fn, 'subtest 59: PASSED'; -- BUG
END
/*
   EXEC tSQLt.Run 'test.test_059_fnGetTyCodeFrmTyNm';
*/
GO

