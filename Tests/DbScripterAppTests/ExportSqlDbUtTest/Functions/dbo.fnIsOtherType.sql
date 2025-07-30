SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===================================================================
-- Author:      Terry Watts
-- Create date: 08-DEC-2024
-- Description: determines if type is of type 'other' 
-- see https://www.sqlshack.com/an-overview-of-sql-server-data-types/
-- Cursor,Rowversion,Hierarchyid,Uniqueidentifier,XML,Spatial Geometry type,Spatial Geography Types,Table
-- ===================================================================
CREATE FUNCTION [dbo].[fnIsOtherType](@v SQL_VARIANT)
RETURNS BIT
AS
BEGIN
   DECLARE @type SQL_VARIANT
   DECLARE @ty   NVARCHAR(500)
   ;
   SELECT @type = SQL_VARIANT_PROPERTY(@v, 'BaseType');
   SET @ty = CONVERT(NVARCHAR(500), @type);
   RETURN
      CASE
         WHEN @ty = 'Cursor'                  THEN 1
         WHEN @ty = 'Rowversion'              THEN 1
         WHEN @ty = 'Hierarchyid'             THEN 1
         WHEN @ty = 'Uniqueidentifier'        THEN 1
         WHEN @ty = 'XML'                     THEN 1
         WHEN @ty = 'Spatial Geometry type'   THEN 1
         WHEN @ty = 'Spatial Geography Types' THEN 1
         WHEN @ty = 'Table'                   THEN 1
         ELSE                                      0
         END;
END
GO

