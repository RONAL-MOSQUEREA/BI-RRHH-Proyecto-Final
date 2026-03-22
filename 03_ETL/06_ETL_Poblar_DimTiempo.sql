-- ============================================================
-- 06_ETL_Poblar_DimTiempo.sql
-- Procedimiento de generación de la Dimensión Tiempo
-- Sistema BI - Proyecto Integrador Final
-- ============================================================

USE RRHH_DWH;
GO

-- ============================================================
-- PROCEDURE: Generar Dim_Tiempo para un rango de fechas
-- ============================================================
CREATE OR ALTER PROCEDURE ETL_Control.sp_Generar_DimTiempo
    @FechaInicio DATE = '2020-01-01',
    @FechaFin    DATE = '2030-12-31'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @LogID INT;
    DECLARE @FechaActual DATE = @FechaInicio;
    DECLARE @Contador INT = 0;

    -- Registrar inicio en Log
    INSERT INTO ETL_Control.Log_ETL (NombreProceso, FechaInicio, Estado)
    VALUES ('sp_Generar_DimTiempo', GETDATE(), 'Ejecutando');
    SET @LogID = SCOPE_IDENTITY();

    -- Limpiar registros en el rango (sin tocar el -1 de "Sin Información")
    DELETE FROM Dim_Tiempo
    WHERE Fecha BETWEEN @FechaInicio AND @FechaFin;

    -- Generar una fila por cada día en el rango
    WHILE @FechaActual <= @FechaFin
    BEGIN
        DECLARE @TiempoKey      INT  = YEAR(@FechaActual)*10000 + MONTH(@FechaActual)*100 + DAY(@FechaActual);
        DECLARE @Anio           INT  = YEAR(@FechaActual);
        DECLARE @Mes            INT  = MONTH(@FechaActual);
        DECLARE @DiaSemana      INT  = DATEPART(WEEKDAY, @FechaActual);  -- 1=Dom en SQL Server
        DECLARE @EsFinSemana    BIT  = CASE WHEN @DiaSemana IN (1,7) THEN 1 ELSE 0 END;
        DECLARE @Trimestre      INT  = DATEPART(QUARTER, @FechaActual);
        DECLARE @Semana         INT  = DATEPART(WEEK, @FechaActual);
        DECLARE @DiaAnio        INT  = DATEPART(DAYOFYEAR, @FechaActual);
        DECLARE @Semestre       INT  = CASE WHEN @Mes <= 6 THEN 1 ELSE 2 END;
        DECLARE @AnioMes        INT  = @Anio * 100 + @Mes;

        DECLARE @NombreMes VARCHAR(20) =
            CASE @Mes
                WHEN 1  THEN 'Enero'      WHEN 2  THEN 'Febrero'   WHEN 3  THEN 'Marzo'
                WHEN 4  THEN 'Abril'      WHEN 5  THEN 'Mayo'       WHEN 6  THEN 'Junio'
                WHEN 7  THEN 'Julio'      WHEN 8  THEN 'Agosto'     WHEN 9  THEN 'Septiembre'
                WHEN 10 THEN 'Octubre'    WHEN 11 THEN 'Noviembre'  WHEN 12 THEN 'Diciembre'
            END;

        DECLARE @NombreMesCorto CHAR(3) = LEFT(@NombreMes, 3);

        DECLARE @NombreDia VARCHAR(15) =
            CASE @DiaSemana
                WHEN 1 THEN 'Domingo'    WHEN 2 THEN 'Lunes'    WHEN 3 THEN 'Martes'
                WHEN 4 THEN 'Miércoles'  WHEN 5 THEN 'Jueves'   WHEN 6 THEN 'Viernes'
                WHEN 7 THEN 'Sábado'
            END;

        DECLARE @NombreTrimestre VARCHAR(10) = @Anio + '-Q' + CAST(@Trimestre AS VARCHAR(1));
        DECLARE @AnioTrimestre   VARCHAR(10) = CAST(@Anio AS VARCHAR(4)) + '-Q' + CAST(@Trimestre AS VARCHAR(1));

        INSERT INTO Dim_Tiempo (
            TiempoKey, Fecha, Anio, Trimestre, NombreTrimestre,
            Mes, NombreMes, NombreMesCorto, Semana, DiaSemana,
            NombreDia, NombreDiaCorto, DiaAnio, EsFeriado,
            EsFinSemana, EsDiaHabil, Semestre, AnioMes, AnioTrimestre
        ) VALUES (
            @TiempoKey, @FechaActual, @Anio, @Trimestre, @NombreTrimestre,
            @Mes, @NombreMes, @NombreMesCorto, @Semana, @DiaSemana,
            @NombreDia, LEFT(@NombreDia,3), @DiaAnio, 0,
            @EsFinSemana, CASE WHEN @EsFinSemana = 1 THEN 0 ELSE 1 END,
            @Semestre, @AnioMes, @AnioTrimestre
        );

        SET @FechaActual = DATEADD(DAY, 1, @FechaActual);
        SET @Contador = @Contador + 1;
    END;

    -- Marcar feriados nacionales de Colombia 2020-2030 (muestra de algunos)
    UPDATE Dim_Tiempo SET EsFeriado = 1, EsDiaHabil = 0
    WHERE (Mes = 1  AND DAY(Fecha) = 1)  -- Año Nuevo
       OR (Mes = 5  AND DAY(Fecha) = 1)  -- Día del Trabajo
       OR (Mes = 7  AND DAY(Fecha) = 20) -- Independencia Colombia
       OR (Mes = 8  AND DAY(Fecha) = 7)  -- Batalla de Boyacá
       OR (Mes = 12 AND DAY(Fecha) = 8)  -- Inmaculada Concepción
       OR (Mes = 12 AND DAY(Fecha) = 25);-- Navidad

    -- Actualizar Log
    UPDATE ETL_Control.Log_ETL
    SET FechaFin = GETDATE(), Estado = 'Exitoso',
        RegistrosCargados = @Contador,
        Mensaje = 'Dim_Tiempo generada para rango ' + CAST(@FechaInicio AS VARCHAR) + ' a ' + CAST(@FechaFin AS VARCHAR)
    WHERE LogID = @LogID;

    PRINT 'Dim_Tiempo generada: ' + CAST(@Contador AS VARCHAR) + ' registros insertados.';
END;
GO

-- ============================================================
-- EJECUCIÓN: Generar datos del 2020 al 2030
-- ============================================================
EXEC ETL_Control.sp_Generar_DimTiempo
    @FechaInicio = '2020-01-01',
    @FechaFin    = '2030-12-31';
GO

SELECT COUNT(*) AS TotalDias,
       MIN(Fecha) AS PrimeraFecha,
       MAX(Fecha) AS UltimaFecha
FROM Dim_Tiempo WHERE TiempoKey > 0;
GO

PRINT 'Dim_Tiempo poblada exitosamente.';
GO
