-- ============================================================
-- 08_ETL_Cargar_Hechos.sql
-- Carga de las 4 tablas de hechos desde RRHH_OLTP
-- Sistema BI - Proyecto Integrador Final
-- ============================================================

USE RRHH_DWH;
GO

-- ============================================================
-- FUNCTION auxiliar: Obtener TiempoKey desde una Fecha
-- ============================================================
CREATE OR ALTER FUNCTION dbo.fn_GetTiempoKey(@Fecha DATE)
RETURNS INT AS
BEGIN
    RETURN ISNULL(
        (SELECT TiempoKey FROM Dim_Tiempo WHERE Fecha = @Fecha),
        -1)
END;
GO

-- ============================================================
-- PROCEDURE 1: Cargar Fact_Ausencias
-- ============================================================
CREATE OR ALTER PROCEDURE ETL_Control.sp_ETL_Fact_Ausencias
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @LogID INT, @Ins INT = 0;
    INSERT INTO ETL_Control.Log_ETL (NombreProceso,FechaInicio,Estado)
    VALUES ('sp_ETL_Fact_Ausencias',GETDATE(),'Ejecutando');
    SET @LogID = SCOPE_IDENTITY();

    -- Eliminar datos previos para recarga completa (para demo)
    TRUNCATE TABLE Fact_Ausencias;

    INSERT INTO Fact_Ausencias (
        TiempoKeyInicio, TiempoKeyFin, EmpleadoKey, DepartamentoKey,
        CargoKey, TipoAusenciaKey, AusenciaID_OLTP,
        DiasAusencia, CostoAusencia, EsRemunerada, EstadoAusencia
    )
    SELECT
        dbo.fn_GetTiempoKey(a.FechaInicio),
        dbo.fn_GetTiempoKey(a.FechaFin),
        ISNULL(de.EmpleadoKey,  -1),
        ISNULL(dd.DepartamentoKey, -1),
        ISNULL(dc.CargoKey, -1),
        ISNULL(dta.TipoAusenciaKey, -1),
        a.AusenciaID,
        a.DiasAusencia,
        -- Costo = (Salario / 30) * Días solo si es remunerada
        CASE WHEN ta.Remunerada = 1
             THEN ROUND((e.Salario / 30.0) * a.DiasAusencia, 2)
             ELSE 0 END,
        ta.Remunerada,
        a.Estado
    FROM RRHH_OLTP.dbo.Ausencias a
    JOIN RRHH_OLTP.dbo.Empleados      e   ON a.EmpleadoID     = e.EmpleadoID
    JOIN RRHH_OLTP.dbo.TiposAusencia  ta  ON a.TipoAusenciaID = ta.TipoAusenciaID
    LEFT JOIN Dim_Empleado             de  ON de.EmpleadoID = e.EmpleadoID AND de.EsActual = 1
    LEFT JOIN Dim_Departamento         dd  ON dd.DepartamentoID = e.DepartamentoID AND dd.EsActual = 1
    LEFT JOIN Dim_Cargo                dc  ON dc.CargoID = e.CargoID AND dc.EsActual = 1
    LEFT JOIN Dim_TipoAusencia         dta ON dta.TipoAusenciaID = ta.TipoAusenciaID AND dta.EsActual = 1;

    SET @Ins = @@ROWCOUNT;
    UPDATE ETL_Control.Log_ETL
    SET FechaFin=GETDATE(),Estado='Exitoso',RegistrosCargados=@Ins,
        Mensaje='Fact_Ausencias: '+CAST(@Ins AS VARCHAR)+' filas cargadas.'
    WHERE LogID=@LogID;
    PRINT 'Fact_Ausencias: ' + CAST(@Ins AS VARCHAR) + ' filas cargadas.';
END;
GO

