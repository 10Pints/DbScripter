SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 05-OCT-2024
-- Description: this view is used to import the Type table
--
-- PRECONDITIONS: none
-- ======================================================================================================
CREATE   VIEW [dbo].[Import_Type_vw]
AS
SELECT [type_id], type_nm
FROM [Type];
/*
SELECT * FROM Import_Type_vw;
SELECT * FROM Type
*/


GO
