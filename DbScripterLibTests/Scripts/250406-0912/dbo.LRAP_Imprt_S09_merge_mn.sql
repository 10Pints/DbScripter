SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ====================================================
-- Procedure:   dbo.LRAP_Imprt_S09_mrg_mn
-- Description: Merge the  mn tables <- staging tables
-- Author:      Terry Watts
-- Create date: 05-FEB-2024
--
-- PRECONDITIONS: Stage 06 ran ok
--
-- POSTCONDITIONS:
--    POST 01: main tables updated
-- ====================================================
ALTER PROCEDURE [dbo].[LRAP_Imprt_S09_merge_mn]
AS
BEGIN
   DECLARE
       @fn        VARCHAR(35)   = 'LRAP_Imprt_S09_merge_mn'

   EXEC sp_log 1, @fn, '00: starting';
   --EXEC sp_register_call @fn;

   -----------------------------------------------------------------------------------
   -- Merge the staging tables to the normalised tables
   -----------------------------------------------------------------------------------
   EXEC sp_log 1, @fn, '10: Merge the staging tables to the normalised tables';
   EXEC sp_merge_mn_tbls;--   EXEC sp_merge_normalised_tables;

   -----------------------------------------------------------------------------------
   -- POSTCONDITIONS: POST 01: main normalised_tables updated
   -----------------------------------------------------------------------------------
   EXEC sp_log 2, @fn, '90: processing complete';
   EXEC sp_log 1, @fn, '99: leaving OK';
END
/*
   EXEC LRAP_Imprt_S09_merge_mn;
*/

GO
