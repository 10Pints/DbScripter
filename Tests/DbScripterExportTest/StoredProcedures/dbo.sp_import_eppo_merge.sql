SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================================
-- Author:      Terry Watts
-- Create date: 13-Nov-2024
-- Description: merges the EPPO staging tables to the main EPPO tables
--
-- Algorithm:
-- The merge map for the EPPO tables is as follows:
--     EPPO_gafgroupStaging --> EPPO_gafgroup
--    ,EPPO_gaflinkStaging  --> EPPO_gaflink
--    ,EPPO_gafnameStaging  --> EPPO_gafname
--    ,EPPO_gaigroupStaging --> EPPO_gaigroup
--    ,EPPO_gailinkStaging  --> EPPO_gailink
--    ,EPPO_gainameStaging  --> EPPO_gainame
--    ,EPPO_ntxlinkStaging  --> EPPO_ntxlink
--    ,EPPO_ntxnameStaging  --> EPPO_ntxname
--    ,EPPO_pflgroupStaging --> EPPO_pflgroup
--    ,EPPO_pfllink Staging --> EPPO_pfllink
--    ,EPPO_pflname Staging --> EPPO_pflname
--    ,EPPO_repcoStaging    --> EPPO_repco
--
-- PRECONDITIONS:
-- PRE 01:the following tables are populated: or exception 71500, <table not populated>
--     EPPO_gafgroupStaging
--    ,EPPO_gaflinkStaging
--    ,EPPO_gafnameStaging
--    ,EPPO_gaigroupStaging
--    ,EPPO_gailinkStaging 
--    ,EPPO_gainameStaging 
--    ,EPPO_ntxlinkStaging 
--    ,EPPO_ntxnameStaging 
--    ,EPPO_pflgroupStaging
--    ,EPPO_pfllink Staging
--    ,EPPO_pflname Staging
--    ,EPPO_repcoStaging
-- POSTCONDITIONS
-- POST01: the following tables are or exception 71501, <table not populated>
--      EPPO_gafgroup
--      EPPO_gaflink
--      EPPO_gafname
--      EPPO_gaigroup
--      EPPO_gailink
--      EPPO_gainame
--      EPPO_ntxlink
--      EPPO_ntxname
--      EPPO_pflgroup
--      EPPO_pfllink
--      EPPO_pflname
--      EPPO_repco
-- CALLED BY: sp_import_eppo
-- =====================================================================
CREATE PROCEDURE [dbo].[sp_import_eppo_merge]
   @display_table    BIT = 0
AS
BEGIN
   SET NOCOUNT OFF;
   DECLARE
    @fn           VARCHAR(35) = 'sp_import_eppo_merge'
   EXEC sp_log 1, @fn,'000: starting:';
   BEGIN TRY
      ----------------------------------------------
      -- Validate precondition 
      ----------------------------------------------
      EXEC sp_log 1, @fn,'010: validating preconditions';
      -- PRE 01:the following tables are populated: or exception 71500, <table not populated>
      EXEC sp_assert_tbl_pop 'EPPO_gafgroupStaging',@ex_num=71500, @ex_msg = 'pre cndtn';
      EXEC sp_assert_tbl_pop 'EPPO_gaflinkStaging ',@ex_num=71500, @ex_msg = 'pre cndtn';
      EXEC sp_assert_tbl_pop 'EPPO_gafnameStaging ',@ex_num=71500, @ex_msg = 'pre cndtn';
      EXEC sp_assert_tbl_pop 'EPPO_gaigroupStaging',@ex_num=71500, @ex_msg = 'pre cndtn';
      EXEC sp_assert_tbl_pop 'EPPO_gailinkStaging ',@ex_num=71500, @ex_msg = 'pre cndtn';
      EXEC sp_assert_tbl_pop 'EPPO_gainameStaging ',@ex_num=71500, @ex_msg = 'pre cndtn';
      EXEC sp_assert_tbl_pop 'EPPO_ntxlinkStaging ',@ex_num=71500, @ex_msg = 'pre cndtn';
      EXEC sp_assert_tbl_pop 'EPPO_ntxnameStaging ',@ex_num=71500, @ex_msg = 'pre cndtn';
      EXEC sp_assert_tbl_pop 'EPPO_pflgroupStaging',@ex_num=71500, @ex_msg = 'pre cndtn';
      EXEC sp_assert_tbl_pop 'EPPO_pfllinkStaging' ,@ex_num=71500, @ex_msg = 'pre cndtn';
      EXEC sp_assert_tbl_pop 'EPPO_pflnameStaging' ,@ex_num=71500, @ex_msg = 'pre cndtn';
      EXEC sp_assert_tbl_pop 'EPPO_repcoStaging'   ,@ex_num=71500, @ex_msg = 'pre cndtn';
      ----------------------------------------------
      -- ASSERTION preconditions Validatated
      ----------------------------------------------
      EXEC sp_log 1, @fn,'020: ASSERTION preconditions Validatated';
      ----------------------------------------------
      -- 03: Process
      ----------------------------------------------
      EXEC sp_log 1, @fn,'030: starting process ';
      ----------------------------------
      -- GafGroupStaging --> GafGroup
         ----------------------------------
      EXEC sp_log 1, @fn,'040: merging GafGroup';
      DELETE FROM EPPO_GafGroup;
      MERGE EPPO_GafGroup as target
      USING
      (
         SELECT identifier, datatype, code, lang, langno, preferred, [status], creation, modification, country, fullname, authority, shortname
         FROM EPPO_GafGroupStaging
      ) AS S
      ON target.identifier = S.identifier
      WHEN NOT MATCHED BY target THEN
         INSERT ( identifier, datatype, code, lang, langno, preferred, [status], creation, modification, country, fullname, authority, shortname)
         VALUES ( identifier, datatype, code, lang, langno, preferred, [status], creation, modification, country, fullname, authority, shortname)
      ;
      IF @display_table =1 SELECT TOP 200 * FROM EPPO_GafGroup;
      ----------------------------------
