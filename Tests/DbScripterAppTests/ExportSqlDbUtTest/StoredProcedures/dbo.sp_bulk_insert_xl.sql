SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================================================================
-- Author:      Terry Watts
-- Create date: 14-JAN-2022
-- Description: Imports Excel file to the given table
--
-- PRE CONDITIONS:
--
-- POST CONDITIONS:
--    POST 1: xl_file exists                                OR (ex: 50101)
--    POST 2: table exists                                  OR (ex: 50102)
--    POST 3: import added added same number of rows as the @csv_file OR (ex: 50103)
--    POST 4: @format_file exists                           OR (ex: 50104)
--
-- Dependencies: none
--
-- =====================================================================================================
CREATE PROCEDURE [dbo].[sp_bulk_insert_xl]
    @xl_file      NVARCHAR(500)
   ,@table_spec   NVARCHAR(70)
   ,@range        NVARCHAR(500) = '[Sheet1$]'
   ,@xl_svr       NVARCHAR(70)
AS
BEGIN
DECLARE 
       @fn          NVARCHAR(20)   = N'BLK INS XL'
      ,@NL          NVARCHAR(2)    = ut.dbo.fnGetNL()
      ,@stage       NVARCHAR(120)
      ,@sql         NVARCHAR(4000)
      ,@flag        BIT
      ,@import_date DATE
   BEGIN TRY
      --EXEC sp_set_session_context N'BLK INS', 1
      EXEC ut..sp_log @fn, 'starting, tsv import file file: ', @xl_file, 'to table: ', @table_spec;
      SET @stage ='Stage 1: validating';
      -------------------------------------------------------------
      -- Validation: 
      -------------------------------------------------------------
      --  @csv_file exists
      -- POST 1: import file exists (validated  ex: 50100)
      EXEC UT.dbo.sp_assert_not_null_or_empty @xl_file, @msg='XL import file not specified', @ex_num=50100, @fn = @fn;
      SET @flag = dbo.fnFileExists (@xl_file)
      EXEC UT.dbo.sp_assert_not_equal 0, @flag, @msg='XL import file not found', @ex_num=50101,  @fn = @fn;
      -- POST 2: table exists                                  OR (ex: 50102)
      EXEC @flag = spTableExists @table_spec
      EXEC UT.dbo.sp_assert_not_equal 0, @flag, @msg='table does note exist: ', @msg2=@table_spec, @ex_num=50102,  @fn = @fn;
      -- POST 3: table  populated with the date from @csv_file OR (ex: 50103) - added same number of rows
      -------------------------------------------------------------
      -- Stage 2: Process
      -------------------------------------------------------------
      SET @stage ='Stage 2: processing'
      EXEC ut..sp_log @fn, @stage;
      SET @stage ='Stage 2: BULK INSERT to '
      EXEC ut..sp_log @fn, @stage, @table_spec;
      -- SELECT * FROM OPENQUERY(ExcelServer, 'SELECT * FROM [Sheet1$]')
      SET @sql = CONCAT('SELECT * FROM OPENQUERY(', @xl_svr, '''SELECT * FROM ', @range,'''' );
      PRINT CONCAT(@fn, ' sql:', @sql);
      EXEC sp_executesql @sql
      -- post processing for inserted ,  ??
--    POST 3: import added added same number of rows as the @csv_file OR (ex: 50103)
      SET @stage ='Stage 4:complete, validated POST CONDITIONS';
      EXEC ut..sp_log @fn, @stage;
   END TRY
   BEGIN CATCH
      EXEC UT.dbo.sp_log_exception @fn, @stage, ' import file: ', @xl_file;
      THROW;
   END CATCH
   EXEC ut..sp_log @fn, 'leaving COMPLETED';
END
/*
EXEC tSQLt.Run 'test.test_039_sp_bulk_insert_xl'
*/
GO

