USE [BDLGP_HERDEZV2]
GO

/****** Object:  Table [dbo].[Folio_Rel_Grupo_Alerta]    Script Date: 26/03/2020 08:40:33 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Folio_Rel_Grupo_Alerta](
	[id_rel_grupo_alerta] [int] IDENTITY(1,1) NOT NULL,
	[id_tipo_alerta] [int] NULL,
	[id_grupo] [int] NULL,
 CONSTRAINT [PK_Folio_Rel_Grupo_Alerta] PRIMARY KEY CLUSTERED 
(
	[id_rel_grupo_alerta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


