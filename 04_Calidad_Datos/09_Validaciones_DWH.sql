-- ============================================================
-- 09_Validaciones_DWH.sql
-- 10+ validaciones de calidad de datos en el Data Warehouse
-- Sistema BI - Proyecto Integrador Final
-- ============================================================

USE RRHH_DWH;
GO

PRINT '========================================================';
PRINT '   VALIDACIONES DE CALIDAD DE DATOS - RRHH_DWH';
PRINT '========================================================';
PRINT '';

-- ============================================================
-- VALIDACIÓN 1: Integridad referencial - FK huérfanas en Fact_Ausencias
-- ============================================================
PRINT '--- VAL 01: FK Huérfanas en Fact_Ausencias ---';
SELECT
    'Fact_Ausencias' AS Tabla,
    'EmpleadoKey -1' AS Validacion,
    COUNT(*) AS Cantidad,
    CASE WHEN COUNT(*) = 0 THEN 'APROBADO' ELSE 'ADVERTENCIA' END AS Resultado
FROM Fact_Ausencias WHERE EmpleadoKey = -1
UNION ALL
SELECT 'Fact_Ausencias','DepartamentoKey -1', COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN 'APROBADO' ELSE 'ADVERTENCIA' END
FROM Fact_Ausencias WHERE DepartamentoKey = -1
UNION ALL
SELECT 'Fact_Ausencias','TipoAusenciaKey -1', COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN 'APROBADO' ELSE 'ADVERTENCIA' END
FROM Fact_Ausencias WHERE TipoAusenciaKey = -1;

-- ============================================================
-- VALIDACIÓN 2: Integridad referencial - FK huérfanas en Fact_Evaluaciones
-- ============================================================
PRINT '';
PRINT '--- VAL 02: FK Huérfanas en Fact_Evaluaciones ---';
SELECT
    'Fact_Evaluaciones' AS Tabla,
    'EmpleadoKey -1' AS Validacion,
    COUNT(*) AS Cantidad,
    CASE WHEN COUNT(*) = 0 THEN 'APROBADO' ELSE 'ADVERTENCIA' END AS Resultado
FROM Fact_Evaluaciones WHERE EmpleadoKey = -1
UNION ALL
SELECT 'Fact_Evaluaciones','CargoKey -1', COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN 'APROBADO' ELSE 'ADVERTENCIA' END
FROM Fact_Evaluaciones WHERE CargoKey = -1;

-- ============================================================
-- VALIDACIÓN 3: Rango de calificaciones [0-100]
-- ============================================================
PRINT '';
PRINT '--- VAL 03: Calificaciones fuera de rango [0,100] ---';
SELECT
    'Fact_Evaluaciones' AS Tabla,
    'CalificacionTotal fuera de rango' AS Validacion,
    COUNT(*) AS Cantidad,
    CASE WHEN COUNT(*) = 0 THEN 'APROBADO' ELSE 'ERROR CRITICO' END AS Resultado
FROM Fact_Evaluaciones
WHERE CalificacionTotal < 0 OR CalificacionTotal > 100;

-- ============================================================
-- VALIDACIÓN 4: Días de ausencia negativos o cero
-- ============================================================
PRINT '';
PRINT '--- VAL 04: Días de ausencia inválidos (<= 0) ---';
SELECT
    'Fact_Ausencias' AS Tabla,
    'DiasAusencia <= 0' AS Validacion,
    COUNT(*) AS Cantidad,
    CASE WHEN COUNT(*) = 0 THEN 'APROBADO' ELSE 'ERROR CRITICO' END AS Resultado
FROM Fact_Ausencias WHERE DiasAusencia <= 0;

-- ============================================================
-- VALIDACIÓN 5: Coherencia de fechas (FechaFin >= FechaInicio en ausencias)
-- ============================================================
PRINT '';
PRINT '--- VAL 05: Coherencia FechaFin >= FechaInicio ---';
SELECT
    'Fact_Ausencias' AS Tabla,
    'TiempoKeyFin < TiempoKeyInicio' AS Validacion,
    COUNT(*) AS Cantidad,
    CASE WHEN COUNT(*) = 0 THEN 'APROBADO' ELSE 'ERROR CRITICO' END AS Resultado
FROM Fact_Ausencias WHERE TiempoKeyFin < TiempoKeyInicio;

-- ============================================================
-- VALIDACIÓN 6: Unicidad de claves naturales en dimensiones vigentes
-- ============================================================
PRINT '';
PRINT '--- VAL 06: Duplicados en dimensiones vigentes (EsActual=1) ---';
SELECT 'Dim_Empleado' AS Dimension,
       'EmpleadoID duplicado activo' AS Validacion,
       COUNT(*) - COUNT(DISTINCT EmpleadoID) AS Duplicados,
       CASE WHEN COUNT(*) = COUNT(DISTINCT EmpleadoID) THEN 'APROBADO' ELSE 'ERROR CRITICO' END AS Resultado
FROM Dim_Empleado WHERE EsActual = 1 AND EmpleadoID > 0
UNION ALL
SELECT 'Dim_Departamento','DepartamentoID duplicado activo',
       COUNT(*) - COUNT(DISTINCT DepartamentoID),
       CASE WHEN COUNT(*) = COUNT(DISTINCT DepartamentoID) THEN 'APROBADO' ELSE 'ERROR CRITICO' END
FROM Dim_Departamento WHERE EsActual = 1 AND DepartamentoID > 0
UNION ALL
SELECT 'Dim_Cargo','CargoID duplicado activo',
       COUNT(*) - COUNT(DISTINCT CargoID),
       CASE WHEN COUNT(*) = COUNT(DISTINCT CargoID) THEN 'APROBADO' ELSE 'ERROR CRITICO' END
