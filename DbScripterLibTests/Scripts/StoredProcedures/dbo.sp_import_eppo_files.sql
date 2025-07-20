SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===================================================================================
-- Author:      Terry Watts
-- Create date: 11-Nov-2024
-- Description: Imports the group of eppo files into their resoective straaging tables
-- PRECONDITIONS: none
-- POSTCONDITIONS:
-- POST 01: all epp tables populated
--
-- Algorithm
-- Import the following tables from the f@older folder:
--    gafgroup, gaflink, gafname,
--    gaigroup, gailink, gainame,
--    ntxlink,  ntxname,
--    pflgroup, pfllink, pflname,
--    repco
--
-- The associated file names are:
--    gafgroup.txt, gaflink.txt, gafname.txt,
--    gaigroup.txt, gailink.txt, gainame.txt,
--    ntxlink.txt, ntxname.txt,
--    pflgroup.txt. pfllink.txt. pflname.txt,
--    repco.txt
--
-- CALLED BY: sp_import_eppo
-- ===================================================================================
CREATE PROCEDURE [dbo].[sp_import_eppo_files]
    @folder           VARCHAR(500)
   ,@field_terminator NCHAR(1)     = ','
   ,@exp_cnts         VARCHAR(2000)= NULL
   ,@display_tables   BIT          = 0

AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
    @fn           VARCHAR(35) = 'import_eppo_files'
   ,@row_cnt      INT
   ,@exp_row_cnt  INT
   ,@table        VARCHAR(60)
   ,@eppo         Eppo
   ;

   EXEC sp_log 2, @fn,'000: starting:
