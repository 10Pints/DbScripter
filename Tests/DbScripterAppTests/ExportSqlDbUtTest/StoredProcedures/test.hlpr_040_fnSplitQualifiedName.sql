SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ========================================================================================
-- Author:           Terry Watts
-- Create date:      12-Nov-2023
-- Description:      test helper rtn for the GetRtnNmBits rtn being tested
-- Tested rtn desc:
--  splits a qualified rtn name
-- into a row containing the schema_nm and the rtn_nm
--
-- e.g.: ('dbo.fnSplit') -> 'dbo'
--
--
-- Tested rtn params:
--    @qual_rtn_nm  NVARCHAR(150)
-- ========================================================================================
CREATE PROCEDURE [test].[hlpr_040_fnSplitQualifiedName]
       @qual_rtn_nm     NVARCHAR(150)
      ,@exp_ex          BIT = 0
      ,@subtest         NVARCHAR(100)
      ,@exp_schema_nm   NVARCHAR(50) = NULL
      ,@exp_rtn_nm      NVARCHAR(50) = NULL
AS
BEGIN
   DECLARE
       @fn              NVARCHAR(35)   = N'hlpr_040_GetRtnNmBits'
      ,@act_schema_nm   NVARCHAR(50)
      ,@act_rtn_nm      NVARCHAR(50)
   EXEC sp_log 1, @fn, '01: starting, @subtest: ', @subtest;
   -- SETUP:
   -- <TBD>
   -- RUN tested rtn:
   EXEC sp_log 1, @fn, '04: running tested rtn '
   IF @exp_ex = 1
   BEGIN
      BEGIN TRY
         -- Expect an exception here
         SELECT * FROM test.fnSplitQualifiedName( @qual_rtn_nm);
         EXEC sp_log 4, @fn, '05: oops! Expected an exception here';
         THROW 51000, ' Expected an exception but none were thrown', 1;
      END TRY
      BEGIN CATCH
         EXEC sp_log 1, @fn, '05: caught expected exception'
      END CATCH
   END -- if expecting an exception
   ELSE
   BEGIN
      -- Not expecting an exception here
      SELECT
          @act_schema_nm = schema_nm
         ,@act_rtn_nm    = rtn_nm
      FROM test.fnSplitQualifiedName( @qual_rtn_nm);
   END -- if not expecting an exception
---- TEST:
   IF @exp_schema_nm IS NOT NULL EXEC tSQLt.AssertEquals @exp_schema_nm, @act_schema_nm, 'schema_nm';
   IF @exp_rtn_nm    IS NOT NULL EXEC tSQLt.AssertEquals @exp_rtn_nm,    @act_rtn_nm,    'rtn_nm';
   -- CLEANUP:
   EXEC sp_log 1, @fn, '99: leaving'
END
/*
EXEC tSQLt.Run 'test.test_040_fnSplitQualifiedName';
EXEC tSQLt.RunAll
*/
GO