FROM Dim_Cargo WHERE EsActual = 1 AND CargoID > 0;

-- ============================================================
-- VALIDACIÓN 7: Completitud de Dim_Tiempo (sin fechas faltantes en 2023)
-- ============================================================
PRINT '';
PRINT '--- VAL 07: Completitud de Dim_Tiempo para 2023 ---';
SELECT
    'Dim_Tiempo' AS Tabla,
    'Dias en 2023' AS Validacion,
    COUNT(*) AS DiasRegistrados,
    CASE WHEN COUNT(*) = 365 THEN 'APROBADO'
         ELSE 'ERROR: Se esperaban 365, hay ' + CAST(COUNT(*) AS VARCHAR) END AS Resultado
FROM Dim_Tiempo WHERE Anio = 2023;

-- ============================================================
-- VALIDACIÓN 8: Salarios no negativos ni cero
-- ============================================================
PRINT '';
PRINT '--- VAL 08: Salarios inválidos en Dim_Empleado ---';
SELECT
    'Dim_Empleado' AS Tabla,
    'Salario <= 0' AS Validacion,
    COUNT(*) AS Cantidad,
    CASE WHEN COUNT(*) = 0 THEN 'APROBADO' ELSE 'ERROR CRITICO' END AS Resultado
FROM Dim_Empleado WHERE Salario <= 0 AND EmpleadoID > 0;

-- ============================================================
-- VALIDACIÓN 9: Costo de ausencia coherente (no negativo)
-- ============================================================
PRINT '';
PRINT '--- VAL 09: Costo de ausencia negativo ---';
SELECT
    'Fact_Ausencias' AS Tabla,
    'CostoAusencia < 0' AS Validacion,
    COUNT(*) AS Cantidad,
    CASE WHEN COUNT(*) = 0 THEN 'APROBADO' ELSE 'ERROR CRITICO' END AS Resultado
FROM Fact_Ausencias WHERE CostoAusencia < 0;

-- ============================================================
-- VALIDACIÓN 10: Conteo de registros DWH vs OLTP
-- ============================================================
PRINT '';
PRINT '--- VAL 10: Conteo filas DWH vs OLTP ---';
SELECT 'Fact_Ausencias' AS Tabla,
       (SELECT COUNT(*) FROM Fact_Ausencias) AS Filas_DWH,
       (SELECT COUNT(*) FROM RRHH_OLTP.dbo.Ausencias) AS Filas_OLTP,
       CASE WHEN (SELECT COUNT(*) FROM Fact_Ausencias) =
                 (SELECT COUNT(*) FROM RRHH_OLTP.dbo.Ausencias)
            THEN 'APROBADO' ELSE 'DIFERENCIA DETECTADA' END AS Resultado
UNION ALL
SELECT 'Fact_Evaluaciones',
       (SELECT COUNT(*) FROM Fact_Evaluaciones),
       (SELECT COUNT(*) FROM RRHH_OLTP.dbo.EvaluacionesDesempeno),
       CASE WHEN (SELECT COUNT(*) FROM Fact_Evaluaciones) =
                 (SELECT COUNT(*) FROM RRHH_OLTP.dbo.EvaluacionesDesempeno)
            THEN 'APROBADO' ELSE 'DIFERENCIA DETECTADA' END
UNION ALL
SELECT 'Fact_Capacitaciones',
       (SELECT COUNT(*) FROM Fact_Capacitaciones),
       (SELECT COUNT(*) FROM RRHH_OLTP.dbo.Capacitaciones),
       CASE WHEN (SELECT COUNT(*) FROM Fact_Capacitaciones) =
                 (SELECT COUNT(*) FROM RRHH_OLTP.dbo.Capacitaciones)
            THEN 'APROBADO' ELSE 'DIFERENCIA DETECTADA' END;

-- ============================================================
-- VALIDACIÓN 11: Empleados activos en OLTP presentes en DWH
-- ============================================================
PRINT '';
PRINT '--- VAL 11: Empleados activos OLTP sin versión vigente en DWH ---';
SELECT
    'Dim_Empleado' AS Tabla,
    'Empleados activos faltantes en DWH' AS Validacion,
    COUNT(*) AS Cantidad,
    CASE WHEN COUNT(*) = 0 THEN 'APROBADO' ELSE 'ERROR CRITICO' END AS Resultado
FROM RRHH_OLTP.dbo.Empleados e
WHERE e.EstadoEmpleado = 'Activo'
  AND NOT EXISTS (
      SELECT 1 FROM Dim_Empleado de
      WHERE de.EmpleadoID = e.EmpleadoID AND de.EsActual = 1);

-- ============================================================
-- VALIDACIÓN 12: Horas de capacitación no negativas
-- ============================================================
PRINT '';
PRINT '--- VAL 12: Horas de capacitación inválidas ---';
SELECT
    'Fact_Capacitaciones' AS Tabla,
    'DuracionHoras <= 0' AS Validacion,
    COUNT(*) AS Cantidad,
    CASE WHEN COUNT(*) = 0 THEN 'APROBADO' ELSE 'ERROR CRITICO' END AS Resultado
FROM Fact_Capacitaciones WHERE DuracionHoras <= 0;

-- ============================================================
-- RESUMEN GLOBAL DE CALIDAD
-- ============================================================
PRINT '';
PRINT '--- RESUMEN: Log de ejecuciones ETL ---';
SELECT NombreProceso, Estado, RegistrosCargados, Mensaje, FechaFin
FROM ETL_Control.Log_ETL
ORDER BY LogID DESC;

PRINT '';
PRINT '========================================================';
PRINT '   FIN DE VALIDACIONES';
PRINT '========================================================';
GO
