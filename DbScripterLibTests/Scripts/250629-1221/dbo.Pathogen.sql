SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Pathogen](
	[pathogen_id] [int] IDENTITY(1,1) NOT NULL,
	[pathogen_nm] [varchar](100) NULL,
	[pathogenType_nm] [varchar](100) NULL,
	[pathogenType_id] [int] NULL,
	[subtype] [varchar](50) NULL,
	[latin_nm] [varchar](150) NULL,
	[alt_latin_nms] [varchar](200) NULL,
	[alt_common_nms] [varchar](200) NULL,
	[ph_common_nms] [varchar](50) NULL,
	[crops] [varchar](360) NULL,
	[taxonomy] [varchar](250) NULL,
	[biological_cure] [varchar](600) NULL,
	[notes] [varchar](500) NULL,
	[urls] [varchar](500) NULL,
	[image] [varchar](500) NULL,
	[binomial_nm] [varchar](50) NULL,
	[synonyms] [varchar](1500) NULL,
 CONSTRAINT [PK_Pathogen] PRIMARY KEY CLUSTERED 
(
	[pathogen_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [IX_Pathogen_nm] UNIQUE NONCLUSTERED 
(
	[pathogen_nm] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Pathogen]  WITH NOCHECK ADD  CONSTRAINT [FK_Pathogen_PathogenType] FOREIGN KEY([pathogenType_id])
REFERENCES [dbo].[PathogenType] ([pathogenType_id])

ALTER TABLE [dbo].[Pathogen] NOCHECK CONSTRAINT [FK_Pathogen_PathogenType]

GO