@folder:   [', @folder,   ']'
;
   BEGIN TRY
         -------------------------------------------------------------------------------------------
         -- 01: Validate parameters
         -------------------------------------------------------------------------------------------
         EXEC sp_log 1, @fn,'010: validating parameters';

         -------------------------------------------------------------------------------------------
         -- 02: Initialise
         -------------------------------------------------------------------------------------------

           -------------------------------------------------------------------------------------------
         -- 03: Process
         -------------------------------------------------------------------------------------------
         EXEC sp_log 1, @fn,'020: starting process';

         IF @exp_cnts IS NOT NULL
         BEGIN
            EXEC sp_log 1, @fn, '030: checking the expected row cnts   ';

            INSERT INTO @eppo(ordinal, [table], exp_row_cnt)
            SELECT ordinal, [table], exp_row_cnt
            FROM
            (
               SELECT ordinal, SUBSTRING(value, 1,CHARINDEX(':', value)-1) AS [table], SUBSTRING(value, CHARINDEX(':', value)+1, 900) AS [exp_row_cnt]
               FROM string_split(@exp_cnts, ',',1) as A
            ) X;
         END

         EXEC sp_log 1, @fn,'040: importing Eppo_GafGroup';
         SELECT @exp_row_cnt = exp_row_cnt FROM @eppo WHERE [table] = 'GafGroup'
         EXEC sp_import_eppo_file_helper
                @table           = 'Eppo_GafGroupStaging'
               ,@file            = 'Eppo_GafGroup.txt'
               ,@field_terminator= @field_terminator
               ,@non_null_flds   = 'identifier,datatype,code,lang,langno,preferred,status,creation,modification,country,fullname,authority,shortname'
               ,@folder          = @folder
               ,@display_table   = @display_tables
               ,@exp_row_cnt     = @exp_row_cnt
               ,@row_cnt         = @row_cnt OUT
               ;

         EXEC sp_log 1, @fn,'050: importing Eppo_GafName';
         SELECT @exp_row_cnt = exp_row_cnt FROM @eppo WHERE [table] = 'GafName'
         EXEC sp_import_eppo_file_helper
                @table           = 'Eppo_GafNameStaging'
               ,@file            = 'Eppo_GafName.txt'
               ,@field_terminator= @field_terminator
               ,@non_null_flds   = 'identifier,datatype,code,lang,langno,preferred,status,creation,modification,country,fullname,authority,shortname'
               ,@folder          = @folder
               ,@display_table   = @display_tables
               ,@exp_row_cnt     = @exp_row_cnt
               ,@row_cnt         = @row_cnt OUT
               ;

         EXEC sp_log 1, @fn,'060: importing Eppo_GaiGroup';
         SELECT @exp_row_cnt = exp_row_cnt FROM @eppo WHERE [table] = 'GaiGroup'
         EXEC sp_import_eppo_file_helper
                @table           = 'Eppo_GaiGroupStaging'
               ,@file            = 'Eppo_GaiGroup.txt'
               ,@field_terminator= @field_terminator
               ,@non_null_flds   = 'identifier,datatype,code,lang,langno,preferred,status,creation,modification,country,fullname,authority,shortname'
               ,@folder          = @folder
               ,@display_table   = @display_tables
               ,@exp_row_cnt     = @exp_row_cnt
               ,@row_cnt         = @row_cnt OUT
               ;

         EXEC sp_log 1, @fn,'070: importing Eppo_GafLink';
         SELECT @exp_row_cnt = exp_row_cnt FROM @eppo WHERE [table] = 'EPPO_GafLink'
         EXEC sp_import_eppo_file_helper
                @table           = 'Eppo_GafLinkStaging'
               ,@file            = 'Eppo_GafLink.txt'
               ,@field_terminator= @field_terminator
               ,@non_null_flds   = 'identifier,datatype,code,creation,modification,grp_dtype,grp_code'
               ,@folder          = @folder
               ,@display_table   = @display_tables
               ,@exp_row_cnt     = @exp_row_cnt
               ,@row_cnt         = @row_cnt OUT
               ;

         EXEC sp_log 1, @fn,'080: importing Eppo_GaiLink';
         SELECT @exp_row_cnt = exp_row_cnt FROM @eppo WHERE [table] = 'GaiLink'
         EXEC sp_import_eppo_file_helper
                @table           = 'Eppo_GaiLinkStaging'
               ,@file            = 'Eppo_GaiLink.txt'
               ,@field_terminator= @field_terminator
               ,@non_null_flds   = 'identifier,datatype,code,creation,modification,grp_dtype,grp_code'
               ,@folder          = @folder
               ,@display_table   = @display_tables
               ,@exp_row_cnt     = @exp_row_cnt
               ,@row_cnt         = @row_cnt OUT
               ;

         EXEC sp_log 1, @fn,'090: importing Eppo_GaiName';
         SELECT @exp_row_cnt = exp_row_cnt FROM @eppo WHERE [table] = 'GaiName'
         EXEC sp_import_eppo_file_helper
                @table           = 'Eppo_GaiNameStaging'
               ,@file            = 'Eppo_GaiName.txt'
               ,@field_terminator= @field_terminator
               ,@non_null_flds   = 'identifier,datatype,code,lang,langno,preferred,status,creation,modification,fullname,shortname'
               ,@folder          = @folder
               ,@display_table   = @display_tables
               ,@exp_row_cnt     = @exp_row_cnt
               ,@row_cnt         = @row_cnt OUT
               ;

         EXEC sp_log 1, @fn,'100: importing Eppo_NtxLink';
         SELECT @exp_row_cnt = exp_row_cnt FROM @eppo WHERE [table] = 'NtxLink'
         EXEC sp_import_eppo_file_helper
                @table           = 'Eppo_NtxLinkStaging'
               ,@file            = 'Eppo_NtxLink.txt'
               ,@field_terminator= @field_terminator
               ,@non_null_flds   = 'identifier,datatype,code,creation,modification,grp_dtype,grp_code'
               ,@folder          = @folder
               ,@display_table   = @display_tables
               ,@exp_row_cnt     = @exp_row_cnt
               ,@row_cnt         = @row_cnt OUT
               ;

         EXEC sp_log 1, @fn,'110: importing Eppo_NtxName';
         SELECT @exp_row_cnt = exp_row_cnt FROM @eppo WHERE [table] = 'NtxName'
         EXEC sp_import_eppo_file_helper
                @table           = 'Eppo_NtxNameStaging'
               ,@file            = 'Eppo_NtxName.txt'
               ,@field_terminator= @field_terminator
               ,@non_null_flds   = 'identifier,datatype,code,lang,langno,preferred,status,creation,modification,country,fullname,authority,shortname'
               ,@folder          = @folder
               ,@display_table   = @display_tables
               ,@exp_row_cnt     = @exp_row_cnt
               ,@row_cnt         = @row_cnt OUT
               ;

         EXEC sp_log 1, @fn,'120: importing Eppo_PflGroup';
         SELECT @exp_row_cnt = exp_row_cnt FROM @eppo WHERE [table] = 'PflGroup'
         EXEC sp_import_eppo_file_helper
                @table           = 'Eppo_PflGroupStaging'
               ,@file            = 'Eppo_PflGroup.txt'
               ,@field_terminator= @field_terminator
               ,@non_null_flds   = 'identifier,datatype,code,lang,langno,preferred,status,creation,modification,country,fullname,authority,shortname'
               ,@folder          = @folder
               ,@display_table   = @display_tables
               ,@exp_row_cnt     = @exp_row_cnt
               ,@row_cnt         = @row_cnt OUT
               ;

         EXEC sp_log 1, @fn,'130: importing Eppo_PflLink';
         SELECT @exp_row_cnt = exp_row_cnt FROM @eppo WHERE [table] = 'PflLink'
         EXEC sp_import_eppo_file_helper
                @table           = 'Eppo_PflLinkStaging'
               ,@file            = 'Eppo_PflLink.txt'
               ,@field_terminator= @field_terminator
               ,@non_null_flds   = 'identifier,datatype,code,creation,modification,grp_dtype,grp_code'
               ,@folder          = @folder
               ,@display_table   = @display_tables
               ,@exp_row_cnt     = @exp_row_cnt
               ,@row_cnt         = @row_cnt OUT
               ;

         EXEC sp_log 1, @fn,'140: importing Eppo_PflName';
         SELECT @exp_row_cnt = exp_row_cnt FROM @eppo WHERE [table] = 'PflName'
         EXEC sp_import_eppo_file_helper
                @table           = 'Eppo_PflNameStaging'
               ,@file            = 'Eppo_PflName.txt'
               ,@field_terminator= @field_terminator
               ,@non_null_flds   = 'identifier,datatype,code,lang,langno,preferred,status,creation,modification,country,fullname,authority,shortname'
               ,@folder          = @folder
               ,@display_table   = @display_tables
               ,@exp_row_cnt     = @exp_row_cnt
               ,@row_cnt         = @row_cnt OUT
               ;

         EXEC sp_log 1, @fn,'150: importing Eppo_Repco';
         SELECT @exp_row_cnt = exp_row_cnt FROM @eppo WHERE [table] = 'Repco'
         EXEC sp_import_eppo_file_helper
                @table           = 'Eppo_RepcoStaging'
               ,@file            = 'Eppo_Repco.txt'
               ,@field_terminator= @field_terminator
               ,@non_null_flds   = 'identifier,datatype,code,statuslink,creation,modification,grp_dtype,grp_code'
               ,@folder          = @folder
               ,@display_table   = @display_tables
               ,@exp_row_cnt     = @exp_row_cnt
               ,@row_cnt         = @row_cnt OUT
               ;

            -------------------------------------------------------------------------------------------
         -- 04: Check postconditions
         -------------------------------------------------------------------------------------------
         EXEC sp_log 1, @fn,'160: validating postconditions';
         -- POST 01: all epp tables populated
         EXEC sp_assert_tbl_pop 'EPPO_gafgroupStaging';
         EXEC sp_assert_tbl_pop 'EPPO_gaflinkStaging';
         EXEC sp_assert_tbl_pop 'EPPO_gafnameStaging';
         EXEC sp_assert_tbl_pop 'EPPO_gaigroupStaging';
         EXEC sp_assert_tbl_pop 'EPPO_gailinkStaging';
         EXEC sp_assert_tbl_pop 'EPPO_gainameStaging';
         EXEC sp_assert_tbl_pop 'EPPO_ntxlinkStaging';
         EXEC sp_assert_tbl_pop 'EPPO_ntxnameStaging';
         EXEC sp_assert_tbl_pop 'EPPO_pflgroupStaging';
         EXEC sp_assert_tbl_pop 'EPPO_pfllinkStaging';
         EXEC sp_assert_tbl_pop 'EPPO_pflnameStaging';
         EXEC sp_assert_tbl_pop 'EPPO_repcoStaging';

            -------------------------------------------------------------------------------------------
         -- 05: Process complete
         -------------------------------------------------------------------------------------------
         EXEC sp_log 1, @fn,'900: process complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn, ' 550: ';
      THROW;
   END CATCH

   EXEC sp_log 2, @fn,'999: leaving:';
END
/*
exec sp_import_eppo_files 'D:\Dev\Farming\Data\EPPO.bayer';

EXEC tSQLt.Run 'test.test_021_sp_import_eppo';
SELECT * FROM gailinkStaging;
*/

GO