-- ============================================================
-- PROCEDURE 2: Cargar Fact_Evaluaciones
-- ============================================================
CREATE OR ALTER PROCEDURE ETL_Control.sp_ETL_Fact_Evaluaciones
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @LogID INT, @Ins INT = 0;
    INSERT INTO ETL_Control.Log_ETL (NombreProceso,FechaInicio,Estado)
    VALUES ('sp_ETL_Fact_Evaluaciones',GETDATE(),'Ejecutando');
    SET @LogID = SCOPE_IDENTITY();

    TRUNCATE TABLE Fact_Evaluaciones;

    INSERT INTO Fact_Evaluaciones (
        TiempoKey, EmpleadoKey, EvaluadorKey, DepartamentoKey, CargoKey,
        EvaluacionID_OLTP, CalificacionTotal, NotaCalidad, NotaProductividad,
        NotaCompetencias, NotaLiderazgo, NivelDesempeno, Anio, Semestre
    )
    SELECT
        dbo.fn_GetTiempoKey(ev.FechaEvaluacion),
        ISNULL(de.EmpleadoKey,   -1),
        ISNULL(deval.EmpleadoKey,-1),
        ISNULL(dd.DepartamentoKey,-1),
        ISNULL(dc.CargoKey,      -1),
        ev.EvaluacionID,
        ev.CalificacionTotal, ev.NotaCalidad, ev.NotaProductividad,
        ev.NotaCompetencias,  ev.NotaLiderazgo,
        ev.NivelDesempeno,
        pe.Anio, pe.Semestre
    FROM RRHH_OLTP.dbo.EvaluacionesDesempeno ev
    JOIN RRHH_OLTP.dbo.Empleados          e     ON ev.EmpleadoID    = e.EmpleadoID
    JOIN RRHH_OLTP.dbo.PeriodosEvaluacion pe    ON ev.PeriodoEvalID = pe.PeriodoEvalID
    LEFT JOIN Dim_Empleado  de    ON de.EmpleadoID    = ev.EmpleadoID   AND de.EsActual = 1
    LEFT JOIN Dim_Empleado  deval ON deval.EmpleadoID = ev.EvaluadorID  AND deval.EsActual = 1
    LEFT JOIN Dim_Departamento dd ON dd.DepartamentoID= e.DepartamentoID AND dd.EsActual = 1
    LEFT JOIN Dim_Cargo        dc ON dc.CargoID       = e.CargoID        AND dc.EsActual = 1;

    SET @Ins = @@ROWCOUNT;
    UPDATE ETL_Control.Log_ETL
    SET FechaFin=GETDATE(),Estado='Exitoso',RegistrosCargados=@Ins,
        Mensaje='Fact_Evaluaciones: '+CAST(@Ins AS VARCHAR)+' filas.'
    WHERE LogID=@LogID;
    PRINT 'Fact_Evaluaciones: ' + CAST(@Ins AS VARCHAR) + ' filas cargadas.';
END;
GO

-- ============================================================
-- PROCEDURE 3: Cargar Fact_Capacitaciones
-- ============================================================
CREATE OR ALTER PROCEDURE ETL_Control.sp_ETL_Fact_Capacitaciones
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @LogID INT, @Ins INT = 0;
    INSERT INTO ETL_Control.Log_ETL (NombreProceso,FechaInicio,Estado)
    VALUES ('sp_ETL_Fact_Capacitaciones',GETDATE(),'Ejecutando');
    SET @LogID = SCOPE_IDENTITY();

    TRUNCATE TABLE Fact_Capacitaciones;

    INSERT INTO Fact_Capacitaciones (
        TiempoKeyInicio, TiempoKeyFin, EmpleadoKey, DepartamentoKey, CursoKey,
        CapacitacionID_OLTP, DuracionHoras, CostoCurso, Calificacion, Certificado, EstadoCurso
    )
    SELECT
        dbo.fn_GetTiempoKey(cap.FechaInicio),
        dbo.fn_GetTiempoKey(cap.FechaFin),
        ISNULL(de.EmpleadoKey,   -1),
        ISNULL(dd.DepartamentoKey,-1),
        ISNULL(dc2.CursoKey,     -1),
        cap.CapacitacionID,
        cur.DuracionHoras,
        ISNULL(cur.Costo, 0),
        cap.Calificacion,
        cap.Certificado,
        cap.Estado
    FROM RRHH_OLTP.dbo.Capacitaciones cap
    JOIN RRHH_OLTP.dbo.Empleados  e   ON cap.EmpleadoID = e.EmpleadoID
    JOIN RRHH_OLTP.dbo.Cursos     cur ON cap.CursoID    = cur.CursoID
    LEFT JOIN Dim_Empleado     de  ON de.EmpleadoID    = e.EmpleadoID   AND de.EsActual = 1
    LEFT JOIN Dim_Departamento dd  ON dd.DepartamentoID= e.DepartamentoID AND dd.EsActual = 1
    LEFT JOIN Dim_Curso        dc2 ON dc2.CursoID      = cur.CursoID     AND dc2.EsActual = 1;

    SET @Ins = @@ROWCOUNT;
    UPDATE ETL_Control.Log_ETL
    SET FechaFin=GETDATE(),Estado='Exitoso',RegistrosCargados=@Ins,
        Mensaje='Fact_Capacitaciones: '+CAST(@Ins AS VARCHAR)+' filas.'
    WHERE LogID=@LogID;
    PRINT 'Fact_Capacitaciones: ' + CAST(@Ins AS VARCHAR) + ' filas cargadas.';
