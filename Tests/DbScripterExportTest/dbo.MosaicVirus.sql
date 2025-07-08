SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[MosaicVirus](
	[Species] [varchar](60) NULL,
	[Crops] [varchar](40) NULL,
	[Genus] [varchar](35) NULL,
	[Subfamily] [varchar](35) NULL,
	[Family] [varchar](35) NULL,
	[Order] [varchar](35) NULL,
	[Class] [varchar](35) NULL,
	[Subphylum] [varchar](35) NULL,
	[Phylum] [varchar](35) NULL,
	[Kingdom] [varchar](35) NULL,
	[Realm] [varchar](35) NULL,
	[Genome] [varchar](35) NULL,
	[Vector] [varchar](35) NULL,
	[OPPO_code] [varchar](16) NULL
) ON [PRIMARY]

GO
