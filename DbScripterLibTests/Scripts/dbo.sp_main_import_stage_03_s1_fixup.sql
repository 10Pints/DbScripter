SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===============================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2024
-- Description: does S1 fixup then copies S1->S2
-- ===============================================
ALTER PROCEDURE [dbo].[sp_main_import_stage_03_s1_fixup]
AS
BEGIN
   DECLARE
       @fn  NVARCHAR(35) = 'MAIN_IMPRT_STG_03'

   EXEC sp_log 1, @fn, '00: starting';
   EXEC sp_register_call @fn;
   EXEC sp_log 2, @fn, '05: calling fixup_s1';
   -----------------------------------------------------------------------------------
   -- S1 fixup
   -----------------------------------------------------------------------------------
   EXEC sp_fixup_s1;

   -----------------------------------------------------------------------------------
   -- Copiy S1->S2
   -----------------------------------------------------------------------------------
   EXEC sp_copy_s1_s2;

   EXEC sp_log 2, @fn, '10: complete';
   EXEC sp_log 1, @fn, '99: leaving';
END
/*
   EXEC sp_main_import_stage_05;
*/

GO
