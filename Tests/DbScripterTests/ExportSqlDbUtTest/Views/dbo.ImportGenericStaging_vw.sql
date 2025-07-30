SET ANSI_NULLS ON
GO
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

