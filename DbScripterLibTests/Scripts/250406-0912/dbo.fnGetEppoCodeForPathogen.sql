SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==============================================================
-- Author:      Terry Watts
-- Create date: 14-NOV-2024
-- Description: gets the EPPO code for a name (latin or english)
-- ================================================================
ALTER   FUNCTION [dbo].[fnGetEppoCodeForPathogen](@name VARCHAR(MAX))
RETURNS @t TABLE
(
    eppo_code  VARCHAR(8)
   ,full_name  VARCHAR(50)
   ,lang       VARCHAR(2)
   ,status     NCHAR
)
AS
BEGIN
   INSERT INTO @t SELECT code, fullname, nm_lang, status
   FROM eppo_gaf_nm_grp_vw 
   WHERE fullname LIKE CONCAT('%',@name,'%')
   AND nm_lang IN ('en','la')
   ;

   RETURN;
END
/*
SELECT * FROM dbo.fnGetEppoCodeForPathogen('Fusarium Wilt');
SELECT * FROM dbo.fnGetEppoCodeForPathogen('Fusarium Wilt%banana');
SELECT * FROM dbo.fnGetEppoCodeForPathogen('Panama');
*/


GO
