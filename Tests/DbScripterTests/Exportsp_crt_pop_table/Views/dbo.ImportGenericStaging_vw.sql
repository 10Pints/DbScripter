SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ImportGenericStaging_vw]
AS
SELECT staging
FROM GenericStaging
;
/*
SELECT * FROM ImportExamSchedule_vw;
*/
GO

