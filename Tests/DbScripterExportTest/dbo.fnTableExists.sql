SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================================
-- Author:      Terry Watts
-- Create date: 08-FEB-2020
-- Description: returns true (1) if table exists else false (0)
-- schema default is dbo
-- =============================================================
CREATE   FUNCTION [dbo].[fnTableExists](@qrn VARCHAR(60))
RETURNS BIT
AS
BEGIN
   DECLARE
       @schema    VARCHAR(10)
      ,@table_nm  VARCHAR(60)
   ;

   SELECT
       @schema    = schema_nm
      ,@table_nm  = rtn_nm
   FROM fnSplitQualifiedName(@qrn);

   RETURN iif(EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @table_nm AND TABLE_SCHEMA = @schema), 1, 0);
END


GO
