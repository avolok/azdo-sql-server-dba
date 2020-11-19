CREATE TABLE [dbo].[Jobs](
	[name] [sysname] NOT NULL,
	[enabled] [bit] NOT NULL,
	[description] [nvarchar](2000) NULL,
	[category_name] [nvarchar](200) NULL,
	[deployment_mode] [varchar](50) NOT NULL	
) ON [PRIMARY]
GO
ALTER TABLE dbo.Jobs ADD CONSTRAINT PK_Jobs PRIMARY KEY ([name]) 