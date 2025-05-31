SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 07-NOV-2023
-- Description: this view is used to import the actions
--
-- PRECONDITIONS: none
-- ======================================================================================================
ALTER   VIEW [dbo].[Import_ActionStaging_vw]
AS
SELECT action_id, action_nm
FROM Actionstaging;

/*
SELECT * FROM ImportActionStaging_vw;
*/


GO
