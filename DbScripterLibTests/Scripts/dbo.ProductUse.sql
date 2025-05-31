IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProductUse]') AND type in (N'U'))
    DROP TABLE[dbo].[ProductUse];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProductUse]') AND type in (N'U'))
DROP TABLE [dbo].[ProductUse]
GO
