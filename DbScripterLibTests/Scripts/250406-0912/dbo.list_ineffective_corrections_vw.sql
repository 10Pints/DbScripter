SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 10-JAN-2025
-- Description: lists the import corrections that did not update any rows
--
-- CHANGES:
-- ======================================================================================================
ALTER VIEW [dbo].[list_ineffective_corrections_vw]
AS
SELECT row_id,command,search_clause,replace_clause,stg_file,[action],update_cnt
FROM ImportCorrections 
WHERE update_cnt = 0 AND (ACTION IS NULL OR ACTION NOT IN ('SKIP','STOP'))
;
/*
SELECT * FROM list_ineffective_corrections_vw
*/

GO
