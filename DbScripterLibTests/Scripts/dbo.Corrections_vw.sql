SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 14-MAR-2024
-- Description: lists the import corrections act_cnt and results
--
-- PRECONDITIONS: 
-- Dependencies: ImportCorrections pop'd
-- ======================================================================================================
ALTER View [dbo].[Corrections_vw]
AS
SELECT id, results, act_cnt, doit, command, search_clause, not_clause
FROM ImportCorrections;
/*
SELECT TOP 50 * FROM ImportCorrections_vw;
*/

GO
