-- ============================================================
-- 01_Crear_RRHH_OLTP.sql
-- Creación de la Base de Datos Operacional de Recursos Humanos
-- Sistema BI - Proyecto Integrador Final
-- ============================================================

USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'RRHH_OLTP')
BEGIN
    ALTER DATABASE RRHH_OLTP SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RRHH_OLTP;
END
GO

CREATE DATABASE RRHH_OLTP;
GO

USE RRHH_OLTP;
GO

-- ============================================================
-- TABLA: Paises
-- ============================================================
CREATE TABLE Paises (
    PaisID       INT IDENTITY(1,1) PRIMARY KEY,
    NombrePais   VARCHAR(100) NOT NULL,
    CodigoISO    CHAR(3) NOT NULL,
    Region       VARCHAR(100)
);

-- ============================================================
-- TABLA: Ciudades
-- ============================================================
CREATE TABLE Ciudades (
    CiudadID     INT IDENTITY(1,1) PRIMARY KEY,
    NombreCiudad VARCHAR(100) NOT NULL,
    PaisID       INT NOT NULL,
    FOREIGN KEY (PaisID) REFERENCES Paises(PaisID)
);

-- ============================================================
-- TABLA: Oficinas
-- ============================================================
CREATE TABLE Oficinas (
    OficinaID    INT IDENTITY(1,1) PRIMARY KEY,
    NombreOficina VARCHAR(150) NOT NULL,
    Direccion    VARCHAR(250),
    CiudadID     INT NOT NULL,
    Telefono     VARCHAR(20),
    Email        VARCHAR(100),
    Activa       BIT NOT NULL DEFAULT 1,
    FOREIGN KEY (CiudadID) REFERENCES Ciudades(CiudadID)
);

-- ============================================================
-- TABLA: Departamentos
-- ============================================================
CREATE TABLE Departamentos (
    DepartamentoID   INT IDENTITY(1,1) PRIMARY KEY,
    NombreDepartamento VARCHAR(150) NOT NULL,
    OficinaID        INT NOT NULL,
    Presupuesto      DECIMAL(18,2),
    Activo           BIT NOT NULL DEFAULT 1,
    FOREIGN KEY (OficinaID) REFERENCES Oficinas(OficinaID)
);

-- ============================================================
-- TABLA: Cargos
-- ============================================================
CREATE TABLE Cargos (
    CargoID      INT IDENTITY(1,1) PRIMARY KEY,
    NombreCargo  VARCHAR(150) NOT NULL,
    Nivel        VARCHAR(50),   -- Operativo, Táctico, Estratégico
    SalarioMin   DECIMAL(18,2),
    SalarioMax   DECIMAL(18,2)
);

-- ============================================================
-- TABLA: Empleados
-- ============================================================
CREATE TABLE Empleados (
    EmpleadoID       INT IDENTITY(1,1) PRIMARY KEY,
    Cedula           VARCHAR(20) NOT NULL UNIQUE,
    Nombres          VARCHAR(100) NOT NULL,
    Apellidos        VARCHAR(100) NOT NULL,
    FechaNacimiento  DATE NOT NULL,
    Genero           CHAR(1) NOT NULL CHECK (Genero IN ('M','F','O')),
    Email            VARCHAR(150) NOT NULL UNIQUE,
    Telefono         VARCHAR(20),
    FechaIngreso     DATE NOT NULL,
    FechaSalida      DATE NULL,
    EstadoEmpleado   VARCHAR(20) NOT NULL DEFAULT 'Activo'
                         CHECK (EstadoEmpleado IN ('Activo','Inactivo','Licencia','Retirado')),
    DepartamentoID   INT NOT NULL,
    CargoID          INT NOT NULL,
    JefeID           INT NULL,         -- Auto-referencia: jefe directo
    Salario          DECIMAL(18,2) NOT NULL,
    TipoContrato     VARCHAR(50) NOT NULL
                         CHECK (TipoContrato IN ('Indefinido','Fijo','Temporal','Pasantia')),
    Modalidad        VARCHAR(30) NOT NULL DEFAULT 'Presencial'
                         CHECK (Modalidad IN ('Presencial','Remoto','Hibrido')),
    FOREIGN KEY (DepartamentoID) REFERENCES Departamentos(DepartamentoID),
    FOREIGN KEY (CargoID) REFERENCES Cargos(CargoID),
    FOREIGN KEY (JefeID) REFERENCES Empleados(EmpleadoID)
);

-- ============================================================
-- TABLA: TiposAusencia
-- ============================================================
CREATE TABLE TiposAusencia (
    TipoAusenciaID   INT IDENTITY(1,1) PRIMARY KEY,
    NombreTipo       VARCHAR(100) NOT NULL,
    Remunerada       BIT NOT NULL DEFAULT 1,
    RequiereAprobacion BIT NOT NULL DEFAULT 1
);

