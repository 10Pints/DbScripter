IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PreCautionaryStatement]') AND type in (N'U'))
    DROP Table[dbo].[PreCautionaryStatement];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PreCautionaryStatement]') AND type in (N'U'))
DROP TABLE [dbo].[PreCautionaryStatement]
GO
