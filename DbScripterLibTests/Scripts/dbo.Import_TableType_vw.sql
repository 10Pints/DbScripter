SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 05-OCT-2024
-- Description: this view is used to import the TableType table
--
-- PRECONDITIONS: none
-- ======================================================================================================
CREATE   VIEW [dbo].[Import_TableType_vw]
AS
SELECT id, name
FROM TableType;
/*
SELECT * FROM Import_TableTypef_vw;
SELECT * FROM TableType
GO
*/


GO
