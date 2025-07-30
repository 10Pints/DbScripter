SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =========================================================
-- Author:      Terry Watts
-- Create date: 12-MAY-2024
-- Description:Creates the drop script for the given schema
-- =========================================================
CREATE VIEW [dbo].[crt_drop_script_vw]
AS
   SELECT
       CONCAT('DROP ', rtn_ty, ' ', schema_nm, '.[', rtn_nm, '];') as cmd
      ,schema_nm
      ,rtn_nm
      ,rtn_ty
   FROM list_rtns_vw
   ;
/*
SELECT * FROM dbo.crt_drop_script_vw;
SELECT * FROM INFORMATION_SCHEMA.TABLES
*/
GO

