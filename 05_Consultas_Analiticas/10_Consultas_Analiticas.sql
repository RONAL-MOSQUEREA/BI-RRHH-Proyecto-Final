-- ============================================================
-- 10_Consultas_Analiticas.sql
-- 15 Consultas Analíticas Multidimensionales - KPIs de RRHH
-- Sistema BI - Proyecto Integrador Final
-- ============================================================

USE RRHH_DWH;
GO

PRINT '============================================================';
PRINT '  CONSULTAS ANALÍTICAS - SISTEMA BI RRHH';
PRINT '============================================================';

-- ============================================================
-- KPI 1: Headcount total por departamento (último snapshot)
-- ============================================================
PRINT '--- KPI 01: Headcount por Departamento ---';
SELECT
    dd.NombreDepartamento,
    dd.NombreOficina,
    dd.NombreCiudad,
    COUNT(fp.PlantillaKey)        AS TotalEmpleados,
    SUM(fp.Salario)               AS MasaSalarial,
    AVG(fp.Salario)               AS SalarioPromedio,
    AVG(fp.AniosAntiguedad)       AS AniosPromedio
FROM Fact_PlantillaEmpleados fp
JOIN Dim_Departamento dd ON fp.DepartamentoKey = dd.DepartamentoKey
JOIN Dim_Tiempo       dt ON fp.TiempoKey       = dt.TiempoKey
WHERE dt.Fecha = (SELECT MAX(Fecha) FROM Dim_Tiempo dt2
                  JOIN Fact_PlantillaEmpleados fp2 ON fp2.TiempoKey = dt2.TiempoKey)
  AND fp.EsActivo = 1
  AND dd.DepartamentoID > 0
GROUP BY dd.NombreDepartamento, dd.NombreOficina, dd.NombreCiudad
ORDER BY TotalEmpleados DESC;
GO

-- ============================================================
-- KPI 2: Tasa de ausentismo por departamento y año
-- Fórmula: (Días ausencia / Días laborables) * 100
-- ============================================================
PRINT '';
PRINT '--- KPI 02: Tasa de Ausentismo por Departamento y Año ---';
SELECT
    dd.NombreDepartamento,
    dt.Anio,
    COUNT(fa.AusenciaKey)              AS NumAusencias,
    SUM(fa.DiasAusencia)               AS TotalDiasAusentes,
    SUM(fa.CostoAusencia)              AS CostoTotalAusencias,
    ROUND(SUM(fa.DiasAusencia) * 100.0
          / (COUNT(DISTINCT fa.EmpleadoKey) * 250), 2) AS TasaAusentismoPct
FROM Fact_Ausencias fa
JOIN Dim_Tiempo       dt ON fa.TiempoKeyInicio = dt.TiempoKey
JOIN Dim_Departamento dd ON fa.DepartamentoKey = dd.DepartamentoKey
WHERE dd.DepartamentoID > 0
GROUP BY dd.NombreDepartamento, dt.Anio
ORDER BY dt.Anio, TasaAusentismoPct DESC;
GO

-- ============================================================
-- KPI 3: Calificación promedio de desempeño por departamento y semestre
-- ============================================================
PRINT '';
PRINT '--- KPI 03: Desempeño Promedio por Departamento y Semestre ---';
SELECT
    dd.NombreDepartamento,
    fe.Anio,
    fe.Semestre,
    COUNT(fe.EvaluacionKey)                    AS NumEvaluaciones,
    ROUND(AVG(fe.CalificacionTotal), 2)        AS CalifPromedio,
    ROUND(AVG(fe.NotaCalidad), 2)              AS CalidadPromedio,
    ROUND(AVG(fe.NotaProductividad), 2)        AS ProductividadPromedio,
    ROUND(AVG(fe.NotaLiderazgo), 2)            AS LiderazgoPromedio,
    SUM(CASE WHEN fe.NivelDesempeno = 'Sobresaliente' THEN 1 ELSE 0 END) AS Sobresalientes,
    SUM(CASE WHEN fe.NivelDesempeno = 'Insuficiente'  THEN 1 ELSE 0 END) AS Insuficientes
