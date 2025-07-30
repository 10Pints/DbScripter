SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EPPO_GafLink](
	[identifier] [nchar](10) NULL,
	[datatype] [nchar](10) NULL,
	[code] [nchar](2) NULL,
	[creation] [date] NULL,
	[modification] [nchar](15) NULL,
	[grp_dtype] [varchar](3) NULL,
	[grp_code] [varchar](6) NULL
) ON [PRIMARY]
GO

