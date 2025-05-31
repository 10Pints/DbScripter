SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 08-OCT-2023
-- Description: Handles the bulk import of the PathogenType.xlsx/txt file
-- NB this is the STATIC DATA: pathogen types not the dynamic data: pathogenTypeStaging
-- the list of pthogen types - Fungus, insec, mollusc
--
-- ALGORITHM:
--    Delete the log files if they exist
--    TRUNCATE the table
--    Bulk insert the file
--    Check the table is populated
--    Do any fixup
--
-- PRECONDITIONS:
--    PathogenTypeStaging table dependents have been creared
--
-- POSTCONDITIONS:
-- POST01: PathogenTypeStaging populated AND retur= 0 or RC = error code
--
-- CALLED BY: 
--
-- TESTS:
--
-- CHANGES:
-- 231103: turned auto increment off so SET IDENTITY_INSERT ON/OFF not needed
-- 240223: import either tsv or xlsx
-- ==============================================================================
ALTER PROCEDURE [dbo].[sp_import_pathogenTypeStaging]
    @import_file   NVARCHAR(500)
AS
BEGIN
   DECLARE
       @fn  NVARCHAR(35)  = N'IMPRT PATHOGENTYPE STAGING'
      ,@sql NVARCHAR(MAX)
      ,@error_msg NVARCHAR(MAX) = NULL
      ,@import_root NVARCHAR(MAX)
      ;

   SET NOCOUNT OFF
   BEGIN TRY
      SET @import_root = Ut.dbo.fnGetImportRoot();
      EXEC sp_log 1, @fn, '00: starting, @import_file: [',@import_file,']';

      EXEC sp_register_call @fn;
      EXEC sp_log 1, @fn, '05: deleting bulk import log files:  D:\Logs\ImportPathogenType_SD.log and .log.Error.Txt';

      EXEC xp_cmdshell 'DEL D:\Logs\ImportPathogenType.log.Error_SD.Txt', NO_OUTPUT;
      EXEC xp_cmdshell 'DEL D:\Logs\ImportPathogenType_SD.log'          , NO_OUTPUT;

      EXEC sp_log 1, @fn, '10: clearing PathogenTypeStaging table';
      DELETE FROM PathogenTypeStaging;

      -------------------------------------------------------------------------------------------
      -- 240223: import either tsv or xlsx
      -------------------------------------------------------------------------------------------
      IF( CHARINDEX('.xlsx', @import_file) = 0)
      BEGIN
         -- csv file
         EXEC sp_log 1, @fn, '15: importing tsv file';

      SET @sql = CONCAT(
     'BULK INSERT [dbo].[PathogenTypeStaging] FROM ', @import_file, '
      WITH
      (
         FIRSTROW        = 2
        ,ERRORFILE       = ''D:\Logs\ImportPathogenType_SD.log''
        ,FIELDTERMINATOR = ''\t''
        ,ROWTERMINATOR   = ''\n''
      );
   ');
      END
      ELSE
      BEGIN
         -- xlsx file
         EXEC sp_log 1, @fn, '20: importing xlsx file';
         SET @sql = Ut.dbo.fnCrtOpenRowsetSqlForXlsx('PathogenTypeStaging', 'id, Pathogen, [Type]', @import_file, 'PathogenType$', 0);
      END
      --------------------------------- END  240223: import either tsv or xlsx ----------------------

      EXEC sp_log 1, @fn, '25: running import cmd';
      EXEC sp_log 1, @fn, @sql;
      EXEC sp_executesql @sql;
      --EXEC sp_log 1, @fn, '30: completed bulk import cmd OK, recreating relation: FK_Pathogen_PathogenType';

      EXEC sp_log 1, @fn, '35';

      -------------------------------------------------------------------------------
      -- Check post conditions
      -------------------------------------------------------------------------------
      -- Check the table is populated
      EXEC sp_chk_tbl_populated 'PathogenTypeStaging';

      -------------------------------------------------------------------------------
      -- Completed processing OK
      -------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '40: completed processing OK';
   END TRY
   BEGIN CATCH
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, '50: Caught exception: ', @error_msg;
      ALTER TABLE [dbo].[Pathogen]  WITH CHECK ADD  CONSTRAINT [FK_Pathogen_PathogenType] FOREIGN KEY([pathogen_type_id])  REFERENCES [dbo].[PathogenType] ([id]);
      ALTER TABLE [dbo].[Pathogen] CHECK CONSTRAINT [FK_Pathogen_PathogenType];
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '99: leaving OK';
END
/*
EXEC sp_import_pathogenTypeStaging 'D:\Dev\Repos\Farming\Data\PathogenType.txt';
*/


GO
