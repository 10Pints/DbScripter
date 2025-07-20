SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[MosaicVirusStaging](
	[Species] [varchar](max) NULL,
	[Crops] [varchar](max) NULL,
	[Genus] [varchar](max) NULL,
	[Subfamily] [varchar](max) NULL,
	[Family] [varchar](max) NULL,
	[Order] [varchar](max) NULL,
	[Class] [varchar](max) NULL,
	[Subphylum] [varchar](max) NULL,
	[Phylum] [varchar](max) NULL,
	[Kingdom] [varchar](max) NULL,
	[Realm] [varchar](max) NULL,
	[Genome] [varchar](max) NULL,
	[Vector] [varchar](max) NULL,
	[OPPO_code] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
