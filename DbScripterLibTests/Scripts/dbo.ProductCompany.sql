IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProductCompany]') AND type in (N'U'))
    DROP TABLE[dbo].[ProductCompany];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProductCompany]') AND type in (N'U'))
DROP TABLE [dbo].[ProductCompany]
GO
