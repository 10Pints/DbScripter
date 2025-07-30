SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================    
-- Author:  Terry Watts
-- Create date: 04-OCT-2019
-- Description: Pads Right
-- =============================================    
CREATE   FUNCTION [dbo].[fnPadRight]( @s VARCHAR(500), @width INT)
RETURNS VARCHAR (1000)
AS
BEGIN
   RETURN dbo.fnPadRight2( @s, @width, ' ' )
END
/*
SELECT CONCAT(', ]', dbo.fnPadRight([name], 25), ']  ', [type])
FROM [tg].[test].[fnCrtPrmMap]( '          @table_nm                  VARCHAR(50)  
         ,@folder                    VARCHAR(260)  
         ,@workbook_nm               VARCHAR(260)   OUTPUT  
         ,@sheet_nm                  VARCHAR(50)    OUTPUT  
         ,@view_nm                   VARCHAR(50)    OUTPUT  
         ,@error_msg                 VARCHAR(200)   OUTPUT  ')
*/
GO

