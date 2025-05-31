SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ================================================================================================
-- Author:      Terry watts
-- Create date: 05-APR-2024
-- Description: returns:
--    if @ty_nm is a text array type then returns the full type from a data type + max_len fields
--    else returns @ty_nm on its own.
--
--    This is useful when using sys rtns like sys.columns
--
-- Test:
-- ================================================================================================
ALTER   FUNCTION [dbo].[fnGetOutputColumnsForTf]
(
    @schema_nm    VARCHAR(40)
   ,@rtn_nm       VARCHAR(60)
)
RETURNS @t TABLE
(
    ordinal       INT
   ,col_nm        VARCHAR(60)
   ,data_type     VARCHAR(20)
   ,is_nullable   BIT
   ,is_chr        BIT
)
AS
BEGIN
   INSERT INTO @t(ordinal , col_nm     , data_type, is_nullable, is_chr)
   SELECT ordinal_position, column_name, data_type, iif(is_nullable='YES', 1,0), is_chr
   FROM list_tf_output_columns_vw
   WHERE table_schema = @schema_nm AND table_name = @rtn_nm

   RETURN;
END
/*
  SELECT * FROM dbo.fnGetOutputColumnsForTf('dbo', 'fnClassCreator');
*/


GO
