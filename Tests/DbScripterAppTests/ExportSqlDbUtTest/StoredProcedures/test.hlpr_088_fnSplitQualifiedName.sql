SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      13-Dec-2023
-- Description:      helper rtn for the fnDequalifyName rtn being tested
-- Tested rtn desc:
-- splits a qualified rtn name 
-- into a row containing the schema_nm and the rtn_nm
-- removes square brackets
--
-- RULES:
-- @qrn  schema   rtn
-- a.b   a        b
-- a     dbo      a
-- NULL  null     null
-- ''    null     null
--
-- Tested rtn params:
--    @rtn_name         NVARCHAR(776)
--========================================================================================
CREATE PROCEDURE [test].[hlpr_088_fnSplitQualifiedName]
    @test_num         NVARCHAR(100)
   ,@qrn              NVARCHAR(150)
   ,@exp_schema_nm    NVARCHAR(50)  = NULL
   ,@exp_rtn_nm       NVARCHAR(100) = NULL
AS
BEGIN
   DECLARE
    @fn               NVARCHAR(35)   = N'hlpr_088_fnDequalifyName'
   ,@act_schema_nm    NVARCHAR(50)
   ,@act_rtn_nm       NVARCHAR(100)
   EXEC sp_log 0, @fn, '01: test: ', @test_num, ' starting';
---- RUN tested rtn:
   EXEC sp_log 0, @fn, '04: calling dbo.fnDequalifyName(', @qrn,');';
   SELECT 
      @act_schema_nm = schema_nm
     ,@act_rtn_nm    = rtn_nm
      FROM test.fnSplitQualifiedName(@qrn);
---- TEST:
   EXEC sp_log 0, @fn, '10: running sub tests...'; 
   IF @exp_schema_nm IS NOT NULL EXEC tSQLt.AssertEquals @exp_schema_nm, @act_schema_nm, 'schema_nm';
   IF @exp_rtn_nm    IS NOT NULL EXEC tSQLt.AssertEquals @exp_rtn_nm   , @act_rtn_nm   , 'rtn_nm';
   EXEC sp_log 1, @fn, 'test# ',@test_num, ': PASSED';
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_088_fnSplitQualifiedName';
*/
GO

