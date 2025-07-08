GO

CREATE TYPE [dbo].[staging2_tbl] AS TABLE(
	[id] [int] NOT NULL,
	[company] [varchar](70) NULL,
	[ingredient] [varchar](250) NULL,
	[product] [varchar](100) NULL,
	[concentration] [varchar](100) NULL,
	[formulation_type] [varchar](7) NULL,
	[uses] [varchar](100) NULL,
	[toxicity_category] [int] NULL,
	[registration] [varchar](65) NULL,
	[expiry] [varchar](30) NULL,
	[entry_mode] [varchar](60) NULL,
	[crops] [varchar](250) NULL,
	[pathogens] [varchar](360) NULL,
	[rate] [varchar](200) NULL,
	[mrl] [varchar](200) NULL,
	[phi] [varchar](200) NULL,
	[phi_resolved] [varchar](120) NULL,
	[reentry_period] [varchar](250) NULL,
	[notes] [varchar](250) NULL,
	[comments] [varchar](500) NULL,
	[created] [datetime] NULL,
	PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)

GO
