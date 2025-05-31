SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2024
-- Description: Merge the staging tables to the normalised tables
--
-- PRECONDITIONS: Stage 06 ran ok
--
-- POSTCONDITIONS:
--    POST 01: main normalised_tables updated
-- ==============================================================
ALTER PROCEDURE [dbo].[sp_main_import_stage_08_mrg_mn]
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35)   = 'MAIN_IMPRT_STG_08'

   EXEC sp_log 1, @fn, '00: starting';
   EXEC sp_register_call @fn;

   -----------------------------------------------------------------------------------
   -- Merge the staging tables to the normalised tables
   -----------------------------------------------------------------------------------
   EXEC sp_log 1, @fn, '10: Merge the staging tables to the normalised tables';
   EXEC sp_merge_normalised_tables;

   -----------------------------------------------------------------------------------
   -- POSTCONDITIONS: POST 01: main normalised_tables updated
   -----------------------------------------------------------------------------------
   EXEC sp_log 2, @fn, '90: processing complete';
   EXEC sp_log 1, @fn, '99: leaving OK';
END
/*
   EXEC sp_main_import_stage_08 @import_id;
*/

GO
