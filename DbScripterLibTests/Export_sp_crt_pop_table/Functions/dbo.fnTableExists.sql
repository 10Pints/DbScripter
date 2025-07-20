SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================================
-- Author:      Terry Watts
-- Create date: 08-FEB-2020
-- Description: returns true (1) if table exists else false (0)
-- schema default is dbo
-- Parameters:  @q_table_nm can be qualified
-- Returns      1 if exists, 0 otherwise
-- =============================================================
CREATE FUNCTION [dbo].[fnTableExists](@q_table_nm VARCHAR(100))
RETURNS BIT
AS
BEGIN
   DECLARE
       @schema    VARCHAR(28)
      ,@table_nm  VARCHAR(60)
   ;

   SELECT
       @schema    = schema_nm
      ,@table_nm  = rtn_nm
   FROM fnSplitQualifiedName(@q_table_nm);

   RETURN iif(EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @table_nm AND TABLE_SCHEMA = @schema), 1, 0);
END

GO
