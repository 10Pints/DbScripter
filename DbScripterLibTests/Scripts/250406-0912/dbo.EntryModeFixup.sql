IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EntryModeFixup]') AND type in (N'U'))
    DROP Table[dbo].[EntryModeFixup];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EntryModeFixup]') AND type in (N'U'))
DROP TABLE [dbo].[EntryModeFixup]
GO