END;
GO

-- ============================================================
-- PROCEDURE 4: Cargar Fact_PlantillaEmpleados (Snapshot mensual)
-- ============================================================
CREATE OR ALTER PROCEDURE ETL_Control.sp_ETL_Fact_PlantillaEmpleados
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @LogID INT, @Ins INT = 0;
    INSERT INTO ETL_Control.Log_ETL (NombreProceso,FechaInicio,Estado)
    VALUES ('sp_ETL_Fact_PlantillaEmpleados',GETDATE(),'Ejecutando');
    SET @LogID = SCOPE_IDENTITY();

    TRUNCATE TABLE Fact_PlantillaEmpleados;

    -- Generar snapshot para el último día de cada mes entre 2022 y 2024
    ;WITH Meses AS (
        SELECT EOMONTH(DATEADD(MONTH, n, '2022-01-01')) AS UltimoDiaMes
        FROM (SELECT TOP 36 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
              FROM sys.objects) nums
    )
    INSERT INTO Fact_PlantillaEmpleados (
        TiempoKey, EmpleadoKey, DepartamentoKey, CargoKey,
        Salario, AniosAntiguedad, EstadoEmpleado, TipoContrato,
        Modalidad, EsActivo, EsNuevoIngreso, EsRetiro
    )
    SELECT
        dbo.fn_GetTiempoKey(m.UltimoDiaMes),
        ISNULL(de.EmpleadoKey,   -1),
        ISNULL(dd.DepartamentoKey,-1),
        ISNULL(dc.CargoKey,      -1),
        e.Salario,
        ROUND(DATEDIFF(DAY, e.FechaIngreso, m.UltimoDiaMes) / 365.25, 2),
        e.EstadoEmpleado,
        e.TipoContrato,
        e.Modalidad,
        CASE WHEN e.EstadoEmpleado = 'Activo' THEN 1 ELSE 0 END,
        CASE WHEN YEAR(e.FechaIngreso) = YEAR(m.UltimoDiaMes)
              AND MONTH(e.FechaIngreso) = MONTH(m.UltimoDiaMes) THEN 1 ELSE 0 END,
        CASE WHEN e.FechaSalida IS NOT NULL
              AND YEAR(e.FechaSalida) = YEAR(m.UltimoDiaMes)
              AND MONTH(e.FechaSalida) = MONTH(m.UltimoDiaMes) THEN 1 ELSE 0 END
    FROM Meses m
    CROSS JOIN RRHH_OLTP.dbo.Empleados e
    LEFT JOIN Dim_Empleado     de ON de.EmpleadoID     = e.EmpleadoID     AND de.EsActual = 1
    LEFT JOIN Dim_Departamento dd ON dd.DepartamentoID = e.DepartamentoID AND dd.EsActual = 1
    LEFT JOIN Dim_Cargo        dc ON dc.CargoID        = e.CargoID        AND dc.EsActual = 1
    WHERE e.FechaIngreso <= m.UltimoDiaMes
      AND (e.FechaSalida IS NULL OR e.FechaSalida >= m.UltimoDiaMes);

    SET @Ins = @@ROWCOUNT;
    UPDATE ETL_Control.Log_ETL
    SET FechaFin=GETDATE(),Estado='Exitoso',RegistrosCargados=@Ins,
        Mensaje='Fact_PlantillaEmpleados: '+CAST(@Ins AS VARCHAR)+' filas.'
    WHERE LogID=@LogID;
    PRINT 'Fact_PlantillaEmpleados: ' + CAST(@Ins AS VARCHAR) + ' filas cargadas.';
END;
GO

-- ============================================================
-- EJECUCIÓN
-- ============================================================
EXEC ETL_Control.sp_ETL_Fact_Ausencias;
EXEC ETL_Control.sp_ETL_Fact_Evaluaciones;
EXEC ETL_Control.sp_ETL_Fact_Capacitaciones;
EXEC ETL_Control.sp_ETL_Fact_PlantillaEmpleados;
GO

-- Resumen de carga
SELECT 'Fact_Ausencias'         AS Tabla, COUNT(*) AS Filas FROM Fact_Ausencias UNION ALL
SELECT 'Fact_Evaluaciones',               COUNT(*)           FROM Fact_Evaluaciones UNION ALL
SELECT 'Fact_Capacitaciones',             COUNT(*)           FROM Fact_Capacitaciones UNION ALL
SELECT 'Fact_PlantillaEmpleados',         COUNT(*)           FROM Fact_PlantillaEmpleados;
GO

PRINT 'Carga de hechos completada exitosamente.';
GO
