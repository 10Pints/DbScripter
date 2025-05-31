SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===================================================
-- Author:      Terry Watts
-- Create date: 28-JUL-2023
-- Description: sp_fixup  helper
-- ===================================================
ALTER   PROCEDURE [dbo].[sp_fixup_jap_chemical_hlpr]
    @search_clause   VARCHAR(1000)
   ,@replace_clause  VARCHAR(1000)
   ,@case_sensitive  BIT = 0
AS
BEGIN
   DECLARE
      @fn VARCHAR(30)=N'FIXUP_CHEMS_HLPR'

   EXEC sp_log 0, @fn, '@search_clause:[', @search_clause, '] @replace_clause:[', @replace_clause,'] cs:', @case_sensitive;

   if @case_sensitive = 1
   BEGIN
      UPDATE japChemical set name = @replace_clause WHERE name LIKE @search_clause COLLATE Latin1_General_BIN; --Latin1_General_CS_AI;
   END
   ELSE
   BEGIN
      UPDATE japChemical set name = @replace_clause WHERE name = @search_clause;
   END
END
/*
EXEC sp_fixup_jap_chemical_hlpr 'Bacillus Amyloliquefaciens', 'Bacillus Amyloliquefaciens D747 Strain'                           , 1;
*/


GO
