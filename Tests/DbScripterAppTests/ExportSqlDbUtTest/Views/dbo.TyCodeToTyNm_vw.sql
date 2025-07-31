SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================
-- Author:		  Terry Watts
-- Create date:  11-OCT-2023
-- Description:  Lists the xtype code to the respectie type name
-- ===============================================================
CREATE VIEW [dbo].[TyCodeToTyNm_vw]
AS
   SELECT LEFT(name,PATINDEX('%:%',name)-1) AS ty_code,
   REPLACE(REPLACE(RIGHT(name, (LEN(name) - PATINDEX('%:%',name))), ' CNS',''), ' (maybe)','') AS ty_nm
FROM master..spt_values
WHERE type = 'O9T'
  AND number  = -1;
/*
SELECT * FROM TyCodeToTyNm_vw
*/
GO

