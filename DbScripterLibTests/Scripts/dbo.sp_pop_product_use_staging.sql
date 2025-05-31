SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 01-AUG-2023
-- Description: Populates the product use table from 2 sources:
--              1: once the S2 table is fixed up call this to pop the product use table
--                  from the S2 information using ALL_vw
--              2: add the extra product use data to the product use table from the spreadsheet tsv
--
-- PRECONDITIONS:
--    PRE01: Use table must be populated
--    PRE02: ProductStaging table must be populated
--
-- POSTCONDITIONS:
--    POST01: ProductUse table populated
--
-- ALGORITHM:
--    0: PRECONDITION VALIDATION CHECKS
--    1: TRUNCATE the staging table
--    2: we can pop the Product Use staging table using All_vw
--    --(3: add the extra product use data to the product use table from the spreadsheet tsv ) redundant?  do in code ?
--    4: update ProductUse tbl with the use_id
--    5: update product_id where it is null
--
-- CHANGES:
-- 231006: added parameter: import id NULL optional
-- 231007: removed the bulk import from file
-- 240124: removed import id parameter
--
-- Tests:
-- ======================================================================================================
ALTER PROCEDURE [dbo].[sp_pop_product_use_staging]
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35)   = N'POP PROD USE_STAGING'
      ,@sql       NVARCHAR(MAX)
      ,@error_msg NVARCHAR(MAX)  = NULL
      ,@rc        INT            =-1
      ,@cnt       INT            = 0
      ;

   EXEC sp_log 2, @fn,'01: starting';
   EXEC sp_register_call @fn;

   BEGIN TRY
      -- PRE01: Use and UseStaging tables must be populated
      EXEC sp_chk_tbl_populated 'UseStaging';
      EXEC sp_chk_tbl_populated 'Use';

      -- ASSERTION: precondition checks passed

      EXEC sp_log 2, @fn,'02: truncating ProductUseStaging table';
      TRUNCATE TABLE dbo.ProductUseStaging;

      -- 2: pop the Product Use staging table using all_vw
      EXEC sp_log 1, @fn,'03: populating the ProductUseStaging table from ALL_vw ';
      INSERT INTO ProductUseStaging (product_nm, use_nm)
      SELECT distinct product_nm, use_nm
      FROM ALL_vw
      WHERE product_nm IS NOT NULL AND use_nm IS NOT NULL
      ORDER BY product_nm, use_nm;

      -- Chk POST01: ProductUse table populated
      EXEC sp_chk_tbl_populated 'ProductUseStaging'
   END TRY
   BEGIN CATCH
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, '50: Caught exception: ', @error_msg;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '99: leaving OK';
   RETURN @RC;

END
/*
   EXEC sp_pop_product_use_staging 1
   SELECT * FROM ProductUseStaging;
*/

GO
