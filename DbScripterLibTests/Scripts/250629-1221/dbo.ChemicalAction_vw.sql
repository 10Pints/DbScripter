SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ====================================================
-- Author:      Terry Watts
-- Create date: 28-OCT-2023
-- Description: lists the chemicals and their actions
-- ====================================================
CREATE   VIEW [dbo].[ChemicalAction_vw]
AS
SELECT c.chemical_nm, a.action_nm, c.chemical_id, a.action_id
FROM ChemicalAction ca
LEFT JOIN Chemical   c ON c.chemical_id = ca.chemical_id
LEFT JOIN [Action]   a ON a.action_id   = ca.action_id 

/*
SELECT * FROM ChemicalAction_vw
DELETE FROM ChemicalAction_vw
WHERE chemical_nm in ('Azoxystrobin','Allyl Ethoxylate','Chlorothalonil','Mancozeb','Propiconazole')
ORDER BY chemical_nm, action_nm
*/


GO
