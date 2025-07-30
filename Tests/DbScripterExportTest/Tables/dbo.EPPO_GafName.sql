SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EPPO_GafName](
	[identifier] [varchar](7) NULL,
	[datatype] [varchar](3) NULL,
	[code] [varchar](8) NULL,
	[lang] [varchar](2) NULL,
	[langno] [varchar](2) NULL,
	[preferred] [nchar](1) NULL,
	[status] [nchar](1) NULL,
	[creation] [date] NULL,
	[modification] [varchar](10) NULL,
	[country] [varchar](2) NULL,
	[fullname] [varchar](150) NULL,
	[authority] [varchar](70) NULL,
	[shortname] [varchar](150) NULL
) ON [PRIMARY]
GO

