SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================================================================
-- Author:      Terry Watts
-- Create date: 14-JAN-2022
-- Description: Imports a CSV file to the given table
--
-- PRE CONDITIONS:
--
-- POST CONDITIONS:
--    POST 1: import file exists                            OR (ex: 50101)
--    POST 2: table exists                                  OR (ex: 50102)
--    POST 3: import added added same number of rows as the @csv_file OR (ex: 50103)
--    POST 4: @format_file exists                           OR (ex: 50104) 'File [',@file,'] does not exist'
--
-- Dependencies:
--
-- =====================================================================================================
CREATE PROCEDURE [dbo].[sp_import_csv]
    @csv_file     NVARCHAR(500)
   ,@table_spec   NVARCHAR(50)
   ,@view_spec    NVARCHAR(50)  = NULL
   ,@format_file  NVARCHAR(500) = NULL
AS
BEGIN
DECLARE 
    @fn              NVARCHAR(20)   = N'sp_import_csv'
   ,@NL              NVARCHAR(2)    = ut.dbo.fnGetNL()
   ,@stage           NVARCHAR(120)
   ,@sql             NVARCHAR(4000)
   ,@tbl_exists_flag BIT
   ,@import_date     DATE
   ,@row_cnt         INT
   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting:
csv_file:   [', @csv_file,']
table_spec: [', @table_spec,']
format_file:[', @format_file, ']'
;
      SET @stage ='Stage 1: validating';
      -------------------------------------------------------------
      -- Validation: 
      -------------------------------------------------------------
      --  @csv_file exists
      EXEC sp_log 1, @fn, '005: chking import file exists';
      -- POST 1: import file exists (validated  ex: 50101)
      EXEC sp_assert_file_exists @csv_file, @ex_num=50101; -- 'File [',@file,'] does not exist'
      EXEC sp_log 1, @fn, '010: ASSERTION: import csv file [', @csv_file,'] exists';
      -- POST 4: @format_file exists                           OR (ex: 50104)
      EXEC sp_assert_file_exists @format_file, @ex_num=50104;
      EXEC sp_log 1, @fn, '015: ASSERTION: format file [', @format_file, '] exists';
      -------------------------------------------------------------
      -- Create import sql
      -------------------------------------------------------------
      -- POST 2: table exists                                  OR (ex: 50102)
      EXEC @tbl_exists_flag = spTableExists @table_spec
      IF @tbl_exists_flag = 1
      BEGIN
         EXEC sp_log 1, @fn, '020: ASSERTION: table [', @table_spec,'] exists';
         SET @sql = CONCAT
         (
            'BULK INSERT ', iif(@view_spec IS NOT NULL, @view_spec, @table_spec),' FROM ''', @csv_file, '''
             WITH
             (
                FIRSTROW = 2
               ', IIF(@format_file IS NOT NULL, CONCAT('FORMATFILE=''', @format_file, ''''),''), ''' 
             );'
         );
      END
      ELSE
      BEGIN
         EXEC sp_log 1, @fn, '021: ASSERTION: table [', @table_spec,'] does not exist - so creating new table';
         SET @sql = CONCAT
         (
            'SELECT *
            INTO [', @table_spec,'] 
            FROM OPENROWSET
            (
                BULK ''', @csv_file, '''
               ,FORMATFILE = ''', @format_file, '''
               ,FIRSTROW   = 2
            ) AS session_insert;'
         );
      END
      EXEC sp_log 1, @fn, '030: sql:
', @sql;
      -------------------------------------------------------------
      -- Stage 2: Process
      -------------------------------------------------------------
      SET @stage ='Stage 2: performing BULK INSERT to table: ';
      EXEC sp_log 1, @fn, '025: ', @stage, @table_spec;
      EXEC (@sql);
      SET @row_cnt = @@ROWCOUNT;
      EXEC sp_log 1, @fn, '035: ASSERTION: imported ', @row_cnt, ' rows';
      -- SET @sql = CONCAT('SELECT * FROM [',@table_spec,'];');
      -- EXEC (@sql);
      -- post processing for inserted ,  ??
--    POST 3: import added added same number of rows as the @csv_file OR (ex: 50103)
      SET @stage ='040: processing complete, validated POST CONDITIONS';
      EXEC sp_log 1, @fn, @stage;
   END TRY
   BEGIN CATCH
      EXEC UT.dbo.sp_log_exception @fn, @stage, '850: import file: ', @csv_file;
      THROW;
   END CATCH
   EXEC ut..sp_log 1, @fn, '999: leaving COMPLETED';
   RETURN @row_cnt;
END
/*
EXEC tSQLt.Run 'test.test_037_sp_import_csv';
DROP TABLE IF EXISTS [table];
SELECT *
INTO [table] 
FROM OPENROWSET
(
BULK 'D:\Dev\Repos\Ut\Tests\test_037.csv'
,FORMATFILE = 'D:\Dev\Repos\Ut\Tests\test_037.fmt'
,FIRSTROW   = 2
) AS session_insert;
SELECT * from [table]
*/
GO

