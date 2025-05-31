IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WarehouseStaging]') AND type in (N'U'))
    DROP Table[dbo].[WarehouseStaging];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WarehouseStaging]') AND type in (N'U'))
DROP TABLE [dbo].[WarehouseStaging]
GO
