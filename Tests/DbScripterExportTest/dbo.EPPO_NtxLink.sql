SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[EPPO_NtxLink](
	[identifier] [varchar](8) NULL,
	[datatype] [varchar](8) NULL,
	[code] [nchar](1) NULL,
	[creation] [date] NULL,
	[modification] [varchar](10) NULL,
	[grp_dtype] [varchar](4) NULL,
	[grp_code] [varchar](8) NULL
) ON [PRIMARY]

GO
