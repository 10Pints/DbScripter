SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================================================
-- Author:      Terry Watts
-- Create date: 21-AUG-2023
-- Description: Stage 2 company fixup
--
-- CHANGES:
-- 05-MAR-2024: added 'Sinochem Crop Protection (phils.) Inc.' -> 'Sinochem'
-- =============================================================================
ALTER PROCEDURE [dbo].[sp_fixup_s2_company]
     @fixup_cnt       INT = NULL OUT
AS
BEGIN
   SET NOCOUNT OFF
   DECLARE
       @fn              NVARCHAR(35) = 'FIXUP S2 COMPANY'

   --SET @fixup_cnt = Ut.dbo.fnGetSessionContextAsInt(N'fixup count');
   EXEC sp_log 2, @fn, '01: starting, @fixup_cnt: ',@fixup_cnt;
   EXEC sp_register_call @fn;

   UPDATE staging2 SET company = '2HJL Development Co.'   WHERE Company = '2hjl Development Co.';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   UPDATE staging2 SET company = 'B.M.Cusipag Agri Trade' WHERE Company = 'B.m. Cusipag Agri Trade' ;
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   UPDATE staging2 SET company = 'Sinochem'   WHERE Company = 'Sinochem Crop Protection (phils.) Inc.';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   EXEC sp_log 2, @fn, '99: leaving, @fixup_cnt: ',@fixup_cnt;
END
/*
DECLARE @fixup_cnt       INT = 0
EXEC sp_fixup_s2_company  @fixup_cnt  OUT
PRINT CONCAT('@fixup_cnt: ', @fixup_cnt);
*/

GO
