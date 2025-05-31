SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =========================================================================================================
-- Author:      Terry Watts
-- Create date: 03-FEB-2024
-- Description: This routine creates or drops the set of tables' FKs dependant on the @table_type parameter.
--
-- Parameters:
--       @table_type: 'main':    main tables not staging tables
--                    'staging': staging tables
--       @mode 1: create keys, 0: drop keys
-- =========================================================================================================
ALTER PROCEDURE [dbo].[sp_crt_FKs]
    @table_type NVARCHAR(60)
   ,@mode       BIT =1
AS
BEGIN
   DECLARE
    @fn                       NVARCHAR(35)   = N'CRT_FKEYS'
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
   ,@table_type2              NVARCHAR(60)
   ,@msg                      NVARCHAR(1000)
   ,@sql                      NVARCHAR(MAX)

   SET NOCOUNT ON;
   EXEC sp_log 2, @fn,'00: starting: table_type:[', @table_type, '] mode: [', @mode, ']';

   BEGIN TRY
      EXEC sp_log 2, @fn,'01: Starting';

      SET @cursor = CURSOR FOR
         SELECT id, fk_nm, foreign_table_nm, primary_tbl_nm, schema_nm, fk_col_nm, pk_col_nm, unique_constraint_name, ordinal, table_type
         FROM ForeignKey fk LEFT JOIN TableDef td ON fk.foreign_table_nm=td.table_nm
         WHERE table_type = @table_type
         ORDER BY id;

      OPEN @cursor;
      FETCH NEXT FROM @cursor INTO @id, @fk_nm, @foreign_table_nm, @primary_tbl_nm, @schema_nm, @fk_col_nm, @pk_col_nm, @unique_constraint_name, @ordinal, @table_type2;
      EXEC sp_log 1, @fn, '02: @@FETCH_STATUS before first fetch: [', @@FETCH_STATUS, ']';

      WHILE (@@FETCH_STATUS = 0)
      BEGIN
         EXEC sp_log 1, @fn,'
 id:       [', @id,']
,fk_nm:    [', @fk_nm,']
,f_tbl_nm :[', @foreign_table_nm,']
,p_tbl_nm: [', @primary_tbl_nm,']
,schema_nm:[', @schema_nm,']
,fk_col_nm:[', @fk_col_nm,']
,pk_col_nm:[', @pk_col_nm,']
,uq_nm:    [', @unique_constraint_name,']
,ordinal:  [', @ordinal,']
,tbl_ty2:  [', @table_type2,']'
;
         IF @mode = 1 -- CREATE FK
         BEGIN
            SET @sql = CONCAT('ALTER TABLE [',@foreign_table_nm,'] WITH CHECK ADD CONSTRAINT [',@fk_nm,'] FOREIGN KEY(',@fk_col_nm,') REFERENCES [',@primary_tbl_nm,'] (',@pk_col_nm,');');
            SET @msg = 'Creating';
            EXEC( @sql);

            SET @sql = CONCAT('ALTER TABLE [',@foreign_table_nm, '] CHECK CONSTRAINT ',@fk_nm, ';');
         END
         ELSE --  @mode = 0: drop FK
         BEGIN
            SET @msg = 'Dropping';
            SET @sql = CONCAT('ALTER TABLE [',@foreign_table_nm,'] DROP CONSTRAINT IF EXISTS  [',@fk_nm,'];');
         END

         EXEC sp_log 1, @fn, @msg, ' @fk_nm: ',@sql;
         EXEC( @sql);

         FETCH NEXT FROM @cursor INTO @id, @fk_nm, @foreign_table_nm, @primary_tbl_nm, @schema_nm, @fk_col_nm, @pk_col_nm, @unique_constraint_name, @ordinal, @table_type;
      END -- WHILE (@@FETCH_STATUS = 0) OR (@id = 0)

      EXEC sp_log 2, @fn, '07: processing corrections Completed at row: ';
      IF @id = 0 EXEC sp_raise_exception 52417, 'No rows were processed'
      EXEC sp_log 2, @fn, '40: completed processing;'
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '99: leaving, OK';
END
/*
   EXEC sp_crt_FKs 'staging', 0
   EXEC sp_crt_FKs 'staging', 1
   EXEC sp_crt_FKs 'main', 0
   EXEC sp_crt_FKs 'main', 1
*/

GO