-- ============================================================
-- TABLA: Ausencias
-- ============================================================
CREATE TABLE Ausencias (
    AusenciaID       INT IDENTITY(1,1) PRIMARY KEY,
    EmpleadoID       INT NOT NULL,
    TipoAusenciaID   INT NOT NULL,
    FechaInicio      DATE NOT NULL,
    FechaFin         DATE NOT NULL,
    DiasAusencia     AS DATEDIFF(DAY, FechaInicio, FechaFin) + 1 PERSISTED,
    Motivo           VARCHAR(500),
    Estado           VARCHAR(20) NOT NULL DEFAULT 'Aprobada'
                         CHECK (Estado IN ('Pendiente','Aprobada','Rechazada','Cancelada')),
    AprobadoPor      INT NULL,
    FOREIGN KEY (EmpleadoID) REFERENCES Empleados(EmpleadoID),
    FOREIGN KEY (TipoAusenciaID) REFERENCES TiposAusencia(TipoAusenciaID),
    FOREIGN KEY (AprobadoPor) REFERENCES Empleados(EmpleadoID)
);

-- ============================================================
-- TABLA: PeriodosEvaluacion
-- ============================================================
CREATE TABLE PeriodosEvaluacion (
    PeriodoEvalID    INT IDENTITY(1,1) PRIMARY KEY,
    NombrePeriodo    VARCHAR(100) NOT NULL,
    FechaInicio      DATE NOT NULL,
    FechaFin         DATE NOT NULL,
    Anio             INT NOT NULL,
    Semestre         INT NOT NULL CHECK (Semestre IN (1,2))
);

-- ============================================================
-- TABLA: Evaluaciones de Desempeño
-- ============================================================
CREATE TABLE EvaluacionesDesempeno (
    EvaluacionID     INT IDENTITY(1,1) PRIMARY KEY,
    EmpleadoID       INT NOT NULL,
    EvaluadorID      INT NOT NULL,
    PeriodoEvalID    INT NOT NULL,
    FechaEvaluacion  DATE NOT NULL,
    CalificacionTotal DECIMAL(5,2) NOT NULL CHECK (CalificacionTotal BETWEEN 0 AND 100),
    NotaCalidad      DECIMAL(5,2) CHECK (NotaCalidad BETWEEN 0 AND 100),
    NotaProductividad DECIMAL(5,2) CHECK (NotaProductividad BETWEEN 0 AND 100),
    NotaCompetencias DECIMAL(5,2) CHECK (NotaCompetencias BETWEEN 0 AND 100),
    NotaLiderazgo    DECIMAL(5,2) CHECK (NotaLiderazgo BETWEEN 0 AND 100),
    NivelDesempeno   VARCHAR(20)
                         CHECK (NivelDesempeno IN ('Sobresaliente','Bueno','Satisfactorio','Mejorable','Insuficiente')),
    Comentarios      VARCHAR(1000),
    FOREIGN KEY (EmpleadoID) REFERENCES Empleados(EmpleadoID),
    FOREIGN KEY (EvaluadorID) REFERENCES Empleados(EmpleadoID),
    FOREIGN KEY (PeriodoEvalID) REFERENCES PeriodosEvaluacion(PeriodoEvalID)
);

-- ============================================================
-- TABLA: AreasCurso (Categorías de capacitación)
-- ============================================================
CREATE TABLE AreasCurso (
    AreaCursoID  INT IDENTITY(1,1) PRIMARY KEY,
    NombreArea   VARCHAR(100) NOT NULL,
    Descripcion  VARCHAR(500)
);

-- ============================================================
-- TABLA: Cursos
-- ============================================================
CREATE TABLE Cursos (
    CursoID      INT IDENTITY(1,1) PRIMARY KEY,
    NombreCurso  VARCHAR(200) NOT NULL,
    AreaCursoID  INT NOT NULL,
    Modalidad    VARCHAR(30) NOT NULL CHECK (Modalidad IN ('Presencial','Virtual','Hibrido')),
    DuracionHoras INT NOT NULL,
    Costo        DECIMAL(18,2),
    Proveedor    VARCHAR(200),
    FOREIGN KEY (AreaCursoID) REFERENCES AreasCurso(AreaCursoID)
);

-- ============================================================
-- TABLA: Capacitaciones (Registro participación)
-- ============================================================
CREATE TABLE Capacitaciones (
    CapacitacionID   INT IDENTITY(1,1) PRIMARY KEY,
    EmpleadoID       INT NOT NULL,
    CursoID          INT NOT NULL,
    FechaInicio      DATE NOT NULL,
    FechaFin         DATE NOT NULL,
    Estado           VARCHAR(20) NOT NULL DEFAULT 'Completado'
                         CHECK (Estado IN ('Inscrito','En Progreso','Completado','Abandonado','Reprobado')),
    Calificacion     DECIMAL(5,2) NULL CHECK (Calificacion BETWEEN 0 AND 100),
    Certificado      BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (EmpleadoID) REFERENCES Empleados(EmpleadoID),
    FOREIGN KEY (CursoID) REFERENCES Cursos(CursoID)
);

-- ============================================================
-- TABLA: HistorialSalarios
-- ============================================================
CREATE TABLE HistorialSalarios (
    HistSalarioID    INT IDENTITY(1,1) PRIMARY KEY,
    EmpleadoID       INT NOT NULL,
    SalarioAnterior  DECIMAL(18,2) NOT NULL,
    SalarioNuevo     DECIMAL(18,2) NOT NULL,
    FechaCambio      DATE NOT NULL,
    Motivo           VARCHAR(300),
    AprobadoPor      INT NULL,
    FOREIGN KEY (EmpleadoID) REFERENCES Empleados(EmpleadoID),
    FOREIGN KEY (AprobadoPor) REFERENCES Empleados(EmpleadoID)
);

PRINT 'BD RRHH_OLTP creada exitosamente con todas las tablas.';
GO
