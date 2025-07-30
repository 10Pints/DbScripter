SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ====================================================================
-- Author:      Terry Watts
-- Create date: 08-DEC-2024
-- Description: determines if a sql_variant is a time type 
-- i.e. in {Date, Datetime,Datetime2,Datetimeoffset,smalldatetime,Time}
-- test: [test].[t 025 fnIsFloat]
-- ====================================================================
CREATE FUNCTION [dbo].[fnIsTimeType]( @v SQL_VARIANT)
RETURNS BIT
AS
BEGIN
   DECLARE @type SQL_VARIANT
   DECLARE @ty   NVARCHAR(500)
   SELECT  @type = SQL_VARIANT_PROPERTY(@v, 'BaseType');
   SET @ty = CONVERT(NVARCHAR(500), @type);
   RETURN
      CASE 
         WHEN @ty = 'Date'           THEN 1
         WHEN @ty = 'Datetime'       THEN 1
         WHEN @ty = 'Datetime2'      THEN 1
         WHEN @ty = 'Datetimeoffset' THEN 1
         WHEN @ty = 'smalldatetime'  THEN 1
         WHEN @ty = 'Time'           THEN 1
         ELSE                        0
         END;
END
GO

