SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===============================================================
-- Author:      Terry watts
-- Create date: 30-MAR-2020
-- Description: returns true if the file exists, false otherwise
-- ===============================================================
ALTER FUNCTION [dbo].[fnFileExists](@path varchar(512))
RETURNS BIT
AS
BEGIN
     DECLARE @result INT
     EXEC master.dbo.xp_fileexist @path, @result OUTPUT
     RETURN cast(@result as bit)
END

GO
