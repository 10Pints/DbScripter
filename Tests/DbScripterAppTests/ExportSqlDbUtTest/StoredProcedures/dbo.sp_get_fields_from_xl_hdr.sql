SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================================================================
-- Author:      Terry Watts
-- Create date: 28-FEB-2024
-- Description: 
--
-- PRECONDITIONS:
-- PRE 01: @file_path must be specified OR EXCEPTION 58000, 'spreadsheet must be specified'
-- PRE 02: @file_path exists,           OR EXCEPTION 58001, 'spreadsheet does not exist'
-- PRE 03: @range not null or empty       OR EXCEPTION 58002, 'range must be specified'
-- 
-- POSTCONDITIONS:
-- POST01:
--
-- CALLED BY:
-- sp_import_XL_new, sp_import_XL_existing
--
-- TESTS:
--
-- CHANGES:
-- 05-MAR-2024: put brackets around the field names to handle spaces reserved words etc.
-- 05-MAR-2024: added parameter validation
-- ==========================================================================================================
CREATE PROCEDURE [dbo].[sp_get_fields_from_xl_hdr]
    @file_path_inc_range   NVARCHAR(500)
   ,@fields                NVARCHAR(4000) OUT            -- comma separated list
AS
BEGIN
   DECLARE 
       @fn        NVARCHAR(35)   = N'GET_FLDS_FRM_XL_HDR'
      ,@cmd       NVARCHAR(4000)
      ,@range     NVARCHAR(100)  = N'Sheet1$'   -- for XL: like 'Table$' OR 'Table$A:B'
      ,@file_path NVARCHAR(500)
   BEGIN TRY
      -------------------------------------------------------
      -- Param validation, fixup
      -------------------------------------------------------
      SELECT 
          @file_path = file_path
         ,@range     = [range]
      FROM Ut.dbo.fnGetRangeFromFileName(@file_path_inc_range);
      throw 59000, 'implement', 1;
      SET @range = ut.dbo.fnFixupXlRange(@range);
      --------------------------------------------------------------------------------------------------------
      -- PRE 01: @file_path must be specified OR EXCEPTION 58000, 'spreadsheet must be specified'
      --------------------------------------------------------------------------------------------------------
      EXEC Ut.dbo.sp_assert_not_null_or_empty @file_path, 'spreadsheet must be specified', @ex_num=58000--, @fn=@fn;
      --------------------------------------------------------------------------------------------------------
      -- PRE 02: @spreadsheet exists,           OR EXCEPTION 58001, 'spreadsheet does not exist'
      --------------------------------------------------------------------------------------------------------
      IF Ut.dbo.fnFileExists(@file_path) = 0 
         EXEC Ut.dbo.sp_raise_exception 58001, 'spreadsheet does not exist'--, @fn=@fn
      --------------------------------------------------------------------------------------------------------
      -- PRE 03: @range not null or empty       OR EXCEPTION 58002, 'range must be specified'
      --------------------------------------------------------------------------------------------------------
      EXEC Ut.dbo.sp_assert_not_null_or_empty @range, 'range must be specified', @ex_num=58002--, @fn=@fn;
      -------------------------------------------------------
      -- ASSERTION: Passed parameter validation
      -------------------------------------------------------
      -------------------------------------------------------
      -- Process
      -------------------------------------------------------
      --EXEC sp_log 1, @fn, '040: processing';
      DROP TABLE IF EXISTS temp;
      -- IMEX=1 treats everything as text
      SET @cmd = 
         CONCAT
         (
      'SELECT * INTO temp 
      FROM OPENROWSET
      (
          ''Microsoft.ACE.OLEDB.12.0''
         ,''Excel 12.0;IMEX=1;HDR=NO;Database='
         ,@file_path,';''
         ,''SELECT TOP 2 * FROM ',@range,'''
      )'
         );
      EXEC(@cmd);
      SELECT @fields = string_agg(CONCAT('concat (''['',','', column_name, ','']''',')'), ','','',')
      FROM list_table_columns_vw
      WHERE TABLE_NAME = 'temp';
      SELECT @cmd = CONCAT('SET @fields = (SELECT TOP 1 CONCAT(',@fields, ') FROM [temp])');
      EXEC sp_executesql @cmd, N'@fields NVARCHAR(4000) OUT', @fields OUT;
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      EXEC sp_log 2, @fn, '000: params, 
   @spreadsheet:  [', @file_path,']
   @range:        [', @range,']'
   ;
      EXEC sp_log 2, @fn, '050: open rowset sql:
   ', @cmd;
      THROW;
   END CATCH
   RETURN
END
/*
DECLARE @fields NVARCHAR(MAX);
EXEC sp_get_fields_from_xl_hdr 'D:\Dev\Repos\Farming\Data\Distributors.xlsx','Distributors$A:H', @fields OUT;
PRINT @fields;
exec sp_describe_first_result_set N'dbo.sp_get_fields_from_xl_hdr'
exec sp_describe_first_result_set N'dbo.sp_class_creator'
is_hidden	column_ordinal	name	is_nullable	system_type_id	system_type_name	max_length	precision	scale	collation_name	user_type_id	user_type_database	user_type_schema	user_type_name	assembly_qualified_type_name	xml_collection_id	xml_collection_database	xml_collection_schema	xml_collection_name	is_xml_document	is_case_sensitive	is_fixed_length_clr_type	source_server	source_database	source_schema	source_table	source_column	is_identity_column	is_part_of_unique_key	is_updateable	is_computed_column	is_sparse_column_set	ordinal_in_order_by_list	order_by_is_descending	order_by_list_length	tds_type_id	tds_length	tds_collation_id	tds_collation_sort_id
0	1	Line	0	231	nvarchar(293)	586	0	0	Latin1_General_CI_AS	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	0	0	0	NULL	NULL	NULL	NULL	NULL	0	NULL	0	1	0	NULL	NULL	NULL	231	586	13632521	0
*/
GO

