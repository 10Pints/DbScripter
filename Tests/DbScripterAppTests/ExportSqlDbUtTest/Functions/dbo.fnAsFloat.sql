SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 18-JAN-2020
-- Description: converts and returns input to a float if possible 
--              or return null of not
--
-- PRECONITIONS - none
--
-- POSTCONDITIONS
-- RETURNS
-- Float value of the input if possible or NULL if not
-- =============================================
CREATE FUNCTION [dbo].[fnAsFloat](@v SQL_VARIANT)
RETURNS FLOAT
AS
BEGIN
   RETURN TRY_CONVERT(float, @v)
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_091_fnAsFloat';
*/
GO

