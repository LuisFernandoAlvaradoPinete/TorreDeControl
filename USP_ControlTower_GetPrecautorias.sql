USE [BDLGP_HERDEZV2]
GO

/****** Object:  StoredProcedure [dbo].[USP_ControlTower_GetPrecautorias]    Script Date: 26/03/2020 09:16:28 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USP_ControlTower_GetPrecautorias]
@Regiones NVARCHAR(MAX) = NULL
AS
BEGIN
	IF(@Regiones IS NULL)
	BEGIN
		SELECT DISTINCT FP.id_folio_precaucion, FP.id_folio, FP.prioridad, FP.fecha_vencimiento, FP.[status], FP.evento
		FROM Folio_Precautoria FP
		INNER JOIN Folio_Viaje_Descarga FVD ON FVD.folio_viaje = FP.id_folio GROUP BY FP.id_folio_precaucion, FP.id_folio, FP.prioridad, FP.fecha_vencimiento, FP.[status], FP.evento ORDER BY FP.fecha_vencimiento, FP.prioridad;
	END
	ELSE
	BEGIN
		SELECT DISTINCT FP.id_folio_precaucion, FP.id_folio, FP.prioridad, FP.fecha_vencimiento, FP.[status], FP.evento
		FROM Folio_Precautoria FP
		INNER JOIN Folio_Viaje_Descarga FVD ON FVD.folio_viaje = FP.id_folio WHERE FP.id_region_destino IN (@Regiones) GROUP BY FP.id_folio_precaucion, FP.id_folio, FP.prioridad, FP.fecha_vencimiento, FP.[status], FP.evento ORDER BY FP.fecha_vencimiento, FP.prioridad;
	END

	SELECT DISTINCT FP.id_folio_precaucion, FVD.folio_viaje, FVD.c_nombre, FVD.c_direccion, PRO.id_provedor, PRO.nombre nombre_proveedor, EMP.usuario id_operador, (EMP.nombre + ' ' + EMP.apellido_p + EMP.apellido_m) nombre_operador, FVD.fecha_cita_destino, FVC.tipo_unidad, FVC.tipo_viaje, FVC.tipo_servicio 
	FROM Folio_Precautoria FP 
	INNER JOIN Folio_Viaje_Descarga FVD ON FVD.folio_viaje = FP.id_folio 
	INNER JOIN Folio_Viaje_Carga FVC ON FVC.folio_viaje = FVD.folio_viaje 
	LEFT JOIN PROVEEDOR PRO ON PRO.id_region = FVD.id_region_origen
	LEFT JOIN PL_RUTAS_T1 PLPRT1 ON PLPRT1.conductor1 = PRO.usuario 
	LEFT JOIN EMPLEADOS EMP ON EMP.usuario = PLPRT1.conductor1;

	SELECT DISTINCT FP.id_folio_precaucion, FVD.folio_viaje, FVD.id_concentrado
	FROM Folio_Precautoria FP 
	INNER JOIN Folio_Viaje_Descarga FVD ON FP.id_folio = FVD.folio_viaje GROUP BY FP.id_folio_precaucion, FVD.folio_viaje, FVD.id_concentrado
END
GO


