SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ====================================================================
-- Author:      Terry Watts
-- Create date: 08-DEC-2024
-- Description: Returns true if a time type
--              Handles single and array types like INT and VARCHAR(MAX)
-- ====================================================================
ALTER   FUNCTION [dbo].[fnIsTimeType](@ty VARCHAR(20))
RETURNS BIT
AS
BEGIN
   RETURN iif(@ty IN ('date','datetime','datetime2','datetimeoffset','smalldatetime','TIME'), 1, 0);
END


GO
