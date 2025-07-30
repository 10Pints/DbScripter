SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ========================================================================================================================
-- Author:      Terry Watts
-- Create date: 17-NOV-2024
-- Description: This lists the unregisterd items in in staging2 for the given field table and logs message
--              and adds the count of unregisterd items to @unmtchd_cnt
--  e.g Pathogen, pathogens
--
-- Notes:
-- There are 2 types of field in staging2
-- 1: single value fields like Company, Product, concentration, formulation_type,toxicity, reg,expiry
-- 2: multi  value fields like ingredient, uses, entry_mode, crops, pathogens
-- These need handling differently
--
-- Design: Farming.eap/Model.SQLServer2012/Procedures/Fixup rtns/Find unmatched dynamic data/
--    Create the select sql/Create the select sql ACT
-- Paramaters:
-- @stg_field_nm:    the staging2 field holding the items to check if they are registered MANDATORY
-- @table_nm:        the primary table holding the list of registered items, default: RTrim2(@stg_field_nm, 's')
-- @pk_field_nm      the pk field of the primary table, default: 
-- @display_tables   optional if true then the list of unregistered items is displayed 
-- @unmtchd_cnt      optional if not null then the count of unregistered items is returned
--
-- Responsibilities:
-- R01: displays a list of unregisterd items in staging2 the given item table
-- R02: populate the dbo.UnregisteredItem table with the unregisterd item data
-- R03: logs message if unregistered items found : level 3, 'found <@cnt> unregistered <table_nm>';
--
-- PRECONDITIONS: none
--
-- POSTCONDITIONS:
-- POST 01: aggregates the count of unregistered items intp @unmtchd_cnt i.e unmtchd_cnt=unmtchd_cnt+cnt of unmtched items
-- POST 02: if @display_tables true then the list of unregistered items is displayed
--
-- Changes:
-- 241210: handle multi value fields differently
-- ========================================================================================================================
CREATE PROCEDURE [dbo].[sp_fnd_unregistered_dyndta_hlpr]
    @stg_field_nm    NVARCHAR(60)
   ,@table_nm        NVARCHAR(60)   = NULL -- default is Staging2
   ,@pk_table_nm     NVARCHAR(60)   = NULL -- default is RTrim(@stg_field_nm, 's') + '_nm'
   ,@pk_field_nm     NVARCHAR(60)   = NULL -- default is @table_nm + '_nm'
   ,@sep             NVARCHAR(1)    = NULL -- null then single value field
   ,@tot_cnt         INT            = NULL OUTPUT
   ,@display_tables  BIT            = 1
AS
BEGIN
   DECLARE
    @fn              VARCHAR(35)    = N'sp_fnd_unregistered_dyndta_hlpr'
   ,@nl              NVARCHAR(2)    = NCHAR(13)+NCHAR(10)
   ,@sql             NVARCHAR(MAX)
   ,@sql_body        NVARCHAR(MAX)
   ,@cnt             INT
   ,@is_multi_value  BIT
   ;
   SET @cnt = 0;
   SET @is_multi_value = iif(@sep IS NULL, 0, 1);
-- 241210: handle multi value fields differently
-- There are 2 types of field in staging2
-- 1: single value fields like Company, Product, concentration, formulation_type,toxicity, reg,expiry
-- 2: multi  value fields like ingredient, uses, entry_mode, crops, pathogens
-- These need handling differently
   SET NOCOUNT ON;
   EXEC sp_log 2, @fn,'000: starting:
stg_field_nm  :[', @stg_field_nm  ,']
table_nm      :[', @table_nm      ,']
pk_table_nm   :[', @pk_table_nm   ,']
pk_field_nm   :[', @pk_field_nm   ,']
sep           :[', @sep           ,']
cnt           :[', @cnt           ,']
is_multi_value:[', @is_multi_value,']
display_tables:[', @display_tables,']
';
   -- Get the sql to find the unregistered items
   EXEC sp_log 1, @fn,'010: calling fnCrtFndUnregisterdItemsSql',@nl, @sql;
   SET @sql_body = dbo.fnCrtFndUnregisterdItemsSql(@is_multi_value ,@stg_field_nm, @table_nm, @pk_table_nm, @pk_field_nm, @sep);
   EXEC sp_log 1, @fn,'020: @sql_body:',@nl, @sql_body;
   IF @display_tables = 1
   BEGIN
      SET @sql = CONCAT('SELECT item AS [',@pk_table_nm,'] FROM ', @sql_body);
      EXEC sp_log 1, @fn,'030: @sql:',@nl, @sql;
      EXEC(@sql);
--      SET @cnt = @@ROWCOUNT;
   END
/*
   ELSE
   BEGIN
      SET @sql = CONCAT('SELECT @cnt = COUNT(*) FROM ', @sql_body);
      EXEC sp_log 1, @fn,'040: @sql:',@nl, @sql;
      EXEC sp_executesql @sql, N'@cnt INT OUT', @cnt OUT;
   END
*/
   -- R02: populate the dbo.UnregisteredItem table with the unregisterd item data
   SET @sql = CONCAT('INSERT INTO UnregisteredItem (unreg_item, [table]) 
SELECT item, ''',@pk_table_nm,''' FROM ',@sql_body);
   EXEC sp_log 1, @fn,'050: insert unreg sql:',@nl, @sql;
   EXEC(@sql);
   SET @cnt = @@ROWCOUNT;
   IF @tot_cnt IS NULL
      SET @tot_cnt = 0;
   SET @tot_cnt = @tot_cnt + @cnt;
   EXEC sp_log 1, @fn,'100: found ',@cnt, ' unregistered ', @stg_field_nm;
   EXEC sp_log 2, @fn,'999: leaving, @tot_cnt:', @tot_cnt, ' found ',@cnt, ' unregistered ', @stg_field_nm, ' items';
END
/*
TRUNCATE table AppLog;
EXEC test.test_031_sp_fnd_unregistered_dyndta_hlpr;
EXEC sp_appLog_display;
EXEC sp_appLog_display 'sp_fnd_unregistered_dyndta_hlp';
--==============================================================================
DECLARE @tot_cnt      INT;
EXEC sp_fnd_unmtchd_dyndta_hlpr 'Pathogen', 'pathogens', @tot_cnt=@tot_cnt OUT, @display_tables=0;
PRINT @tot_cnt;
EXEC sp_fnd_unmtchd_dyndta_hlpr 'Pathogen', 'pathogens', @tot_cnt=@tot_cnt OUT, @display_tables=1;
PRINT @tot_cnt;
--==============================================================================
*/
GO

