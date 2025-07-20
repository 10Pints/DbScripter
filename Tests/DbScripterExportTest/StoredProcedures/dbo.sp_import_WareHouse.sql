SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==========================================================================================================
-- Author:      Terry Watts
-- Create date: 05-NOV-2024
-- Description: Imports the Pg Gov Ag LRAP Fert-Warehouse handlers tsv file
--
-- Fixup:
------------------------------------------------------------------------------
-- column   fixup
------------------------------------------------------------------------------
-- expiry   converts text date to date 
-- type     converts Both Fertilizer & Pesticide to Fertilizer,Pesticide
------------------------------------------------------------------------------
--
-- PRECONDITIONS:
-- PRE01: none
--
-- POSTCONDITIONS:
-- POST01: WareHouse table must have rows
-- POST02: no double quotes exists in any column
-- POST03: no leaading/trailing wsp exists in any column
--
-- TESTS:
--
-- CHANGES:
-- ==========================================================================================================
CREATE   PROCEDURE [dbo].[sp_import_WareHouse]
    @file           VARCHAR(500)
   ,@folder         VARCHAR(600) = NULL
   ,@display_tables BIT = 0
AS
BEGIN
   DECLARE
       @fn                 VARCHAR(35)   = N'import_WareHouse'
      ,@bkslsh             CHAR(1)       = CHAR(92)
      ,@sql                VARCHAR(MAX)
      ,@cmd                VARCHAR(MAX)
      ,@error_file         VARCHAR(400)  = NULL
      ,@error_msg          VARCHAR(MAX)  = NULL
      ,@table_nm           VARCHAR(35)   = 'Distributor'
      ,@rc                 INT            = -1
      ,@import_root        VARCHAR(MAX)  
      ,@pathogen_row_cnt   INT            = -1
      ,@update_row_cnt     INT            = -1
      ,@null_type_row_cnt  INT            = -1
      ;

   SET NOCOUNT OFF
   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting:
file  :[', @file  ,']
folder:[', @folder,']
';

      ---------------------------------------
      -- Validate inputs
      ---------------------------------------
      IF @folder IS NOT NULL
         SET @file = CONCAT(@folder, @bkslsh, @file);

      ----------------------------------------------------------------------------------
      -- Process
      ----------------------------------------------------------------------------------

      EXEC sp_log 1, @fn, '020: calling sp_bulk_import_tsv2';
      EXEC sp_import_txt_file
          @table        ='WarehouseStaging'
         ,@file         = @file
         ,@non_null_flds='region,company_nm,warehouse_nm,address,type,expiry'
         ;

      ----------------------------------------------------------------------------------
      -- Do any fixup
      ----------------------------------------------------------------------------------

      ----------------------------------------------------------------------------------
      -- Copy WarehouseStaging to main Warehouse table with fixup
      ----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '030: Copy WarehouseStaging to main Warehouse table with fixup';
      DELETE FROM Warehouse;
      INSERT INTO Warehouse 
      (
          [region]
         ,[company_nm]
         ,[warehouse_nm]
         ,[address]
         ,[type]
         ,[expiry]
      )
      SELECT 
          tpc.dbo.NormaliseRegionShortName([region])
         ,[company_nm]
         ,[warehouse_nm]
         ,[address]
         ,iif([type]='Both Fertilizer & Pesticide', 'Fertilizer,Pesticide', [type])
         ,CONVERT(DATE,[expiry])
      FROM WarehouseStaging;

      IF @display_tables = 1 SELECT * FROM Warehouse;

      ----------------------------------------------------------------------------------
      -- Completed processing OK
      ----------------------------------------------------------------------------------
      SET @rc = 0; -- OK
      EXEC sp_log 1, @fn, '800: completed import and fixup OK'
   END TRY
   BEGIN CATCH
      SET @error_msg = ERROR_MESSAGE();
      EXEC sp_log 4, @fn, '500: Caught exception: ', @error_msg;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, RC: ', @rc
   RETURN @RC;
END
/*
EXEC sp_import_WareHouse 'D:\Dev\Farming\Data\Fert-Warehouse-20231231.txt';
SELECT * from Warehouse;
SELECT distinct [type] from Warehouse;
SELECT distinct [region] from Warehouse order by region;
*/


GO
