SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================================
-- Author:      Terry Watts
-- Create date: 28-FEb-2024
-- Description: this view lists all the staging table names
--
-- PRECONDITIONS: none
-- =============================================================
CREATE VIEW [dbo].[list_staging_tables_vw]
AS
SELECT TOP (1000) table_nm
FROM list_tables_vw where table_nm like '%staging%';

GO
