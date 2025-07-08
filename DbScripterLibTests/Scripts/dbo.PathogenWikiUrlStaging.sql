SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[PathogenWikiUrlStaging](
	[id] [int] NOT NULL,
	[pathogen_nm] [nvarchar](max) NULL,
	[url] [nvarchar](max) NULL,
	[image] [nvarchar](max) NULL,
	[taxonomy] [nvarchar](max) NULL,
	[binomial_nm] [nvarchar](max) NULL,
	[synonyms] [nvarchar](max) NULL,
	[status] [nvarchar](max) NULL,
 CONSTRAINT [PK_PathogenWikiUrlStaging] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
