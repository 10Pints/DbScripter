SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 11-JUN-2021
--
-- Description: Imports Covid csv data into the database
--
-- PRECONDITIONS:
--    @imprt_csv_file not open
--
-- POSTCONDITIONS:
--    BoreholeImportStaging staging column 
--    populated with the entire import row
--
-- Tests:
-- =============================================
CREATE FUNCTION [dbo].[fnDeQuote](@s NVARCHAR(4000))
RETURNS NVARCHAR(4000)
AS
BEGIN
   RETURN IIF( SUBSTRING(@s,1,1) = '"',SUBSTRING(@s,2,dbo.fnLen(@s)-2), @s);
END
GO

