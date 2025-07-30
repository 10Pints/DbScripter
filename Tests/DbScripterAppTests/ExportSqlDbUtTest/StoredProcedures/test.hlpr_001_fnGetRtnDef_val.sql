SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      18-Nov-2023
-- Description:      test helper rtn for fnGetRtnDef_val
-- Tested rtn desc:
-- test.fnGetRtnDef validation rtn
--    Performs validation and some initialisation - hence the out params in the returned table
--    Cleans up  [ ] --> DeSquareBracket
-- Author:      Terry Watts
--
-- POSTCONDITIONS
-- POST 00: RETURNS      1 line (@rtn_name,@objid) OR @rtn_name = error msg, @objid = error code as a negative number
-- POST 01: Make sure the @objname is local to the current database. OR ERROR(-15251, 'Error 01: database not parsed')
-- POST 02: db_nm found     or ERROR(-15252, 'Error 02: database name not parsed')
-- POST 03: schema_nm found or ERROR(-15253, 'Error 03: schema name not parsed')
-- POST 04: rtn_nm   found  or ERROR(-15254, 'Error 04: routine name not parsed')
-- POST 05: objid    found  or ERROR(-15009, 'Error 05: rtn does not exist')
-- POST 06: db_nm found     or ERROR(-15197, 'Error 06: rtn has no lines')
-- POST 07: db_nm found     or ERROR(-15257, 'Error 07: rtn has no lines*')
--Removes square brackets OR error returned
-- POST 03: rtn_name contains the existing schema qualified routine name
--========================================================================================
CREATE PROCEDURE [test].[hlpr_001_fnGetRtnDef_val]
    @test_num        NVARCHAR(100)
   ,@inp_qrn         NVARCHAR(100)
   ,@tst_key         INT = 0
   ,@exp_schema_nm   NVARCHAR(30)   = NULL
   ,@exp_rtn_nm      NVARCHAR(60)   = NULL
   ,@exp_objid       INT            = NULL
   ,@exp_ex_num      INT            = NULL
   ,@exp_ex_msg      NVARCHAR(100)  = NULL
   ,@display_table   BIT            = 0
AS
BEGIN
   DECLARE
       @fn              NVARCHAR(35)   = N'H001_fnGetRtnDef_val'
      ,@act_schema_nm   NVARCHAR(30) = NULL
      ,@act_rtn_nm      NVARCHAR(60) = NULL
   EXEC test.sp_tst_hlpr_st @fn, @test_num;
   EXEC sp_log 1, @fn, '01: starting, 
@test_num     :[', @test_num      ,']
@inp_qrn      :[', @inp_qrn      ,']
@tst_key      :[', @tst_key      ,']
@exp_schema_nm:[', @exp_schema_nm,']
@exp_rtn_nm   :[', @exp_rtn_nm   ,']
@exp_objid    :[', @exp_objid    ,']
@exp_ex_num   :[', @exp_ex_num   ,']
@exp_ex_msg   :[', @exp_ex_msg   ,']
@display_table:[', @display_table,']'
;
---- SETUP:
   -- <TBD>
---- RUN tested rtn:
   EXEC sp_log 1, @fn, '04: running tested rtn '
   IF @exp_ex_num IS NULL
    BEGIN -- @exp_ex_num is not specified
      -- Do not expect an exception here
      EXEC sp_log 1, @fn, '10: Running fnGetRtnDef_val()...'
      SELECT 
          @act_schema_nm = schema_nm
         ,@act_rtn_nm    = rtn_nm
      FROM test.fnSplitQualifiedName (@inp_qrn);
      EXEC sp_log 1, @fn, '15: results, 
@act_schema_nm:[', @act_schema_nm,']
@act_rtn_nm   :[', @act_rtn_nm   ,']'
;
---- TEST:
      EXEC sp_log 1, @fn, '20: Running tests';
      IF @exp_schema_nm IS NOT NULL EXEC tSQLt.AssertEquals @exp_schema_nm, @act_schema_nm;
      IF @exp_rtn_nm    IS NOT NULL EXEC tSQLt.AssertEquals @exp_rtn_nm   , @act_rtn_nm;
   END  -- @exp_ex_num is not specified
   ELSE -- @exp_ex_num is specified
   BEGIN
      BEGIN TRY
         -- Expect an exception here
         EXEC sp_log 2, @fn, '10: Running fnGetRtnDef_val(), expect an exception here'
         SELECT * FROM fnSplitQualifiedName (@inp_qrn);
         EXEC sp_log 4, @fn, '05: oops! Expected an exception here';
         THROW 51000, ' Expected an exception but none were thrown', 1;
      END TRY
      BEGIN CATCH
         EXEC sp_log 2, @fn, '05: caught expected exception';
         -- test it
         RETURN;
      END CATCH
   END -- ELSE @exp_ex_num is specified
---- CLEANUP:
   -- <TBD>
   EXEC test.sp_tst_hlpr_hndl_success;
END
/*
EXEC tSQLt.RunAll
EXEC tSQLt.Run 'test.test_001_fnGetRtnDef_val';
*/
GO

