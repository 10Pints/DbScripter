SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ======================================================================================================
-- Author:       Terry Watts
-- Create date:  02-AUG-2023
-- Description:  sets a session context
--
-- See Also: fnGetSessionContextAsString, fnGetSessionContextAsInt
-- ======================================================================================================
CREATE   PROCEDURE [dbo].[sp_set_session_context]
    @key     VARCHAR(100)
   ,@val     SQL_VARIANT
AS
BEGIN
   EXEC sp_set_session_context @key, @val;
END
/*
EXEC dbo.sp_set_session_context 'Import Root', 'D:\Dev\Farming\Data'
PRINT CONCAT('[', dbo.fnGetSessionContextAsString('Import Root'),']');
*/


GO
