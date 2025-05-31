SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 05-OCT-2024
-- Description: this view is used to import the import summary table
--
-- PRECONDITIONS: none
-- ======================================================================================================
ALTER   VIEW [dbo].[Import_Import_vw]
AS
SELECT import_id, import_nm, [description], new_fields, dropped_fields, error_count
FROM Import;
/*
SELECT * FROM [Import_Import_vw];
SELECT * FROM Import
*/


GO
