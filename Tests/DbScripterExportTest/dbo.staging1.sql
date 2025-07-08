SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[staging1](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[company] [varchar](500) NULL,
	[ingredient] [varchar](500) NULL,
	[product] [varchar](200) NULL,
	[concentration] [varchar](200) NULL,
	[formulation_type] [varchar](20) NULL,
	[uses] [varchar](200) NULL,
	[toxicity_category] [varchar](200) NULL,
	[registration] [varchar](100) NULL,
	[expiry] [varchar](200) NULL,
	[entry_mode] [varchar](200) NULL,
	[crops] [varchar](500) NULL,
	[pathogens] [varchar](1000) NULL,
	[rate] [varchar](200) NULL,
	[mrl] [varchar](200) NULL,
	[phi] [varchar](200) NULL,
	[phi_resolved] [varchar](120) NULL,
	[reentry_period] [varchar](250) NULL,
	[notes] [varchar](250) NULL,
	[comments] [varchar](500) NULL,
	[created] [datetime] NULL,
 CONSTRAINT [PK_staging1] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
