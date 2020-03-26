USE [BDLGP_HERDEZV2]
GO

/****** Object:  StoredProcedure [dbo].[USP_ControlTower_GetFolios]    Script Date: 26/03/2020 09:05:43 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USP_ControlTower_GetFolios]
@Campo NVARCHAR(255) = NULL,
@Busqueda NVARCHAR(255) = NULL,
@IdRegion NVARCHAR(MAX) = NULL
AS
	DECLARE @Folios TABLE(
	[folio_viaje] NUMERIC(20,0),
	[id_origen] NVARCHAR(50),
	[nombre_origen] NVARCHAR(255),
	[direccion_origen] NVARCHAR(255),
	[id_destino] NVARCHAR(50),
	[nombre_destino] NVARCHAR(255),
	[direccion_destino] NVARCHAR(255),
	[evento] NVARCHAR(50),
	[fecha_planeada] DATETIME,
	[hora_partida] DATETIME,
	[fecha_vencimiento] DATETIME,
	[eta] DECIMAL(18,2),
	[id_proveedor] NVARCHAR(50),
	[nombre_proveedor] NVARCHAR(100),
	[id_region] INT);

	-- SET STATISTICS TIME ON;
	DECLARE @Consulta NVARCHAR(MAX) = N'SELECT DISTINCT [folio_viaje], [id_origen], [direccion_origen], [nombre_origen], [id_destino], [nombre_destino], [direccion_destino], [evento], [fecha_planeada], [hora_partida], [fecha_vencimiento], [eta], [id_proveedor], [nombre_proveedor], [id_region] FROM View_FolioViaje ';
	IF(@Campo IS NOT NULL AND @Campo <> '' AND @Busqueda IS NOT NULL AND @Busqueda <> '')
	BEGIN
		SET @Consulta = CONCAT(@Consulta, 'WHERE ', @Campo, ' LIKE ''%'' + CAST(''' , @Busqueda  , ''' AS NVARCHAR(MAX)) + ''%''');
		IF(@Campo <> 'folio_viaje')
		BEGIN
			SET @Consulta = CONCAT(@Consulta, ' AND status = 0');
		END
		IF(@IdRegion <> '' AND @IdRegion IS NOT NULL)
		BEGIN
			SET @Consulta = CONCAT(@Consulta, ' AND CAST(id_region AS VARCHAR) IN (', @IdRegion,')');
		END
	END
	ELSE
	BEGIN
		IF(@IdRegion <> '' AND @IdRegion IS NOT NULL)
		BEGIN
			IF(@Campo IS NOT NULL AND @Campo <> '' AND @Busqueda IS NOT NULL AND @Busqueda <> '')
			BEGIN
				SET @Consulta = CONCAT(@Consulta,'WHERE id_region IN (', @IdRegion,')');
			END
			ELSE
			BEGIN
				--SET @Consulta = CONCAT(@Consulta,'WHERE id_region IN (', @IdRegion,') AND CAST(fecha_cita_destino AS DATE) = CAST(GETDATE() AS DATE)'); MODIFICADO 17/03/2020
				SET @Consulta = CONCAT(@Consulta,'WHERE id_region IN (', @IdRegion,') AND status = 0');
			END
		END
		ELSE
		BEGIN
			--SET @Consulta = CONCAT(@Consulta,'WHERE CAST(fecha_cita_destino AS DATE) = CAST(GETDATE() AS DATE)');  MODIFICADO 17/03/2020
			SET @Consulta = CONCAT(@Consulta,'WHERE status = 0')
		END
	END

	SET NOCOUNT ON;

	INSERT INTO @Folios
	EXEC (@Consulta);
	-- AGREGADO 17/03/2020
	UPDATE F SET F.id_destino = FVD.id_destino, F.direccion_destino = FVD.c_direccion, F.nombre_destino = FVD.c_nombre FROM @Folios F
	INNER JOIN Folio_Viaje_Descarga FVD ON F.folio_viaje = FVD.folio_viaje
	INNER JOIN PL_PEDIDOS_T1 PLPT1 ON FVD.folio_viaje = PLPT1.folio_viaje
	LEFT JOIN PL_PARADAS_T1_FINALIZADAS_2 PLPT1F2 ON  PLPT1F2.id_parada = PLPT1.id_parada WHERE PLPT1F2.[status] IN (3,4,5);
	
	-- SET STATISTICS TIME OFF;  
	SELECT * FROM @Folios;
	
	-- SET STATISTICS TIME ON;
	SELECT
		FVC.folio_viaje,
		PLPT1F2.fecha_llegada_prog fecha_cita_destino,
		PLRT1.conductor1 id_operador,
		(PLRT1.emp_nombre1) nombre_operador,
		FVC.tipo_unidad,
		FVC.tipo_servicio,
		FVC.tipo_viaje,
		PLPT1F2.id_parada id_parada_actual,
		PLPT1F2.c_dir dir_parada_actual
	FROM @Folios F
	INNER JOIN Folio_Viaje_Carga FVC ON FVC.folio_viaje = F.folio_viaje
	LEFT JOIN PL_RUTAS_T1_FINALIZADAS_2 PLRT1 ON PLRT1.folio = FVC.folio_viaje
	LEFT JOIN PL_PARADAS_T1_FINALIZADAS_2 PLPT1F2 ON PLPT1F2.id_ruta = PLRT1.id_ruta AND PLPT1F2.[status] IN (3,4,5,6,7)
	GROUP BY FVC.folio_viaje, PLPT1F2.fecha_llegada_prog, PLRT1.conductor1, PLRT1.emp_nombre1, FVC.tipo_unidad, FVC.tipo_servicio, FVC.tipo_viaje, PLPT1F2.id_parada, PLPT1F2.c_dir

	SELECT 0 id_evento, FVC.folio_viaje, FVC.id_origen, ('Asignado a Proveedor') nombre_evento, ('ADMINISTRATIVO') tipo_evento, (FVC.fecha_asignacion_proveedor) fecha_real, (FVC.fecha_asignacion_flotilla_teorica) fecha_planeada, null descri
	FROM Folio_Viaje_Carga FVC
	WHERE fecha_asignacion_proveedor IS NOT NULL AND FVC.folio_viaje IN (SELECT folio_viaje FROM @Folios)
	UNION ALL
	SELECT RFS.folio_status_id id_evento, 
		   FVC.folio_viaje, FVC.id_origen, 
		   (CASE
				WHEN RFS.folio_status_id = 21 THEN 'Asignado a Flotilla'
				WHEN RFS.folio_status_id = 1 THEN 'Folio Sincronizado'
				WHEN RFS.folio_status_id = 2 THEN 'Inicio de Folio'
				WHEN RFS.folio_status_id = 3 THEN 'Llegada a Origen'
				WHEN RFS.folio_status_id = 4 THEN 'Inicio de Carga'
				WHEN RFS.folio_status_id = 5 THEN 'Fin de Carga'
				WHEN RFS.folio_status_id = 6 THEN 'Salida de origen'
		   END) nombre_evento,
		   (CASE
				WHEN RFS.folio_status_id IN (21) THEN 'ADMINISTRATIVO'
				WHEN RFS.folio_status_id IN (1,2,3,4,5,6) THEN 'OPERATIVO'
		   END) tipo_evento,
		   (CASE
				WHEN RFS.folio_status_id = 21 THEN FVC.fecha_asignacion_flotilla
				WHEN RFS.folio_status_id = 1 THEN FVC.fecha_sincronizacion
				WHEN RFS.folio_status_id = 2 THEN FVC.inicio_folio
				WHEN RFS.folio_status_id = 3 THEN FVC.fecha_llegada_origen_QR
				WHEN RFS.folio_status_id = 4 THEN FVC.fecha_inicio_carga_QR
				WHEN RFS.folio_status_id = 5 THEN FVC.fecha_fin_carga
				WHEN RFS.folio_status_id = 6 THEN FVC.fecha_salida_origen_QR
		   END) fecha_real,
		   (CASE
				WHEN RFS.folio_status_id = 21 THEN FVC.fecha_asignacion_flotilla_teorica
				WHEN RFS.folio_status_id = 1 THEN FVC.fecha_salida_origen_teorico
				WHEN RFS.folio_status_id = 2 THEN FVC.arribo_origen_teorico
				WHEN RFS.folio_status_id = 3 THEN FVC.arribo_origen_teorico
				WHEN RFS.folio_status_id = 4 THEN FVC.fecha_inicio_carga_QR_teorica
				WHEN RFS.folio_status_id = 5 THEN FVC.fecha_fin_carga_teorica
				WHEN RFS.folio_status_id = 6 THEN FVC.fecha_salida_origen_teorico
		   END) fecha_planeada,
		   null descri
	FROM Folio_Viaje_Carga FVC 
	INNER JOIN PL_RUTAS_T1_FINALIZADAS_2 PLRT1F2 ON PLRT1F2.folio = FVC.folio_viaje
	INNER JOIN RelFolioStatus RFS ON RFS.id_ruta = PLRT1F2.id_ruta 
	WHERE RFS.folio_status_id IN (21,1,2,26,3,4,5,6) AND (CASE 
		WHEN RFS.folio_status_id = 21 THEN FVC.fecha_asignacion_flotilla 
		WHEN RFS.folio_status_id = 1 THEN FVC.fecha_sincronizacion
		WHEN RFS.folio_status_id = 2 THEN FVC.inicio_folio
		WHEN RFS.folio_status_id = 3 THEN FVC.fecha_llegada_origen_QR
		WHEN RFS.folio_status_id = 4 THEN FVC.fecha_inicio_carga_QR
		WHEN RFS.folio_status_id = 5 THEN FVC.fecha_fin_carga
		WHEN RFS.folio_status_id = 6 THEN FVC.fecha_salida_origen_QR
	END) IS NOT NULL AND RFS.id_parada IS NULL AND RFS.id_pedido IS NULL AND FVC.folio_viaje IN (SELECT folio_viaje FROM @Folios)
	UNION ALL
	SELECT 26 id_evento, FVC.folio_viaje, FVC.id_origen, ('Tránsito al origen') nombre_evento, ('OPERATIVO') tipo_evento, (FVC.inicio_folio) fecha_real, (FVC.arribo_origen_teorico) fecha_planeada, null descri
	FROM Folio_Viaje_Carga FVC 
	INNER JOIN PL_RUTAS_T1_FINALIZADAS_2 PLRT1F2 ON PLRT1F2.folio = FVC.folio_viaje
	LEFT JOIN RelFolioStatus RFS ON RFS.id_ruta = PLRT1F2.id_ruta 
	WHERE RFS.folio_status_id = 2 AND RFS.id_parada IS NULL AND RFS.id_pedido IS NULL AND FVC.fecha_llegada_origen_geo IS NOT NULL AND FVC.folio_viaje IN (SELECT folio_viaje FROM @Folios) 
	UNION ALL -- AGREGADO 17/03/2020
	SELECT 7 id_evento, FVC.folio_viaje, FVC.id_origen, ('Llegada a destino') nombre_evento, ('OPERATIVO') tipo_evento, (FVD.fecha_llegada_destino_QR) fecha_real, (FVD.fecha_llegada_destino_QR_teorica), FVD.c_nombre descri
	FROM Folio_Viaje_Carga FVC
	INNER JOIN Folio_Viaje_Descarga FVD ON FVC.folio_viaje = FVD.folio_viaje
	INNER JOIN PL_PEDIDOS_T1 PLPT1 ON PLPT1.pedido = FVD.pedido
	INNER JOIN RelFolioStatus RFS ON RFS.id_parada = PLPT1.id_parada WHERE RFS.folio_status_id = 7 AND FVC.folio_viaje IN (SELECT folio_viaje FROM @Folios)-- AGREGADO 17/03/2020
	UNION ALL
	SELECT 27 id_evento, FVC.folio_viaje, FVC.id_origen, ('Facturación') nombre_evento, ('ADMINISTRATIVO') tipo_evento, (FVD.fecha_facturacion) fecha_real, (FVD.fecha_facturacion_teorica) fecha_planeada, null descri
	FROM Folio_Viaje_Carga FVC INNER JOIN Folio_Viaje_Descarga FVD ON FVD.folio_viaje = FVC.folio_viaje
	WHERE FVD.fecha_facturacion IS NOT NULL AND FVC.folio_viaje IN (SELECT folio_viaje FROM @Folios) ORDER BY fecha_real;
GO


