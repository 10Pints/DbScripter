IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DistributorStaging]') AND type in (N'U'))
    DROP TABLE[dbo].[DistributorStaging];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DistributorStaging]') AND type in (N'U'))
DROP TABLE [dbo].[DistributorStaging]
GO
