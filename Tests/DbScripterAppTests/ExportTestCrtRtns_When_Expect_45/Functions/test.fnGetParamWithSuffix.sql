SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- ============================================================================================================================
-- Author:      Terry Watts
-- Create date: 03-MAY-2024
-- Description: provides teh suffix for a pparameter based on its test ty in Test.ParamDetails
--
-- PRECONDITIONS:
-- test.ParamDetails pop'd
--
-- POSTCONDITIONS:
-- POST 01:
--
-- Tests:
-- ============================================================================================================================
CREATE FUNCTION [test].[fnGetParamWithSuffix](@param_nm      VARCHAR(20))
RETURNS VARCHAR(50)
AS
BEGIN
   DECLARE
       @rtn_nm      VARCHAR(4000)
      ,@tst_ty      VARCHAR(3)
   SELECT
        @tst_ty  = tst_ty
   FROM test.ParamDetails
   WHERE
      param_nm=@param_nm;
   RETURN LOWER(CONCAT('@', IIF(@tst_ty='TST', '',CONCAT(@tst_ty, '_')), @param_nm));
END
/*
EXEC test.sp_get_rtn_details 'dbo.sp_grep_rtns', @display_tables=1;
PRINT test.fnGetParamWithSuffix('ss_principal_id');
*/
GO

