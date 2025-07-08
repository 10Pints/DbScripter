SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =================================================================
-- Author:      Terry Wayys
-- Create date: 13-NOV-2024
-- Description: returns the column info for the given table or view
-- =================================================================
CREATE FUNCTION [dbo].[fnGetCols4Tbl]
(
   @tbl_or_vw VARCHAR(80)
)
RETURNS @t TABLE
(
    schema_nm          VARCHAR(32)
   ,table_nm           VARCHAR(60)
   ,table_ty           VARCHAR(6)
   ,col_nm             VARCHAR(40)
   ,ordinal            INT
   ,is_nullable        BIT
   ,data_ty            VARCHAR(17)
   ,is_char_ty         BIT
   ,col_len            INT
   ,CHARACTER_SET_NAME VARCHAR(32)
   ,COLLATION_NAME     VARCHAR(32)
)
AS
BEGIN
   INSERT INTO @t 
   (schema_nm, table_nm, table_ty, col_nm, ordinal, is_nullable, data_ty, is_char_ty, col_len, CHARACTER_SET_NAME, COLLATION_NAME)
   SELECT
       schema_nm
      ,table_nm
      ,table_ty
      ,col_nm
      ,ordinal
      ,is_nullable
      ,data_ty
      ,is_char_ty
      ,col_len
      ,CHARACTER_SET_NAME
      ,COLLATION_NAME
   FROM SysTblCols_vw WHERE table_nm = @tbl_or_vw;
   RETURN;
END
/*
SELECT * FROM dbo.fnGetCols4Tbl('GafGroupStaging');
*/

GO
