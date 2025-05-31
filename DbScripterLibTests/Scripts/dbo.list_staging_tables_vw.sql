SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
/****** Script for SelectTopNRows command from SSMS  ******/
-- =============================================================
-- Author:      Terry Watts
-- Create date: 28-FEb-2024
-- Description: this view lists all the staging table names
--
-- PRECONDITIONS: none
-- =============================================================
ALTER view [dbo].[list_staging_tables_vw]
AS
SELECT TOP (1000) table_name
  FROM list_tables_vw where table_name like '%staging%';

GO
