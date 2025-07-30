SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EPPO_GaiNameStaging](
	[identifier] [varchar](max) NULL,
	[datatype] [varchar](max) NULL,
	[code] [varchar](max) NULL,
	[lang] [varchar](max) NULL,
	[langno] [varchar](max) NULL,
	[preferred] [varchar](max) NULL,
	[status] [varchar](max) NULL,
	[creation] [varchar](max) NULL,
	[modification] [varchar](max) NULL,
	[country] [varchar](max) NULL,
	[fullname] [varchar](max) NULL,
	[authority] [varchar](max) NULL,
	[shortname] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

