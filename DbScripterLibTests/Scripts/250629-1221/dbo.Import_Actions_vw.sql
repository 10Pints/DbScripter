SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 22-OCT-2023
-- Description: this view is used to import the chemical action types
--
-- PRECONDITIONS:
-- none
-- ======================================================================================================
CREATE   VIEW [dbo].[Import_Actions_vw]
AS
SELECT action_nm
FROM [ActionStaging];

/*
SELECT * FROM ImportActions_vw;
*/


GO