FROM Fact_Evaluaciones fe
JOIN Dim_Departamento dd ON fe.DepartamentoKey = dd.DepartamentoKey
WHERE dd.DepartamentoID > 0
GROUP BY dd.NombreDepartamento, fe.Anio, fe.Semestre
ORDER BY fe.Anio, fe.Semestre, CalifPromedio DESC;
GO

-- ============================================================
-- KPI 4: Top 10 empleados con mayor calificación (último semestre)
-- ============================================================
PRINT '';
PRINT '--- KPI 04: Top 10 Empleados por Desempeño ---';
SELECT TOP 10
    de.NombreCompleto,
    dc.NombreCargo,
    dd.NombreDepartamento,
    fe.Anio,
    fe.Semestre,
    fe.CalificacionTotal,
    fe.NivelDesempeno
FROM Fact_Evaluaciones fe
JOIN Dim_Empleado     de ON fe.EmpleadoKey     = de.EmpleadoKey
JOIN Dim_Cargo        dc ON fe.CargoKey        = dc.CargoKey
JOIN Dim_Departamento dd ON fe.DepartamentoKey = dd.DepartamentoKey
WHERE de.EmpleadoID > 0
  AND fe.Anio = (SELECT MAX(Anio) FROM Fact_Evaluaciones)
  AND fe.Semestre = (SELECT MAX(Semestre) FROM Fact_Evaluaciones
                     WHERE Anio = (SELECT MAX(Anio) FROM Fact_Evaluaciones))
ORDER BY fe.CalificacionTotal DESC;
GO

-- ============================================================
-- KPI 5: Inversión en capacitación por departamento y año
-- ============================================================
PRINT '';
PRINT '--- KPI 05: Inversión en Capacitación por Departamento ---';
SELECT
    dd.NombreDepartamento,
    dt.Anio,
    COUNT(fc.CapacitacionKey)          AS TotalCapacitaciones,
    SUM(fc.DuracionHoras)              AS TotalHoras,
    SUM(fc.CostoCurso)                 AS InversionTotal,
    AVG(fc.CostoCurso)                 AS CostoPromedioCurso,
    SUM(CASE WHEN fc.Certificado = 1 THEN 1 ELSE 0 END) AS Certificados,
    ROUND(AVG(ISNULL(fc.Calificacion, 0)), 2)           AS CalifPromedio
FROM Fact_Capacitaciones fc
JOIN Dim_Departamento dd ON fc.DepartamentoKey  = dd.DepartamentoKey
JOIN Dim_Tiempo       dt ON fc.TiempoKeyInicio  = dt.TiempoKey
WHERE dd.DepartamentoID > 0
GROUP BY dd.NombreDepartamento, dt.Anio
ORDER BY dt.Anio, InversionTotal DESC;
GO

-- ============================================================
-- KPI 6: Tipos de ausencia más frecuentes
-- ============================================================
PRINT '';
PRINT '--- KPI 06: Ranking de Tipos de Ausencia ---';
SELECT
    dta.NombreTipo,
    dta.Remunerada,
    COUNT(fa.AusenciaKey)    AS Frecuencia,
    SUM(fa.DiasAusencia)     AS TotalDias,
    SUM(fa.CostoAusencia)    AS CostoTotal,
    ROUND(AVG(CAST(fa.DiasAusencia AS FLOAT)), 1) AS DuracionPromedio
FROM Fact_Ausencias fa
JOIN Dim_TipoAusencia dta ON fa.TipoAusenciaKey = dta.TipoAusenciaKey
WHERE dta.TipoAusenciaID > 0
GROUP BY dta.NombreTipo, dta.Remunerada
ORDER BY Frecuencia DESC;
GO

