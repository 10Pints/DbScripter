SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


--================================================================================================
-- Author:        Terry Watts
-- Create date:   15-Nov-2024
-- Description:   check there are no NULL entries supplied columns
--
-- PRECONDITIONS: none
--
-- POSTCONDITIONS:
-- POST 01: returns 0 and no inccurrences in any of the specified fields in the specified table 
-- OR throws exception 56321, msg: 'mandatory field:['<@table?'].'<field> has Null value
--================================================================================================
CREATE PROCEDURE [dbo].[sp_chk_flds_not_null]
    @table            VARCHAR(60)
   ,@non_null_flds    VARCHAR(MAX) = NULL
   ,@display_results  BIT           = 0
   ,@msg              VARCHAR(100) = ''
AS
BEGIN
   DECLARE
    @fn           VARCHAR(35)   = N'sp_chk_flds_not_null'
   ,@max_len_fld  INT
   ,@col          VARCHAR(32)
--   ,@msg          VARCHAR(200)
   ,@sql          NVARCHAR(MAX)
   ,@ndx          INT = 1
   ,@end          INT
   ,@nl           NCHAR(2) = NCHAR(13) + NCHAR(10)
   ,@flds         ChkFldsNotNullDataType
    ;

   EXEC sp_log 1, @fn, '000: starting:
table           :[', @table          , ']
non_null_flds   :[', @non_null_flds  , ']
display_results :[', @display_results, ']'
   ;

   IF @non_null_flds IS NULL
      RETURN;

   BEGIN TRY
      SET @sql = CONCAT('SELECT @max_len_fld = MAX(dbo.fnLen(column_name)) FROM list_table_columns_vw WHERE table_name = ''', @table, ''';');
      EXEC sp_log 0, @fn, '010: getting max field len: @sql:', @sql;
      EXEC sp_executesql @sql, N'@max_len_fld INT OUT', @max_len_fld OUT;
      EXEC sp_log 1, @fn, '020: @max_len_fld: ', @max_len_fld;

      ----------------------------------------------------------------
      -- Create script to run non null chks on a set of fields
      ----------------------------------------------------------------
      EXEC sp_log 1, @fn, '030: Creating script to run non null chks on a set of fields';
      INSERT INTO @flds (ordinal, col, sql) 
      SELECT
          ordinal
         ,value
         ,CONCAT
         (
            'IF EXISTS (SELECT 1 FROM ['
            , @table,'] WHERE ',CONCAT('[',value,']'), ' IS NULL) EXEC sp_raise_exception 56321, ''mandatory field:['
            , @table,'].',CONCAT('[',value,'] has Null value'';')
         ) as sql
         FROM
         (
            SELECT ordinal, TRIM(dbo.fnDeSquareBracket(value)) as value FROM string_split( @non_null_flds, ',', 1)
         ) X

      IF @display_results = 1 SELECT * FROM @flds;
      --THROW 51000, 'debug',20;

      ----------------------------------------------------------------
      -- Execute script: run non null chks on each required field
      ----------------------------------------------------------------
      SELECT @end = COUNT(*) FROM @flds;

      WHILE @ndx < = @end
      BEGIN
         SELECT 
             @sql = sql
            ,@col = col
         FROM @flds
         WHERE ordinal = @ndx;

         --SET @msg = CONCAT('040: checking col: ', dbo.fnPadRight( CONCAT( '[', @col, ']'), @max_len_fld +1), ' has no NULL values');
         --SET @msg = CONCAT('050: check sql: ', @sql);
         --EXEC sp_log 1, @fn, @msg;
         EXEC (@sql);
         SET @ndx = @ndx + 1
      END
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn, 'table: ', @table, ' col ', @col,'has a null value. ', @msg;
      SELECT * FROM @flds;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: there are no null values in the checked columns';
END
/*
EXEC tSQLt.Run 'test.test_030_sp_chk_flds_not_null';
SELECT * FROM @flds
*/


GO
