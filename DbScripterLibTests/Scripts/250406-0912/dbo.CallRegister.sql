IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CallRegister]') AND type in (N'U'))
    DROP Table[dbo].[CallRegister];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CallRegister]') AND type in (N'U'))
DROP TABLE [dbo].[CallRegister]
GO
