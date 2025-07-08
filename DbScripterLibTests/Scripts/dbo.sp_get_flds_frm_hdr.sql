SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==========================================================================
-- Author:      Terry Watts
-- Create date: 15-MAR-2024
-- Description: gets the header fields from a tsv text file or an Excel file
--
-- PRECONDITIONS: file must be a tsv or Excel file
--
-- POSTCONDITIONS:
-- POST 01: return header fields in the @fields OUT parameter
-- ==========================================================================
CREATE PROCEDURE [dbo].[sp_get_flds_frm_hdr]
 @import_file  VARCHAR(500)
,@range        VARCHAR(100) = NULL
,@fields       VARCHAR(4000) OUT            -- comma separated
AS
BEGIN
DECLARE
 @fn           VARCHAR(30)   = 'sp_get_flds_frm_hdr'
,@file_type    BIT

      EXEC sp_log 1, @fn,'00: starting:
import_file:[', @import_file,']
range      :[', @range      ,']
fields     :[', @fields     ,']
';

   BEGIN TRY
      IF dbo.fnIsExcel(@import_file) = 1
         EXEC sp_get_flds_frm_hdr_xl @import_file, @range=@range, @fields=@fields OUT;
      ELSE
         EXEC sp_get_flds_frm_hdr_txt @import_file, @fields OUT, @file_type=NULL;
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      EXEC sp_log 3, @fn,'50: parameters:
file_path:   [', @import_file, ']';
      THROW;
   END CATCH

   EXEC sp_log 1, @fn,'99: leaving:';
END
/*
EXEC test'sp_get_flds_frm_hdr';

----------------------------------------------
DECLARE @fields       VARCHAR(4000)
EXEC sp_get_flds_frm_hdr 'D:\Dev\Farming\Data\Actions.txt',@fields OUT
PRINT CONCAT('fields: ', @fields);
----------------------------------------------
*/

GO
