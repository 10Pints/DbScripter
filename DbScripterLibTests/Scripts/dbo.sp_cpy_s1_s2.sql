SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===================================================================================
-- Author:      Terry Watts
-- Create date: 20-JUN-2023
-- Description: copy (replaces) Staging2 with all of Staging1
--    Does some simple initital fixup. Can use S1 as a backup
-- CHANGES:
-- 231103: turned auto increment off so SET IDENTITY_INSERT ON/OFF not needed
-- 231106: increase S2 pathogens col sz from 180 to 360 - as issues in 231005 import
-- ===================================================================================
CREATE   PROCEDURE [dbo].[sp_cpy_s1_s2]
AS
BEGIN
   DECLARE 
       @rc   INT = 0
      ,@cnt  INT = 0
      ,@result_msg   VARCHAR(500) = NULL
      ,@fn           VARCHAR(500) = 'CPY_S1_S2'

   SET NOCOUNT OFF;

   BEGIN TRY
      EXEC sp_log 1, @fn, '00:starting';
      --EXEC sp_register_call @fn;
      SET XACT_ABORT ON;

      EXEC sp_log 0, @fn, '01: truncating S2   ';

      TRUNCATE TABLE Staging2;
      SET @rc = @@ERROR;

      IF @RC <> 0
      BEGIN
         SET @result_msg = CONCAT('stage 1 TRUNCATE TABLE Staging2; failed: ',ERROR_MESSAGE());
         EXEC sp_log 4, @fn, @result_msg;
         THROW 50600, @result_msg, 1;
      END

      EXEC sp_log 1, @fn, '03: about to copy s1 -> S2   ';

      INSERT INTO dbo.staging2
      (
          id
         ,company
         ,ingredient
         ,product
         ,concentration
         ,formulation_type
         ,uses
         ,toxicity_category
         ,registration
         ,expiry
         ,entry_mode
         ,crops
         ,pathogens
         ,rate
         ,mrl
         ,phi
         ,reentry_period
         ,notes
         ,created
      )
      SELECT 
          id
         ,company
         ,ingredient
         ,product
         ,concentration
         ,formulation_type
         ,uses
         ,toxicity_category
         ,registration
         ,expiry
         ,entry_mode
         ,crops
         ,pathogens
         ,rate
         ,mrl
         ,phi
         ,reentry_period
         ,notes
         ,created
      FROM dbo.staging1;

      EXEC sp_log 1, @fn, '04: copied s1 -> S2   ';
      SET @rc  = @@ERROR;
      SET @cnt = @@ROWCOUNT;

      IF @RC <> 0
      BEGIN
         SET @result_msg = CONCAT('stage 2 insert failed: ',ERROR_MESSAGE());
         EXEC sp_log 4, @fn, @result_msg;
         THROW 50601, @result_msg, 1;
      END

      EXEC sp_log 1, @fn, '05: success   ';
   END TRY
   BEGIN CATCH
      DECLARE @error_msg VARCHAR(500);
      SET @error_msg = ERROR_MESSAGE();
      SET @RC = -1;
      EXEC sp_log 4, @fn, '50: caught exception: ', @error_msg;
      THROW;
   END CATCH
   EXEC sp_log 1, @fn, 'leaving ok';
END
/*
EXEC sp_copy_s1_s2;
SELECT * FROM staging1;
SELECT MAX(dbo.fnLen(pathogens)) FROM staging1;
SELECT id, dbo.fnLen(pathogens), pathogens FROM staging1 WHERE dbo.fnLen(pathogens) > 200 ORDER BY dbo.fnLen(pathogens) DESC;
SELECT * FROM staging2 where pathogens LIKE '%-%';
*/


GO
