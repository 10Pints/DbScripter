SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


--==========================================================================================================================================================
-- Author:           Terry Watts
-- Create date:      04-Dec-2024
-- Description: merge helper for sp_import_eppo_merge
--
--
-- Algorithm
--==========================================================================================================================================================
CREATE   PROCEDURE [dbo].[sp_sp_import_eppo_merge_hlpr]
    @table           VARCHAR(60)
   ,@fields          VARCHAR(3000) -- comma sepreted list
   ,@display_tables  BIT         = 1
AS
BEGIN
DECLARE
    @fn              VARCHAR(35)= 'sp_sp_import_eppo_merge_hlpr' 
   ,@sql             VARCHAR(4000)

   EXEC sp_log 2, @fn,'000: starting:';
   BEGIN TRY
      ----------------------------------------------
      -- 03: Process
      ----------------------------------------------
      EXEC sp_log 1, @fn,'030: starting process ';

      ----------------------------------
      -- GafGroupStaging --> GafGroup
         ----------------------------------
      EXEC sp_log 1, @fn,'040: merging GafGroup';
      SET @sql = CONCAT('DELETE FROM [', @table,']');
      EXEC(@sql);

      --DELETE FROM EPPO_GafGroup;

      SET @sql = CONCAT('MERGE[',@table,']as target
      USING
      (
         SELECT ', @fields, ' 
         FROM [', @table,']
      ) AS S
      ON target.identifier = S.identifier
      WHEN NOT MATCHED BY target THEN
         INSERT ( ', @fields, ')
         VALUES ( ', @fields, ')
      ;'
      );

      EXEC(@sql);

      IF @display_tables =1
      BEGIN
         SET @sql = CONCAT('SELECT TOP 200 * FROM [', @table,']');
         EXEC(@sql);
      END

      EXEC sp_assert_tbl_pop @table;
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
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_021_sp_import_eppo';
*/


GO
