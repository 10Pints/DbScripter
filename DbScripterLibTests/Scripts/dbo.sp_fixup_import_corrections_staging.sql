SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ========================================================================================================
-- Author:      Terry Watts
-- Create date: 28-JUN-2023
--
-- Description: Called immediatly after import to fixup the
-- MS  tsv import issues like wrapping double quotes "
-- The import data issues like our wrapping [] used to highlight
-- leading/trailing spaces
--
-- PRECONDITIONS:
--    corrections staging Bulk import done
--
-- POSTCONDITIONS:
--    Ready to process the pesticide register import
--    Clean bulk insert to tble from file
--    No wrapping " or {}
--    If error throws exception
--
-- Sets the following defaults:
--    doit -> 1
--    must_update to 1
--
-- ERROR HANDLING by exception handling
--
-- Tests:
--    test 012 sp_jh_imp_stg_1_bulk_insert
--
-- Called by the min import corrections routine
--
-- CHANGES:
-- 230710: wrapping barckets are now {} to avoid clash with regex [] brackets
-- 230712: rtn is now responsible for its own chk: - throw exception if error
-- 240201: XL imports using openrowset to the xl file directly limit the field width to 255
--         so we are using a second field to hold chars 256-end then concat this to the search field here
-- ========================================================================================================
ALTER procedure [dbo].[sp_fixup_import_corrections_staging]
AS
BEGIN
   DECLARE
       @fn     NVARCHAR(35)   = N'FIXUP_IMP_CRCTNS_STG'
      ,@sql    NVARCHAR(4000)
      ,@msg    NVARCHAR(500)
      ;

   EXEC sp_log 1, @fn, '00: starting';
   EXEC sp_register_call @fn;

   -- Remove wrapping "
   EXEC sp_log 1, @fn, '01: remove wrapping double quotes from the following columns: search_clause, not_clause, replace_clause, crops, chk';

   -- REMOVE the first 2 imported header rows
   DELETE FROM ImportCorrectionsStaging WHERE id2<3;

   UPDATE ImportCorrectionsStaging
   SET 
       chk            = Ut.dbo.fnTrim2( chk           , '"')
      ,crops          = Ut.dbo.fnTrim2( crops         , '"')
      ,not_clause     = Ut.dbo.fnTrim2( not_clause    , '"')
      ,replace_clause = Ut.dbo.fnTrim2( replace_clause, '"')
      ,search_clause  = Ut.dbo.fnTrim2( search_clause , '"')
      ;

   -- we do use regex - but they wont have an opening [
   EXEC sp_log 1, @fn, '02: remove wrapping []{}';


   -- 10-JUL-2023: Wrapping barckets are now {} to avoid clash with regex [] brackets
   UPDATE ImportCorrectionsStaging  
   SET
        search_clause  = Ut.dbo.fnTrim2( search_clause,  '{')
       ,replace_clause = Ut.dbo.fnTrim2( replace_clause, '{')
       ,not_clause     = Ut.dbo.fnTrim2( not_clause,     '{')
       ,chk            = Ut.dbo.fnTrim2( chk,            '[')
       ;

   UPDATE ImportCorrectionsStaging
   SET
        search_clause  = Ut.dbo.fnTrim2( search_clause,  '}')
       ,replace_clause = Ut.dbo.fnTrim2( replace_clause, '}')
       ,not_clause     = Ut.dbo.fnTrim2( not_clause,     '}')
       ,chk            = Ut.dbo.fnTrim2( chk,            ']')
       ;

   -- 240201: XL imports using openrowset to the xl file directly limit the field width to 255
   --         so we are using a second field to hold chars 256-end then concat this to the search field here
   EXEC sp_log 1, @fn, '03: joining search_clause and  search_clause_cont => search_clause';
   UPDATE ImportCorrectionsStaging SET search_clause = CONCAT(search_clause, search_clause_cont);

   -- Run checks
   EXEC sp_log 1, @fn, '04: running checks';
   IF EXISTS
   (
      SELECT 1 from ImportCorrectionsStaging 
      WHERE 
         search_clause  LIKE '{%'
      OR search_clause  LIKE '%}'
      OR replace_clause LIKE '{%'
      OR replace_clause LIKE '%}'
      OR not_clause     LIKE '{%'
      OR not_clause     LIKE '%}'

      OR search_clause  LIKE '"%'
      OR search_clause  LIKE '%"'
      OR replace_clause LIKE '"%'
      OR replace_clause LIKE '%"'
      OR not_clause     LIKE '"%'
      OR not_clause     LIKE '%"'
      OR chk            LIKE '"%'
      OR chk            LIKE '%"'
      OR chk            LIKE '[%'
      OR chk            LIKE '%]'
  )
   BEGIN
      SET @msg = '05: [sp_fixup_import_corrections_staging failed: {,}or " still exist in in search_clause or replace_clause or not_clause';
      EXEC sp_log 4, @fn, @msg;
      THROW 58126, @msg, 1;
   END
   -- set defaults: 
   -- doit controls whether the command is run or not
   EXEC sp_log 1, @fn,  '06: set doit col default if not specd';

   UPDATE ImportCorrectionsStaging
   SET doit = '1' WHERE doit IS NULL OR doit = '';

   -- must_update
   EXEC sp_log 1, @fn, '07: set must_update col default if not specd';
   UPDATE ImportCorrectionsStaging 
   SET must_update = '0' WHERE must_update IS NULL OR must_update = '';

   IF NOT EXISTS (SELECT 1 FROM ImportCorrectionsStaging WHERE ut.dbo.fnLen(search_clause_cont)>1)
      THROW 60001, 'FIXUP_IMP_CRCTNS_STG failed to import search_clause_cont', 1;

   EXEC sp_log 1, @fn, '99: leaving OK';
   RETURN 0;
END
/*
EXEC sp_fixup_import_corrections_staging;
EXEC sp_copy_corrections_staging_to_mn;
SELECT id, search_clause, replace_clause, chk FROM ImportCorrectionsStaging WHERE replace_clause like '%{%';
SELECT id, search_clause, replace_clause, chk FROM ImportCorrectionsStaging WHERE replace_clause like '%}%';
SELECT id, search_clause, replace_clause, chk FROM ImportCorrectionsStaging
WHERE id =43;
SELECT id, search_clause, replace_clause  FROM ImportCorrections WHERE search_clause  like '%{%';
SELECT id, search_clause, replace_clause  FROM ImportCorrections WHERE replace_clause like '%}%';
SELECT id, search_clause, replace_clause  FROM ImportCorrections WHERE replace_clause like '%"%';

SELECT * FROM ImportCorrectionsStaging;
EXEC sp_fixup_import_corrections_staging;
SELECT Count(*) from ImportCorrectionsStaging;
*/

GO
