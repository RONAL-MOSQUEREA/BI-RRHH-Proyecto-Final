-- ============================================================
-- 07_ETL_Cargar_Dimensiones.sql
-- Procedimientos ETL con lógica SCD Tipo 2 para todas las dimensiones
-- Sistema BI - Proyecto Integrador Final
-- ============================================================

USE RRHH_DWH;
GO

-- ============================================================
-- PROCEDURE 1: Cargar Dim_Departamento (SCD Tipo 2)
-- ============================================================
CREATE OR ALTER PROCEDURE ETL_Control.sp_ETL_Dim_Departamento
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @LogID INT, @Ins INT = 0, @Upd INT = 0;
    INSERT INTO ETL_Control.Log_ETL (NombreProceso,FechaInicio,Estado)
    VALUES ('sp_ETL_Dim_Departamento',GETDATE(),'Ejecutando');
    SET @LogID = SCOPE_IDENTITY();

    -- Fuente: JOIN de Departamentos + Oficinas + Ciudades + Países
    ;WITH Fuente AS (
        SELECT d.DepartamentoID,
               d.NombreDepartamento,
               d.Presupuesto,
               o.NombreOficina,
               c.NombreCiudad,
               p.NombrePais
        FROM RRHH_OLTP.dbo.Departamentos d
        JOIN RRHH_OLTP.dbo.Oficinas  o ON d.OficinaID  = o.OficinaID
        JOIN RRHH_OLTP.dbo.Ciudades  c ON o.CiudadID   = c.CiudadID
        JOIN RRHH_OLTP.dbo.Paises    p ON c.PaisID     = p.PaisID
    )
    -- 1) Cerrar versiones antiguas (registros que cambiaron)
    , Cambios AS (
        SELECT dim.DepartamentoKey
        FROM Dim_Departamento dim
        JOIN Fuente f ON dim.DepartamentoID = f.DepartamentoID AND dim.EsActual = 1
        WHERE dim.NombreDepartamento <> f.NombreDepartamento
           OR ISNULL(dim.Presupuesto,0) <> ISNULL(f.Presupuesto,0)
           OR dim.NombreOficina <> f.NombreOficina
    )
    UPDATE Dim_Departamento
    SET FechaFinVigencia = CAST(GETDATE() AS DATE), EsActual = 0
    FROM Dim_Departamento dim
    JOIN Cambios c ON dim.DepartamentoKey = c.DepartamentoKey;
    SET @Upd = @@ROWCOUNT;

    -- 2) Insertar nuevos registros (nuevos IDs o versiones nuevas)
    INSERT INTO Dim_Departamento (DepartamentoID,NombreDepartamento,Presupuesto,
        NombreOficina,NombreCiudad,NombrePais,FechaInicioVigencia,EsActual,Version)
    SELECT f.DepartamentoID, f.NombreDepartamento, f.Presupuesto,
           f.NombreOficina, f.NombreCiudad, f.NombrePais,
           CAST(GETDATE() AS DATE), 1,
           ISNULL((SELECT MAX(Version) FROM Dim_Departamento WHERE DepartamentoID = f.DepartamentoID),0) + 1
    FROM (
        SELECT d.DepartamentoID, d.NombreDepartamento, d.Presupuesto,
               o.NombreOficina, c.NombreCiudad, p.NombrePais
        FROM RRHH_OLTP.dbo.Departamentos d
        JOIN RRHH_OLTP.dbo.Oficinas  o ON d.OficinaID = o.OficinaID
        JOIN RRHH_OLTP.dbo.Ciudades  c ON o.CiudadID  = c.CiudadID
        JOIN RRHH_OLTP.dbo.Paises    p ON c.PaisID    = p.PaisID
    ) f
    WHERE NOT EXISTS (
        SELECT 1 FROM Dim_Departamento dim
        WHERE dim.DepartamentoID = f.DepartamentoID AND dim.EsActual = 1
    );
    SET @Ins = @@ROWCOUNT;

    UPDATE ETL_Control.Log_ETL
    SET FechaFin=GETDATE(),Estado='Exitoso',RegistrosCargados=@Ins+@Upd,
        Mensaje='Ins:'+CAST(@Ins AS VARCHAR)+' Upd:'+CAST(@Upd AS VARCHAR)
    WHERE LogID=@LogID;
    PRINT 'Dim_Departamento: ' + CAST(@Ins AS VARCHAR) + ' insertados, ' + CAST(@Upd AS VARCHAR) + ' actualizados.';
END;
GO

