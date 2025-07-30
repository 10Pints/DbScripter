SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CropStaging](
	[crop_id] [int] NULL,
	[crop_nm] [varchar](100) NULL,
	[latin_nm] [varchar](50) NULL,
	[alt_latin_nms] [varchar](50) NULL,
	[alt_common_nms] [varchar](50) NULL,
	[taxonomy] [varchar](500) NULL,
	[notes] [varchar](150) NULL
) ON [PRIMARY]
GO