-- ============================================================
-- KPI 7: Evolución mensual del headcount (tendencia de crecimiento)
-- ============================================================
PRINT '';
PRINT '--- KPI 07: Evolución Mensual del Headcount ---';
SELECT
    dt.Anio,
    dt.NombreMes,
    dt.Mes,
    COUNT(fp.PlantillaKey)         AS TotalEmpleados,
    SUM(fp.EsNuevoIngreso)         AS NuevosIngresos,
    SUM(fp.EsRetiro)               AS Retiros,
    SUM(fp.Salario)                AS MasaSalarialTotal,
    AVG(fp.AniosAntiguedad)        AS AntigüedadPromedio
FROM Fact_PlantillaEmpleados fp
JOIN Dim_Tiempo dt ON fp.TiempoKey = dt.TiempoKey
WHERE fp.EsActivo = 1 AND DAY(dt.Fecha) = DAY(EOMONTH(dt.Fecha))  -- último día de mes
GROUP BY dt.Anio, dt.NombreMes, dt.Mes, dt.AnioMes
ORDER BY dt.AnioMes;
GO

-- ============================================================
-- KPI 8: Distribución por género y nivel de cargo
-- ============================================================
PRINT '';
PRINT '--- KPI 08: Distribución Empleados por Género y Nivel ---';
SELECT
    dc.Nivel,
    de.Genero,
    COUNT(fp.PlantillaKey)   AS CantidadEmpleados,
    AVG(fp.Salario)          AS SalarioPromedio,
    ROUND(COUNT(fp.PlantillaKey) * 100.0 /
          SUM(COUNT(fp.PlantillaKey)) OVER (PARTITION BY dc.Nivel), 2) AS PorcentajeEnNivel
FROM Fact_PlantillaEmpleados fp
JOIN Dim_Empleado de ON fp.EmpleadoKey = de.EmpleadoKey
JOIN Dim_Cargo    dc ON fp.CargoKey    = dc.CargoKey
JOIN Dim_Tiempo   dt ON fp.TiempoKey  = dt.TiempoKey
WHERE fp.EsActivo = 1
  AND de.EmpleadoID > 0 AND dc.CargoID > 0
  AND dt.Fecha = (SELECT MAX(Fecha) FROM Dim_Tiempo dt2
                  JOIN Fact_PlantillaEmpleados fp2 ON fp2.TiempoKey = dt2.TiempoKey)
GROUP BY dc.Nivel, de.Genero
ORDER BY dc.Nivel, de.Genero;
GO

-- ============================================================
-- KPI 9: Correlación capacitación-desempeño (empleados con/sin cursos)
-- ============================================================
PRINT '';
PRINT '--- KPI 09: Impacto de Capacitación en Desempeño ---';
SELECT
    de.NombreCompleto,
    dd.NombreDepartamento,
    COUNT(DISTINCT fc.CapacitacionKey)    AS CursosCompletados,
    SUM(fc.DuracionHoras)                 AS HorasTotales,
    MAX(fe.CalificacionTotal)             AS UltimaCalificacion,
    AVG(fe.CalificacionTotal)             AS CalifPromedio
FROM Dim_Empleado de
LEFT JOIN Fact_Capacitaciones fc ON fc.EmpleadoKey = de.EmpleadoKey
                                 AND fc.EstadoCurso = 'Completado'
LEFT JOIN Fact_Evaluaciones   fe ON fe.EmpleadoKey = de.EmpleadoKey
LEFT JOIN Dim_Departamento    dd ON dd.DepartamentoKey =
         (SELECT TOP 1 DepartamentoKey FROM Fact_PlantillaEmpleados
          WHERE EmpleadoKey = de.EmpleadoKey ORDER BY TiempoKey DESC)
WHERE de.EmpleadoID > 0 AND de.EsActual = 1
GROUP BY de.NombreCompleto, dd.NombreDepartamento
ORDER BY CalifPromedio DESC;
GO

