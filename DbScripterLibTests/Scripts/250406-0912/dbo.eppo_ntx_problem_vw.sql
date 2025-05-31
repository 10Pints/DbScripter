SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================
-- Author:      Terry Watts
-- Create date: 14-NOV-2024
-- Description: lists problem names in eppo.Ntxname
-- ======================================================
ALTER   VIEW [dbo].[eppo_ntx_problem_vw]
AS
SELECT TOP (1000) [identifier]
      ,[datatype]
      ,[code]
      ,[lang]
      ,[langno]
      ,[preferred]
      ,[status]
      ,[creation]
      ,[modification]
      ,[country]
      ,[fullname]
      ,[authority]
      ,[shortname]
  FROM Eppo_Ntxname
  WHERE lang in ('en','la')
  ;
/*
SELECT distinct datatype from eppo_ntx_problem_vw - 1: NTX
SELECT top 200 * FROM eppo_ntx_problem_vw
*/


GO
