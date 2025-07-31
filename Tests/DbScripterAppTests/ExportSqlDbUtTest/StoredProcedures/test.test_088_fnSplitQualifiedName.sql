SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      13-Dec-2023
-- Description:      test rtn for the fnDequalifyName rtn being tested
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
CREATE PROCEDURE [test].[test_088_fnSplitQualifiedName]
AS
BEGIN
   DECLARE
    @fn               NVARCHAR(35)   = N'test_088_fnDequalifyName'
   EXEC sp_log 1, @fn, '01: starting'
---- RUN tests
   EXEC test.hlpr_088_fnSplitQualifiedName 'TG001 a.b'   , 'a.b'  , 'a'  ,'b';
   EXEC test.hlpr_088_fnSplitQualifiedName 'TG002 a.b.c ', 'a.b.c', 'a'  ,'b.c';
   EXEC test.hlpr_088_fnSplitQualifiedName 'TG003 a'     , 'a'    , 'dbo','a';
   EXEC test.hlpr_088_fnSplitQualifiedName 'TG004 NULL ' , NULL   , NULL , NULL;
   EXEC test.hlpr_088_fnSplitQualifiedName 'TG005 Empty' , ''     , NULL , NULL;
   EXEC sp_log 2, @fn, 'all ',fnDequalifyName,' tests PASSED';
END
/*-- 48
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_088_fnSplitQualifiedName';
*/
GO

