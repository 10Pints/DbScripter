SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[EPPO_GaiGroup](
	[identifier] [varchar](7) NULL,
	[datatype] [varchar](3) NULL,
	[code] [varchar](8) NULL,
	[lang] [varchar](2) NULL,
	[langno] [int] NULL,
	[preferred] [bit] NULL,
	[status] [nchar](1) NULL,
	[creation] [date] NULL,
	[modification] [varchar](10) NULL,
	[country] [varchar](2) NULL,
	[fullname] [varchar](60) NULL,
	[authority] [varchar](32) NULL,
	[shortname] [varchar](60) NOT NULL
) ON [PRIMARY]

GO
