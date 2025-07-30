SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================================
-- Author:      Terry Watts
-- Create date: 31-OCT-2024
-- Description: determines if @ty is a text datatype
-- e.g. 'VARCHAR' is a text type
-- 
-- PRECONDITIONS: @ty is just the datatype without ()
-- e.g. 'VARCHAR' is OK but 'VARCHAR(20)' the output is undefined
-- =====================================================================
CREATE   FUNCTION [dbo].[fnIsTextType](@ty   VARCHAR(500))
RETURNS BIT
AS
BEGIN
   RETURN iif(@ty IN ('char','nchar','varchar','nvarchar'), 1, 0);
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_097_fnIsTextType';
*/
GO

