USE [BDLGP_HERDEZV2]
GO

/****** Object:  Table [dbo].[Folio_Incidencias]    Script Date: 26/03/2020 08:40:09 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Folio_Incidencias](
	[id_incidencia] [int] IDENTITY(1,1) NOT NULL,
	[nombre] [nvarchar](50) NULL,
	[descripcion] [nvarchar](255) NULL,
	[prioridad] [int] NULL,
	[id_tipo] [int] NULL,
 CONSTRAINT [PK_Folio_Incidencias] PRIMARY KEY CLUSTERED 
(
	[id_incidencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Folio_Incidencias]  WITH CHECK ADD  CONSTRAINT [FK_Folio_Incidencias_Folio_Incidencias] FOREIGN KEY([id_incidencia])
REFERENCES [dbo].[Folio_Incidencias] ([id_incidencia])
GO

ALTER TABLE [dbo].[Folio_Incidencias] CHECK CONSTRAINT [FK_Folio_Incidencias_Folio_Incidencias]
GO


