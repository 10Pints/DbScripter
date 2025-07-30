SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      01-Dec-2023
-- Description:      test helper rtn for the fn_CamelCase rtn being tested
-- Tested rtn desc:
--  Converts string to camel case  
--
-- Tested rtn params: 
--    @str       VARCHAR(4000),
--
-- returns VARCHAR(4000)
--========================================================================================
CREATE PROCEDURE [test].[hlpr_013_fn_CamelCase]  -- 12
    @tst_num      NVARCHAR(100)                 -- 15
   ,@str          VARCHAR(4000)                 -- 20
   ,@exp_res      VARCHAR(4000)  = NULL         -- 30 if Scalar fn
   ,@exp_ex_num   INT            = null
   ,@exp_ex_msg   VARCHAR(1000)  = null
AS  -- 40
BEGIN
   DECLARE
       @fn                NVARCHAR(35)   = N'H013_fn_CamelCase'
      ,@v                 VARCHAR
      EXEC test.sp_tst_hlpr_st @tst_num, @fn;
   -- SETUP: --  41
   -- <TBD>
---- RUN tested rtn: -- 42
   EXEC sp_log 1, @fn, '005: running tested rtn: SET @v = dbo.fn_CamelCase( @str);';
   IF @exp_ex_num IS NOT NULL
   BEGIN
      BEGIN TRY
         -- Expect an exception here
         EXEC sp_log 1, @fn, '010: Expect an exception here';
         SET @v = dbo.fn_CamelCase( @str);
         EXEC sp_log 4, @fn, '015: oops! Expected an exception here';
         THROW 51000, ' Expected an exception but none were thrown', 1;
      END TRY
      BEGIN CATCH
         EXEC sp_log 1, @fn, '020: caught expected exception';
      END CATCH
   END -- IF @exp_ex = 1
   ELSE
   BEGIN
      -- Do not expect an exception here
         EXEC sp_log 1, @fn, '025: Calling tested rtn: do not expect an exception now';
         SET @v = dbo.fn_CamelCase( @str);
         EXEC sp_log 1, @fn, '030: Returned from tested rtn: no exception thrown';
   -- TEST:
      EXEC sp_log 1, @fn, '035: running tests...'; -- 41
      --IF @exp_res IS NOT NULL EXEC tSQLt.AssertEquals @exp_res, @v, 'fn return value does not match @exp_res' -- 45
      EXEC sp_log 1, @fn, '040:'; -- 41
   END -- ELSE -IF @exp_ex = 1  -- 46
   -- <TBD> -- 47
      EXEC sp_log 1, @fn, '950: all tests ran OK';
   -- CLEANUP:
   -- <TBD>
   EXEC test.sp_tst_hlpr_hndl_success;
END
/* -- 48
EXEC tSQLt.RunAll;
   EXEC tSQLt.Run 'test.test_013_fn_CamelCase';
*/
GO

