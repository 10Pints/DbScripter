SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE FUNCTION [dbo].[fnGetTableColumns]
(
    @name       VARCHAR(128)
   ,@schema_nm  VARCHAR(128)
)
RETURNS
@t TABLE
(
    TABLE_CATALOG    VARCHAR(128)
   ,TABLE_SCHEMA     VARCHAR(128)
   ,TABLE_NAME       VARCHAR(128)
   ,COLUMN_NAME      VARCHAR(128)
   ,ORDINAL_POSITION INT
   ,IS_NULLABLE      BIT
   ,DATA_TYPE        VARCHAR(128)
)
AS
BEGIN
   INSERT INTO @t(
    TABLE_CATALOG
   ,TABLE_SCHEMA
   ,TABLE_NAME
   ,COLUMN_NAME
   ,ORDINAL_POSITION
   ,IS_NULLABLE
   ,DATA_TYPE
)
   SELECT
    TABLE_CATALOG
   ,TABLE_SCHEMA
   ,TABLE_NAME
   ,COLUMN_NAME
   ,ORDINAL_POSITION
   ,iif(IS_NULLABLE = 'YES', 1, 0)
   ,DATA_TYPE
   FROM TableColumns_vw
   WHERE
          (TABLE_SCHEMA = @schema_nm OR @schema_nm IS NULL)
      AND TABLE_NAME   = @name
      ORDER BY ORDINAL_POSITION
   ;

   RETURN;
END
/*
   SELECT * FROM dbo.fnGetTableColumns('Attendance', NULL);
*/

GO
