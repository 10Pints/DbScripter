IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UnregisteredItem]') AND type in (N'U'))
    DROP Table[dbo].[UnregisteredItem];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UnregisteredItem]') AND type in (N'U'))
DROP TABLE [dbo].[UnregisteredItem]
GO
