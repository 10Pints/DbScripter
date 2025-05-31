SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ============================================================================
-- Description:   Lists the S2 updates for the crops field from s2_updateLog
-- Preconditions: 
-- Postconditions:
-- Design:        EA
-- Tests:         EXEC tSQLt.Run 'test.test_<nnn>_List_S2Updates_Pathogens';
-- Author:        Terry Watts
-- Create date:   8-FEB-2024
--
-- CHANGES:
-- ============================================================================
ALTER FUNCTION [dbo].[fnList_S2Updates_Crops]( @crop_clause NVARCHAR(400))
RETURNS @T table
(
    fixup_id      INT
   ,new_crops NVARCHAR(400)
   ,old_crops NVARCHAR(400)
)
AS
BEGIN
   INSERT INTO @t
      SELECT TOP 1000
       fixup_id
      ,new_crops
      ,old_crops

      FROM S2UpdateLOG
      WHERE
         new_crops LIKE CONCAT('%',@crop_clause,'%')
      OR old_pathogens LIKE CONCAT('%',@crop_clause,'%')
      ORDER BY fixup_id;

   RETURN;
END
/*
EXEC tSQLt.RunAll;
SELECT * FROM dbo.fnList_S2Updates_Crops('Green beansbeans') WHERE new_crops LIKE '%Green beansbeans%' AND old_crops LIKE '%Stringbeans%';

SELECT * FROM s12_vw where s1_crops LIKE '%Green BeansBeans%';
SELECT * FROM s12_vw where s2_crops LIKE '%Green BeansBeans%';
*/

GO
