SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[EPPO_PflGroup](
	[identifier] [varchar](8) NULL,
	[datatype] [varchar](4) NULL,
	[code] [varchar](8) NULL,
	[lang] [varchar](2) NULL,
	[langno] [int] NULL,
	[preferred] [bit] NULL,
	[status] [nchar](1) NULL,
	[creation] [date] NULL,
	[modification] [varchar](10) NULL,
	[country] [varchar](2) NULL,
	[fullname] [varchar](64) NULL,
	[authority] [varchar](64) NULL,
	[shortname] [varchar](64) NULL
) ON [PRIMARY]

GO
