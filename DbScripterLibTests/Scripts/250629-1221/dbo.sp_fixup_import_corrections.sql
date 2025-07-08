SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ========================================================================================================
-- Author:      Terry Watts
-- Create date: 28-JUN-2023
--
-- Description: Called immediatly after import to fixup the
-- Removes any  wrapping double quotes "
-- The import data issues like our wrapping [] used to highlight
-- leading/trailing spaces
--
-- PRECONDITIONS:
--    corrections staging Bulk import done
--
-- POSTCONDITIONS:
--    Ready to process the pesticide register import
--    Clean bulk insert to tble from file
--    POST01: No wrapping " or {} in the following fields:
--    search_clause, not_clause,replace_clause, latin_name, common_name, local_name, alt_names, crops, note_clause
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
CREATE PROCEDURE [dbo].[sp_fixup_import_corrections]
AS
BEGIN
   DECLARE
       @fn     VARCHAR(35)   = N'sp_fixup_import_corrections]'
      ,@sql    VARCHAR(4000)
      ,@msg    VARCHAR(500)
      ;

   EXEC sp_log 1, @fn, '000: starting';
   --EXEC sp_register_call @fn;

   -- Remove wrapping "
   EXEC sp_log 1, @fn, '010: remove wrapping double quotes from the following columns: search_clause, not_clause, replace_clause, crops, chk';

   -- REMOVE the first 2 imported header rows
   --DELETE FROM ImportCorrectionsStaging WHERE id2<3;

   UPDATE ImportCorrectionsStaging
   SET
       [action]       = dbo.fnTrim2( [action]       , '"')
      ,table_nm       = dbo.fnTrim2( table_nm       , '"')
      ,field_nm       = dbo.fnTrim2( field_nm       , '"')
      ,search_clause  = dbo.fnTrim2( search_clause  , '"')
      ,filter_field_nm= dbo.fnTrim2( filter_field_nm, '"')
      ,filter_clause  = dbo.fnTrim2( filter_clause  , '"')
      ,not_clause     = dbo.fnTrim2( not_clause     , '"')
      ,replace_clause = dbo.fnTrim2( replace_clause , '"')
      ,field2_nm      = dbo.fnTrim2( field2_nm      , '"')
      ,field2_clause  = dbo.fnTrim2( field2_clause  , '"')
      ,must_update    = dbo.fnTrim2( must_update    , '"')
      ,comments       = dbo.fnTrim2( comments       , '"')
      ,exact_match    = dbo.fnTrim2( exact_match    , '"')
   ;

   -- we do use regex - but they wont have an opening [
   EXEC sp_log 1, @fn, '020: remove wrapping []{}';

   -- 10-JUL-2023: Wrapping brackets are now {} to avoid clash with regex [] brackets
   UPDATE ImportCorrectionsStaging  
   SET
        search_clause  = dbo.fnTrim2( search_clause,  '{')
       ,replace_clause = dbo.fnTrim2( replace_clause, '{')
       ,not_clause     = dbo.fnTrim2( not_clause,     '{')
       ;

   EXEC sp_log 1, @fn, '030: remove wrapping []{}';
   UPDATE ImportCorrectionsStaging
   SET
        search_clause  = dbo.fnTrim2( search_clause,  '}')
       ,replace_clause = dbo.fnTrim2( replace_clause, '}')
       ,not_clause     = dbo.fnTrim2( not_clause,     '}')
       ;

   -- 240201: XL imports using openrowset to the xl file directly limit the field width to 255
   --         so we are using a second field to hold chars 256-end then concat this to the search field here
   --EXEC sp_log 1, @fn, '040: joining search_clause and  search_clause_cont => search_clause';
   --UPDATE ImportCorrectionsStaging SET search_clause = CONCAT(search_clause, search_clause_cont);

   -- Run checks
   EXEC sp_log 1, @fn, '050: running checks';
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
  )
   BEGIN
      SET @msg = '060: [sp_fixup_import_corrections_staging failed: {,}or " still exist in in search_clause or replace_clause or not_clause';
      EXEC sp_log 4, @fn, @msg;
      THROW 58126, @msg, 1;
   END

   EXEC sp_log 1, @fn, '999: leaving OK';
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
