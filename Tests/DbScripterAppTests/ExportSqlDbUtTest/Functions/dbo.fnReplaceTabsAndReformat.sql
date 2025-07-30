SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[fnReplaceTabsAndReformat](@sql_snippet [nvarchar](4000), @tab_size [int])
RETURNS [nvarchar](4000) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [ClrFunctions].[ClrFunctions.ClrFunctions].[ReplaceTabsAndReformat_V3]
GO

