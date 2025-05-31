SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ====================================================================
-- Author       Terry Watts
-- Create date: 21-MAR-2024
-- Description: List the pathogen erros in the LRAP Import S2 table
--              NB: use this in preference to fnListPathogens() 
-- ====================================================================
ALTER VIEW [dbo].[list_unregistered_pathogens_vw]
AS
   SELECT TOP 10000 Pathogen as [Unregisterd Pathogen], concat('[',Pathogen,']') as x
   FROM dbo.fnListDistinctPathogensInS2()
   WHERE pathogen NOT in (SELECT pathogen_nm FROM Pathogen)
   ;
/*
SELECT * FROM list_unregistered_pathogens_vw ORDER BY [Unregisterd Pathogen];
*/

GO
