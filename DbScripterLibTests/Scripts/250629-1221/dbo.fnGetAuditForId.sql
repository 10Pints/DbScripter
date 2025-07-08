SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===========================================================
-- Author:      Terry Watts
-- Create date: 16-AUG-2023
-- Description: Corrections Audit helper.
--  Use this to track which changes were applied to a reord.
-- ===========================================================
CREATE   FUNCTION [dbo].[fnGetAuditForId]( @id INT)
RETURNS @t TABLE 
(
    ids            VARCHAR(MAX)  NULL
   ,cor_id         int            NULL
   ,old            VARCHAR(250)  NULL
   ,new            VARCHAR(250)  NULL
   ,search_clause  VARCHAR(250)  NULL
   ,replace_clause VARCHAR(150)  NULL
   ,not_clause     VARCHAR(150)  NULL
   ,row_cnt        int            NULL
) 
AS
BEGIN

   DECLARE @id_str VARCHAR(20);
   SET @id_str = CONVERT( int, @id);

   INSERT INTO @t
   (
       ids
      ,cor_id
      ,old
      ,new
      ,search_clause
      ,replace_clause
      ,not_clause
      ,row_cnt
   )
   SELECT 
       ids
      ,cor_id
      ,old
      ,new
      ,search_clause
      ,replace_clause
      ,not_clause
      ,row_cnt
   FROM audit_vw
   WHERE
      ids =@id_str 
      OR ids LIKE CONCAT(@id_str,',%')
      OR ids LIKE CONCAT('%,', @id_str)
      OR ids LIKE CONCAT('%,', @id_str, ',%')

   RETURN;
END
/*
SELECT * FROM audit_vw
-- 23531,13632,6002,15624,2816
SELECT * FROM dbo.fnGetAuditForId(6002)  -- middle, end        11 records
SELECT * FROM dbo.fnGetAuditForId(24305) -- first of many      23 records
SELECT * FROM dbo.fnGetAuditForId(15179) -- singleton or first 6 records
SELECT * FROM dbo.fnGetAuditForId(13324) -- end of many        2 records
SELECT * FROM dbo.fnGetAuditForId(21094) -- first of a pair: [21094,18224}] 17 records 1 pair, rest end of multiple
SELECT * FROM dbo.fnGetAuditForId(18224) -- last of a pair   [21094,18224]  1 record
*/


GO
