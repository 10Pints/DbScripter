SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ======================================================================================================
-- Author:       Terry Watts
-- Create date:  02-AUG-2023
-- Description:  Stage 2 products fixup
-- ======================================================================================================
CREATE   PROCEDURE [dbo].[sp_pre_fixup_s2_products_deprecated]
     @fixup_cnt       INT = NULL OUT
AS
BEGIN
   SET NOCOUNT OFF
   DECLARE
       @fn              VARCHAR(35) = 'FIXUP S2 PRODUCTS'

   EXEC sp_log 2, @fn, '01: starting, @fixup_cnt: ',@fixup_cnt;
   EXEC sp_register_call @fn;

   UPDATE staging2 SET product = 'Perfekthion 40 EC' WHERE product IS NULL AND company='Basf Philippines, Inc.' AND ingredient='Dimethoate';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   UPDATE staging2 SET product = 'Agrotechno Lambdacyhalothrin 2.5 Ec' WHERE product = 'Agrotechno Lambdacyhalothrin 2.5 ec' COLLATE Latin1_General_CS_AI;
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   UPDATE staging2 SET product = 'Zulpac Lambda 2.5 Ec' WHERE product='Zulpac -Lambda 2.5 Ec';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;
   UPDATE staging2 SET product = 'Benomax 50 Wp' WHERE product='Benomex 50 Wp';
   SET @fixup_cnt = @fixup_cnt + @@ROWCOUNT;

   EXEC sp_log 2, @fn, '99: leaving, @fixup_cnt: ',@fixup_cnt;
END
/*
SELECT product From Staging2 WHERE product like '%Agrotechno Lambdacyhalothrin 2.5 ec%';
DECLARE @fixup_cnt       INT = 0;
EXEC sp_fixup_s2_products  @fixup_cnt OUT;
PRINT CONCAT('@fixup_cnt: ', @fixup_cnt);
*/


GO
