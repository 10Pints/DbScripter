SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =========================================================================================================
-- Author:      Terry Watts
-- Create date: 10-JAN-2025
-- Description: lists the import corrections that did not update any rows for teh give file, or all if null
--
-- CHANGES:
-- =========================================================================================================
CREATE FUNCTION [dbo].[ListIneffectiveCorrections](@file NVARCHAR(500))
RETURNS @t TABLE
(
     stg_id           INT
   ,[command] [varchar](50) NULL
   ,[search_clause] [varchar](700) NULL
   ,[replace_clause] [varchar](500) NULL
   ,[stg_file] [varchar](100) NULL
   ,[action] [varchar](12) NULL
   ,[update_cnt] [int] NULL
)
AS
BEGIN
   INSERT INTO @t
   SELECT stg_id,command,search_clause,replace_clause,stg_file,[action],update_cnt
   FROM list_ineffective_corrections_vw 
   WHERE stg_file=@file OR @file IS NULL;

   RETURN;
END
/*
SELECT * FROM ListIneffectiveCorrections('ImportCorrections_221018-Pathogens_A-C.txt');
*/

GO