-- ============================================================
-- PROCEDURE 2: Cargar Dim_Cargo (SCD Tipo 2)
-- ============================================================
CREATE OR ALTER PROCEDURE ETL_Control.sp_ETL_Dim_Cargo
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @LogID INT, @Ins INT = 0, @Upd INT = 0;
    INSERT INTO ETL_Control.Log_ETL (NombreProceso,FechaInicio,Estado)
    VALUES ('sp_ETL_Dim_Cargo',GETDATE(),'Ejecutando');
    SET @LogID = SCOPE_IDENTITY();

    -- Cerrar versiones que cambiaron
    UPDATE Dim_Cargo SET FechaFinVigencia=CAST(GETDATE() AS DATE), EsActual=0
    FROM Dim_Cargo dim
    JOIN RRHH_OLTP.dbo.Cargos src ON dim.CargoID = src.CargoID AND dim.EsActual = 1
    WHERE dim.NombreCargo  <> src.NombreCargo
       OR dim.Nivel        <> src.Nivel
       OR ISNULL(dim.SalarioMin,0) <> ISNULL(src.SalarioMin,0)
       OR ISNULL(dim.SalarioMax,0) <> ISNULL(src.SalarioMax,0);
    SET @Upd = @@ROWCOUNT;

    -- Insertar nuevos
    INSERT INTO Dim_Cargo (CargoID,NombreCargo,Nivel,SalarioMin,SalarioMax,
        FechaInicioVigencia,EsActual,Version)
    SELECT src.CargoID, src.NombreCargo, src.Nivel, src.SalarioMin, src.SalarioMax,
           CAST(GETDATE() AS DATE), 1,
           ISNULL((SELECT MAX(Version) FROM Dim_Cargo WHERE CargoID = src.CargoID),0)+1
    FROM RRHH_OLTP.dbo.Cargos src
    WHERE NOT EXISTS (
        SELECT 1 FROM Dim_Cargo dim WHERE dim.CargoID=src.CargoID AND dim.EsActual=1);
    SET @Ins = @@ROWCOUNT;

    UPDATE ETL_Control.Log_ETL
    SET FechaFin=GETDATE(),Estado='Exitoso',RegistrosCargados=@Ins+@Upd,
        Mensaje='Ins:'+CAST(@Ins AS VARCHAR)+' Upd:'+CAST(@Upd AS VARCHAR)
    WHERE LogID=@LogID;
    PRINT 'Dim_Cargo: ' + CAST(@Ins AS VARCHAR) + ' insertados, ' + CAST(@Upd AS VARCHAR) + ' actualizados.';
END;
GO

-- ============================================================
-- PROCEDURE 3: Cargar Dim_TipoAusencia (SCD Tipo 2)
-- ============================================================
CREATE OR ALTER PROCEDURE ETL_Control.sp_ETL_Dim_TipoAusencia
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @LogID INT, @Ins INT = 0, @Upd INT = 0;
    INSERT INTO ETL_Control.Log_ETL (NombreProceso,FechaInicio,Estado)
    VALUES ('sp_ETL_Dim_TipoAusencia',GETDATE(),'Ejecutando');
    SET @LogID = SCOPE_IDENTITY();

    UPDATE Dim_TipoAusencia SET FechaFinVigencia=CAST(GETDATE() AS DATE), EsActual=0
    FROM Dim_TipoAusencia dim
    JOIN RRHH_OLTP.dbo.TiposAusencia src ON dim.TipoAusenciaID=src.TipoAusenciaID AND dim.EsActual=1
    WHERE dim.Remunerada<>src.Remunerada OR dim.RequiereAprobacion<>src.RequiereAprobacion;
    SET @Upd = @@ROWCOUNT;

    INSERT INTO Dim_TipoAusencia (TipoAusenciaID,NombreTipo,Remunerada,RequiereAprobacion,
        FechaInicioVigencia,EsActual,Version)
    SELECT src.TipoAusenciaID,src.NombreTipo,src.Remunerada,src.RequiereAprobacion,
           CAST(GETDATE() AS DATE), 1,
           ISNULL((SELECT MAX(Version) FROM Dim_TipoAusencia WHERE TipoAusenciaID=src.TipoAusenciaID),0)+1
    FROM RRHH_OLTP.dbo.TiposAusencia src
    WHERE NOT EXISTS (
        SELECT 1 FROM Dim_TipoAusencia dim WHERE dim.TipoAusenciaID=src.TipoAusenciaID AND dim.EsActual=1);
    SET @Ins = @@ROWCOUNT;

    UPDATE ETL_Control.Log_ETL
    SET FechaFin=GETDATE(),Estado='Exitoso',RegistrosCargados=@Ins+@Upd,
        Mensaje='Ins:'+CAST(@Ins AS VARCHAR)+' Upd:'+CAST(@Upd AS VARCHAR)
    WHERE LogID=@LogID;
    PRINT 'Dim_TipoAusencia: ' + CAST(@Ins AS VARCHAR) + ' insertados.';
END;
GO

