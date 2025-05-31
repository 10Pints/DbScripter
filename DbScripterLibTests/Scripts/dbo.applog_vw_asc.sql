SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 09-MAR-2024
-- Description: this view displays the last 20 rows in teh applog in descend order by id (insertion)
--
-- CHANGES:
-- ======================================================================================================
ALTER VIEW [dbo].[applog_vw_asc]
AS
SELECT TOP 1000000
    id
   ,[level]
   ,fn
   ,row_count
   ,SUBSTRING(msg, 1, 128)   AS [msg                                                                                                                            .]
   ,SUBSTRING(msg, 129, 128) AS [msg2                                                                                                                           .]
   ,SUBSTRING(msg, 257, 128) AS [msg3                                                                                                                           .]
   ,SUBSTRING(msg, 385, 128) AS [msg4                                                                                                                           .]
FROM AppLog ORDER BY id ASC;
/*
SELECT * FROM AppLog_vw_asc
*/

GO
