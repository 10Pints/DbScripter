SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===========================================================================
-- Procedure:   sp_assert_all_data_tbls_pop
-- Description: checks all the non staging tables except the excluded ones
-- EXEC tSQLt.Run 'test.test_000_sp_assert_all_data_tbls_pop';
-- Design:      
-- Tests:       
-- Author:      
-- Create date: 
-- ===========================================================================
ALTER PROCEDURE [dbo].[sp_assert_all_data_tbls_pop]
    @mn_tbls   BIT = 1
   ,@inc_eppo  BIT = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
    @fn              VARCHAR(35)  = N'import_static_data_staging'
   ,@items           NVARCHAR(MAX) -- comma separated list of tables to run the sp_assert_tbl_pop against
   ,@excluded        NVARCHAR(MAX)
   ,@excluded_items  NVARCHAR(MAX)
   ,@sql             NVARCHAR(MAX)
   ,@row_cnt         INT

   EXEC sp_log 1, @fn ,'000: starting:
mn_tbls :[',@mn_tbls ,']
inc_eppo:[',@inc_eppo,']
';

   IF @mn_tbls = 1
      SET @excluded = ''--ActionFixup,ChemicalAction,ChemicalProduct,ChemicalUse,CorrectionLog';
   ELSE
      SET @excluded = 'ImportCorrectionsStaging';

   SELECT @excluded_items = string_agg(CONCAT('''',value, ''''),',') FROM string_split(@excluded, ',');
   EXEC sp_log 1, @fn ,'010: @excluded_items: ',@excluded_items;
   SET @sql = CONCAT('SELECT @items = string_agg(table_nm,'','')
FROM dbo.fnListTables(''dbo'')
WHERE table_nm ',iif( @mn_tbls = 1, 'NOT ', ''), 'LIKE ', '''%Staging%'' AND table_nm NOT IN (',@excluded_items,')');

   IF @inc_eppo = 0
      SET @sql = CONCAT( @sql, ' AND table_nm NOT LIKE ''%EPPO%'' ');

   SET @sql = CONCAT( @sql, ';');
   PRINT CONCAT('100: @sql: ',@sql);
   EXEC sp_executesql @sql, N'@items NVARCHAR(MAX) OUT, @excluded_items NVARCHAR(MAX)', @items OUT, @excluded_items;
   EXEC sp_log 1, @fn ,'020: @items:[',@items,']';
   EXEC sp_log 1, @fn ,'030: calling spExecuteCmds @items';
   EXEC spExecuteCmds 'EXEC sp_assert_tbl_pop', @items, @row_cnt OUT;
   EXEC sp_log 1, @fn ,'999: leaving';
END
/*
   EXEC sp_assert_all_data_tbls_pop 0,0
   EXEC sp_assert_all_data_tbls_pop 1,1
   SELECT * FROM ChemicalActionStaging
*/

GO
