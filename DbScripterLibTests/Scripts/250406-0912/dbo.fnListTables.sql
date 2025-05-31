SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 03-DEc-2024
-- Description: lists the dbo and or test tables
-- =============================================
ALTER FUNCTION [dbo].[fnListTables](@schema_nm VARCHAR(32))
RETURNS
@t TABLE
(
   schema_nm       VARCHAR(32) NOT NULL,
   table_nm        VARCHAR(60) NOT NULL
)
AS
BEGIN
   INSERT INTO @t
   SELECT * FROM list_tables_vw
   WHERE schema_nm = @schema_nm OR @schema_nm IS NULL
   ORDER BY schema_nm, table_nm ASC;

   RETURN;
END
/*
SELECT * FROM dbo.fnListTables('dbo');
SELECT * FROM dbo.fnListTables('test');
SELECT * FROM dbo.fnListTables(NULL);
*/

GO
