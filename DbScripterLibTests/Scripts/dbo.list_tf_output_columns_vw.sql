SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================================
-- Author:      Terry Watts
-- Create date: 17-APR-2024
-- Description: lists the output columns for table functions
-- =============================================================
ALTER VIEW [dbo].[list_tf_output_columns_vw]
AS
SELECT TOP 10000 
   table_schema
   ,TABLE_NAME
   ,COLUMN_NAME
   ,ORDINAL_POSITION
   ,is_nullable
   ,dbo.fnGetFullTypeName(DATA_TYPE, CHARACTER_MAXIMUM_LENGTH) as data_type
   ,IIF(DATA_TYPE IN ('NVARCHAR', 'VARCHAR', 'NCHAR', 'CHAR'), 1, 0) AS is_chr
FROM INFORMATION_SCHEMA.ROUTINE_COLUMNS isc
ORDER BY TABLE_NAME, ORDINAL_POSITION;
/*
SELECT * FROM list_tf_output_columns_vw;
*/

GO
