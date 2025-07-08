SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ======================================================
-- Author:      Terry Watts
-- Create date: 14-NOV-2024
-- Description: lists Eppo names, and related group info
-- ======================================================
CREATE   VIEW [dbo].[eppo_gaf_nm_grp_vw]
AS
SELECT N.code, N.lang as nm_lang, N.langno, N.preferred as preferred_nm, N.fullname, N.shortname, n.authority as nm_auth, n.status as nm_status,L.grp_dtype, L.grp_code, G.lang as grp_lang, G.preferred as preferred_grp,g.status,g.fullname as grp_full_nm, g.shortname as grp_short_nm, g.authority as grp_auth
FROM Eppo_GAFNAME n JOIN Eppo_GAFLINK L ON n.code= L.datatype
LEFT JOIN Eppo_GAFGROUP g on G.code = L.grp_code;
/*
SELECT TOP 200 * FROM eppo_gaf_nm_grp_vw
WHERE fullname like '%Bunchy top%' AND  fullname like '%Banana%'
ORDER BY code, nm_lang, preferred_nm DESC;

SELECT TOP 200 * FROM eppo_gaf_nm_grp_vw
WHERE fullname like '%Fusarium wilt%' 
and (fullname like '%banana%' OR fullname like '%musa%')
ORDER BY fullname, nm_lang, preferred_nm DESC;

SELECT TOP 200 * FROM eppo_gaf_nm_grp_vw
WHERE fullname like '%Fusarium oxysporum%cubense%' 

SELECT TOP 200 * FROM eppo_gaf_nm_grp_vw
WHERE code LIKE 'BBTV%'
ORDER BY code, nm_lang, preferred_nm DESC;

SELECT * FROM eppo_gaf_nm_grp_vw
WHERE code LIKE 'FUSAC%'
ORDER BY code, nm_lang, preferred_nm DESC;

SELECT * FROM eppo_gaf_nm_grp_vw ev JOIN
(
SELECT distinct code FROM eppo_gaf_nm_grp_vw 
WHERE code LIKE 'FUSAC%'
) x ON ev.code = x.code
WHERE ev.nm_lang IN ('en','la')
ORDER BY ev.code;

SELECT * FROM GAFNAME WHERE fullname like '%''''%'
SELECT top 100 * FROM GafGroup WHERE fullname like '%''%' OR shortname like '%''%';
*/


GO
