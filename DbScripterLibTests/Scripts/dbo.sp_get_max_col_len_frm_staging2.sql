SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON


CREATE PROC [dbo].[sp_get_max_col_len_frm_staging2]
AS
BEGIN
   SELECT 
        max(ut.dbo.fnLen(company          )) as company         
      , max(ut.dbo.fnLen(ingredient       )) as ingredient      
      , max(ut.dbo.fnLen(product          )) as product         
      , max(ut.dbo.fnLen(concentration    )) as concentration   
      , max(ut.dbo.fnLen(formulation_type )) as formulation_type
      , max(ut.dbo.fnLen(uses ))             as uses 
      , max(ut.dbo.fnLen(toxicity_category)) as toxicity_category
      , max(ut.dbo.fnLen(registration ))     as registration 
      , max(ut.dbo.fnLen(expiry ))           as expiry 
      , max(ut.dbo.fnLen(entry_mode ))       as entry_mode 
      , max(ut.dbo.fnLen(crops ))            as crops 
      , max(ut.dbo.fnLen(pathogens ))        as pathogens 
      , max(ut.dbo.fnLen(notes ))            as notes 
      , max(ut.dbo.fnLen(Comment ))          as Comment 
   FROM staging2;
END
/*
EXEC sp_get_max_col_len_frm_staging2;
*/

GO
