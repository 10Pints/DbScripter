SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChemicalAction](
	[chemical_id] [int] NOT NULL,
	[action_id] [int] NOT NULL,
	[chemical_nm] [varchar](400) NULL,
	[action_nm] [varchar](50) NULL,
	[created] [date] NULL,
 CONSTRAINT [PK_ChemicalEntryMode] PRIMARY KEY CLUSTERED 
(
	[chemical_id] ASC,
	[action_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ChemicalEntryMode_chemical] ON [dbo].[ChemicalAction]
(
	[chemical_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ChemicalEntryMode_entry_mode] ON [dbo].[ChemicalAction]
(
	[action_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChemicalAction] ADD  CONSTRAINT [DF_ChemicalAction_created]  DEFAULT (getdate()) FOR [created]
GO
ALTER TABLE [dbo].[ChemicalAction]  WITH CHECK ADD  CONSTRAINT [FK_ChemicalAction_Action] FOREIGN KEY([action_id])
REFERENCES [dbo].[Action] ([action_id])
GO
ALTER TABLE [dbo].[ChemicalAction] CHECK CONSTRAINT [FK_ChemicalAction_Action]
GO
ALTER TABLE [dbo].[ChemicalAction]  WITH CHECK ADD  CONSTRAINT [FK_ChemicalAction_Chemical] FOREIGN KEY([chemical_id])
REFERENCES [dbo].[Chemical] ([chemical_id])
GO
ALTER TABLE [dbo].[ChemicalAction] CHECK CONSTRAINT [FK_ChemicalAction_Chemical]
GO

