SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ====================================================================
-- Author       Terry Watts
-- Create date: 21-MAR-2024
-- Description: List the pathogen erros in the LRAP Import S2 table
--              NB: use this in preference to fnListPathogens() 
-- ====================================================================
ALTER view [dbo].[list_unregistered_pathogens_vw]
AS
   SELECT TOP 1000 Pathogen as Pathogen
   FROM dbo.fnListPathogens()
   WHERE pathogen NOT in (SELECT pathogen_nm FROM Pathogen)
   ORDER BY pathogen;

/*
SELECT * FROM list_unregistered_pathogens_vw;
*/

GO
