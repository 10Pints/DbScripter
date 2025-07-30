SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EPPO_PflName](
	[identifier] [varchar](7) NULL,
	[datatype] [varchar](3) NULL,
	[code] [varchar](8) NULL,
	[lang] [varchar](2) NULL,
	[langno] [varchar](2) NULL,
	[preferred] [varchar](1) NULL,
	[status] [varchar](1) NULL,
	[creation] [date] NULL,
	[modification] [date] NULL,
	[country] [varchar](2) NULL,
	[fullname] [varchar](250) NULL,
	[authority] [varchar](120) NULL,
	[shortname] [varchar](250) NULL
) ON [PRIMARY]
GO

