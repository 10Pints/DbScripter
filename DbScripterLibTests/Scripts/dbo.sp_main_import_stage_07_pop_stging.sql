SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ============================================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2024
-- Description: populate the staging tables from S2 after fixup
--              run staging post condition checks
--
-- PRECONDITIONS: S2 fixed up
--
-- POSTCONDITIONS: See sp_pop_staging_tables_post_condition_checks
-- =============================================================
ALTER PROCEDURE [dbo].[sp_main_import_stage_07_pop_stging]
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35)   = 'MAIN_IMPRT_STG_07'

   EXEC sp_log 1, @fn, '00: starting';
   EXEC sp_register_call @fn;

   -----------------------------------------------------------------------------------
   -- Populate the staging tables
   -----------------------------------------------------------------------------------
   EXEC sp_log 2, @fn, '10:populating the staging tables';
   EXEC sp_pop_staging_tables;

   -----------------------------------------------------------------------------------
   -- Populate the staging tables post condition check
   -----------------------------------------------------------------------------------
   EXEC sp_log 2, @fn, '10: post condition checks: calling sp_pop_staging_tables_post_condition_checks';
   EXEC sp_pop_staging_tables_post_condition_checks;     -- Post condition chk

   EXEC sp_log 2, @fn, '90: processing complete';
   EXEC sp_log 1, @fn, '99: leaving';
END
/*
   EXEC sp_main_import_stage_07;
*/

GO
