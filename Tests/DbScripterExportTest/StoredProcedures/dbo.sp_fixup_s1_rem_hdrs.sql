SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 16-JUL-2023
-- Description: Removes the page headers and 
-- other occasional headers
-- =============================================
CREATE PROCEDURE [dbo].[sp_fixup_s1_rem_hdrs]
      @fixup_cnt       INT = NULL OUT
AS
BEGIN
   DECLARE
       @fn              VARCHAR(35) = 'FIXUP sp_fixup_s1_rem_hdrs REM HDRS'
   SET NOCOUNT OFF;
   BEGIN TRY
      IF @fixup_cnt IS NULL SET @fixup_cnt = dbo.fnGetSessionContextAsInt(N'fixup count');
      EXEC sp_log 1, @fn, '000: starting, @fixup_cnt: ',@fixup_cnt
      EXEC sp_log 1, @fn, '010: Remove page header rows'
      EXEC sp_delete '%NAME OF COMPANY%'            , 'company', 'staging1';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_delete '%REPUBLIC OF THE PHILIPPINES%', 'company', 'staging1';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '030: Removing rows where company LIKE REPUBLIC OF THE PHILIPPINES'
      EXEC sp_delete '%REPUBLIC OF THE PHILIPPINES%', 'company', 'staging1';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '040: Removing rows where company LIKE DEPARTMENT OF AGRICULTURE'
      EXEC sp_delete '%NAME OF COMPANY%'     , 'company', 'staging1';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 0, @fn, '050: Removing rows where company LIKE DEPARTMENT OF AGRICULTURE'
      EXEC sp_delete '%Department Of Agriculture%'     , 'company', 'staging1';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 0, @fn, '060: Removing rows where company LIKE FERTILIZER AND PESTICIDE AUTHORITY'
      EXEC sp_delete '%FERTILIZER AND PESTICIDE AUTHORITY%', 'company', 'staging1';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 0, @fn, '070: sp_fixup_staging1: Removing rows where company LIKE LIST OF REGISTERED AGRICULTURAL PESTICIDES'
      EXEC sp_delete '%LIST OF REGISTERED AGRICULTURAL PESTICIDES%', 'company', 'staging1';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '080: DELETE ''as of %'' rows'
      EXEC sp_delete '%as of %', 'company', 'staging1';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 1, @fn, '090: DELETE null company,ingredient,product'
      DELETE FROM staging1 WHERE company IS NULL AND product IS NULL AND ingredient IS NULL;
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn, '@fixup_cnt: ',@fixup_cnt;
      THROW;
   END CATCH
      
   EXEC sp_log 2, @fn, '99: leaving, @fixup_cnt: ',@fixup_cnt
END
/*
EXEC sp_fixup_s1_rem_hdrs
SELECT * FROM staging1 where pathogens LIKE  '% and and %'
*/
GO

