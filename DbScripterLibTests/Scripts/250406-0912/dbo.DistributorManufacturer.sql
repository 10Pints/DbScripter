IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DistributorManufacturer]') AND type in (N'U'))
    DROP Table[dbo].[DistributorManufacturer];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DistributorManufacturer]') AND type in (N'U'))
DROP TABLE [dbo].[DistributorManufacturer]
GO
