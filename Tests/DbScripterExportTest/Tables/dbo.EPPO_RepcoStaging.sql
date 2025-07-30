SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EPPO_RepcoStaging](
	[identifier] [varchar](max) NULL,
	[datatype] [varchar](max) NULL,
	[code] [varchar](max) NULL,
	[statuslink] [varchar](max) NULL,
	[creation] [varchar](max) NULL,
	[modification] [varchar](max) NULL,
	[grp_dtype] [varchar](max) NULL,
	[grp_code] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

