SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================    
-- Author:  Terry Watts
-- Create date: 04-OCT-2019
-- Description: Pads Right
-- =============================================    
ALTER FUNCTION [dbo].[fnPadRight]( @s NVARCHAR(500), @width INT)
RETURNS NVARCHAR (1000)
AS
BEGIN
   RETURN dbo.fnPadRight2( @s, @width, ' ' )
END
/*
SELECT CONCAT(', ]', ut.dbo.fnPadRight([name], 25), ']  ', [type])
FROM [tg].[test].[fnCrtPrmMap]( '          @table_nm                  NVARCHAR(50)  
         ,@folder                    NVARCHAR(260)  
         ,@workbook_nm               NVARCHAR(260)   OUTPUT  
         ,@sheet_nm                  NVARCHAR(50)    OUTPUT  
         ,@view_nm                   NVARCHAR(50)    OUTPUT  
         ,@error_msg                 NVARCHAR(200)   OUTPUT  ')
*/

GO
