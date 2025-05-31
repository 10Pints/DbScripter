SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

--==========================================================================================================
-- Author:           Terry Watts
-- Create date:      30-Nov-2024
-- Description: checks that all the supplied columns have at least 1 non null entry each
--
-- PRECONDITIONS: none
--
-- POSTCONDITIONS:
-- POST 01: returns 0 and all the specified fields in the specified table have at least 1 item of data each
-- OR throws exception 56321, msg: 'mandatory field:['<@table?'].'<field> has all Null values
--==========================================================================================================
ALTER   PROCEDURE [dbo].[sp_chk_flds_have_some_data]
    @table_nm        VARCHAR(60)
   ,@non_null_flds   VARCHAR(1000)= NULL
   ,@display_results BIT           = 0
AS
BEGIN
   DECLARE
    @fn              VARCHAR(35)   = N'chk_flds_have_some_data'
   ,@max_len_fld     INT
   ,@col             VARCHAR(32)
   ,@msg             VARCHAR(200)
   ,@sql             NVARCHAR(MAX)
   ,@ndx             INT = 1
   ,@end             INT
   ,@nl              NCHAR(2)       = NCHAR(13) + NCHAR(10)
   ,@cmds            ChkFldsNotNullDataType
    ;

   EXEC sp_log 0, @fn, '000: starting:
table_nm        :[', @table_nm       , ']
non_null_flds   :[', @non_null_flds  , ']
display_results :[', @display_results, ']'
   ;

   IF @non_null_flds IS NULL
      RETURN;

   BEGIN TRY
      SET @sql = CONCAT('SELECT @max_len_fld = MAX(dbo.fnLen(column_name)) FROM list_table_columns_vw WHERE table_name = ''', @table_nm, ''' AND is_txt = 1;');
      EXEC sp_log 0, @fn, '010: getting max field len: @sql:', @sql;
      EXEC sp_executesql @sql, N'@max_len_fld INT OUT', @max_len_fld OUT;
      EXEC sp_log 1, @fn, '020: @max_len_fld: ', @max_len_fld;

      INSERT INTO @cmds (ordinal, col, sql) 
      SELECT
          ordinal
         ,value
         ,CONCAT
         (
             'IF NOT EXISTS (SELECT 1 FROM ['
            ,@table_nm,'] WHERE '
            ,CONCAT('[',value,']') -- dbo.fnPadRight( CONCAT('[',value,']'), @max_len_fld+2)
            ,' IS NOT NULL) EXEC sp_raise_exception 56321, ''mandatory field:['
            ,@table_nm,'].['
            --,dbo.fnPadRight(CONCAT('[',value,'] has all Null values'';'), @max_len_fld+20)
            , value, '] column has no data'';'
         )
         FROM
         (
            SELECT ordinal, TRIM(dbo.fnDeSquareBracket(value)) as value 
            FROM string_split( @non_null_flds, ',', 1)
            WHERE TRIM(dbo.fnDeSquareBracket(value))<> '' AND value IS NOT NULL
         ) X

      IF @display_results = 1 SELECT * FROM @cmds;

      SELECT @end = COUNT(*) FROM @cmds;

      WHILE @ndx < = @end
      BEGIN
         SELECT 
             @sql = sql
            ,@col = col
         FROM @cmds
         WHERE ordinal = @ndx;

         SET @msg = CONCAT('030: checking col:[', @col, '] has no NULL values
SQL:
'
,@sql);

         EXEC sp_log 1, @fn, @msg;
         EXEC (@sql);
         SET @ndx = @ndx + 1
      END
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn, 'ordinal: ', ordinal, ' @sql: ', @nl, @sql;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: there are no null values in the checked columns';
END
/*
   CREATE TABLE #tmp
   (
       aaa VARCHAR(10)
      ,bbb  VARCHAR(10)
      ,ccc  VARCHAR(10)
   )
EXEC sp_chk_flds_have_some_data '#tmp', 'aaa';

EXEC tSQLt.Run 'test.test_045_sp_chk_flds_have_some_data';
*/


GO
