SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================
-- Author:      Terry
-- Create date: 05-FEB-2021
-- Description: settings key for the failes test sub number
-- Tests: [test].[test 030 chkTestConfig]
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntFailedTstNumKey]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN N'Failed test num';
END


GO
