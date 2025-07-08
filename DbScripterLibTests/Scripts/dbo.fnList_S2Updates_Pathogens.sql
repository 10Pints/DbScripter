SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ============================================================================
-- Description: Lists the S2 updates for the pathogens field from s2_updateLog
-- EXEC tSQLt.Run 'test.test_<nnn>_List_S2Updates_Pathogens';
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 10-JAN-2024
-- ============================================================================
CREATE FUNCTION [dbo].[fnList_S2Updates_Pathogens]( @pathogen_clause NVARCHAR(400))
RETURNS @T table
(
    fixup_id      INT
   ,[new_pathogens                                                                                                                  |] NVARCHAR(400)
   ,[old_pathogens                                                                                                                  |] NVARCHAR(400)
   ,crops         NVARCHAR(250)
)
AS
BEGIN
   INSERT INTO @t
      SELECT TOP 1000
       fixup_id
      ,new_pathogens
      ,old_pathogens
      ,crops     AS crops

      FROM s2_updateLog_pathogens_vw
      WHERE
         new_pathogens LIKE CONCAT('%',@pathogen_clause,'%')
      OR old_pathogens LIKE CONCAT('%',@pathogen_clause,'%')
      ORDER BY fixup_id;

   RETURN;
END
/*
EXEC tSQLt.RunAll;
SELECT * FROM dbo.List_S2Updates_Pathogens(' Fusarium wilt');
EXEC tSQLt.Run 'test.test_nnn_List_S2Updates_Pathogens;
EXEC sp_fndUnregPathogens;
*/

GO
