SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 29-JUL-2023
-- Description: slists the import corractions actions and results
--
-- PRECONDITIONS: Dependencies: Staging2 upto date
--   Dependencies: staging2
-- ======================================================================================================
ALTER View [dbo].[ImportCorrections_vw]
AS
SELECT 
    id,command, doit,must_update, act_cnt, results, search_clause, not_clause, replace_clause,case_sensitive, latin_name
   ,common_name, local_name, alt_names, note_clause, crops, comments
FROM ImportCorrections;
/*
SELECT TOP 50 * FROM ImportCorrections_vw;
*/

GO
