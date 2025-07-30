SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PathogenChemicalStaging](
	[pathogen_nm] [varchar](200) NULL,
	[chemical_nm] [varchar](100) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_PathogenChemicalStaging_chemical_nm] ON [dbo].[PathogenChemicalStaging]
(
	[chemical_nm] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED COLUMNSTORE INDEX [UQ_PathogenChemicalStaging] ON [dbo].[PathogenChemicalStaging]
(
	[pathogen_nm],
	[chemical_nm]
)WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0, DATA_COMPRESSION = COLUMNSTORE) ON [PRIMARY]
GO

