SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      18-Nov-2023
-- Description:      test helper rtn for the fnDequalifyName rtn being tested
-- Tested rtn desc:
--  splits a qualified rtn name   
-- into a row containing the schema_nm and the rtn_nm  
--  
-- e.g.: ('dbo.fnSplit') -> 'dbo'  
--  
-- ASSERTED PRECONDITIONS:  
-- PRE01: @qual_rtn_nm NOT NULL  
-- PRE02: @qual_rtn_nm NOT empty  
--  
-- Changes:   
-- 231117: handle [ ] wrappers  
--
-- Tested rtn params: 
--    @qual_rtn_nm  NVARCHAR
--========================================================================================
CREATE PROCEDURE [test].[hlpr_002_fnSplitQualifiedName]
   @test_num      NVARCHAR(100),
   @qual_rtn_nm   NVARCHAR(100),
   @exp_ex        BIT = 0,
   @exp_schema_nm NVARCHAR(30) = NULL,
   @exp_rtn_nm    NVARCHAR(60) = NULL
AS
BEGIN
   DECLARE
       @fn              NVARCHAR(35)   = N'H002_fnSplitQualifiedName'
      ,@act_schema_nm   NVARCHAR(30) = NULL
      ,@act_rtn_nm      NVARCHAR(60) = NULL
   EXEC ut.test.sp_tst_hlpr_st @fn, @test_num;
   EXEC sp_log 1, @fn, '01: starting, 
@subtest      :[', @test_num      ,']
@qual_rtn_nm  :[', @qual_rtn_nm  ,'[
@exp_ex       :[', @exp_ex       ,'[
@exp_schema_nm:[', @exp_schema_nm,'[
@exp_rtn_nm   :[', @exp_rtn_nm   ,'[
';
---- SETUP:
   -- <TBD>
---- RUN tested rtn:
   EXEC sp_log 1, @fn, '04: running tested rtn '
   IF @exp_ex = 1
   BEGIN
      BEGIN TRY
         -- Expect an exception here
         --EXEC sp_log 2, @fn, '10: Running fnDequalifyName, expect an exception here'
         SELECT * FROM fnSplitQualifiedName (@qual_rtn_nm);
         EXEC sp_log 4, @fn, '05: oops! Expected an exception here';
         THROW 51000, ' Expected an exception but none were thrown', 1;
      END TRY
      BEGIN CATCH
         EXEC sp_log 2, @fn, '05: caught expected exception';
      END CATCH
   END -- IF @exp_ex = 1
   ELSE
   BEGIN
      -- Do not expect an exception here
      EXEC sp_log 1, @fn, '10: Running fnDequalifyName, do not expect an exception here'
      SELECT 
          @act_schema_nm = schema_nm
         ,@act_rtn_nm    = rtn_nm
      FROM test.fnSplitQualifiedName (@qual_rtn_nm);
      EXEC sp_log 1, @fn, '15: results, 
@act_schema_nm:[', @act_schema_nm,']
@act_rtn_nm   :[', @act_rtn_nm   ,']'
;
---- TEST:
      EXEC sp_log 1, @fn, '20: Running tests';
      IF @exp_schema_nm IS NOT NULL EXEC tSQLt.AssertEquals @exp_schema_nm, @act_schema_nm;
      IF @exp_rtn_nm    IS NOT NULL EXEC tSQLt.AssertEquals @exp_rtn_nm   , @act_rtn_nm;
   END -- ELSE -IF @exp_ex = 1
---- CLEANUP:
   -- <TBD>
   EXEC sp_log 2, @fn, '99: leaving subtest ',@test_num,' PASSED'
END
/*
EXEC tSQLt.RunAll
EXEC tSQLt.Run 'test.test_002_fnSplitQualifiedName';
*/
GO