-- ============================================================
-- PROCEDURE 4: Cargar Dim_Curso (SCD Tipo 2)
-- ============================================================
CREATE OR ALTER PROCEDURE ETL_Control.sp_ETL_Dim_Curso
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @LogID INT, @Ins INT = 0, @Upd INT = 0;
    INSERT INTO ETL_Control.Log_ETL (NombreProceso,FechaInicio,Estado)
    VALUES ('sp_ETL_Dim_Curso',GETDATE(),'Ejecutando');
    SET @LogID = SCOPE_IDENTITY();

    UPDATE Dim_Curso SET FechaFinVigencia=CAST(GETDATE() AS DATE), EsActual=0
    FROM Dim_Curso dim
    JOIN RRHH_OLTP.dbo.Cursos      c ON dim.CursoID=c.CursoID AND dim.EsActual=1
    JOIN RRHH_OLTP.dbo.AreasCurso  a ON c.AreaCursoID=a.AreaCursoID
    WHERE dim.NombreCurso<>c.NombreCurso
       OR dim.DuracionHoras<>c.DuracionHoras
       OR ISNULL(dim.Costo,0)<>ISNULL(c.Costo,0);
    SET @Upd = @@ROWCOUNT;

    INSERT INTO Dim_Curso (CursoID,NombreCurso,NombreArea,Modalidad,DuracionHoras,Costo,Proveedor,
        FechaInicioVigencia,EsActual,Version)
    SELECT c.CursoID,c.NombreCurso,a.NombreArea,c.Modalidad,c.DuracionHoras,c.Costo,c.Proveedor,
           CAST(GETDATE() AS DATE),1,
           ISNULL((SELECT MAX(Version) FROM Dim_Curso WHERE CursoID=c.CursoID),0)+1
    FROM RRHH_OLTP.dbo.Cursos c
    JOIN RRHH_OLTP.dbo.AreasCurso a ON c.AreaCursoID=a.AreaCursoID
    WHERE NOT EXISTS (SELECT 1 FROM Dim_Curso dim WHERE dim.CursoID=c.CursoID AND dim.EsActual=1);
    SET @Ins = @@ROWCOUNT;

    UPDATE ETL_Control.Log_ETL
    SET FechaFin=GETDATE(),Estado='Exitoso',RegistrosCargados=@Ins+@Upd,
        Mensaje='Ins:'+CAST(@Ins AS VARCHAR)+' Upd:'+CAST(@Upd AS VARCHAR)
    WHERE LogID=@LogID;
    PRINT 'Dim_Curso: ' + CAST(@Ins AS VARCHAR) + ' insertados.';
END;
GO

-- ============================================================
-- PROCEDURE 5: Cargar Dim_Empleado (SCD Tipo 2)
-- ============================================================
CREATE OR ALTER PROCEDURE ETL_Control.sp_ETL_Dim_Empleado
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @LogID INT, @Ins INT = 0, @Upd INT = 0;
    INSERT INTO ETL_Control.Log_ETL (NombreProceso,FechaInicio,Estado)
    VALUES ('sp_ETL_Dim_Empleado',GETDATE(),'Ejecutando');
    SET @LogID = SCOPE_IDENTITY();

    -- Cerrar versiones si cambió cargo, depto, salario o modalidad
    UPDATE Dim_Empleado SET FechaFinVigencia=CAST(GETDATE() AS DATE), EsActual=0
    FROM Dim_Empleado dim
    JOIN RRHH_OLTP.dbo.Empleados src ON dim.EmpleadoID=src.EmpleadoID AND dim.EsActual=1
    WHERE dim.Salario     <> src.Salario
       OR dim.TipoContrato<> src.TipoContrato
       OR dim.Modalidad   <> src.Modalidad;
    SET @Upd = @@ROWCOUNT;

    -- Insertar nuevos
    INSERT INTO Dim_Empleado (EmpleadoID,Cedula,Nombres,Apellidos,FechaNacimiento,
        Genero,Email,Salario,TipoContrato,Modalidad,FechaIngreso,
        FechaInicioVigencia,EsActual,Version)
    SELECT src.EmpleadoID,src.Cedula,src.Nombres,src.Apellidos,src.FechaNacimiento,
           src.Genero,src.Email,src.Salario,src.TipoContrato,src.Modalidad,src.FechaIngreso,
           CAST(GETDATE() AS DATE),1,
           ISNULL((SELECT MAX(Version) FROM Dim_Empleado WHERE EmpleadoID=src.EmpleadoID),0)+1
    FROM RRHH_OLTP.dbo.Empleados src
    WHERE NOT EXISTS (SELECT 1 FROM Dim_Empleado dim WHERE dim.EmpleadoID=src.EmpleadoID AND dim.EsActual=1);
    SET @Ins = @@ROWCOUNT;

    UPDATE ETL_Control.Log_ETL
    SET FechaFin=GETDATE(),Estado='Exitoso',RegistrosCargados=@Ins+@Upd,
        Mensaje='Ins:'+CAST(@Ins AS VARCHAR)+' Upd:'+CAST(@Upd AS VARCHAR)
    WHERE LogID=@LogID;
    PRINT 'Dim_Empleado: ' + CAST(@Ins AS VARCHAR) + ' insertados, ' + CAST(@Upd AS VARCHAR) + ' actualizados.';
END;
GO

-- ============================================================
-- EJECUCIÓN DE TODOS LOS ETL DE DIMENSIONES
-- ============================================================
EXEC ETL_Control.sp_ETL_Dim_Departamento;
EXEC ETL_Control.sp_ETL_Dim_Cargo;
EXEC ETL_Control.sp_ETL_Dim_TipoAusencia;
EXEC ETL_Control.sp_ETL_Dim_Curso;
EXEC ETL_Control.sp_ETL_Dim_Empleado;
GO

PRINT 'Todas las dimensiones cargadas exitosamente.';
GO
