USE [BDLGP_HERDEZV2]
GO

/****** Object:  StoredProcedure [dbo].[USP_ControlTower_InsertAlertas]    Script Date: 26/03/2020 09:15:56 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--SELECT fecha_cita_destino FROM Folio_Viaje_Carga

CREATE PROCEDURE [dbo].[USP_ControlTower_InsertAlertas]
@Urgente INT = 5,
@Alta INT = 10,
@Media INT = 15
AS
	DECLARE @descripcion_evento NVARCHAR(50);
	DECLARE @requestBody NVARCHAR(MAX);
	
	DECLARE @Alertas TABLE(
	id_folio NUMERIC(20, 0),
	prioridad INT,
	fecha_vencimiento DATETIME,
	[status] BIT,
	evento NVARCHAR(50),
	id_region_destino INT,
	regiones NVARCHAR(MAX)
	);

	INSERT INTO @Alertas
	SELECT DISTINCT FVC.folio_viaje,
		   (CASE
				WHEN FVC.fecha_asignacion_proveedor IS NULL THEN (CASE
																    WHEN DATEADD(MINUTE, @Urgente, GETDATE()) > DATEADD(HOUR, -12, FVC.fecha_cita_destino) THEN 1
																	WHEN DATEADD(MINUTE, @Alta, GETDATE()) > DATEADD(HOUR, -12, FVC.fecha_cita_destino) THEN 2
																	WHEN DATEADD(MINUTE, @Media, GETDATE()) > DATEADD(HOUR, -12, FVC.fecha_cita_destino) THEN 3
																 END)
				WHEN FVC.fecha_asignacion_flotilla IS NULL THEN (CASE
																	WHEN DATEADD(MINUTE, @Urgente, GETDATE()) > FVC.arribo_origen_teorico THEN 1
																	WHEN DATEADD(MINUTE, @Alta, GETDATE()) > FVC.arribo_origen_teorico THEN 2
																	WHEN DATEADD(MINUTE, @Media, GETDATE()) > FVC.arribo_origen_teorico THEN 3
																END)
		        WHEN FVC.fecha_sincronizacion IS NULL THEN (CASE
																WHEN DATEADD(MINUTE, P.ETA + @Urgente, GETDATE()) > FVC.arribo_origen_teorico THEN 1
																WHEN DATEADD(MINUTE, P.ETA + @Alta, GETDATE()) > FVC.arribo_origen_teorico THEN 2
																WHEN DATEADD(MINUTE, P.ETA + @Media, GETDATE()) > FVC.arribo_origen_teorico THEN 3
														   END)
	            WHEN FVC.inicio_folio IS NULL THEN (CASE
														WHEN DATEADD(MINUTE, P.ETA + @Urgente, GETDATE()) > FVC.arribo_origen_teorico THEN 1
														WHEN DATEADD(MINUTE, P.ETA + @Alta, GETDATE()) > FVC.arribo_origen_teorico THEN 2
														WHEN DATEADD(MINUTE, P.ETA + @Media, GETDATE()) > FVC.arribo_origen_teorico THEN 3
				                                   END)
	            WHEN FVC.fecha_llegada_origen_QR IS NULL THEN (CASE
																 WHEN DATEADD(MINUTE, P.ETA + @Urgente, GETDATE()) > FVC.arribo_origen_teorico THEN 1
																 WHEN DATEADD(MINUTE, P.ETA + @Alta, GETDATE()) > FVC.arribo_origen_teorico THEN 2
																 WHEN DATEADD(MINUTE, P.ETA + @Media, GETDATE()) > FVC.arribo_origen_teorico THEN 3
				                                              END)		    
				WHEN FVC.fecha_inicio_carga_QR IS NULL THEN (CASE
																WHEN DATEADD(MINUTE, P.ETA + @Urgente, GETDATE()) > FVC.fecha_inicio_carga_QR_teorica THEN 1
																WHEN DATEADD(MINUTE, P.ETA + @Alta, GETDATE()) > FVC.fecha_inicio_carga_QR_teorica THEN 2
																WHEN DATEADD(MINUTE, P.ETA + @Media, GETDATE()) > FVC.fecha_inicio_carga_QR_teorica THEN 3
				                                            END)
				WHEN FVD.fecha_facturacion IS NULL THEN (CASE
															WHEN DATEADD(MINUTE, P.ETA + @Urgente, GETDATE()) > FVD.fecha_facturacion_teorica THEN 1
															WHEN DATEADD(MINUTE, P.ETA + @Alta, GETDATE()) > FVD.fecha_facturacion_teorica THEN 2
															WHEN DATEADD(MINUTE, P.ETA + @Media, GETDATE()) > FVD.fecha_facturacion_teorica THEN 3
														END)
	            WHEN FVC.fecha_fin_carga IS NULL THEN (CASE
																WHEN DATEADD(MINUTE, P.ETA + @Urgente, GETDATE()) > FVC.fecha_fin_carga_teorica THEN 1
																WHEN DATEADD(MINUTE, P.ETA + @Alta, GETDATE()) > FVC.fecha_fin_carga_teorica THEN 2
																WHEN DATEADD(MINUTE, P.ETA + @Media, GETDATE()) > FVC.fecha_fin_carga_teorica THEN 3
													   END)
				WHEN FVC.fecha_salida_origen_QR IS NULL THEN (CASE
															    WHEN DATEADD(MINUTE, P.ETA + @Urgente, GETDATE()) > FVC.fecha_salida_origen_teorico THEN 1
																WHEN DATEADD(MINUTE, P.ETA + @Alta, GETDATE()) > FVC.fecha_salida_origen_teorico THEN 2
																WHEN DATEADD(MINUTE, P.ETA + @Media, GETDATE()) > FVC.fecha_salida_origen_teorico THEN 3
				                                             END)
			    WHEN FVD.fecha_llegada_destino_QR IS NULL THEN (CASE
																	WHEN DATEADD(MINUTE, P.ETA + @Urgente, GETDATE()) > FVD.fecha_llegada_destino_QR_teorica THEN 1
																	WHEN DATEADD(MINUTE, P.ETA + @Alta, GETDATE()) > FVD.fecha_llegada_destino_QR_teorica THEN 2
																	WHEN DATEADD(MINUTE, P.ETA + @Media, GETDATE()) > FVD.fecha_llegada_destino_QR_teorica THEN 3
																END)
				WHEN FVD.fecha_inicio_descarga IS NULL THEN (CASE
																	WHEN DATEADD(MINUTE, P.ETA + @Urgente, GETDATE()) > FVD.fecha_inicio_descarga_teorica THEN 1
																	WHEN DATEADD(MINUTE, P.ETA + @Alta, GETDATE()) > FVD.fecha_inicio_descarga_teorica THEN 2
																	WHEN DATEADD(MINUTE, P.ETA + @Media, GETDATE()) > FVD.fecha_inicio_descarga_teorica THEN 3
															END)
			    WHEN FVD.fecha_fin_descarga IS NULL THEN (CASE
																	WHEN DATEADD(MINUTE, P.ETA + @Urgente, GETDATE()) > FVD.fecha_fin_descarga_teorica THEN 1
																	WHEN DATEADD(MINUTE, P.ETA + @Alta, GETDATE()) > FVD.fecha_fin_descarga_teorica THEN 2
																	WHEN DATEADD(MINUTE, P.ETA + @Media, GETDATE()) > FVD.fecha_fin_descarga_teorica THEN 3
				                                         END)
	   END) prioridad,
	   (CASE
			WHEN FVC.fecha_asignacion_proveedor IS NULL THEN FVC.arribo_origen_teorico
			WHEN FVC.fecha_asignacion_flotilla IS NULL THEN FVC.arribo_origen_teorico
			WHEN FVC.fecha_sincronizacion IS NULL THEN FVC.arribo_origen_teorico
			WHEN FVC.inicio_folio IS NULL THEN FVC.arribo_origen_teorico
			WHEN FVC.fecha_llegada_origen_QR IS NULL THEN FVC.arribo_origen_teorico
			WHEN FVC.fecha_inicio_carga_QR IS NULL THEN FVC.fecha_inicio_carga_QR_teorica
			WHEN FVC.fecha_fin_carga IS NULL THEN FVC.fecha_fin_carga_teorica
			WHEN FVC.fecha_salida_origen_QR IS NULL THEN FVC.fecha_salida_origen_teorico
			WHEN FVD.fecha_llegada_destino_QR IS NULL THEN FVD.fecha_llegada_destino_QR_teorica
			WHEN FVD.fecha_inicio_descarga IS NULL THEN FVD.fecha_inicio_descarga_teorica
			WHEN FVD.fecha_fin_descarga IS NULL THEN FVD.fecha_fin_descarga_teorica
	   END) fecha_vencimiento,
	   0 [status],
	   (CASE
			WHEN FVC.fecha_asignacion_proveedor IS NULL THEN 'Por Asignar a Proveedor'
			WHEN FVC.fecha_asignacion_flotilla IS NULL THEN 'Por Asignar a Flotilla'
			WHEN FVC.fecha_sincronizacion IS NULL THEN 'Por Sincronizar'
			WHEN FVC.inicio_folio IS NULL THEN 'Inicio de Folio'
			WHEN FVC.fecha_llegada_origen_QR IS NULL THEN 'Llegada a Orgien'
			WHEN FVC.fecha_inicio_carga_QR IS NULL THEN 'Inicio de Carga'
			WHEN FVC.fecha_fin_carga IS NULL THEN 'Fin de Carga'
			WHEN FVD.fecha_facturacion IS NULL THEN 'Facturación'
			WHEN FVC.fecha_salida_origen_QR IS NULL THEN 'Salida de origen'
			WHEN FVD.fecha_llegada_destino_QR IS NULL THEN 'Llegada al destino'
			WHEN FVD.fecha_inicio_descarga IS NULL THEN 'Inicio de descarga'
			WHEN FVD.fecha_fin_descarga IS NULL THEN 'Fin de descarga'
	   END) evento,
	   FVC.id_region_destino,
	   PRO.regiones
	FROM Folio_Viaje_Carga FVC
	INNER JOIN Folio_Viaje_Descarga FVD ON FVC.folio_viaje = FVD.folio_viaje
	LEFT JOIN PL_RUTAS_T1_FINALIZADAS_2 r ON r.folio = FVC.folio_viaje
	LEFT JOIN PL_PARADAS_T1_FINALIZADAS_2 p ON p.id_ruta = r.id_ruta and p.id_cliente = FVD.id_destino
	LEFT JOIN PROVEEDOR PRO ON PRO.id_region = CAST(FVC.id_region_destino AS NVARCHAR);

	INSERT INTO Folio_Precautoria(id_folio, prioridad, fecha_vencimiento, [status], evento, id_region_destino)
	SELECT id_folio, prioridad, fecha_vencimiento, [status], evento, id_region_destino FROM @Alertas WHERE prioridad IS NOT NULL AND [status] = 0 AND fecha_vencimiento IS NOT NULL;

	INSERT INTO [Notificaciones].[cuenta].[whatsapp_Salida]
	SELECT DISTINCT ('Retraso a evento *(' + CAST(AL.id_folio AS NVARCHAR) + ')*: ' + AL.evento) mensaje, C.id_contacto contacto, GETDATE() fecha_envio, 1 modulo, 1 estatus, AL.id_folio FROM @Alertas AL 
	LEFT JOIN Folio_Rel_Grupo_Alerta FRGA ON AL.prioridad = FRGA.id_tipo_alerta
	INNER JOIN [Notificaciones].[cuenta].[grupo_contactos] GC ON GC.grupo = FRGA.id_grupo
	INNER JOIN [Notificaciones].[cat].[contactos] C ON C.id_contacto = GC.contacto
	WHERE AL.prioridad IS NOT NULL;

	SET @requestBody = CONCAT('[',(SELECT STUFF((SELECT ', ' + CAST(regiones AS NVARCHAR) FROM @Alertas WHERE regiones IS NOT NULL GROUP BY regiones FOR XML PATH('')),1, 2, '')),']');
	EXEC USP_HTTPRequest 'http://lgp2.logisticpro.com.mx:100/TrackingAPI/api/ControlTower/Prueba','POST', @requestBody
GO