--    GafLinkStaging --> GafLink
      ----------------------------------
      EXEC sp_log 1, @fn,'050: merging gaflink';
      DELETE FROM EPPO_GafLink;
      MERGE EPPO_GafLink as target
      USING
      (
         SELECT identifier, datatype, code, creation, modification, grp_dtype, grp_code
         FROM EPPO_GafLinkStaging
      ) AS S
      ON target.identifier = S.identifier
      WHEN NOT MATCHED BY target THEN
         INSERT (identifier, datatype, code, creation, modification, grp_dtype, grp_code)
         VALUES (identifier, datatype, code, creation, modification, grp_dtype, grp_code)
      ;
      IF @display_table =1 SELECT TOP 200 * FROM EPPO_Gaflink;
      ----------------------------------
--    GafNameStaging  --> GafName
      ----------------------------------
      EXEC sp_log 1, @fn,'060: merging GafName';
      DELETE FROM EPPO_GafName;
      MERGE EPPO_GafName as target
      USING
      (
         SELECT identifier, datatype, code, lang, langno,preferred,status,creation, modification,country,fullname,authority,shortname
         FROM EPPO_GafNameStaging
      ) AS S
      ON target.identifier = S.identifier
      WHEN NOT MATCHED BY target THEN
         INSERT (identifier, datatype, code, lang, langno,preferred,status,creation, modification,country,fullname,authority,shortname)
         VALUES (identifier, datatype, code, lang, langno,preferred,status,creation, modification,country,fullname,authority,shortname)
      ;
      IF @display_table =1 SELECT TOP 200 * FROM EPPO_GafName;
      ----------------------------------
--    GaiGroupStaging --> GaiGroup
      ----------------------------------
      EXEC sp_log 1, @fn,'070: merging GaiGroup';
      DELETE FROM EPPO_GaiGroup;
      MERGE EPPO_GaiGroup as target
      USING
      (
         SELECT identifier, datatype, code, lang, langno,preferred,status,creation, modification,country,fullname,authority,shortname
         FROM EPPO_GaiGroupStaging
      ) AS S
      ON target.identifier = S.identifier
      WHEN NOT MATCHED BY target THEN
         INSERT (identifier, datatype, code, lang, langno,preferred,status,creation, modification,country,fullname,authority,shortname)
         VALUES (identifier, datatype, code, lang, langno,preferred,status,creation, modification,country,fullname,authority,shortname)
      ;
      IF @display_table =1 SELECT TOP 200 * FROM EPPO_Gaigroup;
      ----------------------------------
