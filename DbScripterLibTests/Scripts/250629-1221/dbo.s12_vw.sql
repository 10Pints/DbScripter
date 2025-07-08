SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===================================================
-- Author:      Terry Watts
-- Create date: 27-JUN-20223
-- Description: List the 2 staging tables side by side
-- to help check update issues
-- ===================================================
CREATE   VIEW [dbo].[s12_vw]
AS 
   SELECT 
    a.id          AS id
   ,a.[uses]      AS s2_uses
   ,b.[uses]      AS s1_uses
   ,a.ingredient  AS s2_chemical
   ,b.ingredient  AS s1_chemical
   ,a.entry_mode  AS s2_entry_mode
   ,b.entry_mode  AS s1_entry_mode
   ,a.crops       AS s2_crops
   ,b.crops       AS s1_crops
   ,a.pathogens   AS s2_pathogens
   ,b.pathogens   AS s1_pathogens
   ,a.product     AS s2_product
   ,a.company     AS s2_company
   ,a.notes       AS s2_notes
   FROM list_staging2_vw a FULL JOIN list_staging1_vw b ON a.id=b.id;
/*
SELECT TOP 50 * FROM s12_vw;
*/


GO
