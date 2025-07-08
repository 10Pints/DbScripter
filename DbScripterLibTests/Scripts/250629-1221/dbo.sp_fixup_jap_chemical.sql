SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 29-JUL-2023
-- Description: fixup the japChemList import
-- =============================================
CREATE PROCEDURE [dbo].[sp_fixup_jap_chemical]
AS
BEGIN
   DECLARE
      @fn VARCHAR(30)=N'FIXUP_JAP_CHEMS'

   EXEC sp_log 0, @fn, '01: starting';
   --EXEC sp_register_call @fn;
   UPDATE japChemical set type= 'HERBICIDE' WHERE name = 'Chlorthal-dimethyl' AND type NOT LIKE 'HERBICIDE'
   EXEC sp_fixup_jap_chemical_hlpr '1,3-dichloropropene', '1,3 Dichloropropene', 1;
   EXEC sp_fixup_jap_chemical_hlpr 'Bensulfuron-methyl',  'Bensulfuron-Methyl'  ,1;
   EXEC sp_fixup_jap_chemical_hlpr 'Kresoxim-methyl',     'Kresoxim-Methyl'     ,1;
   EXEC sp_fixup_jap_chemical_hlpr 'Iminoctadine tris(albesilate)', 'Iminoctadine Tris (albesilate)'
   EXEC sp_log 0, @fn, '99: leaving';
END
/*
EXEC sp_fixup_japChemList
*/

GO
