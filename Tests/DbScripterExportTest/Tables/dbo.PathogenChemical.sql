SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PathogenChemical](
	[pathogen_id] [int] NULL,
	[chemical_id] [int] NULL,
	[pathogenType_id] [int] NULL,
	[pathogen_nm] [varchar](100) NULL,
	[chemical_nm] [varchar](100) NULL,
	[created] [datetime] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PathogenChemical] ON [dbo].[PathogenChemical]
(
	[pathogen_id] ASC,
	[chemical_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PathogenChemical_1] ON [dbo].[PathogenChemical]
(
	[pathogen_nm] ASC,
	[chemical_nm] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PathogenChemical_chemical] ON [dbo].[PathogenChemical]
(
	[chemical_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PathogenChemical_pathogen] ON [dbo].[PathogenChemical]
(
	[pathogen_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PathogenChemical] ADD  CONSTRAINT [DF_PathogenChemical_created]  DEFAULT (getdate()) FOR [created]
GO
ALTER TABLE [dbo].[PathogenChemical]  WITH NOCHECK ADD  CONSTRAINT [FK_PathogenChemical_Chemical] FOREIGN KEY([chemical_nm])
REFERENCES [dbo].[Chemical] ([chemical_nm])
GO
ALTER TABLE [dbo].[PathogenChemical] CHECK CONSTRAINT [FK_PathogenChemical_Chemical]
GO
ALTER TABLE [dbo].[PathogenChemical]  WITH CHECK ADD  CONSTRAINT [FK_PathogenChemical_Pathogen] FOREIGN KEY([pathogen_nm])
REFERENCES [dbo].[Pathogen] ([pathogen_nm])
GO
ALTER TABLE [dbo].[PathogenChemical] CHECK CONSTRAINT [FK_PathogenChemical_Pathogen]
GO
ALTER TABLE [dbo].[PathogenChemical]  WITH CHECK ADD  CONSTRAINT [FK_PathogenChemical_type] FOREIGN KEY([pathogenType_id])
REFERENCES [dbo].[PathogenType] ([pathogenType_id])
GO
ALTER TABLE [dbo].[PathogenChemical] CHECK CONSTRAINT [FK_PathogenChemical_type]
GO

