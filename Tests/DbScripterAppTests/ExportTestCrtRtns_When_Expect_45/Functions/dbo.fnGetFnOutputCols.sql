SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================================
-- Author:        Terry watts
-- Create date:   05-APR-2024
-- Description:   gets the output columns from a table function (TF)
-- Tests:         test_042_fnGetFnOutputCols
-- Preconditions  @q_rtn_nm is a table function
-- Postconditions OUTPUT table holds the output column meta data for the given TF
-- ===============================================================================
CREATE FUNCTION [dbo].[fnGetFnOutputCols]
(
    @q_rtn_nm     VARCHAR(60)
)
RETURNS @t TABLE
(
    name          VARCHAR(50)
   ,ordinal       INT
   ,ty_nm         VARCHAR(40)
   ,[len]         INT
   ,is_nullable   BIT
   ,is_results    BIT
)
AS
BEGIN
      INSERT INTO @t (name, ordinal, ty_nm, [len], is_nullable, is_results)
      --SELECT name, column_id as ordinal, TYPE_NAME(user_type_id) as ty_nm, max_length, is_nullable
      SELECT name, column_id as ordinal, dbo.fnGetFullTypeName(TYPE_NAME(user_type_id), max_length) as ty_nm, max_length, is_nullable, 0
      FROM sys.columns
      WHERE object_id=object_id(@q_rtn_nm)
      ORDER BY column_id
      ;

   RETURN;
END
/*
EXEC test.test_042_fnGetFnOutputCols;

SELECT * FROM dbo.fnGetFnOutputCols('test.fnCrtHlprSigParams');
SELECT * FROM dbo.fnGetFnOutputCols('test.fnCrtHlprSigParams');

SELECT name, column_id as ordinal, TYPE_NAME(user_type_id) as ty_nm, max_length, is_nullable
FROM sys.columns
WHERE object_id=object_id('test.fnCrtHlprSigParams')
ORDER BY column_id
;
SELECT *, column_id as ordinal, TYPE_NAME(user_type_id) as ty_nm, dbo.fnGetFullTypeName(TYPE_NAME(user_type_id), max_length) as ty_nm_full, max_length, is_nullable
FROM sys.columns
WHERE object_id=object_id('test.fnCrtHlprSigParams')
ORDER BY column_id
;
EXEC test.sp__crt_tst_rtns '[dbo].[fnGetFnOutputCols]';
*/


GO
