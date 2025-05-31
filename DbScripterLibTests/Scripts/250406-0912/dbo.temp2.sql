IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[temp2]') AND type in (N'U'))
    DROP Table[dbo].[temp2];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[temp2]') AND type in (N'U'))
DROP TABLE [dbo].[temp2]
GO
