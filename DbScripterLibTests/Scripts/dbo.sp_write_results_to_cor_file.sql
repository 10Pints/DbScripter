SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ============================================================================================================================
-- Author:      Terry Watts
-- Create date: 15-MAR-2024
-- Description: This routine writes the results back to the cor file in the import root folder
--
-- Parameters:
--  @cor_file_path : the corrections Excel full file path
--  @cor_range     : the specified range to write to - uses the columns act_cnt and results
--
-- PRECONDITIONS:
-- PRE 01: ImportCorrections table results and cnt fields populated
--
-- POSTCONDITIONS:
-- POST 01: @cor_file_path must be specified exception 90000, 'The cor file must be specified'
-- POST 02: @cor_file_path must be an .xlsx file or exception 90001, 'The cor file [',@cor_file_path,'] must be an Excel file'
-- POST 03: cor_file_pathfile must exist or exception 90002, 'The cor file [',@cor_file_path,'] does not exist'
-- POST 04: results written back to @cor_file_path or error message logged
--
-- Changes:
-- 240329: changed input parameter @cor_file_path to @cor_file i.e. just the file name - the folder is now the import rot
--          if just the file name is specified in @cor_file then the default folder is the import root
--
-- ============================================================================================================================
ALTER PROCEDURE [dbo].[sp_write_results_to_cor_file]
    @cor_file        NVARCHAR(1000)
   ,@cor_range       NVARCHAR(1000) = 'ImportCorrections$A:S'
AS
BEGIN
   DECLARE
    @fn              NVARCHAR(35)   = N'WRITE_RSLTS_TO_COR_FILE'
   ,@sql             NVARCHAR(MAX)
   ,@cnt             INT
   ,@cor_file_path   NVARCHAR(1000)

   SET NOCOUNT ON;

   EXEC sp_log 2, @fn,'00: starting:
@cor_file:     [',@cor_file,      ']
@cor_range:    [',@cor_range,     ']
';

   -- if just the file name is specified in @cor_file then the default folder is the import root
   IF CHARINDEX('\', @cor_file) = 0
      SET @cor_file_path = CONCAT(ut.dbo.fnGetImportRoot(), '\', @cor_file);
   ELSE
   BEGIN
      SET @cor_file_path = @cor_file;
      SET @cor_file = Ut.dbo.fnGetFileNameFromPath(@cor_file, 1); -- if @cor_file was spec'd as full path - set it to be the file only
   END

   EXEC sp_log 1, @fn,'05: updated params:
@cor_file:     [',@cor_file,      ']
@cor_file_path:[',@cor_file_path, ']
@cor_range:    [',@cor_range,     ']
';

    BEGIN TRY
      -----------------------------------------------------------------------------------------------------------
      -- Validating parameters
      -----------------------------------------------------------------------------------------------------------
      EXEC sp_write_results_to_cor_file_param_val
          @cor_file      = @cor_file
         ,@cor_file_path = @cor_file_path
         ,@cor_range     = @cor_range;

      -----------------------------------------------------------------------------------------------------------
      -- Processing
      -----------------------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'10: processing';
      SELECT @cnt = COUNT(*) FROM ImportCorrections
      EXEC sp_log 2, @fn,'15: updating Excel cor file, ImportCorrections has ', @cnt, ' rows ...';
      EXEC sp_executesql @sql, N'@cnt INT OUT', @cnt OUT;
      EXEC sp_log 2, @fn,'20: Excel cor file JOIN ImportCorrections has ', @cnt, ' common rows ...';

      SET @sql = 
CONCAT
(
'UPDATE xl
SET act_cnt=ic.act_cnt,results=ic.results
FROM OPENROWSET
(
      ''Microsoft.ACE.OLEDB.12.0''
   ,''Excel 12.0;HDR=YES;Database='    , @cor_file_path , ';''
   ,''SELECT id,results,act_cnt FROM [', @cor_range, ']''
) AS xl
JOIN ImportCorrections ic ON xl.id=ic.id'
);

      PRINT @sql;
      EXEC(@sql);

      -----------------------------------------------------------------------------------------------------------
      -- Processing complete
      -----------------------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '30: completed processing;'
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '50: sql:',@sql;
      EXEC Ut.dbo.sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '99: leaving, OK';
END
/*                                                                                              -- Expect:
EXEC sp_write_results_to_cor_file @cor_file_path = NULL, @cor_range = 'ImportCorrections$A:S'              -- exception 90000, 'The cor file must be specified'
EXEC sp_write_results_to_cor_file @cor_file_path = '', @cor_range   = 'ImportCorrections$A:S'              -- exception 90000, 'The cor file must be specified'
EXEC sp_write_results_to_cor_file @cor_file_path = 'x.xlsy'                                     -- exception 90001, 'The cor file [x.xlsy] must be an Excel file'
EXEC sp_write_results_to_cor_file @cor_file_path = 'ImportCorrections 221018 230816-2000.xlsx'  -- exception 90002, 'The cor file [ImportCorrections 221018 230816-2000.xlsx] does not exist'

EXEC sp_write_results_to_cor_file
 @cor_file   ='ImportCorrections 221018 230816-2000.xlsx'
,@cor_range  ='ImportCorrections$A:S'
*/

GO
