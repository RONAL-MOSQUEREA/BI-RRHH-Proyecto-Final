-- ============================================================
-- 04_Crear_Dimensiones.sql
-- Implementación de 5 Dimensiones con SCD Tipo 2
-- Sistema BI - Proyecto Integrador Final
-- ============================================================

USE RRHH_DWH;
GO

-- ============================================================
-- DIM 1: Dim_Tiempo
-- Dimensión de Tiempo (sin SCD - es estática)
-- ============================================================
CREATE TABLE Dim_Tiempo (
    TiempoKey        INT          NOT NULL PRIMARY KEY,  -- YYYYMMDD
    Fecha            DATE         NOT NULL UNIQUE,
    Anio             INT          NOT NULL,
    Trimestre        INT          NOT NULL,
    NombreTrimestre  VARCHAR(10)  NOT NULL,  -- Q1, Q2, Q3, Q4
    Mes              INT          NOT NULL,
    NombreMes        VARCHAR(20)  NOT NULL,
    NombreMesCorto   CHAR(3)      NOT NULL,
    Semana           INT          NOT NULL,
    DiaSemana        INT          NOT NULL,  -- 1=Lunes … 7=Domingo
    NombreDia        VARCHAR(15)  NOT NULL,
    NombreDiaCorto   CHAR(3)      NOT NULL,
    DiaAnio          INT          NOT NULL,
    EsFeriado        BIT          NOT NULL DEFAULT 0,
    EsFinSemana      BIT          NOT NULL DEFAULT 0,
    EsDiaHabil       BIT          NOT NULL DEFAULT 1,
    Semestre         INT          NOT NULL,
    AnioMes          INT          NOT NULL,  -- YYYYMM
    AnioTrimestre    VARCHAR(10)  NOT NULL   -- 2024-Q1
);

-- ============================================================
-- DIM 2: Dim_Empleado (SCD Tipo 2)
-- Registra historial de cambios en cargo, departamento, salario, modalidad
-- ============================================================
CREATE TABLE Dim_Empleado (
    EmpleadoKey      INT          IDENTITY(1,1) PRIMARY KEY,
    EmpleadoID       INT          NOT NULL,   -- NK: clave natural del OLTP
    Cedula           VARCHAR(20)  NOT NULL,
    Nombres          VARCHAR(100) NOT NULL,
    Apellidos        VARCHAR(100) NOT NULL,
    NombreCompleto   AS (Nombres + ' ' + Apellidos) PERSISTED,
    FechaNacimiento  DATE         NOT NULL,
    Genero           CHAR(1)      NOT NULL,
    Email            VARCHAR(150) NOT NULL,
    Salario          DECIMAL(18,2) NOT NULL,
    TipoContrato     VARCHAR(50)  NOT NULL,
    Modalidad        VARCHAR(30)  NOT NULL,
    FechaIngreso     DATE         NOT NULL,
    -- SCD Tipo 2: columnas de versión
    FechaInicioVigencia DATE      NOT NULL,
    FechaFinVigencia    DATE      NULL,       -- NULL = registro vigente
    EsActual            BIT       NOT NULL DEFAULT 1,
    Version             INT       NOT NULL DEFAULT 1
);

-- ============================================================
-- DIM 3: Dim_Departamento (SCD Tipo 2)
-- Registra historial si un departamento cambia de oficina o presupuesto
-- ============================================================
CREATE TABLE Dim_Departamento (
    DepartamentoKey     INT         IDENTITY(1,1) PRIMARY KEY,
    DepartamentoID      INT         NOT NULL,  -- NK
    NombreDepartamento  VARCHAR(150) NOT NULL,
    Presupuesto         DECIMAL(18,2),
    NombreOficina       VARCHAR(150) NOT NULL,
    NombreCiudad        VARCHAR(100) NOT NULL,
    NombrePais          VARCHAR(100) NOT NULL,
    -- SCD Tipo 2
    FechaInicioVigencia DATE        NOT NULL,
    FechaFinVigencia    DATE        NULL,
    EsActual            BIT         NOT NULL DEFAULT 1,
    Version             INT         NOT NULL DEFAULT 1
);

-- ============================================================
-- DIM 4: Dim_Cargo (SCD Tipo 2)
-- Registra historial si el rango salarial de un cargo cambia
-- ============================================================
CREATE TABLE Dim_Cargo (
    CargoKey         INT         IDENTITY(1,1) PRIMARY KEY,
    CargoID          INT         NOT NULL,  -- NK
    NombreCargo      VARCHAR(150) NOT NULL,
    Nivel            VARCHAR(50) NOT NULL,
    SalarioMin       DECIMAL(18,2),
    SalarioMax       DECIMAL(18,2),
    -- SCD Tipo 2
    FechaInicioVigencia DATE     NOT NULL,
    FechaFinVigencia    DATE     NULL,
    EsActual            BIT      NOT NULL DEFAULT 1,
    Version             INT      NOT NULL DEFAULT 1
);

