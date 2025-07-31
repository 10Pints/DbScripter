SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      19-Apr-2024
-- Description:      helper rtn for the fnDequalifyName rtn being tested
-- Tested rtn desc:
-- converts and returns input to a float if possible 
--              or return null of not
--
-- PRECONITIONS - none
--
-- POSTCONDITIONS
-- RETURNS
-- Float value of the input if possible or NULL if not
--
-- Tested rtn params:
--    @v SQL_VARIANT the value to be converted
--========================================================================================
CREATE PROCEDURE [test].[hlpr_091_fnAsFloat]
    @tst_num   NVARCHAR(100)
   ,@inp_value SQL_VARIANT
   ,@exp_value FLOAT          = NULL
AS
BEGIN
   DECLARE
    @fn        NVARCHAR(35)      = N'hlpr_088_fnDequalifyName'
   ,@act_value FLOAT
   ,@inp_value_str NVARCHAR(MAX)
   EXEC test.sp_tst_hlpr_st @fn, @tst_num;
   SET @inp_value_str = TRY_CONVERT(NVARCHAR(MAX), @inp_value);
   -- RUN tested rtn:
   EXEC sp_log 1, @fn, '010: running dbo.AsFloat(', @inp_value_str,')'; 
   SET @act_value = dbo.fnAsFloat(@inp_value);
   -- TEST:
   EXEC sp_log 1, @fn, '020: running sub tests...';
   -- Get around testing NULL problem
   EXEC tSQLt.AssertEquals @exp_value, @act_value, '25 chking value';
   EXEC test.sp_tst_hlpr_hndl_success;
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_091_fnAsFloat';
*/
GO

