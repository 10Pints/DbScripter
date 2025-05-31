SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:       Terry Watts
-- Create date:  22-JAN-2024
-- Description:  Populates the ChemicalActionStaging table from all_vw:
--               Takes the minimum set of uses from the products containing the chemical
--               2:[OPTIONAL] add the extra chemical action data from a spreadsheet tsv
--
-- PRECONDITIONS:
--       PRE01: S2 table         populated
--       PRE02: ActionStaging    populated
--       PRE03: ChemicalStaging  populated
--       PRE04: S2 table fixup done
--
-- POSTCONDITIONS:
-- POST 01: ChemicalActionStaging table populated
-- POST 02: Mancozeb exists in ChemicalActionStaging and is only contact
--
-- ALGORITHM:
--    0: PRECONDITION VALIDATION CHECKS
--    1: TRUNCATE the ChemicalActionStaging table
--    2: using All_vw get each chemical and its set of actions for products with ingredients containing only 1 chemical
--
-- CHANGES:
-- 241107: Re visited requirements, resonsibiities, pre and post conditions
--    PRE: All fixup to be done before this stage
--    POST: only 1 postcondition: ChemicalActionStaging table populated
--
-- Tests:
-- ======================================================================================================
ALTER PROCEDURE [dbo].[sp_pop_ChemicalActionStaging]
AS
BEGIN
   DECLARE
       @fn        VARCHAR(35)   = N'sp_pop_ChemicalActionStaging'
      ,@sql       VARCHAR(MAX)
      ,@error_msg VARCHAR(MAX)  = NULL
      ,@rc        INT            =-1
      ,@cnt       INT            = 0
      ,@stage     INT            = 1;
      ;

   BEGIN TRY
      EXEC sp_log 2, @fn,'000: starting, validating preconditions';
      --EXEC sp_register_call @fn;

      ----------------------------------------
      -- Validate preconditions
      ----------------------------------------
      EXEC sp_assert_tbl_pop 'Staging2';
      EXEC sp_assert_tbl_pop 'ActionStaging';
      EXEC sp_assert_tbl_pop 'ChemicalStaging';

      ----------------------------------------
      -- Process
      ----------------------------------------
      -- ASSERTION: S2 table populated

      EXEC sp_log 1, @fn,'020: truncating ChemicalActionStaging table';
      TRUNCATE TABLE dbo.ChemicalActionStaging;

      -- 2: using All_vw get each chemical and its set of actions for products with ingredients containing only 1 chemical
      SET @stage = 2;
      EXEC sp_log 1, @fn,'030: populating the ChemicalActionStaging table from ALL_vw ';

      INSERT INTO ChemicalActionStaging(chemical_nm, action_nm)
      SELECT DISTINCT chemical_nm, action_nm
      FROM ALL_vw 
      WHERE
             chemical_nm IS NOT NULL 
         AND action_nm   IS NOT NULL
         AND action_nm   NOT IN (' ','-')
         AND chemicals   NOT LIKE '%+%'
      ORDER BY chemical_nm, action_nm;

      SET @stage = 3;
      EXEC sp_log 1, @fn, '040: populated the ChemicalActionStaging table OK';

      ----------------------------------------
      -- Validate postconditions
      ----------------------------------------
      EXEC sp_log 1, @fn, '050: postcondition checks   ';

      -- Chk POST01: ChemicalActionStaging table populated
      EXEC sp_log 1, @fn, '060: chk ChemicalActionStaging pop';
      EXEC sp_assert_tbl_pop 'ChemicalActionStaging';

      -- POST 02: Mancozeb exists in ChemicalActionStaging and is only contact
      SELECT @cnt = COUNT(*) FROM ChemicalActionStaging WHERE chemical_nm='Mancozeb' AND action_nm='CONTACT';
      EXEC sp_log 1, @fn, '070: chk ChemicalActionStaging has only 1 Mancozeb/CONTACT row, actual row cnt: ', @cnt;

      IF(@cnt> 1)
      BEGIN
         SELECT * FROM ChemicalActionStaging WHERE chemical_nm='Mancozeb';
         EXEC sp_assert_equal 2, 1, 'Mancozeb should only have 1 entry in ChemicalActionStaging and it should be contact, count: ', @cnt, @ex_num=53224, @fn=@fn;
      END

      EXEC sp_log 2, @fn, '800: completed processing OK';
      SET @stage = 99;
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception, stage: ',@stage;
      EXEC sp_log_exception @fn;

      IF @stage = 2
      BEGIN
         SELECT  DISTINCT action_nm as [un registered actions]
         FROM ALL_vw
         WHERE
             action_nm IS NOT NULL
         AND action_nm NOT IN (' ','-')
         AND chemicals NOT LIKE '%+%'
         AND action_nm NOT IN ( SELECT action_nm FROM ActionStaging)
         ;

         SELECT action_nm AS [registered actions]
         FROM ActionStaging;
      END

      ;THROW;
   END CATCH

   EXEC sp_log 2, @fn, '999: leaving OK';
   RETURN @RC;

END
/*
EXEC sp_pop_ChemicalActionStaging;
SELECT * FROM ChemicalActionStaging ORDER BY chemical_nm, action_nm
sp_pop_ChemicalActionStaging
*/


GO
