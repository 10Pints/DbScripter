SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==================================================================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2024
-- Description: does S2 fixup using the sp_fixup_s2 stored procedure not the xls
--              then caches Staging2->Staging3
-- ===============================================
ALTER PROCEDURE [dbo].[sp_main_import_stage_04_s2_fixup]
AS
BEGIN
   DECLARE
       @fn  NVARCHAR(35)  = 'MAIN_IMPRT_STG_04'

   BEGIN TRY
      EXEC sp_log 1, @fn, '00: starting';
      EXEC sp_register_call @fn;

      -----------------------------------------------------------------------------------
      -- S2 fixup using the sp_fixup_s2 stored procedure not the xls
      -----------------------------------------------------------------------------------
      IF EXISTS (SELECT 1 FROM staging2 WHERE entry_mode LIKE '%Early post-emergent%')
         EXEC ut.dbo.sp_raise_exception 58740, 'Early post-emergent now exists after stage 3', @fn=@fn;

      EXEC sp_log 1, @fn, '10: cache S2->S3';
      EXEC sp_fixup_s2;

      IF EXISTS (SELECT 1 FROM staging2 WHERE entry_mode LIKE '%Early post-emergent%')
         EXEC ut.dbo.sp_raise_exception 58741, 'Early post-emergent now exists after stage 3', @fn=@fn;

      -----------------------------------------------------------------------------------
      -- Cache a backup of Staging2 to Staging3
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '15: cache S2->S3';
      EXEC sp_copy_s2_s3;

      EXEC sp_log 2, @fn, '90: processing complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
   END CATCH

   EXEC sp_log 1, @fn, '99: leaving OK';
END
/*
SELECT COUNT(*) FROM staging1 WHERE entry_mode LIKE '%Early post-emergent%'
SELECT COUNT(*) FROM staging2 WHERE entry_mode LIKE '%Early post-emergent%'
EXEC sp_main_import_stage_04;
*/

GO