-- ============================================================
-- KPI 10: Cursos más populares y con mejor calificación
-- ============================================================
PRINT '';
PRINT '--- KPI 10: Ranking de Cursos de Capacitación ---';
SELECT
    dc.NombreCurso,
    dc.NombreArea,
    dc.Modalidad,
    dc.DuracionHoras,
    dc.Costo,
    COUNT(fc.CapacitacionKey)            AS VecesImpartido,
    ROUND(AVG(ISNULL(fc.Calificacion,0)),2) AS CalifPromedio,
    SUM(CASE WHEN fc.Certificado=1 THEN 1 ELSE 0 END) AS TotalCertificados,
    SUM(fc.CostoCurso)                   AS InversionGenerada
FROM Fact_Capacitaciones fc
JOIN Dim_Curso dc ON fc.CursoKey = dc.CursoKey
WHERE dc.CursoID > 0
GROUP BY dc.NombreCurso, dc.NombreArea, dc.Modalidad, dc.DuracionHoras, dc.Costo
ORDER BY VecesImpartido DESC, CalifPromedio DESC;
GO

-- ============================================================
-- KPI 11: Análisis SCD - Historial de cambios en empleados
-- ============================================================
PRINT '';
PRINT '--- KPI 11: Historial de Cambios SCD Tipo 2 en Empleados ---';
SELECT
    de.Cedula,
    de.NombreCompleto,
    de.Version,
    de.Salario,
    de.TipoContrato,
    de.Modalidad,
    de.FechaInicioVigencia,
    ISNULL(CAST(de.FechaFinVigencia AS VARCHAR), 'VIGENTE') AS FechaFinVigencia,
    de.EsActual
FROM Dim_Empleado de
WHERE de.EmpleadoID > 0
  AND de.EmpleadoID IN (
      SELECT EmpleadoID FROM Dim_Empleado
      WHERE EmpleadoID > 0
      GROUP BY EmpleadoID HAVING COUNT(*) > 1)
ORDER BY de.Cedula, de.Version;
GO

-- ============================================================
-- KPI 12: Empleados con mayor ausentismo acumulado
-- ============================================================
PRINT '';
PRINT '--- KPI 12: Top Empleados por Días de Ausencia ---';
SELECT TOP 10
    de.NombreCompleto,
    dc.NombreCargo,
    dd.NombreDepartamento,
    COUNT(fa.AusenciaKey)    AS NumAusencias,
    SUM(fa.DiasAusencia)     AS TotalDiasAusente,
    SUM(fa.CostoAusencia)    AS CostoTotalAusencias
FROM Fact_Ausencias fa
JOIN Dim_Empleado     de ON fa.EmpleadoKey     = de.EmpleadoKey AND de.EsActual = 1
JOIN Dim_Cargo        dc ON fa.CargoKey        = dc.CargoKey    AND dc.EsActual = 1
JOIN Dim_Departamento dd ON fa.DepartamentoKey = dd.DepartamentoKey AND dd.EsActual = 1
WHERE de.EmpleadoID > 0
GROUP BY de.NombreCompleto, dc.NombreCargo, dd.NombreDepartamento
ORDER BY TotalDiasAusente DESC;
GO

-- ============================================================
-- KPI 13: Comparativo semestral de desempeño (YoY)
-- ============================================================
PRINT '';
PRINT '--- KPI 13: Comparativo Año vs Año en Desempeño ---';
SELECT
    fe.Semestre,
    fe.Anio,
    COUNT(fe.EvaluacionKey)            AS NumEvaluaciones,
    ROUND(AVG(fe.CalificacionTotal),2) AS Promedio,
    MAX(fe.CalificacionTotal)          AS MaxCalif,
    MIN(fe.CalificacionTotal)          AS MinCalif,
    SUM(CASE WHEN fe.NivelDesempeno='Sobresaliente' THEN 1 ELSE 0 END) AS Sobresalientes,
    SUM(CASE WHEN fe.NivelDesempeno='Bueno'         THEN 1 ELSE 0 END) AS Buenos,
    SUM(CASE WHEN fe.NivelDesempeno='Satisfactorio' THEN 1 ELSE 0 END) AS Satisfactorios,
    SUM(CASE WHEN fe.NivelDesempeno='Insuficiente'  THEN 1 ELSE 0 END) AS Insuficientes