--    GaiLinkStaging --> GaiLink
      ----------------------------------
      EXEC sp_log 1, @fn,'080: merging GaiLink';
      DELETE FROM EPPO_GaiLink;
      MERGE EPPO_GaiLink as target
      USING
      (
         SELECT identifier, datatype, code, creation, modification
         FROM EPPO_GaiLinkStaging
      ) AS S
      ON target.identifier = S.identifier
      WHEN NOT MATCHED BY target THEN
         INSERT (identifier, datatype, code, creation, modification)
         VALUES (identifier, datatype, code, creation, modification)
      ;
      SELECT TOP 200 * FROM EPPO_Gailink;
      ----------------------------------
--    GaiNameStaging --> GaiName
      ----------------------------------
      EXEC sp_log 1, @fn,'090: merging GaiName';
      DELETE FROM EPPO_GaiName;
      MERGE EPPO_GaiName as target
      USING
      (
         SELECT identifier, datatype, code, creation, modification
         FROM EPPO_GaiNameStaging
      ) AS S
      ON target.identifier = S.identifier
      WHEN NOT MATCHED BY target THEN
         INSERT (identifier, datatype, code, creation, modification)
         VALUES (identifier, datatype, code, creation, modification)
      ;
      IF @display_table =1 SELECT TOP 200 * FROM EPPO_GaiName;
      ----------------------------------
--    NtxLinkStaging --> NtxLink
      ----------------------------------
      EXEC sp_log 1, @fn,'100: merging NtxLink';
      DELETE FROM EPPO_NtxLink;
      MERGE EPPO_NtxLink as target
      USING
      (
         SELECT identifier, datatype, code, creation, modification,grp_dtype,grp_code
         FROM EPPO_NtxLinkStaging
      ) AS S
      ON target.identifier = S.identifier
      WHEN NOT MATCHED BY target THEN
         INSERT (identifier, datatype, code, creation, modification,grp_dtype,grp_code)
         VALUES (identifier, datatype, code, creation, modification,grp_dtype,grp_code)
      ;
      IF @display_table =1 SELECT TOP 200 * FROM EPPO_NtxLink;
      ----------------------------------
--    NtxNameStaging  --> NtxName
      ----------------------------------
      EXEC sp_log 1, @fn,'110: merging NtxName';
      DELETE FROM EPPO_NtxName;
      MERGE EPPO_NtxName as target
      USING
      (
         SELECT identifier, datatype, code, lang, langno,preferred,status,creation, modification,country,fullname,authority,shortname
         FROM EPPO_NtxNameStaging
      ) AS S
      ON target.identifier = S.identifier
      WHEN NOT MATCHED BY target THEN
         INSERT (identifier, datatype, code, lang, langno,preferred,status,creation, modification,country,fullname,authority,shortname)
         VALUES (identifier, datatype, code, lang, langno,preferred,status,creation, modification,country,fullname,authority,shortname)
      ;
      IF @display_table =1 SELECT TOP 200 * FROM EPPO_NtxName;
      ----------------------------------
--    PflGroupStaging --> PflGroup
      ----------------------------------
      EXEC sp_log 1, @fn,'120: merging PflGroup';
      DELETE FROM EPPO_PflGroup;
      MERGE EPPO_PflGroup as target
      USING
      (
         SELECT identifier, datatype, code, lang, langno,preferred,status,creation, modification,country,fullname,authority,shortname
         FROM EPPO_PflGroupStaging
      ) AS S
      ON target.identifier = S.identifier
      WHEN NOT MATCHED BY target THEN
         INSERT (identifier, datatype, code, lang, langno,preferred,status,creation, modification,country,fullname,authority,shortname)
         VALUES (identifier, datatype, code, lang, langno,preferred,status,creation, modification,country,fullname,authority,shortname)
      ;
      IF @display_table =1 SELECT TOP 200 * FROM EPPO_PflGroup;
      ----------------------------------
--    PflLinkStaging --> PflLink
      ----------------------------------
      EXEC sp_log 1, @fn,'130: merging PflLink';
      DELETE FROM EPPO_PflLink;
      MERGE EPPO_PflLink as target
      USING
      (
         SELECT identifier, datatype, code, creation, modification,grp_dtype,grp_code
         FROM EPPO_PflLinkStaging
      ) AS S
      ON target.identifier = S.identifier
      WHEN NOT MATCHED BY target THEN
         INSERT (identifier, datatype, code, creation, modification,grp_dtype,grp_code)
         VALUES (identifier, datatype, code, creation, modification,grp_dtype,grp_code)
      ;
      IF @display_table =1 SELECT TOP 200 * FROM EPPO_PflLink;
      ----------------------------------
