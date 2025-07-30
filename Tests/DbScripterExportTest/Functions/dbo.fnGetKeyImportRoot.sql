SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =================================================================================
-- Author:      Terry Watts
-- Create date: 02-AUG-2023
-- Description: returns the standard session kjey for import root: [Import Root]
-- =================================================================================
CREATE FUNCTION [dbo].[fnGetKeyImportRoot]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN N'Import Root';
END
/*
PRINT CONCAT('[', dbo.fnGetKeyImportRoot(), ']');
*/
GO

