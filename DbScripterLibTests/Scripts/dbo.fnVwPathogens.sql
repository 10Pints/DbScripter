SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ======================================================================================================================
-- Author:      Terry Watts
-- Create date: 14-OCT-2024
-- Description: utility function to view likely pathogens use when correcting imports
-- ======================================================================================================================
CREATE   FUNCTION [dbo].[fnVwPathogens](@clause VARCHAR(4000))
RETURNS TABLE
AS RETURN
   SELECT TOP 100 pathogen_nm, pathogenType_nm
   FROM pathogen_vw WHERE    pathogen_nm LIKE CONCAT('%', @clause, '%');

/*
SELECT * FROM dbo.fnVwPathogens('Scab');
*/


GO
