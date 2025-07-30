SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 16-DEC-2021
-- Description: Removes specific characters from 
--              the beginning end of a string
-- =============================================
CREATE FUNCTION [dbo].[fnTrim2]
(
    @str NVARCHAR(MAX)
   ,@trim_chr NVARCHAR(1)
)
RETURNS  NVARCHAR(MAX)
AS
BEGIN
   RETURN dbo.fnRTrim2(dbo.fnLTrim2(@str, @trim_chr), @trim_chr);
END
GO

