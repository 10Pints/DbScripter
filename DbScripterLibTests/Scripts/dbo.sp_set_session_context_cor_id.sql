SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:		  Terry Watts
-- Create date:  19-AUG-2023
-- Description:  SETS a session context
-- ======================================================================================================
ALTER PROCEDURE [dbo].[sp_set_session_context_cor_id]
   @val     INT
AS
BEGIN
   DECLARE     @key     NVARCHAR(30)
   SET @key = dbo.fnGetSessionKeyCorId();
   EXEC sp_set_session_context @key, @val;
END
/*
EXEC sp_set_session_context_cor_id 35
PRINT CONCAT('old cor_id: [', dbo.fnGetSessionValueCorId(),']');
*/

GO
