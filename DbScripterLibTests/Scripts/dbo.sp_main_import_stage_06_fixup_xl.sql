SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2024
-- Description: fixup S2 using a Spreadsheets.xlsx file
--              then cache S2->S3 to make re-entry after this point quicker
--
-- Parameters:
-- @start_row:       this is the row id - the id column in the excel sheet default: 1
-- @stop_row:        [OPT] last row to be processed                        default: 100000
-- @cor_file_path:   [REQ] full path to the cor file
-- @cor_range:       [OPT]                                                 default: 'Sheet1$A:S'
-- @fixup_cnt        [OPT,OUT] returns the count of rows changed in the S2 table
--
-- POSTCONDITIONS:
-- POST 01: all pathogens should exist in the primary pathogens table or EX 57980, '<cnt> Unregistered pathogens exist in S2 see last results table', 1
-- POST 02: summary results (count and status msg) are always written back to the excel sheet in the act_cnt and results column
--
-- RETURNS:
--    0:  OK
--    1:  STOP signal detected
--   -1:  Error
--
-- CHANGES:
-- 240315: added optional parameters:
-- 240315: @cor_file to apply the feed back - results,errors, act counts
-- 240315: @cor_range to specifiy the range of the cor file
-- ======================================================================================
ALTER PROCEDURE [dbo].[sp_main_import_stage_06_fixup_xl]
    @start_row       INT            = 1
   ,@stop_row        INT            = 100000
   ,@cor_file_path   NVARCHAR(1000) = NULL
   ,@cor_range       NVARCHAR(1000) = 'Sheet1$A:S'
   ,@fixup_cnt       INT            = NULL OUTPUT
AS
BEGIN
   DECLARE
    @fn              NVARCHAR(35)   = 'MAIN_IMPRT_STG_06'
   ,@rc              INT            = 0
   ,@cnt             INT            = -1
   ,@msg             NVARCHAR(500)

   EXEC sp_log 1, @fn, '00: starting
start_row: [', @start_row,     ']
stop_row : [', @stop_row ,     ']
cor_file : [', @cor_file_path ,']
cor_range: [', @cor_range,     ']
fixup_cnt: [', @fixup_cnt,     ']
';

   BEGIN TRY
      EXEC sp_register_call @fn;

      ---------------------------------------------------------------------------------------------
      -- Fixup S2 using a Spreadsheets.xlsx file
      ---------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '05: calling sp_fixup_s2_using_corrections_file';

      EXEC @rc = sp_fixup_s2_using_corrections_file
          @start_row    = @start_row
         ,@stop_row     = @stop_row
         ,@fixup_cnt    = @fixup_cnt OUTPUT
         ,@cor_file     = @cor_file_path
         ,@cor_range    = @cor_range
         ;

      -- POST 01: all S2 pathogens should exist in the primary pathogens table or EX 57980, 'Unregistered pathogens exist in S2 see last results table', 1
      EXEC sp_log 1, @fn, '06: ret frm sp_fixup_s2_using_corrections_file';

      SET @cnt = (SELECT COUNT(*) FROM list_unregistered_pathogens_vw);

      IF @cnt <> 0
      BEGIN
         SELECT * FROM list_unregistered_pathogens_vw;
         SET @msg = CONCAT(@cnt, ' unregistered pathogens exist in S2 see last results table');
         EXEC sp_log 4, @fn, @msg;
         THROW 57980, @msg, 1;
      END

      ---------------------------------------------------------------------------------------------
      -- ASSERTION: all S2 pathogens exist in the primary pathogens table
      ---------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '10: ASSERTION: all S2 pathogens exist in the primary pathogens table';

      ---------------------------------------------------------------------------------------------
      -- if successful - and not stopped then cache a backup of Staging2 to Staging3 again 
      -- so can make re-entry after this point quicker
      ---------------------------------------------------------------------------------------------
      IF @rc = 0
      BEGIN
         EXEC sp_log 2, @fn, '15: caching S2->S3';
         EXEC sp_copy_s2_s3;
      END

      ---------------------------------------------------------------------------------------------
      -- Processing complete
      ---------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '80: Processing complete';
   END TRY
   BEGIN CATCH
      EXEC Ut.dbo.sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '95: leaving, @rc: ',@rc;
   RETURN @rc;
END
/*
   ---------------------------------------------------------------------------------------------
   EXEC sp_reset_CallRegister;
   DECLARE    ,@fixup_cnt    INT
   EXEC sp_main_import_stage_06_fixup_xl
    @start_row    = 1
   ,@stop_row     = 100000
   ,@cor_file     = ''
   ,@cor_range    = 'Sheet1$A:S'
   ,@fixup_cnt    = NULL OUTPUT
   ---------------------------------------------------------------------------------------------
*/

GO
