SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EPPO_GafNameStaging](
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
EXEC sys.sp_addextendedproperty @name=N'DESC', @value=N'micro-organisms, viruses, abiotic growth factors' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EPPO_GafNameStaging'
GO

