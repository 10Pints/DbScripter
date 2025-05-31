SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ====================================================================================
-- Author:      Terry Watts
-- Create date: 26-MAR-2024
-- Description: lists the chemicals and their aggregated actions on 1 row per chemical
-- ====================================================================================
ALTER VIEW [dbo].[ChemicalActionAgg_vw]
AS
SELECT chemical_nm, string_agg(action_nm,',') as actions
FROM ChemicalAction_vw
GROUP BY chemical_nm

/*
SELECT * FROM ChemicalActionAgg_vw where chemical_nm = '2,4-D Amine'
*/    

GO
