IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ForeignKey]') AND type in (N'U'))
    DROP TABLE[dbo].[ForeignKey];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ForeignKey]') AND type in (N'U'))
DROP TABLE [dbo].[ForeignKey]
GO
