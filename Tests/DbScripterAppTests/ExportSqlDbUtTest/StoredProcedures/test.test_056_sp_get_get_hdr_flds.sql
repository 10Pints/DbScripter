SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================================================================================================================
-- Author:      Terry Watts
-- Create date: 15-MAR-2024
-- Description: tests the sp_get_get_hdr_flds routine
-- Tested routine Description: gets the header fields from a tsv text file for Excel file
--
-- PRECONDITIONS: file must be a tsv or Excel file
--
-- POSTCONDITIONS:
-- POST 01: return header fields in the @fields OUT parameter
-- ============================================================================================================================
--[@tSQLt:SkipTest]('Temporarily disabled while refactoring')
CREATE PROCEDURE [test].[test_056_sp_get_get_hdr_flds]
    @rtn_name NVARCHAR(500) -- can be [db_nm.][schema_nm.][rtn_nm]
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn              NVARCHAR(35) = 'TEST_GET_GET_HDR_FLDS'
  EXEC sp_log 1, @fn,'00: starting:';
  EXEC sp_log 2, @fn,'99: leaving, OK';
END
/*
   EXEC test.test_sp_get_get_hdr_flds;
*/
GO

