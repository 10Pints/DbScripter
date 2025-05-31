SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =====================================================================================
-- Author:      Terry Watts
-- Create date: 25-AUG-2023
-- Description: Truncates the main tables
-- Method:
-- Drop the main table FKs
-- Truncate each table
-- Create the main table FKs
--
-- Calls: sp_create_main_table_FKs twice, once to drop the keys, once to recreate them
-- 
-- =====================================================================================
ALTER PROCEDURE [dbo].[sp_truncate_main_tables] 
AS
BEGIN
   SET NOCOUNT ON
   DECLARE
    @fn        NVARCHAR(30)   = 'TRUNC_MN_TBLS'
   ,@cursor                   CURSOR
   ,@id                       INT   = 0
   ,@fk_nm                    NVARCHAR(60)
   ,@foreign_table_nm         NVARCHAR(60)
   ,@primary_tbl_nm           NVARCHAR(60)
   ,@schema_nm                NVARCHAR(60)
   ,@fk_col_nm                NVARCHAR(60)
   ,@pk_col_nm                NVARCHAR(60)
   ,@unique_constraint_name   NVARCHAR(60)
   ,@ordinal                  INT
   ,@ndx                      INT = 0
   ,@table_type2              NVARCHAR(60)
   ,@msg                      NVARCHAR(1000)
   ,@sql                      NVARCHAR(MAX)

   BEGIN TRY
      EXEC sp_log 2, @fn, '00: starting';
      THROW 56214, 'DEPRECATED - DO NOT USE',1;
      EXEC sp_register_call @fn;

      ------------------------------------------------------------------------------------------------
      -- Drop the main table FKs
      ------------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '05: drop FKs, calling sp_crt_mn_tbl_FKs 0';
      EXEC sp_crt_mn_tbl_FKs 0; -- drop FKs
      EXEC sp_log 2, @fn, '10: ret frm sp_crt_mn_tbl_FKs 0';

      ------------------------------------------------------------------------------------------------
      -- Truncate each table
      ------------------------------------------------------------------------------------------------
/*      SET @cursor = CURSOR FOR
         SELECT id, fk_nm, foreign_table_nm, primary_tbl_nm, schema_nm, fk_col_nm, pk_col_nm, unique_constraint_name, ordinal, table_type
         FROM ForeignKey fk LEFT JOIN TableDef td ON fk.foreign_table_nm=td.table_nm
         WHERE table_type = 'Main'
         ORDER BY id;*/
      EXEC sp_log 2, @fn, '15: Truncate table loop: starting';
      SET @cursor = CURSOR FOR
         SELECT DISTINCT foreign_table_nm--, primary_tbl_nm, schema_nm, fk_col_nm, pk_col_nm, unique_constraint_name, ordinal, table_type
         FROM ForeignKey fk LEFT JOIN TableDef td ON fk.foreign_table_nm=td.table_nm
         WHERE table_type = 'Main'
--         ORDER BY id;

      OPEN @cursor;

      --FETCH NEXT FROM @cursor INTO @id, @fk_nm, @foreign_table_nm, @primary_tbl_nm, @schema_nm, @fk_col_nm, @pk_col_nm, @unique_constraint_name, @ordinal, @table_type2;
      FETCH NEXT FROM @cursor INTO @foreign_table_nm;
      EXEC sp_log 1, @fn, '20: @@FETCH_STATUS before first fetch: [', @@FETCH_STATUS, ']';

      WHILE (@@FETCH_STATUS = 0)
      BEGIN
         SET @ndx = @ndx + 1;
         SET @sql = CONCAT('TRUNCATE TABLE [',@foreign_table_nm,']');
         EXEC sp_log 1, @fn, '25: [', @ndx,'] ', @sql;
         EXEC( @sql);
         --FETCH NEXT FROM @cursor INTO @id, @fk_nm, @foreign_table_nm, @primary_tbl_nm, @schema_nm, @fk_col_nm, @pk_col_nm, @unique_constraint_name, @ordinal, @table_type2;
         FETCH NEXT FROM @cursor INTO @foreign_table_nm;
      END

      EXEC sp_log 2, @fn, '30: processing corrections Completed at row: ';
      IF @ndx = 0 EXEC Ut.dbo.sp_raise_exception 52417, 'No rows were processed'
      ------------------------------------------------------------------------------------------------
      -- Recreate the main table FKs
      ------------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '35: recreate FKs, calling sp_crt_mn_tbl_FKs 1'
      EXEC sp_crt_mn_tbl_FKs 1; -- recreate FKs
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      --EXEC sp_crt_mn_tbl_FKs 0; -- recreate FKs drop first if state is inconsistent
      --EXEC sp_crt_mn_tbl_FKs 1; -- recreate FKs
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '99: leaving OK';
END
/*
TRUNCATE TABLE Applog;
EXEC sp_reset_callRegister 'TRUNC_MN_TBLS';
EXEC sp_truncate_main_tables;

EXEC sp_list_AppLog @fnFilter='TRUNC_MN_TBLS,CRT_MN_TBL_FKS,CRT_FKEYS'--,@asc=0
SELECT * FROM fnListFKeysForPrimaryTable('Pathogen')
ALTER TABLE CropPathogenStaging DROP CONSTRAINT FK_CropPathogenStaging_Pathogen
ALTER TABLE PathogenChemicalStaging DROP CONSTRAINT FK_PathogenChemicalStaging_PathogenStaging
*/

GO
