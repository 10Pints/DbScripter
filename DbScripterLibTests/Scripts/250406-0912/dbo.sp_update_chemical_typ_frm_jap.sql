SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =========================================================
-- Author:      Terry Watts
-- Create date: 29-JUL-2023
-- Description:
-- Adds the type information from the japChemList table
-- Do after jap chemlist and chemical alignment
--  sp_fixup_japChemList and sp_fixup_s2_chems
-- =========================================================
ALTER   PROCEDURE [dbo].[sp_update_chemical_typ_frm_jap]
AS
BEGIN
   DECLARE
       @fn        VARCHAR(30)   = 'UPDATE_CHEM_TYP_FRM_JAP'

   EXEC sp_register_call @fn;
/*   UPDATE  c
   SET c.[type_nm] = j.[type]
   FROM Chemical c JOIN japChemical j ON j.name = c.name
   WHERE c.[type_nm] NOT LIKE j.[type] COLLATE Latin1_General_BIN;

   -- Add in new type info
   UPDATE  c
   SET c.type_id = t.id
   FROM Chemical c JOIN ChemicalType t ON c.type_nm = t.name
   WHERE c.[type_id] <> t.id;
   */
   ;THROW 60000, 'Not implemented',1;
END
/*
EXEC sp_fixup_jap_chemical;
EXEC sp_fixup_s2_chems;
EXEC sp_update_chemical_typ_frm_jap;
*/


GO
