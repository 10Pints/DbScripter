SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =========================================================
-- Author:      Terry Watts
-- Create date: 03-FEB-240203
-- Description: Import Excel sheet importer into an existing table
-- =========================================================
ALTER PROCEDURE [dbo].[sp_import_ForeignKey_XL]
(
    @spreadsheet  NVARCHAR(400)  -- path to xls
   ,@range        NVARCHAR(100)  -- like 'Corrections_221008$A:P' OR 'Corrections_221008$'
)
AS
BEGIN
   DECLARE @fn NVARCHAR(35) = 'IMPRT_FKS_XL'

   EXEC sp_log 0, @fn, '00: starting:
@spreadsheet:[',@spreadsheet,']
@range:      [',@range,']';

   EXEC sp_log 0, @fn, '05: deleting rows in ForeignKeys';
   DELETE FROM ForeignKey;

   EXEC sp_log 0, @fn, '10: importing ForeignKeys from ', @spreadsheet, ' range: ', @range;

   EXEC sp_import_XL_existing
          @spreadsheet  = @spreadsheet
         ,@range        = @range
         ,@table        = 'ForeignKey';
--   'id,fk_nm,foreign_table_nm,primary_tbl_nm,schema_nm,fk_col_nm,pk_col_nm,unique_constraint_name,ordinal,table_type'

   EXEC sp_log 0, @fn, '15: imported OK';
   EXEC sp_log 1, @fn, '99: leaving OK';
END
/*
EXEC sp_import_ForeignKey_XL 'D:\Dev\Repos\Farming\Data\ForeignKeys.xlsx', 'Sheet1$';
SELECT * FROM ForeignKeys;
*/

GO
