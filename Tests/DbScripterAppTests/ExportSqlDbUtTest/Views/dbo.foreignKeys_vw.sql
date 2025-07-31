SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================
-- Author:		  Terry Watts
-- Create date:  11-OCT-2023
-- Description:  Lists the table FKs
-- ===========================================================
CREATE VIEW [dbo].[foreignKeys_vw]
AS
SELECT     TABLE_SCHEMA, TABLE_NAME, CONSTRAINT_NAME
FROM        INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE     (CONSTRAINT_TYPE = 'FOREIGN KEY')
/*
SELECT * FROM foreignKeysVw
*/
GO

