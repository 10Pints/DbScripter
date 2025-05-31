SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===============================================================
-- Author:      Terry Watts
-- Create date: 20-SEP-2024
-- Description: this view is used to import the call register
--
-- PRECONDITIONS: none
-- ===============================================================
ALTER VIEW [dbo].[Import_CallRegister_vw]
AS
SELECT
       id
      ,rtn
      ,limit

FROM CallRegister;

/*
SELECT * FROM Import_CallRegister_vw;
*/

GO
