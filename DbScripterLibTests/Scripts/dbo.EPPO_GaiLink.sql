SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[EPPO_GaiLink](
	[identifier] [varchar](7) NULL,
	[datatype] [varchar](6) NULL,
	[code] [nchar](1) NULL,
	[creation] [date] NULL,
	[modification] [varchar](10) NULL,
	[grp_dtype] [varchar](3) NULL,
	[grp_code] [varchar](6) NULL
) ON [PRIMARY]

GO
