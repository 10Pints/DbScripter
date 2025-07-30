SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ========================================================================
-- Author:      Terry Watts
-- Create date: 15-MAR-2024
-- Description: gets the header fields from a tsv text file for Excel file
--
-- PRECONDITIONS: file must be a tsv or Excel file
--
-- POSTCONDITIONS:
-- POST 01: return header fields in the @fields OUT parameter
-- ========================================================================
CREATE PROCEDURE [dbo].[sp_get_get_hdr_flds]
          @file_path_inc_range    NVARCHAR(500)
         ,@fields       NVARCHAR(4000) OUT            -- comma separated
AS
BEGIN
   DECLARE
          @fn           NVARCHAR(30)   = 'GET_HDR_FLDS'
      EXEC sp_log 1, @fn,'00: starting:
@file_path_inc_range:[', @file_path_inc_range,']';
   BEGIN TRY
      IF dbo.fnIsExcel(@file_path_inc_range) = 1
         EXEC sp_get_fields_from_xl_hdr @file_path_inc_range, @fields OUT;
      ELSE
         EXEC sp_get_fields_from_tsv_hdr @file_path_inc_range, @fields OUT;
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      EXEC sp_log 1, @fn,'50: parameters:
   file_path:   [', @file_path_inc_range, ']';
      THROW;
   END CATCH
   EXEC sp_log 1, @fn,'99: leaving:';
END
/*
EXEC test'test_sp_get_get_hdr_flds';
*/
GO

