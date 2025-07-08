SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ============================================================================================================
-- Author:      Terry Watts
-- Create date: 29-MAR-2024
-- Description: returns the import root key
--
-- Tests:
--
-- Changes:
-- ===========================================================================================================
CREATE   FUNCTION [dbo].[fnGetSessionKeyImportRoot]()
RETURNS NVARCHAR(50)
AS
BEGIN
   RETURN N'Import Root';
END


GO
