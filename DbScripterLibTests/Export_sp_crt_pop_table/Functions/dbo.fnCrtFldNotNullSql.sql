SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===============================================================
-- Author:      Terry Watts
-- Create date: 17-JUN-2025
-- Description: generates the sql to check if every value 
--    in field @fld_nm of the table @q_table_nm
--    can be cast to the type @ty
-- Tests      : test_075_fnCrtFldNotNullSql
--
-- Postconditions: returns the check SQL for the given parameters
-- ===============================================================
CREATE FUNCTION [dbo].[fnCrtFldNotNullSql]
(
    @q_table_nm VARCHAR(60)
   ,@fld_nm     VARCHAR(40)
   ,@ty         VARCHAR(25)
)
RETURNS NVARCHAR(4000)
AS
BEGIN
     DECLARE @sql NVARCHAR(4000)
     ;

     SET @sql =
     CONCAT
     (
'IF NOT EXISTS
(
   SELECT 1 FROM ',@q_table_nm,'
   WHERE TRY_CAST([',@fld_nm,'] AS ',@ty,') IS NULL
)
   SET @fld_ty = ''',@ty,'''
ELSE
   SET @fld_ty = NULL
;'
     );

     RETURN @sql;
END
/*
EXEC test.sp__crt_tst_rtns '[dbo].[fnCrtFldNotNullSql]'
*/

GO