FROM Fact_Evaluaciones fe
GROUP BY fe.Semestre, fe.Anio
ORDER BY fe.Anio, fe.Semestre;
GO

-- ============================================================
-- KPI 14: Masa salarial por modalidad de trabajo
-- ============================================================
PRINT '';
PRINT '--- KPI 14: Distribución Salarial por Modalidad ---';
SELECT
    fp.Modalidad,
    COUNT(fp.PlantillaKey)  AS NumEmpleados,
    SUM(fp.Salario)         AS MasaSalarial,
    AVG(fp.Salario)         AS SalarioPromedio,
    MIN(fp.Salario)         AS SalarioMinimo,
    MAX(fp.Salario)         AS SalarioMaximo,
    ROUND(SUM(fp.Salario) * 100.0 / SUM(SUM(fp.Salario)) OVER (), 2) AS PctMasaSalarial
FROM Fact_PlantillaEmpleados fp
JOIN Dim_Tiempo dt ON fp.TiempoKey = dt.TiempoKey
WHERE fp.EsActivo = 1
  AND dt.Fecha = (SELECT MAX(Fecha) FROM Dim_Tiempo dt2
                  JOIN Fact_PlantillaEmpleados fp2 ON fp2.TiempoKey = dt2.TiempoKey)
GROUP BY fp.Modalidad
ORDER BY MasaSalarial DESC;
GO

-- ============================================================
-- KPI 15: Dashboard resumen ejecutivo (Vista 360° RRHH)
-- ============================================================
PRINT '';
PRINT '--- KPI 15: Resumen Ejecutivo BI RRHH ---';
SELECT
    'Total Empleados Activos'     AS Indicador,
    CAST(COUNT(*) AS VARCHAR)     AS Valor
FROM Fact_PlantillaEmpleados fp
JOIN Dim_Tiempo dt ON fp.TiempoKey = dt.TiempoKey
WHERE fp.EsActivo=1
  AND dt.Fecha=(SELECT MAX(Fecha) FROM Dim_Tiempo dt2
                JOIN Fact_PlantillaEmpleados fp2 ON fp2.TiempoKey=dt2.TiempoKey)
UNION ALL
SELECT 'Masa Salarial Mensual Total',
    '$' + FORMAT(SUM(fp.Salario),'N0','es-CO')
FROM Fact_PlantillaEmpleados fp
JOIN Dim_Tiempo dt ON fp.TiempoKey=dt.TiempoKey
WHERE fp.EsActivo=1
  AND dt.Fecha=(SELECT MAX(Fecha) FROM Dim_Tiempo dt2
                JOIN Fact_PlantillaEmpleados fp2 ON fp2.TiempoKey=dt2.TiempoKey)
UNION ALL
SELECT 'Total Ausencias Registradas',
    CAST(COUNT(*) AS VARCHAR)
FROM Fact_Ausencias
UNION ALL
SELECT 'Dias Totales de Ausencia',
    CAST(SUM(DiasAusencia) AS VARCHAR)
FROM Fact_Ausencias
UNION ALL
SELECT 'Total Evaluaciones Realizadas',
    CAST(COUNT(*) AS VARCHAR)
FROM Fact_Evaluaciones
UNION ALL
SELECT 'Calificacion Promedio Global',
    CAST(ROUND(AVG(CalificacionTotal),2) AS VARCHAR)
FROM Fact_Evaluaciones
UNION ALL
SELECT 'Total Capacitaciones',
    CAST(COUNT(*) AS VARCHAR)
FROM Fact_Capacitaciones
UNION ALL
SELECT 'Inversion Total Capacitacion',
    '$' + FORMAT(SUM(CostoCurso),'N0','es-CO')
FROM Fact_Capacitaciones;
GO

PRINT '============================================================';
PRINT '  FIN - 15 CONSULTAS ANALÍTICAS EJECUTADAS';
PRINT '============================================================';
GO
