SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==========================================================================
-- Author:		 Terry Watts
-- Create date: 28-JUNE-2023
-- Description: lists the inport corrrections table rows that had an error
--              or no row updates occured
-- ==========================================================================
ALTER VIEW [dbo].[ICErrors_Vw]
AS
SELECT * FROM ImportCorrections WHERE act_cnt = 0;

/*
SELECT TOP 50 * FROM ICErrors_Vw;
*/

GO