--    PflNameStaging --> PflName
      ----------------------------------
      EXEC sp_log 1, @fn,'140: merging PflName';
      DELETE FROM EPPO_PflName;
      MERGE EPPO_PflName as target
      USING
      (
         SELECT identifier, datatype, code, lang, langno,preferred,status,creation, modification,country,fullname,authority,shortname
         FROM EPPO_PflNameStaging
      ) AS S
      ON target.identifier = S.identifier
      WHEN NOT MATCHED BY target THEN
         INSERT (identifier, datatype, code, lang, langno,preferred,status,creation, modification,country,fullname,authority,shortname)
         VALUES (identifier, datatype, code, lang, langno,preferred,status,creation, modification,country,fullname,authority,shortname)
      ;
      IF @display_table =1 SELECT TOP 200 * FROM EPPO_PflName;
      ----------------------------------
--    RepcoStaging    --> Repco
      ----------------------------------
      EXEC sp_log 1, @fn,'150: merging Repco';
      DELETE FROM EPPO_Repco;
      MERGE EPPO_Repco as target
      USING
      (
         SELECT identifier, datatype, code, statuslink,creation, modification,grp_dtype,grp_code
         FROM EPPO_RepcoStaging
      ) AS S
      ON target.identifier = S.identifier
      WHEN NOT MATCHED BY target THEN
         INSERT (identifier, datatype, code, statuslink,creation, modification,grp_dtype,grp_code)
         VALUES (identifier, datatype, code, statuslink,creation, modification,grp_dtype,grp_code)
      ;
      IF @display_table =1 SELECT TOP 200 * FROM EPPO_Repco;
      -------------------------------------------------------------------------------------------
      -- 04: Check postconditions
      -------------------------------------------------------------------------------------------
      -- POST01: All tables populated
      EXEC sp_log 1, @fn,'160: validating postconditions'
      EXEC sp_assert_tbl_pop 'EPPO_GafGroup'       , @ex_num=71501, @ex_msg = 'post cndtn';
      EXEC sp_assert_tbl_pop 'EPPO_GafLinkStaging' , @ex_num=71501, @ex_msg = 'post cndtn';
      EXEC sp_assert_tbl_pop 'EPPO_GafNameStaging' , @ex_num=71501, @ex_msg = 'post cndtn';
      EXEC sp_assert_tbl_pop 'EPPO_GaiGroupStaging', @ex_num=71501, @ex_msg = 'post cndtn';
      EXEC sp_assert_tbl_pop 'EPPO_GaiLinkStaging' , @ex_num=71501, @ex_msg = 'post cndtn';
      EXEC sp_assert_tbl_pop 'EPPO_GaiNameStaging' , @ex_num=71501, @ex_msg = 'post cndtn';
      EXEC sp_assert_tbl_pop 'EPPO_NtxLinkStaging' , @ex_num=71501, @ex_msg = 'post cndtn';
      EXEC sp_assert_tbl_pop 'EPPO_NtxNameStaging' , @ex_num=71501, @ex_msg = 'post cndtn';
      EXEC sp_assert_tbl_pop 'EPPO_PflGroupStaging', @ex_num=71501, @ex_msg = 'post cndtn';
      EXEC sp_assert_tbl_pop 'EPPO_PflLinkStaging' , @ex_num=71501, @ex_msg = 'post cndtn';
      EXEC sp_assert_tbl_pop 'EPPO_PflNameStaging' , @ex_num=71501, @ex_msg = 'post cndtn';
      EXEC sp_assert_tbl_pop 'EPPO_RepcoStaging'   , @ex_num=71501, @ex_msg = 'post cndtn';
      -------------------------------------------------------------------------------------------
      -- 05: Process complete
      -------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'300: process complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn, ' 550: ';
      THROW;
   END CATCH
   EXEC sp_log 2, @fn,'999: leaving:';
END
/*
EXEC tSQLt.Run 'test.test_006_sp_import_eppo_merge';
EXEC tSQLt.RunAll;
*/
GO

