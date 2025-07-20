SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 17-JUN-2025
-- Description: infers the field types froma staging table
--    based on its data
--    pops the FieldInfo table
--
-- Design:      EA: Dorsu Model.Use Case Model.Create and populate a table from a data file.Infer the field types from the staged data
-- Tests:       test_074_sp_infer_field_types
--
-- Postconditions: POST01: pops the FieldInfo table
-- =============================================
CREATE PROCEDURE [dbo].[sp_infer_field_types]
   @q_table_nm VARCHAR(60)
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn           VARCHAR(35)   = N'sp_infer_field_types'
      ,@sql          NVARCHAR(4000)
      ,@schema       VARCHAR(60)
      ,@table_nm     VARCHAR(60)
      ,@fld_ty       VARCHAR(25)
      ,@fld_id       INT
      ,@fld_nm       VARCHAR(50)
      ,@len          INT
  ;

   EXEC sp_log 1, @fn, '000: starting:
@q_table_nm:[',@q_table_nm,']
';

   BEGIN TRY
      SELECT
          @schema = a
         ,@table_nm = b
      FROM dbo.fnSplitPair2(@q_table_nm, '.');

      IF @table_nm IS NULL
      BEGIN
         EXEC sp_log 1, @fn, '005: schema not specified - defaulting to dbo';
         SELECT
             @table_nm = @schema
            ,@schema   = 'dbo'
         ;
      END

      EXEC sp_log 1, @fn, '010: starting:
   @schema:  [',@schema,']
   @table_nm:[',@table_nm,']
   ';

      -- Clear the field info table
      TRUNCATE TABLE FieldInfo;

      -- Get the field info for the table
      SET @sql = CONCAT('INSERT INTO FieldInfo(nm) SELECT COLUMN_NAME
   FROM INFORMATION_SCHEMA.COLUMNS
   WHERE TABLE_NAME = '''  , @table_nm, '''
     AND TABLE_SCHEMA = ''', @schema, ''';'
     );

      EXEC sp_log 1, @fn, '020: @sql:
', @sql;

      EXEC (@sql);
      EXEC sp_log 1, @fn, '030:';
      --SELECT * FROM FieldInfo;

      -- For each field in the staged data
      DECLARE _cursor CURSOR FOR SELECT id, nm  FROM FieldInfo;
      OPEN _cursor;
      FETCH NEXT FROM _cursor INTO @fld_id, @fld_nm;
      EXEC sp_log 1, @fn, '035:';

      -- For each fields
      WHILE @@FETCH_STATUS = 0
      BEGIN
         EXEC sp_log 1, @fn, '040: @fld_id: ',@fld_id, ' @fld_nm[',@fld_nm,']';

         -- For each field type we are interested in:
         -- Chk if all data item in that field are:
         WHILE 1=1
         BEGIN
            SET @fld_ty = NULL;
            EXEC sp_log 1, @fn, '050: trying BIT';

            -- Bit?	Set field type = bit
            SET @sql = dbo.fnCrtFldNotNullSql(@q_table_nm, @fld_nm, 'BIT');
            EXEC sp_executesql @sql, N'@fld_ty VARCHAR(15) OUT', @fld_ty OUT;
            IF @fld_ty IS NOT NULL BREAK;

            -- Int?	Set field type = int
            EXEC sp_log 1, @fn, '060: trying INT';
            SET @sql = dbo.fnCrtFldNotNullSql(@q_table_nm, @fld_nm, 'INT');
            EXEC sp_executesql @sql, N'@fld_ty VARCHAR(15) OUT', @fld_ty OUT;
            IF @fld_ty IS NOT NULL BREAK;

            EXEC sp_log 1, @fn, '070: trying REAL';
            SET @sql = dbo.fnCrtFldNotNullSql(@q_table_nm, @fld_nm, 'REAL');
            EXEC sp_executesql @sql, N'@fld_ty VARCHAR(15) OUT', @fld_ty OUT;
            IF @fld_ty IS NOT NULL BREAK;

         -- Floating point?	Set field type = double
            EXEC sp_log 1, @fn, '080: trying FLOAT';
            SET @sql = dbo.fnCrtFldNotNullSql(@q_table_nm, @fld_nm, 'FLOAT');
            EXEC sp_executesql @sql, N'@fld_ty VARCHAR(15) OUT', @fld_ty OUT;
            IF @fld_ty IS NOT NULL BREAK;

            -- GUID ?	Set field type = GUID
            EXEC sp_log 1, @fn, '090: trying GUID';
            SET @sql = dbo.fnCrtFldNotNullSql(@q_table_nm, @fld_nm, 'UNIQUEIDENTIFIER');
            EXEC sp_executesql @sql, N'@fld_ty VARCHAR(15) OUT', @fld_ty OUT;
            IF @fld_ty IS NOT NULL BREAK;

            -- Assume text field
            EXEC sp_log 1, @fn, '100: Assume text field';
            -- Set len = max len of the field
            SET @sql =
            CONCAT
            (
               'SELECT @len = MAX(dbo.fnLen(',@fld_nm,')) FROM 
            ', @q_table_nm, ';'
            )

            EXEC sp_log 1, @fn, '110:sql:
',@sql;
            EXEC sp_executesql @sql, N'@len INT OUT', @len OUT;
            EXEC sp_log 1, @fn, '120:@len:
',@len;
            SET @fld_ty = CONCAT('VARCHAR(', @len, ')')
            BREAK;
         END -- for each wanted field ty

         EXEC sp_log 1, @fn, '110: field ty is ',@fld_ty;
         -- Add the field info to the FieldInfo table
         UPDATE FieldInfo SET ty = @fld_ty WHERE id = @fld_id;
         FETCH NEXT FROM _cursor INTO @fld_id, @fld_nm;
      END -- outer while - for each row in FieldInfo

      CLOSE _cursor;
      DEALLOCATE _cursor;
      EXEC sp_log 1, @fn, '200: checking postconditions';

      -- Postconditions: POST01: pops the FieldInfo table
      EXEC sp_log 1, @fn, '210: checking POST01: pops the FieldInfo table';
      EXEC sp_assert_tbl_pop 'FieldInfo';
      EXEC sp_log 1, @fn, '299: completed processing loop';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';

      IF CURSOR_STATUS('global','_cursor')>=-1 
      BEGIN
         CLOSE _cursor;
         DEALLOCATE _cursor;
      END
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving ok';
END
/*
EXEC test.test_074_sp_infer_field_types;
SELECT * FROM FileActivityStaging

EXEC tSQLt.RunAll;
*/

GO
