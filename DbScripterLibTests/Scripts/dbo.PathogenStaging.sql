IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PathogenStaging]') AND type in (N'U'))
    DROP TABLE[dbo].[PathogenStaging];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PathogenStaging]') AND type in (N'U'))
DROP TABLE [dbo].[PathogenStaging]
GO
