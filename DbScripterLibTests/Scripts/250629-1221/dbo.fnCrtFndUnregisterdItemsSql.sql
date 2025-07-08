SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==================================================================================================
-- Author:      Terry Watts
-- Create date: 10-DEC-2024
-- Description: returns the body of the select unregistered items SQL
--
-- Notes:
-- There are 2 types of field in staging2
-- 1: single value fields like Company, Product, concentration, formulation_type,toxicity, reg,expiry
-- 2: multi  value fields like ingredient, uses, entry_mode, crops, pathogens
-- These need handling differently
--
-- Preconditions: all parameters must be valid
-- Postconditions: output valid SQL body part to find the unregistered
--                 items for valid inoputs parameters
-- ==================================================================================================
CREATE FUNCTION [dbo].[fnCrtFndUnregisterdItemsSql]
(
    @is_multi_value  BIT
   ,@stg_field_nm    NVARCHAR(40)
   ,@table_nm        NVARCHAR(60)
   ,@pk_table_nm     NVARCHAR(40)
   ,@pk_field_nm     NVARCHAR(40)
   ,@sep             NVARCHAR(1)
)
RETURNS NVARCHAR(4000)
AS
BEGIN
   DECLARE
       @sql          NVARCHAR(4000)
      ,@nl           NCHAR(2) = NCHAR(13)+NCHAR(10)
      ,@tab          NCHAR(3) = '   '
   ;

-- 241210: handle multi value fields differently
-- There are 2 types of field in staging2
-- 1: single value fields like Company, Product, concentration, formulation_type,toxicity, reg,expiry
-- 2: multi  value fields like ingredient, uses, entry_mode, crops, pathogens
-- These need handling differently
   IF @table_nm       IS NULL SET @table_nm       = 'Staging2';
   IF @pk_table_nm    IS NULL SET @pk_table_nm    = dbo.fnRTrim2(@stg_field_nm, 's');
   IF @pk_field_nm    IS NULL SET @pk_field_nm    = CONCAT(dbo.fnRTrim2(@stg_field_nm, 's'), '_nm');
   IF @is_multi_value IS NULL SET @is_multi_value = iif(@stg_field_nm IN ('ingredient','uses','entry_mode','crops','pathogens'),1, 0);

   SET @sql = iif
   (
       @is_multi_value = 0
      ,CONCAT
      (
'(',@nl
,@tab,'SELECT DISTINCT TOP 1000 [', @stg_field_nm,'] AS item',@nl
,@tab,'FROM [', @table_nm,']',@nl
,@tab,'WHERE [', @stg_field_nm,'] NOT IN',@nl
,@tab,'(',@nl
,@tab,@tab,'SELECT [', @pk_field_nm,']',@nl
,@tab,@tab,'FROM [', @pk_table_nm,']', @nl
,@tab, ')', @nl
,') AS X;')

      ,CONCAT
      (@nl
,'(',@nl
,@tab,'SELECT DISTINCT TOP 1000 value AS item',@nl
,@tab,'FROM Staging2 CROSS APPLY string_split([', @stg_field_nm,'], ''',@sep, ''')',@nl
,@tab,'WHERE value NOT IN',@nl
,@tab,'(',@nl
,@tab,@tab,'SELECT [', @pk_field_nm,']', @nl
,@tab,@tab,'FROM [', @pk_table_nm,']',@nl
,@tab,')',@nl
,') X;')
   ); -- end iif

   --SET @sql = CONCAT(@sql,@NL, N'ORDER BY [', @stg_field_nm,'];');
   RETURN @sql;
END
/*
EXEC sp_fnd_unregistered_dynamic_data;
EXEC tSQLt.Run 'test.test_007_fnCrtFndUnregisterdItemsSql';

PRINT dbo.fnCrtFndUnregisterdItemsSql(1,'pathogens','staging2','Pathogen', 'pathogen_nm', ',');
GO
*/

GO
