SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 03-JUL-2023
-- Description: Converts string to camel case
-- =============================================
CREATE FUNCTION [dbo].[fn_CamelCase]( @str AS VARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS
BEGIN
DECLARE @bitval   BIT;
DECLARE @result   VARCHAR(1000);
DECLARE @i        INT;
DECLARE @j        CHAR(1);
SELECT @bitval = 1, @i=1, @result = '';
WHILE (@i <= LEN(@str))
   SELECT   
       @j      = SUBSTRING(@str,@i,1)
      ,@result = @result + 
                 CASE 
                    WHEN @bitval=1 THEN UPPER(@j) 
                    ELSE LOWER(@j)
                 END
      ,@bitval = 
         CASE
            WHEN @j LIKE '[a-zA-Z]' THEN 0 
            ELSE 1
         END
      ,@i = @i +1;
RETURN @result
END
/*
*/
GO

