IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Distributor]') AND type in (N'U'))
    DROP TABLE[dbo].[Distributor];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Distributor]') AND type in (N'U'))
DROP TABLE [dbo].[Distributor]
GO
