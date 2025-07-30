SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================================================================
-- Author:      Terry Watts
-- Create date: 15-MAR-2024
-- Description: gets the fields from the first row of a tsv file
--
-- PRECONDITIONS:
-- PRE 01: @file_path must be specified   OR EXCEPTION 58000, 'file must be specified'
-- PRE 02: @file_path exists,             OR EXCEPTION 58001, 'file does not exist'
-- 
-- POSTCONDITIONS:
-- POST01:
--
-- CALLED BY: sp_get_get_hdr_flds
--
-- TESTS: test.test_sp_get_fields_from_tsv_hdr
--
-- CHANGES:
-- 05-MAR-2024: put brackets around the field names to handle spaces reserved words etc.
-- 05-MAR-2024: added parameter validation
-- ==========================================================================================================
CREATE PROCEDURE [dbo].[sp_get_fields_from_tsv_hdr]
    @file_path    NVARCHAR(500)
   ,@fields       NVARCHAR(4000) OUT            -- comma separated list
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35)   = N'GET_FLDS_FRM_TSV_HDR'
      ,@cmd       NVARCHAR(4000)
      ,@row_cnt   INT
   EXEC sp_log 2, @fn, '00: starting';
   BEGIN TRY
      -------------------------------------------------------
      -- Param validation, fixup
      -------------------------------------------------------
      --EXEC sp_log 1, @fn, '05: validating inputs';
      --------------------------------------------------------------------------------------------------------
      -- PRE 01: @file_path must be specified   OR EXCEPTION 58000, 'file must be specified'
      --------------------------------------------------------------------------------------------------------
      --EXEC sp_log 1, @fn, '010: checking PRE 01';
      EXEC Ut.dbo.sp_assert_not_null_or_empty @file_path, 'file must be specified', @ex_num=58000--, @fn=@fn;
      --------------------------------------------------------------------------------------------------------
      -- PRE 02: @file_path exists,             OR EXCEPTION 58001, 'file does not exist'
      --------------------------------------------------------------------------------------------------------
      --EXEC sp_log 1, @fn, '020: checking PRE 02';
      IF Ut.dbo.fnFileExists(@file_path) = 0 
         EXEC Ut.dbo.sp_raise_exception 58001, 'file does not exist';
      -------------------------------------------------------
      -- ASSERTION: Passed parameter validation
      -------------------------------------------------------
      --EXEC sp_log 1, @fn, '10: validation passed';
      -------------------------------------------------------
      -- Process
      -------------------------------------------------------
      --EXEC sp_log 1, @fn, '040: processing';
      DROP TABLE IF EXISTS temp;
      CREATE TABLE temp
      (fields NVARCHAR(MAX));
      -- IMEX=1 treats everything as text
      SET @cmd = 
         CONCAT
         (
      'BULK INSERT [temp] FROM ''', @file_path, '''
      WITH
      (
         FIRSTROW        = 1
        ,LASTROW         = 1
        ,ERRORFILE       = ''D:\Logs\get_flds_Import.log''
        ,FIELDTERMINATOR = ''\n''
        ,ROWTERMINATOR   = ''\n''
      );
   ');
      EXEC(@cmd);
      SET @row_cnt = (SELECT COUNT(*) FROM temp);
      --EXEC sp_log 1, @fn, '20: @row_cnt: ',@row_cnt;
      UPDATE temp SET fields = REPLACE(fields, NCHAR(9), ',');
      SET @fields = (SELECT TOP 1 fields FROM temp);
      --EXEC sp_log 1, @fn, '22: fields:[',@fields, ']';
      --SELECT * from temp;
      EXEC sp_assert_gtr_than @row_cnt, 0, 'header row not found (no rows inmported)';
      --SELECT @cmd = CONCAT('SET @fields = (SELECT TOP 1 CONCAT(',@fields, ') FROM [temp])');
      --EXEC sp_executesql @cmd, N'@fields NVARCHAR(4000) OUT', @fields OUT;
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      EXEC sp_log 2, @fn, '50: params, 
   @file_path:  [', @file_path,']
   @fields:     [', @fields,']'
   ;
      EXEC sp_log 1, @fn, '55: bulk insert command was:
',@cmd;
      THROW;
   END CATCH
   EXEC sp_log 2, @fn, '99: leaving, OK';
END
/*
EXEC tSQLt.Run 'test.test_sp_get_fields_from_tsv_hdr';
*/
GO

