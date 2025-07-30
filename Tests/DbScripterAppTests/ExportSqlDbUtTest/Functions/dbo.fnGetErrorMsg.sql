SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      TERRY WATTS
-- Create date: SEP-2019
-- Description: Creates an error message based on the current exception
-- =============================================
CREATE FUNCTION [dbo].[fnGetErrorMsg]() 
RETURNS NVARCHAR(3000)
AS
BEGIN
   RETURN 
      CONCAT
      (
          'Error ', ERROR_NUMBER()
         ,iif
         ( 
            ERROR_NUMBER() >=0, 
            CONCAT( ', MSG: ', 
            ERROR_MESSAGE()), ''
         )
         , ' Ln: ', ERROR_LINE()
         , ' st: ', ERROR_STATE()
      );
END
/*
;THROW 54721, 'abcd',1;
PRINT [dbo].[fnGetErrorMsg]();
*/
GO

