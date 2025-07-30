SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================
-- Author:		 TerryWatts
-- Create date: 27-DEC-2021
-- Description: returns true if tests are to be run in Debug mode
--               or false if value set to 0 or not defined 
-- ===========================================================================
CREATE FUNCTION [dbo].[fnGetDebugMode]()
RETURNS INT
AS
BEGIN
   RETURN ut.dbo.fnGetSessionContextAsInt(N'DEBUG');
END
GO

