SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:		 Terry Watts
-- Create date: 16-JUL-2023
-- Description: Removes the page headers and 
-- other occasional headers
-- =============================================
ALTER PROCEDURE [dbo].[sp_fixup_s1_rem_hdrs]
      @fixup_cnt       INT = NULL OUT
AS
BEGIN
   DECLARE
       @fn              NVARCHAR(35) = 'FIXUP STG1 REM HDRS'

   BEGIN TRY

      IF @fixup_cnt IS NULL SET @fixup_cnt = Ut.dbo.fnGetSessionContextAsInt(N'fixup count');
      EXEC sp_log 2, @fn, '01: starting, @fixup_cnt: ',@fixup_cnt
	   SET NOCOUNT OFF;
     -- IF EXISTS (SELECT 1 FROM staging1 WHERE pathogens like '% and and %') THROW 60000,'AND AND present',1

      EXEC sp_log 0, @fn, 'Remove page header rows'
      EXEC sp_delete '%NAME OF COMPANY%'            , 'company', 'staging1';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      EXEC sp_delete '%REPUBLIC OF THE PHILIPPINES%', 'company', 'staging1';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      EXEC sp_log 0, @fn, 'Removing rows where company LIKE REPUBLIC OF THE PHILIPPINES'
      EXEC sp_delete '%REPUBLIC OF THE PHILIPPINES%', 'company', 'staging1';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      EXEC sp_log 0, @fn, 'Removing rows where company LIKE DEPARTMENT OF AGRICULTURE'
      EXEC sp_delete '%NAME OF COMPANY%'     , 'company', 'staging1';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      EXEC sp_log 0, @fn, 'Removing rows where company LIKE DEPARTMENT OF AGRICULTURE'
      EXEC sp_delete '%Department Of Agriculture%'     , 'company', 'staging1';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      EXEC sp_log 0, @fn, 'Removing rows where company LIKE FERTILIZER AND PESTICIDE AUTHORITY'
      EXEC sp_delete '%FERTILIZER AND PESTICIDE AUTHORITY%', 'company', 'staging1';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      EXEC sp_log 0, @fn, 'sp_fixup_staging1: Removing rows where company LIKE LIST OF REGISTERED AGRICULTURAL PESTICIDES'
      EXEC sp_delete '%LIST OF REGISTERED AGRICULTURAL PESTICIDES%', 'company', 'staging1';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

      EXEC sp_log 0, @fn, 'DELETE ''as of %'' rows'
      EXEC sp_delete '%as of %', 'company', 'staging1';
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
      EXEC sp_log 0, @fn, 'DELETE null company,ingredient,product'
      DELETE FROM staging1 WHERE company IS NULL AND product IS NULL AND ingredient IS NULL;
      SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   END TRY
   BEGIN CATCH
      DECLARE @error_msg NVARCHAR(MAX)
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, ' caught exception: ', @error_msg, ' , @fixup_cnt: ',@fixup_cnt;
      THROW;
   END CATCH
      
   EXEC sp_log 2, @fn, '99: leaving, @fixup_cnt: ',@fixup_cnt
END

/*
EXEC sp_fixup_s1_rem_hdrs
SELECT * FROM staging1 where pathogens LIKE  '% and and %'
*/

GO
