SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PathogenStaging](
	[pathogen_nm] [varchar](50) NOT NULL,
	[pathogenType_nm] [varchar](50) NULL,
	[subtype] [varchar](25) NULL,
	[latin_nm] [varchar](120) NULL,
	[alt_latin_nms] [varchar](500) NULL,
	[alt_common_nms] [varchar](650) NULL,
	[ph_common_nms] [varchar](50) NULL,
	[crops] [varchar](2000) NULL,
	[taxonomy] [varchar](650) NULL,
	[biological_cure] [varchar](max) NULL,
	[notes] [varchar](3500) NULL,
	[urls] [varchar](250) NULL,
 CONSTRAINT [PK_PathogenStaging] PRIMARY KEY CLUSTERED 
(
	[pathogen_nm] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

