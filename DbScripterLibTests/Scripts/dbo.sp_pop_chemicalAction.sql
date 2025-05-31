SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===========================================================================
-- Author:      Terry Watts
-- Create date: 22-OCT-2023
-- Description: fixes up the ChemicalEntryMode link table
--    from the corrected Staging2 table
--
-- PRECONDITIONS:
--    PRE01: Chemical table populated
--    PRE02: EntryModeType table populated
--
-- POSTCONDITIONS:
-- POST01: ChemicalAction table has rows
-- POST02: mancozeb exists and is only contact
-- ===========================================================================
ALTER PROCEDURE [dbo].[sp_pop_chemicalAction]
AS
BEGIN
   SET NOCOUNT OFF;

   DECLARE
     @fn          NVARCHAR(35)   = N'POP_ChemicalAction'
    ,@row_cnt     INT = -1

   BEGIN TRY
      EXEC sp_log 2, @fn, '01: starting, validation chks';
      EXEC sp_register_call @fn;

      ------------------------------------------------------------------
      -- VALIDATION:
      ------------------------------------------------------------------
      -- PRE01: Chemical table populated
      -- PRE02: EntryModeType table populated
      EXEC sp_chk_tbl_populated 'Chemical';
      EXEC sp_chk_tbl_populated 'Action';

      ------------------------------------------------------------------
      -- ASSERTION: precondition validation passed
      ------------------------------------------------------------------
      EXEC sp_log 2, @fn, '05: passed validation chks';

      ------------------------------------------------------------------
      -- Process
      ------------------------------------------------------------------
      EXEC sp_log 2, @fn, '10: Process';

            -- First update the names in the link table
      UPDATE ChemicalAction 
      SET chemical_nm=X.chemical_nm
      ,action_nm = X.action_nm
      FROM
      (
         SELECT c.chemical_nm, a.action_nm, a.action_id, c.chemical_id 
         FROM ChemicalAction ca join Chemical c ON ca.chemical_id = c.chemical_id
         JOIN Action a ON a.action_id=ca.action_id
      ) AS X
      WHERE ChemicalAction.action_id = X.action_id
        AND ChemicalAction.chemical_id = X.chemical_id;

      -- Now merge
      MERGE ChemicalAction as target
      USING
      (
         SELECT c.chemical_id, c.chemical_nm, a.action_nm, a.action_id
         FROM ChemicalActionStaging  cas 
         JOIN Chemical        c  ON c.chemical_nm = cas.chemical_nm
         JOIN [Action] a ON a.action_nm=cas.action_nm
      ) AS S
      ON target.chemical_nm = S.chemical_nm AND target.action_nm = s.action_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  chemical_id,   action_id,   chemical_nm,   action_nm)
         VALUES (s.chemical_id, s.action_id, s.chemical_nm, s.action_nm)
      ;

      SET @row_cnt = @@ROWCOUNT;

      ------------------------------------------------------------------
      -- check postconditions
      ------------------------------------------------------------------
      EXEC sp_log 1, @fn, '20: checking postconditions...';
      -- Chk POST01: ChemicalActionStaging table populated
      -- Chk POST02: mancozeb exists and is only contact
      EXEC sp_chk_tbl_populated 'ChemicalAction';
      SELECT @row_cnt = COUNT(*) FROM ChemicalActionStaging WHERE chemical_nm='Mancozeb';
      EXEC sp_raise_assert @row_cnt, 1, 'Mancozeb should only have 1 entry in ChemicalActionStaging, count: ', @row_cnt, @ex_num=53224, @fn=@fn;
      SELECT @row_cnt = COUNT(*) FROM ChemicalActionStaging WHERE chemical_nm='Mancozeb' AND action_nm='CONTACT';
      EXEC sp_raise_assert @row_cnt, 1, 'Mancozeb mode should be CONTACT in ChemicalActionStaging, count: ', @row_cnt, @ex_num=53224, @fn=@fn;

      ------------------------------------------------------------------
      -- ASSERTION: postcondition validation passed
      ------------------------------------------------------------------
      EXEC sp_log 1, @fn, '25: passed postcondition checks';
      EXEC sp_log 1, @fn, '40: process complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '99: leaving, updated ', @row_cnt, ' rows', @row_count=@row_cnt;
END
/*
EXEC sp_pop_chemicalAction; -- 91 -> 156 -> 332 rows
SELECT * FROM [ChemicalAction];
*/

GO
