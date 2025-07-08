SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[EPPO_Repco](
	[identifier] [varchar](5) NULL,
	[datatype] [varchar](3) NULL,
	[code] [varchar](8) NULL,
	[statuslink] [varchar](1) NULL,
	[creation] [date] NOT NULL,
	[modification] [date] NULL,
	[grp_dtype] [varchar](3) NULL,
	[grp_code] [varchar](6) NULL
) ON [PRIMARY]

GO
