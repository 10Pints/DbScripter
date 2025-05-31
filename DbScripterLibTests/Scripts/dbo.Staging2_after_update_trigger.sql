SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:		 Terry Watts
-- Create date: 15-AUG-2023
-- Description: After update trigger
-- =============================================
ALTER PROCEDURE [dbo].[Staging2_after_update_trigger] 
--   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
   DECLARE 
        @fn          NVARCHAR(35) = 'S2_UPDATE_TRIGGER: '
       ,@id          INT
       ,@cnt_new     INT
       ,@cnt_old     INT
       ,@cnt_dif     INT
/*       ,@old_cor_id  INT
--       ,@new_cor_id  INT

--   SET @old_cor_id = dbo.fnGetSessionValueCorId();
   --IF @old_cor_id IS NULL SET @old_cor_id = 0;
--   SET @new_cor_id = (SELECT top 1 cor_id FROM INSERTED);

   --EXEC sp_log 2, @fn,'01: starting: old cor_id: ', @old_cor_id, '  new cor_id [', @new_cor_id, ']';

   IF @new_cor_id <> @old_cor_id
   BEGIN
      -- Set the session context now to avoid duplicate rows
      EXEC sp_set_session_context_cor_id @new_cor_id;
      SELECT @cnt_new = COUNT(*) FROM INSERTED; -- new
      SELECT @cnt_old = COUNT(*) FROM DELETED;  -- old

      SELECT @cnt_dif = COUNT(*) 
      FROM INSERTED i JOIN DELETED d ON i.stg2_id=d.stg2_id 
      WHERE i.pathogens<>d.pathogens;

      --EXEC sp_log 2, @fn, '02 cnt_new: ', @cnt_new, ' @cnt_old: ',@cnt_old, ' @cnt_dif@ ', @cnt_dif;

      --IF @cnt_dif > 0
      --BEGIN
         --EXEC sp_log 2, @fn, '03: logging the update';
         INSERT INTO CorrectionLog (cor_id, stg_id, search_clause, replace_clause, not_clause, old, new, row_cnt)
         SELECT 
            old.stg2_id
           ,new.search_clause
           ,new.replace_clause
           ,new.not_clause
           ,old.pathogens  AS pathogens_old
           ,new.pathogens  AS pathogens_new
           ,@cnt_new
         FROM INSERTED new FULL JOIN DELETED old ON new.stg2_id=old.stg2_id
         WHERE old.pathogens <> new.pathogens
      --END

      -- Flag insertion of problems
   END

   --EXEC sp_log 1, @fn, '99: leaving'
   IF EXISTS (SELECT 1 FROM inserted WHERE pathogens LIKE '%Golden apple snails%') THROW 60000
      , 'S2 update trigger: ''Golden apple snails'' has just been inserted into S2.pathogens',1;
      */
END
/*
SELECT * FROM CorrectionLog
SELECT * FROM Staging2 WHERE pathogens LIKE '%Golden apple Snails%'
*/

GO
