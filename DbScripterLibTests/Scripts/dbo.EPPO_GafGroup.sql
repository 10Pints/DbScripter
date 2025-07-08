SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[EPPO_GafGroup](
	[identifier] [varchar](10) NULL,
	[datatype] [varchar](5) NULL,
	[code] [varchar](8) NULL,
	[lang] [varchar](6) NULL,
	[langno] [int] NULL,
	[preferred] [bit] NULL,
	[status] [nchar](1) NULL,
	[creation] [varchar](10) NULL,
	[modification] [varchar](10) NULL,
	[country] [varchar](20) NULL,
	[fullname] [varchar](80) NULL,
	[authority] [varchar](50) NULL,
	[shortname] [varchar](80) NULL
) ON [PRIMARY]

GO
