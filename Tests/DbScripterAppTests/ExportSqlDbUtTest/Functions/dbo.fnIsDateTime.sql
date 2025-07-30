SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ====================================================================
-- Author:      Terry Watts
-- Create date: 01-FEB-2021
-- Description: determines if a sql_variant is an
-- integral type: {int, smallint, tinyint, bigint, money, smallmoney}
-- ====================================================================
CREATE FUNCTION [dbo].[fnIsDateTime](@v SQL_VARIANT)
RETURNS BIT
AS
BEGIN
   DECLARE @type SQL_VARIANT
   DECLARE @ty   NVARCHAR(500)
   SELECT @type = SQL_VARIANT_PROPERTY(@v, 'BaseType');
   SET @ty = CONVERT(NVARCHAR(500), @type);
   RETURN
      CASE 
         WHEN @ty = 'date'             THEN  1
         WHEN @ty = 'datetime'         THEN  1
         WHEN @ty = 'datetime2'        THEN  1
         WHEN @ty = 'datetimeoffset'   THEN  1
         WHEN @ty = 'smalldatetime'    THEN  1
         ELSE                                0
         END;
END
GO

