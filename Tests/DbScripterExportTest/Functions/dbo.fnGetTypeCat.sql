SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===================================================================
-- Author:      Terry Watts
-- Create date: 08-DEC-2024
-- Description: Gets the type category for a Sql Uerver datatype
-- e.g. Exact types : INT, MONEY 
-- Floating point types: float real
--
-- TESTS:
-- ===================================================================
CREATE   FUNCTION [dbo].[fnGetTypeCat](@ty VARCHAR(25))
RETURNS VARCHAR(25)
AS
BEGIN
   DECLARE @type SQL_VARIANT
   ;
   RETURN
      CASE
         WHEN dbo.fnIsIntType (@ty)     = 1 THEN 'Int'
         WHEN dbo.fnIsTextType(@ty)     = 1 THEN 'Text'
         WHEN dbo.fnIsTimeType(@ty) = 1 THEN 'Time'
         WHEN dbo.fnIsFloatType(@ty)    = 1 THEN 'Float'
         WHEN dbo.fnIsGuidType(@ty)     = 1 THEN 'GUID'
         END;
END
/*
EXEC test.sp__crt_tst_rtns '[dbo].[fnGetTypeCat]';
*/
GO

