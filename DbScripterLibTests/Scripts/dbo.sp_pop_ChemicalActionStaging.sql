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
--       PRE01: S2 table populated
--
-- POSTCONDITIONS:
-- POST01: ChemicalActionStaging table populated
-- POST02: mancozeb exists and is only contact
--
-- ALGORITHM:
--    0: PRECONDITION VALIDATION CHECKS
--    1: TRUNCATE the ChemicalActionStaging table
--    2: using All_vw get each chemical and its set of actions for products with ingredients containing only 1 chemical
--
-- CHANGES:
-- Tests:
-- ======================================================================================================
ALTER PROCEDURE [dbo].[sp_pop_ChemicalActionStaging]
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35)   = N'POP CHEM ACTN STAGING'
      ,@sql       NVARCHAR(MAX)
      ,@error_msg NVARCHAR(MAX)  = NULL
      ,@rc        INT            =-1
      ,@cnt       INT            = 0
      ;

   BEGIN TRY
      EXEC sp_log 2, @fn,'01: starting, running precondition checks';
      EXEC sp_register_call @fn;

      -- PRE01: S2 table populated
      EXEC sp_log 1, @fn,'02: PRE01: S2 table must be populated';
      EXEC sp_chk_tbl_populated 'Staging2';
      EXEC sp_chk_tbl_populated 'ActionStaging';
      EXEC sp_chk_tbl_populated 'ChemicalStaging';

      --------------------------------------------------------------------------------
      -- ASSERTION: S2 table populated
      --------------------------------------------------------------------------------

      EXEC sp_log 1, @fn,'03: truncating ChemicalActionStaging table';
      TRUNCATE TABLE dbo.ChemicalActionStaging;

      -- 2: using All_vw get each chemical and its set of actions for products with ingredients containing only 1 chemical

      EXEC sp_log 1, @fn,'05: populating the ChemicalActionStaging table from ALL_vw ';
      INSERT INTO ChemicalActionStaging(chemical_nm, action_nm)
      SELECT DISTINCT chemical_nm, action_nm
      FROM ALL_vw 
      WHERE
               chemical_nm IS NOT NULL 
         AND action_nm   IS NOT NULL
         AND action_nm NOT IN (' ','-')
         AND chemicals   NOT LIKE '%+%'
      ORDER BY chemical_nm, action_nm;

      -- Chk POST01: ChemicalActionStaging table populated
      -- Chk POST02: mancozeb exists and is only contact
      SELECT @cnt = COUNT(*) FROM ChemicalActionStaging WHERE chemical_nm='Mancozeb';
      EXEC sp_raise_assert @cnt, 1, 'Mancozeb should only have 1 entry in ChemicalActionStaging, count: ', @cnt, @ex_num=53224, @fn=@fn;
      SELECT @cnt = COUNT(*) FROM ChemicalActionStaging WHERE chemical_nm='Mancozeb' AND action_nm='CONTACT';
      EXEC sp_raise_assert @cnt, 1, 'Mancozeb mode should be CONTACT in ChemicalActionStaging, count: ', @cnt, @ex_num=53224, @fn=@fn;

      EXEC sp_chk_tbl_populated 'ChemicalActionStaging';
   END TRY
   BEGIN CATCH
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '99: leaving OK';
   RETURN @RC;

END
/*
EXEC sp_pop_chemical_use_staging 1
SELECT * FROM ChemicalActionStaging ORDER BY chemical_nm, action_nm

*/

GO
