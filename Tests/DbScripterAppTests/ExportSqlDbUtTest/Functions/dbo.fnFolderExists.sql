SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnFolderExists](@path varchar(512))
RETURNS BIT
AS
BEGIN
   RETURN dbo.fnFileExists (@path + '\nul')
END;
GO

