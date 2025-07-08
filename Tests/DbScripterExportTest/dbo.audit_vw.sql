SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 16-AUG-2023
-- Description: displays the import/update audit
--
-- CHANGES:
--
-- ==============================================================================
CREATE   VIEW [dbo].[audit_vw] AS
SELECT TOP 10000 *
FROM
(
SELECT distinct ids, X.cor_id, old, new, search_clause, replace_clause, not_clause, row_cnt 
FROM
(
SELECT STRING_AGG(id, ',') as ids, cor_id --, old, new, search_clause, replace_clause, not_clause, row_cnt, cor_rnk 
FROM
(
SELECT id, stg_id, cor_id, old, new, search_clause, replace_clause, not_clause, row_cnt
,row_number() over (partition by cor_id order by id) as cor_rnk
FROM  CorrectionLog
) ranks
where cor_rnk<100
group by cor_id --, old, new, search_clause, replace_clause, not_clause, row_cnt, cor_rnk  
) X
JOIN CorrectionLog cl ON X.cor_id = cl.cor_id 
) Y
order by y.cor_id;
/*
SELECT TOP 50 * FROM audit_vw;
*/


GO
