SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =======================================================
-- Author:      Terry Watts
-- Create date: 11-OCT-2023
-- Description: Lists the table FKs for either of
--  all tables:   (NULL,NULL)
--  1 table       (tbl_nm,NULL)
--  1 FK nm       (NULL,fk_nm)
-- =======================================================
ALTER FUNCTION [dbo].[fnListFkeys]
(
    @tbl_nm NVARCHAR(100) = NULL
   ,@fk_nm  NVARCHAR(100) = NULL
)
RETURNS 
@t TABLE
(
   fk_nm             NVARCHAR(60),
   foreign_table_nm  NVARCHAR(60),
   primary_tbl_nm    NVARCHAR(60),
   fk_col_nm         NVARCHAR(60),
   pk_col_nm         NVARCHAR(60),
   ordinal           INT,
   schema_nm         NVARCHAR(60)
)
AS
BEGIN
   INSERT INTO @t (fk_nm, foreign_table_nm, primary_tbl_nm, fk_col_nm, pk_col_nm, ordinal, schema_nm)
   SELECT
       fk_nm
      ,foreign_table_nm
      ,primary_tbl_nm
      ,fk_col_nm
      ,pk_col_nm
      ,ordinal
      ,schema_nm
   FROM fKeys_vw
   WHERE
       (foreign_table_nm= @tbl_nm OR @tbl_nm IS NULL)
   AND (fk_nm  = @fk_nm  OR @fk_nm  IS NULL)
   ORDER BY foreign_table_nm, fk_nm, ordinal
   RETURN;
END
/*
foreign_table_nm	fk_nm	primary_tbl_nm	schema_nm	col_nm	ordinal
Chemical	FK_Chemical_Import	Import	dbo	import_id	1
SELECT * FROM dbo.fnListFkeys( NULL, NULL);                                 -- Should list all FKs in database
SELECT * FROM dbo.fnListFkeys( 'ChemicalProduct', NULL);                    -- Should list all FKs for the ChemicalProduct table
SELECT * FROM dbo.fnListFkeys( NULL, 'FK_PathogenChemicalStaging_ChemicalStaging');  -- Should list 1 FK: FK_ChemicalPathogenStaging_Import
SELECT * FROM fnListFKeysForPrimaryTable('Chemical')
PRINT OBJECT_NAME(1214731480)
SELECT * FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE;
*/

GO
