SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ====================================================================
-- Author:      Terry Watts
-- Create date: 12-OCT-2023
-- Description: Lists the table FKs for the @primary_table parameter
-- ====================================================================
ALTER   FUNCTION [dbo].[fnListFKeysForPrimaryTable](@primary_table VARCHAR(4000))
RETURNS table
AS
   RETURN
      SELECT * FROM dbo.fnListFkeys(NULL, NULL) WHERE primary_tbl_nm = @primary_table;

/*
SELECT * FROM dbo.fnListFKeysForPrimaryTable('Chemical')
*/


GO
