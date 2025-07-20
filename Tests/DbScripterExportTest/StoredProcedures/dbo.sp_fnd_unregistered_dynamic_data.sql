SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =================================================================================================
-- Author:      Terry Watts
-- Create date: 04-NOV-2024
-- Description: This rtn finds the unmatched dynamic data items derived from the LRAP
--
-- Details:  Once the S2 fixup has been completed we need to find any S2 data that 
--    is still not matched against the primary data.
--    The LRAP data is very dirty so we need some rigorous checks in place to filter bad data
--
-- Responsibilities:
-- R01: displays a list of unregisterd items in staging2 the given item table
-- R02: populate the dbo.UnregisteredItem table with the unregisterd item data
-- R03: logs message if unregistered items found : level 3, 'found <@cnt> unregistered <table_nm>';
--
-- Dynamic Tables that need checking for null references:
--    ChemicalStaging
--    ChemicalActionStaging
--    ChemicalProductStaging
--    ChemicalUseStaging
--    CompanyStaging
--    CropPathogenStaging
--    PathogenChemicalStaging
--    ProductCompanyStaging
--    ProductStaging
--    ProductUseStaging
--
-- PRECONDITIONS:
--    All static data loaded
--    S2 cleaned up
--    sp_pop_dynamic_data called
--
-- POSTCONDITIONS:
-- POST 01: RETURNS the total count of unregistered items
-- =================================================================================================
CREATE PROCEDURE [dbo].[sp_fnd_unregistered_dynamic_data]
AS
BEGIN
   DECLARE
    @fn        VARCHAR(35) = N'sp_fnd_unregistered_dynamic_data'
   ,@tot_cnt   INT = 0
   ,@was_error INT = 0
    ;

   SET NOCOUNT ON;
   EXEC sp_log 2, @fn,'000: starting';

   BEGIN TRY
      TRUNCATE TABLE UnregisteredItem;

      --------------------------------------------------------------------
      -- Validate preconditions
      --------------------------------------------------------------------
      EXEC sp_log 1, @fn,'010: validating dynamic data populated';
      EXEC sp_fnd_unregistered_dyndta_chk_precndtns;

      --------------------------------------------------------------------
      -- Check for bad data in the LRAP extracted dynamic data tables
      -- to do this we need assocated primary static data from non LRAP sources
      -- E.G: Company, Crop, Pathogen, Use
      --------------------------------------------------------------------
      EXEC sp_log 1, @fn,'010: checking for bad data in the LRAP extracted dynamic data tables';
      --   sp_fnd_unregistered_dyndta_hlpr @stg_field_nm @table_nm,  @pk_table_nm,@pk_field_nm, @sep, @tot_cnt, @display_tables
      EXEC sp_fnd_unregistered_dyndta_hlpr 'company'   ,'Staging2', 'Company'                             ,@sep = NULL,@tot_cnt = @tot_cnt OUT;
      EXEC sp_fnd_unregistered_dyndta_hlpr 'crops'     ,'Staging2', 'Crop'                                ,@sep = ',' ,@tot_cnt = @tot_cnt OUT;
      EXEC sp_fnd_unregistered_dyndta_hlpr 'pathogens' ,'Staging2', 'Pathogen'                            ,@sep = ',' ,@tot_cnt = @tot_cnt OUT;
    --EXEC @tot_cnt = sp_fndUnregPathogens;                                                                           
      EXEC sp_fnd_unregistered_dyndta_hlpr 'uses'      ,'Staging2', 'Use'                                 ,@sep = ',' ,@tot_cnt = @tot_cnt OUT;
      EXEC sp_fnd_unregistered_dyndta_hlpr 'entry_mode','Staging2', 'Action','action_nm'                  ,@sep = ',' ,@tot_cnt = @tot_cnt OUT;
   END TRY
   BEGIN CATCH
      SET @was_error = 1;
      EXEC sp_log 4, @fn,'500: caught exception';
      EXEC sp_log_exception @fn;
   END CATCH

   SELECT CONCAT('Total unregisterd count = ', @tot_cnt) AS [Total unregisterd count    .];
   SELECT * FROM UnregisteredItem;
   EXEC sp_log 2, @fn, '999: leaving, errors?: ',@was_error;
-- POST 01: RETURNS (0 and all data matched) or (1 and some data not matched with  the static data)
   RETURN @tot_cnt; -- iif(@tot_cnt = 0, 0, 1);
END
/*
TRUNCATE TABLE AppLog;
EXEC sp_fnd_unregistered_dynamic_data;
SELECT * FROM UnregisteredItem;
EXEC sp_appLog_display @dir=0;-- desc
*/

GO
