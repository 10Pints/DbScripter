SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EPPO_GaiName](
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
	[fullname] [varchar](192) NULL,
	[authority] [varchar](64) NULL,
	[shortname] [varchar](128) NULL
) ON [PRIMARY]
GO

