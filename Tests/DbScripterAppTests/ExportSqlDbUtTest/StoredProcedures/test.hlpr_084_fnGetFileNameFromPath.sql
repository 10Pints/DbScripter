SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      07-MAR-2024
-- Description: Tests the fnGetFileNameFromPath rtn
--
-- Tested rtn description:
-- Gets the file name optionally with the extension from the supplied file path
--
-- Tested rtn params: 
--    @path       NVARCHAR(MAX), @with_ext BIT)
--    @with_ext   BIT
--========================================================================================
CREATE PROCEDURE [test].[hlpr_084_fnGetFileNameFromPath]
    @test_num  NVARCHAR(50)
   ,@path      NVARCHAR(MAX)
   ,@with_ext  BIT
   ,@exp       NVARCHAR(200)
AS
BEGIN
   DECLARE
    @fn        NVARCHAR(35)   = N'hlpr_083_clr_stgng_tbl_chk'
   ,@act       NVARCHAR(200)
   SET @act = dbo.fnGetFileNameFromPath(@path, @with_ext);
   EXEC sp_log 1, @fn, '00: starting, 
test_num [', @test_num, ']
path:    [', @path    , ']
with_ext:[', @with_ext, ']
exp:     [', @exp     , ']
act:     [', @act     , ']';
   EXEC tSQLt.AssertEquals @exp, @act;
END
/*
*/
GO

