SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ========================================================================================
-- Author:      Terry Watts
-- Create date: 15-MAR-2023
-- Description: returns 1 if the the file name has an .xlsx extension, 0 otherwise
--    0 = case insensitive, 1 = case sensitive
--
-- Postconditions:
--   POST01: returns 1 if the the file name has an .xlsx extension, 0 otherwise
-- ========================================================================================
CREATE   FUNCTION [dbo].[fnIsExcel](@filePath VARCHAR(500))
RETURNS BIT
AS
BEGIN
   RETURN IIF( @filePath IS NULL OR CHARINDEX('.xlsx', @filePath) = 0, 0, 1);
END
/*
   EXEC test.test_fnIsExcel;
*/


GO
