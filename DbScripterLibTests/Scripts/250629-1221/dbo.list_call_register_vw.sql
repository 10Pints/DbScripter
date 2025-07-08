SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ============================================================================
-- Author       Terry Watts
-- Create date: 07-FEB-2024
-- Description: List all Registered fn call counts by fn
-- ============================================================================
CREATE   VIEW [dbo].[list_call_register_vw]
AS
   SELECT id, rtn, [count], updated FROM dbo.CallRegister;

/*
SELECT * FROM list_call_register_vw  ORDER BY updated;
*/


GO
