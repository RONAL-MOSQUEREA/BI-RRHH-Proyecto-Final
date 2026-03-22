-- ============================================================
-- 03_Crear_RRHH_DWH.sql
-- Creación del Data Warehouse RRHH_DWH con tablas de control
-- Sistema BI - Proyecto Integrador Final
-- ============================================================

USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'RRHH_DWH')
BEGIN
    ALTER DATABASE RRHH_DWH SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RRHH_DWH;
END
GO

CREATE DATABASE RRHH_DWH;
GO

USE RRHH_DWH;
GO

-- ============================================================
-- ESQUEMA SEPARADO PARA CONTROL ETL
-- ============================================================
CREATE SCHEMA ETL_Control;
GO

-- ============================================================
-- TABLA DE CONTROL: Log de ejecuciones ETL
-- ============================================================
CREATE TABLE ETL_Control.Log_ETL (
    LogID            INT IDENTITY(1,1) PRIMARY KEY,
    NombreProceso    VARCHAR(200) NOT NULL,
    FechaInicio      DATETIME NOT NULL DEFAULT GETDATE(),
    FechaFin         DATETIME NULL,
    Estado           VARCHAR(20) NOT NULL DEFAULT 'Ejecutando'
                         CHECK (Estado IN ('Ejecutando','Exitoso','Error','Advertencia')),
    RegistrosCargados INT NULL,
    RegistrosErrores  INT NULL,
    Mensaje          VARCHAR(2000) NULL
);

-- ============================================================
-- TABLA DE CONTROL: Marcas de agua (Watermarks) para ETL incremental
-- ============================================================
CREATE TABLE ETL_Control.WaterMark (
    TablaOrigen      VARCHAR(200) PRIMARY KEY,
    UltimaEjecucion  DATETIME NOT NULL DEFAULT '1900-01-01',
    ColumnaMarca     VARCHAR(100) NOT NULL DEFAULT 'FechaModificacion'
);

-- Inicializar marcas de agua para las tablas OLTP
INSERT INTO ETL_Control.WaterMark (TablaOrigen, UltimaEjecucion, ColumnaMarca) VALUES
('RRHH_OLTP.dbo.Empleados',              '1900-01-01', 'FechaIngreso'),
('RRHH_OLTP.dbo.Ausencias',              '1900-01-01', 'FechaInicio'),
('RRHH_OLTP.dbo.EvaluacionesDesempeno',  '1900-01-01', 'FechaEvaluacion'),
('RRHH_OLTP.dbo.Capacitaciones',         '1900-01-01', 'FechaInicio'),
('RRHH_OLTP.dbo.Departamentos',          '1900-01-01', 'DepartamentoID'),
('RRHH_OLTP.dbo.Cargos',                 '1900-01-01', 'CargoID');

-- ============================================================
-- TABLA DE CONTROL: Errores de validación
-- ============================================================
CREATE TABLE ETL_Control.Errores_Validacion (
    ErrorID          INT IDENTITY(1,1) PRIMARY KEY,
    FechaDeteccion   DATETIME NOT NULL DEFAULT GETDATE(),
    TipoValidacion   VARCHAR(100) NOT NULL,
    TablaAfectada    VARCHAR(200) NOT NULL,
    Descripcion      VARCHAR(2000) NOT NULL,
    Severidad        VARCHAR(20) NOT NULL CHECK (Severidad IN ('Critico','Alto','Medio','Bajo')),
    Resuelto         BIT NOT NULL DEFAULT 0
);

PRINT 'BD RRHH_DWH creada exitosamente con tablas de control ETL.';
GO
