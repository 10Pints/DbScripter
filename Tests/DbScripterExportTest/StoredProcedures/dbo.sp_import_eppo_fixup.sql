SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- Author:      Terry Watts
-- Create date: 11-Nov-2024
-- Description: does any required fixup to the Staging tables
--              before merging to the main EPPO tables
--
-- RESPONSIBILITIES:
-- RO1: standardising dates ready to import and be implicitly convertible to DATE
-- R02: remove unwanted languages, only want english and latin applies toNaes and Groups
--
-- POSTCONDITIONS:
-- POST 01: all creation and modification fields should be implicitlyconvertible to DATE
-- POST 02: only langages are {en, la}
-- CALLED BY: sp_import_eppo
-- ======================================================================================
CREATE   PROCEDURE [dbo].[sp_import_eppo_fixup]
AS
BEGIN
   SET NOCOUNT OFF;
   DECLARE
    @fn           VARCHAR(35) = 'sp_import_eppo_fixup'
   EXEC sp_log 2, @fn,'000: starting:';
   BEGIN TRY
      EXEC sp_log 1, @fn,'010: starting process';
      ----------------------------------------------------------
      -- EPPO_GafGroupStaging
      ----------------------------------------------------------
      EXEC sp_log 1, @fn,'020: fixup GafGroupStaging';
      DELETE FROM EPPO_GafGroupStaging WHERE lang NOT IN ('en', 'la');
      -- 1 row has wrapping single quotes
      UPDATE EPPO_GafGroupStaging SET fullname = REPLACE(fullname, '''', '') WHERE fullname like '%''%'; -- 241114: 1 row
      EXEC sp_eppo_fixup_stgng_dates 'EPPO_GafGroupStaging';
      ----------------------------------------------------------
      -- EPPO_GafLinkStaging
      ----------------------------------------------------------
      EXEC sp_log 1, @fn,'020: fixup EPPO_GafLinkStaging';
      EXEC sp_eppo_fixup_stgng_dates 'EPPO_GafLinkStaging';
      ----------------------------------------------------------
      -- GEPPO_afNameStaging
      ----------------------------------------------------------
      EXEC sp_log 1, @fn,'030: fixup EPPO_GafNameStaging';
      DELETE FROM EPPO_GafNameStaging WHERE lang NOT IN ('en', 'la');
      EXEC sp_eppo_fixup_stgng_dates 'EPPO_GafNameStaging';
      ----------------------------------------------------------
      -- EPPO_GaiGroupStaging
      ----------------------------------------------------------
      EXEC sp_log 1, @fn,'040: fixup EPPO_GaiGroupStaging';
      DELETE FROM EPPO_GaiGroupStaging WHERE lang NOT IN ('en', 'la');
      EXEC sp_eppo_fixup_stgng_dates 'EPPO_GaiGroupStaging';
      ----------------------------------------------------------
      -- EPPO_GaiLinkStaging
      ----------------------------------------------------------
      EXEC sp_log 1, @fn,'050: fixup EPPO_GaiLinkStaging';
      EXEC sp_eppo_fixup_stgng_dates 'EPPO_GaiLinkStaging';
      ----------------------------------------------------------
      -- EPPO_GaiNameStaging
      ----------------------------------------------------------
      EXEC sp_log 1, @fn,'060: fixup EPPO_GaiNameStaging';
      DELETE FROM EPPO_GaiNameStaging WHERE lang NOT IN ('en', 'la');
      EXEC sp_eppo_fixup_stgng_dates 'EPPO_GaiNameStaging';
      ----------------------------------------------------------
      -- EPPO_NtxLinkStaging
      ----------------------------------------------------------
      EXEC sp_log 1, @fn,'070: fixup EPPO_NtxLinkStaging';
      EXEC sp_eppo_fixup_stgng_dates 'EPPO_NtxLinkStaging';
      ----------------------------------
      -- EPPO_NtxNameStaging  --> NtxName
      ----------------------------------
      EXEC sp_log 1, @fn,'080: fixup EPPO_NtxNameStaging';
      DELETE FROM EPPO_NtxNameStaging WHERE lang NOT IN ('en', 'la');
      EXEC sp_eppo_fixup_stgng_dates 'EPPO_NtxNameStaging';
      ----------------------------------
      -- EPPO_PflGroupStaging --> PflGroup
      ----------------------------------
      EXEC sp_log 1, @fn,'090: fixup EPPO_PflGroupStaging';
      DELETE FROM EPPO_PflGroupStaging WHERE lang NOT IN ('en', 'la');
      EXEC sp_eppo_fixup_stgng_dates 'EPPO_PflGroupStaging';
      ----------------------------------
      -- EPPO_PflLinkStaging --> PflLink
      ----------------------------------
      EXEC sp_log 1, @fn,'100: fixup EPPO_PflLinkStaging';
      EXEC sp_eppo_fixup_stgng_dates 'EPPO_PflLinkStaging';
      ----------------------------------
      -- EPPO_PflNameStaging --> PflName
      ----------------------------------
      EXEC sp_log 1, @fn,'110: fixup PflNameStaging';
      DELETE FROM EPPO_PflNameStaging WHERE lang NOT IN ('en', 'la');
      EXEC sp_eppo_fixup_stgng_dates 'EPPO_PflNameStaging';
      ----------------------------------
      -- RepcoStaging    --> EPPO_Repco
      ----------------------------------
      EXEC sp_log 1, @fn,'120: fixup EPPO_RepcoStaging';
      EXEC sp_eppo_fixup_stgng_dates 'EPPO_RepcoStaging';
      ---------------------------------------------------------------
      -- Postcondition checks: delgated to sp_eppo_fixup_stgng_dates
      ---------------------------------------------------------------
      EXEC sp_log 1, @fn,'130: completed process';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH
   EXEC sp_log 2, @fn,'999: leaving:';
END
/*
EXEC sp_import_eppo_fixup;
*/
GO

