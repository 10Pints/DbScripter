SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      TERRY WATTS
-- Create date: 18-APR-2020
-- Description: Creates an error message based on the current exception
--              and returns the full error message and its components (ex msg ex num, ex st, ex_ln)
-- =============================================
CREATE PROCEDURE [dbo].[sp_get_error_msg]
    @msg    NVARCHAR(500)     OUT
AS
BEGIN
   DECLARE @RC INT = ERROR_NUMBER();
   SET @msg =  CONCAT( @RC, ' proc: ', ERROR_PROCEDURE(),  ' line :', ERROR_LINE(), ' msg: ',ERROR_MESSAGE(), ' sev: ',ERROR_SEVERITY(), ' st:',ERROR_STATE()  );
   RETURN @RC;
END
/*
DECLARE @msg NVARCHAR(500) ;
EXEC sp_get_error_msg @msg OUT
*/
GO

