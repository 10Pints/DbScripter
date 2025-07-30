SET ANSI_NULLS ON
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
    @str VARCHAR(MAX)
   ,@trim_chr VARCHAR(1)
)
RETURNS  VARCHAR(MAX)
AS
BEGIN
   RETURN dbo.fnRTrim2(dbo.fnLTrim2(@str, @trim_chr), @trim_chr);
END
GO

