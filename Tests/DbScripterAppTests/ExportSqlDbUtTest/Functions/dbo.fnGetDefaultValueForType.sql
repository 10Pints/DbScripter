SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================================
-- Author:      Terry Watts
-- Create date: 15-NOV-2023
-- Description: returns a string representing the default vlue for the type
-- ==========================================================================
CREATE FUNCTION [dbo].[fnGetDefaultValueForType]
(
   @ty_nm NVARCHAR(25)
)
RETURNS NVARCHAR(25)
AS
BEGIN
   DECLARE @r NVARCHAR(25)
   SET @r =
      CASE
         WHEN @ty_nm = 'BIT'           THEN '0'
         WHEN @ty_nm = 'BIGINT'        THEN '0'
         WHEN @ty_nm = 'SMALLINT'      THEN '0'
         WHEN @ty_nm = 'TINYINT'       THEN '0'
         WHEN @ty_nm = 'INT'           THEN '0'
         WHEN @ty_nm = 'NVARCHAR'      THEN ''''''
         WHEN @ty_nm = 'CHAR'          THEN ''''''
         WHEN @ty_nm = 'NCHAR'         THEN ''''''
         WHEN @ty_nm = 'NTEXT'         THEN ''''''
         WHEN @ty_nm = 'TEXT'          THEN ''''''
         WHEN @ty_nm = 'DATE'          THEN '0001-01-01'
         WHEN @ty_nm = 'DATETIME'      THEN 'January 1, 1753'
         WHEN @ty_nm = 'DATETIME2'     THEN 'January 1, 1753'
         WHEN @ty_nm = 'SQL_VARIANT'   THEN 'NULL'
         WHEN @ty_nm = 'BINARY'        THEN 'NULL'
         WHEN @ty_nm = 'VARBINARY'     THEN 'NULL'
         ELSE '????'
      END;
   RETURN @r
END
/*
PRINT dbo.fnGetDefaultValueForType('BIT'        )
PRINT dbo.fnGetDefaultValueForType('BIGINT'     )
PRINT dbo.fnGetDefaultValueForType('SMALLINT'   )
PRINT dbo.fnGetDefaultValueForType('TINYINT'    )
PRINT dbo.fnGetDefaultValueForType('INT'        )
PRINT dbo.fnGetDefaultValueForType('NVARCHAR'   )
PRINT dbo.fnGetDefaultValueForType('CHAR'       )
PRINT dbo.fnGetDefaultValueForType('NCHAR'      )
PRINT dbo.fnGetDefaultValueForType('NTEXT'      )
PRINT dbo.fnGetDefaultValueForType('TEXT'       )
PRINT dbo.fnGetDefaultValueForType('DATE'       )
PRINT dbo.fnGetDefaultValueForType('DATETIME'   )
PRINT dbo.fnGetDefaultValueForType('DATETIME2'  )
PRINT dbo.fnGetDefaultValueForType('SQL_VARIANT')
PRINT dbo.fnGetDefaultValueForType('BINARY'     )
PRINT dbo.fnGetDefaultValueForType('VARBINARY'  )
PRINT dbo.fnGetDefaultValueForType(''  )
PRINT dbo.fnGetDefaultValueForType(NULL)
PRINT dbo.fnGetDefaultValueForType('abc'  )
*/
GO

