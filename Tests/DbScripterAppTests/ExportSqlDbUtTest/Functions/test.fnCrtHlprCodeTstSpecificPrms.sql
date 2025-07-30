SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ====================================================================================
-- Author:      Terry Watts
-- Create date: 16-DEC-2023
--
-- Description: adds 2 blocs to the test hlp parameters
-- Bloc 1: test parameters
--   ,@exp_add_step       BIT            = NULL
--   ,@chk_step_id        NVARCHAR(50)   = NULL -- line to check
--   ,@exp_line           NVARCHAR(500)  = NULL -- expected line 
-- only add these if a procedure - functions should not throw exceptions
--   ,@exp_ex_num         INT            = NULL
--   ,@exp_ex_msg         NVARCHAR(100)  = NULL
-- Bloc 2:the routine output parameters if a table function
--  and
-- test specific parameters:
--  expected values  @exp_<>     optional
-- check step id:  @chk_step_id  optional
-- expected line: @exp_line      optional
-- expected exception info       optional (@exp_ex_num and @exp_ex_msg)
--
-- if qrn does not exist then return no rows then returned table has no rows
--
-- Parameters:
--    @qrn     the schema qualified routine name
--    @ordinal the ordinal position to start the ordinal numbering of the returned rows
--
-- PRECONDITTIONS: test.RtnDetails and test.ParamDetails pop
--
-- POST COMDITIONS:
-- The following rows are added to the output table
-- 1.  {@exp_add_step, @chk_step_id, @exp_line}
-- 2 if a TF then the TF output table columns
--
-- Algorithm:
-- add in the following 
--   ,@exp_add_step       BIT            = NULL
--   ,@chk_step_id        NVARCHAR(50)   = NULL -- line to check
--   ,@exp_line           NVARCHAR(25)   = NULL -- expected line
--   ,@exp_ex_num         INT            = NULL
--   ,@exp_ex_msg         NVARCHAR(100)  = NULL
--
-- Test rtn: test.test_085_fnCrtHlprCodeTstSpecificPrms
--
-- ====================================================================================
CREATE FUNCTION [test].[fnCrtHlprCodeTstSpecificPrms]
(
    @qrn       NVARCHAR(120)
   ,@ordinal   INT
)
RETURNS @t TABLE
(
    rtn_nm              NVARCHAR(60)
   ,rtn_ty              NVARCHAR(5)
   ,schema_nm           NVARCHAR(25)
   ,param_nm            NVARCHAR(60)
   ,ordinal_position    INT
   ,param_ty_nm         NVARCHAR(25)
   ,is_output           BIT
   ,has_default_value   BIT
   ,is_nullable         BIT
)
AS
BEGIN
   DECLARE
    @schema_nm          NVARCHAR(50)
   ,@rtn_nm             NVARCHAR(60)
   ,@rtn_ty             NCHAR(1)
   SELECT
       @schema_nm = schema_nm
      ,@rtn_nm     = rtn_nm
   FROM test.fnSplitQualifiedName(@qrn);
   SELECT @rtn_ty = rtn_ty
   FROM test.RtnDetails;
   INSERT INTO @t( rtn_nm, rtn_ty, schema_nm, param_nm, ordinal_position, param_ty_nm, is_output, has_default_value, is_nullable)
   VALUES
       (@rtn_nm, @rtn_ty, @schema_nm, '@exp_add_step', @ordinal+0, 'BIT'           , 0, 0, 1)
      ,(@rtn_nm, @rtn_ty, @schema_nm, '@chk_step_id' , @ordinal+1, 'NVARCHAR(50)'  , 0, 0, 1)
      ,(@rtn_nm, @rtn_ty, @schema_nm, '@exp_line   ',  @ordinal+1, 'NVARCHAR(25)'  , 0, 0, 1)
   IF @rtn_ty = 'P'
      INSERT INTO @t( rtn_nm, rtn_ty, schema_nm, param_nm, ordinal_position, param_ty_nm, is_output, has_default_value, is_nullable)
         VALUES
          (@rtn_nm, @rtn_ty, @schema_nm, '@exp_ex_num'  , @ordinal+3, 'INT'           , 0, 0, 1)
         ,(@rtn_nm, @rtn_ty, @schema_nm, '@exp_ex_msg'  , @ordinal+4, 'NVARCHAR(500)' , 0, 0, 1)
   INSERT INTO @t( rtn_nm, rtn_ty, schema_nm, param_nm, ordinal_position, param_ty_nm, is_output, has_default_value, is_nullable)
   SELECT         @rtn_nm, @rtn_ty,@schema_nm, CONCAT('@exp_',name), ordinal + @ordinal+4, dbo.fnGetFullTypeName(ty_nm, [len]/2), 0, 0, is_nullable
   FROM dbo.fnGetFnOutputCols(@qrn);
   RETURN;
END
/*
EXEC tSQLt.Run 'test.test_085_fnCrtHlprCodeTstSpecificPrms';
EXEC tSQLt.RunAll;
*/
GO

