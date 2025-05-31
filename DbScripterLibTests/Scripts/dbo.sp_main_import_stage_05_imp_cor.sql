SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===============================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2024
-- Description: import the import correction files
-- ===============================================
ALTER PROCEDURE [dbo].[sp_main_import_stage_05_imp_cor]
    @import_root              NVARCHAR(450)  = 'D:\Dev\Repos\Farming\Data'
   ,@correction_file_inc_rng  NVARCHAR(MAX)
AS
BEGIN
   DECLARE
       @fn  NVARCHAR(35) = 'MAIN_IMPRT_STG_05'

   EXEC sp_log 1, @fn, '00: starting
import_root            :[', @import_root, ']
correction_file_inc_rng:[', @correction_file_inc_rng, ']'
;

   EXEC sp_register_call @fn;

   -----------------------------------------------------------------------------------
   -- Process
   -----------------------------------------------------------------------------------
   EXEC sp_log 2, @fn, '05: Import the import correction files';
   EXEC sp_import_corrections_file @import_root, @correction_file_inc_rng;

   -----------------------------------------------------------------------------------
   -- Process complete
   -----------------------------------------------------------------------------------
   EXEC sp_log 2, @fn, '80: processing complete';
   EXEC sp_log 1, @fn, '99: leaving';
END
/*
   EXEC sp_main_import_stage_05;
*/

GO