-- ============================================================
-- DIM 5: Dim_TipoAusencia (SCD Tipo 2)
-- Registra si la política de una ausencia cambia (remunerada/no)
-- ============================================================
CREATE TABLE Dim_TipoAusencia (
    TipoAusenciaKey     INT         IDENTITY(1,1) PRIMARY KEY,
    TipoAusenciaID      INT         NOT NULL,  -- NK
    NombreTipo          VARCHAR(100) NOT NULL,
    Remunerada          BIT         NOT NULL,
    RequiereAprobacion  BIT         NOT NULL,
    -- SCD Tipo 2
    FechaInicioVigencia DATE        NOT NULL,
    FechaFinVigencia    DATE        NULL,
    EsActual            BIT         NOT NULL DEFAULT 1,
    Version             INT         NOT NULL DEFAULT 1
);

-- ============================================================
-- DIM 6 (Bonus): Dim_Curso (SCD Tipo 2)
-- Registra cambios en costo u horas de los cursos
-- ============================================================
CREATE TABLE Dim_Curso (
    CursoKey         INT         IDENTITY(1,1) PRIMARY KEY,
    CursoID          INT         NOT NULL,  -- NK
    NombreCurso      VARCHAR(200) NOT NULL,
    NombreArea       VARCHAR(100) NOT NULL,
    Modalidad        VARCHAR(30) NOT NULL,
    DuracionHoras    INT         NOT NULL,
    Costo            DECIMAL(18,2),
    Proveedor        VARCHAR(200),
    -- SCD Tipo 2
    FechaInicioVigencia DATE     NOT NULL,
    FechaFinVigencia    DATE     NULL,
    EsActual            BIT      NOT NULL DEFAULT 1,
    Version             INT      NOT NULL DEFAULT 1
);

-- ============================================================
-- REGISTRO ESPECIAL: Fila "Sin Información" para cada dimensión
-- Permite FK válida cuando no hay dato (buena práctica DWH)
-- ============================================================
SET IDENTITY_INSERT Dim_Empleado ON;
INSERT INTO Dim_Empleado (EmpleadoKey,EmpleadoID,Cedula,Nombres,Apellidos,
    FechaNacimiento,Genero,Email,Salario,TipoContrato,Modalidad,FechaIngreso,
    FechaInicioVigencia,EsActual,Version)
VALUES(-1,-1,'N/A','Sin','Información','1900-01-01','O','N/A',0,'N/A','N/A','1900-01-01','1900-01-01',1,1);
SET IDENTITY_INSERT Dim_Empleado OFF;

SET IDENTITY_INSERT Dim_Departamento ON;
INSERT INTO Dim_Departamento (DepartamentoKey,DepartamentoID,NombreDepartamento,
    NombreOficina,NombreCiudad,NombrePais,FechaInicioVigencia,EsActual,Version)
VALUES(-1,-1,'Sin Información','N/A','N/A','N/A','1900-01-01',1,1);
SET IDENTITY_INSERT Dim_Departamento OFF;

SET IDENTITY_INSERT Dim_Cargo ON;
INSERT INTO Dim_Cargo (CargoKey,CargoID,NombreCargo,Nivel,FechaInicioVigencia,EsActual,Version)
VALUES(-1,-1,'Sin Información','N/A','1900-01-01',1,1);
SET IDENTITY_INSERT Dim_Cargo OFF;

SET IDENTITY_INSERT Dim_TipoAusencia ON;
INSERT INTO Dim_TipoAusencia (TipoAusenciaKey,TipoAusenciaID,NombreTipo,
    Remunerada,RequiereAprobacion,FechaInicioVigencia,EsActual,Version)
VALUES(-1,-1,'Sin Información',0,0,'1900-01-01',1,1);
SET IDENTITY_INSERT Dim_TipoAusencia OFF;

SET IDENTITY_INSERT Dim_Curso ON;
INSERT INTO Dim_Curso (CursoKey,CursoID,NombreCurso,NombreArea,Modalidad,
    DuracionHoras,FechaInicioVigencia,EsActual,Version)
VALUES(-1,-1,'Sin Información','N/A','N/A',0,'1900-01-01',1,1);
SET IDENTITY_INSERT Dim_Curso OFF;

PRINT '5 dimensiones creadas exitosamente con SCD Tipo 2.';
GO
