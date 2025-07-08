SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ========================================================================================
-- Author:      Terry Watts
-- Create date: 09-JUL-2023
-- Description: returns the collation string for case sensitive or insensitve searches
--    0 = case insensitive, 1 = case sensitive
-- ========================================================================================
CREATE   FUNCTION [dbo].[fnGetCollation]( @case_sensitive BIT)
RETURNS VARCHAR(60)
AS
BEGIN
   RETURN IIF(@case_sensitive = 1, 'COLLATE Latin1_General_CS_AI', 'COLLATE Latin1_General_CI_AI');
END


GO
