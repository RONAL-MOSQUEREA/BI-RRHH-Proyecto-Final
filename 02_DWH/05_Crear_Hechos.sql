-- ============================================================
-- 05_Crear_Hechos.sql
-- Implementación de 4 Tablas de Hechos
-- Sistema BI - Proyecto Integrador Final
-- ============================================================

USE RRHH_DWH;
GO

-- ============================================================
-- HECHO 1: Fact_Ausencias
-- Granularidad: 1 fila por ausencia registrada
-- ============================================================
CREATE TABLE Fact_Ausencias (
    AusenciaKey          INT IDENTITY(1,1) PRIMARY KEY,
    -- Claves foráneas a dimensiones
    TiempoKeyInicio      INT NOT NULL REFERENCES Dim_Tiempo(TiempoKey),
    TiempoKeyFin         INT NOT NULL REFERENCES Dim_Tiempo(TiempoKey),
    EmpleadoKey          INT NOT NULL REFERENCES Dim_Empleado(EmpleadoKey),
    DepartamentoKey      INT NOT NULL REFERENCES Dim_Departamento(DepartamentoKey),
    CargoKey             INT NOT NULL REFERENCES Dim_Cargo(CargoKey),
    TipoAusenciaKey      INT NOT NULL REFERENCES Dim_TipoAusencia(TipoAusenciaKey),
    -- Clave natural para trazabilidad
    AusenciaID_OLTP      INT NOT NULL,
    -- Medidas (hechos numéricos)
    DiasAusencia         INT NOT NULL,
    CostoAusencia        DECIMAL(18,2) NOT NULL DEFAULT 0, -- Días * (Salario/30)
    EsRemunerada         BIT NOT NULL DEFAULT 1,
    -- Degenerate dimension
    EstadoAusencia       VARCHAR(20) NOT NULL
);

-- ============================================================
-- HECHO 2: Fact_Evaluaciones
-- Granularidad: 1 fila por evaluación de desempeño
-- ============================================================
CREATE TABLE Fact_Evaluaciones (
    EvaluacionKey        INT IDENTITY(1,1) PRIMARY KEY,
    -- Claves foráneas
    TiempoKey            INT NOT NULL REFERENCES Dim_Tiempo(TiempoKey),
    EmpleadoKey          INT NOT NULL REFERENCES Dim_Empleado(EmpleadoKey),
    EvaluadorKey         INT NOT NULL REFERENCES Dim_Empleado(EmpleadoKey),
    DepartamentoKey      INT NOT NULL REFERENCES Dim_Departamento(DepartamentoKey),
    CargoKey             INT NOT NULL REFERENCES Dim_Cargo(CargoKey),
    -- Clave natural
    EvaluacionID_OLTP    INT NOT NULL,
    -- Medidas
    CalificacionTotal    DECIMAL(5,2) NOT NULL,
    NotaCalidad          DECIMAL(5,2),
    NotaProductividad    DECIMAL(5,2),
    NotaCompetencias     DECIMAL(5,2),
    NotaLiderazgo        DECIMAL(5,2),
    -- Degenerate dimensions
    NivelDesempeno       VARCHAR(30) NOT NULL,
    Anio                 INT NOT NULL,
    Semestre             INT NOT NULL
);

-- ============================================================
-- HECHO 3: Fact_Capacitaciones
-- Granularidad: 1 fila por participación de empleado en curso
-- ============================================================
CREATE TABLE Fact_Capacitaciones (
    CapacitacionKey      INT IDENTITY(1,1) PRIMARY KEY,
    -- Claves foráneas
    TiempoKeyInicio      INT NOT NULL REFERENCES Dim_Tiempo(TiempoKey),
    TiempoKeyFin         INT NOT NULL REFERENCES Dim_Tiempo(TiempoKey),
    EmpleadoKey          INT NOT NULL REFERENCES Dim_Empleado(EmpleadoKey),
    DepartamentoKey      INT NOT NULL REFERENCES Dim_Departamento(DepartamentoKey),
    CursoKey             INT NOT NULL REFERENCES Dim_Curso(CursoKey),
    -- Clave natural
    CapacitacionID_OLTP  INT NOT NULL,
    -- Medidas
    DuracionHoras        INT NOT NULL,
    CostoCurso           DECIMAL(18,2) NOT NULL DEFAULT 0,
    Calificacion         DECIMAL(5,2) NULL,
    Certificado          BIT NOT NULL DEFAULT 0,
    -- Degenerate dimension
    EstadoCurso          VARCHAR(30) NOT NULL
);

-- ============================================================
-- HECHO 4: Fact_PlantillaEmpleados (Snapshot mensual)
-- Granularidad: 1 fila por empleado activo por mes
-- Permite análisis de tendencias de headcount
-- ============================================================
CREATE TABLE Fact_PlantillaEmpleados (
    PlantillaKey         INT IDENTITY(1,1) PRIMARY KEY,
    -- Claves foráneas
    TiempoKey            INT NOT NULL REFERENCES Dim_Tiempo(TiempoKey),
    EmpleadoKey          INT NOT NULL REFERENCES Dim_Empleado(EmpleadoKey),
    DepartamentoKey      INT NOT NULL REFERENCES Dim_Departamento(DepartamentoKey),
    CargoKey             INT NOT NULL REFERENCES Dim_Cargo(CargoKey),
    -- Medidas
    Salario              DECIMAL(18,2) NOT NULL,
    AniosAntiguedad      DECIMAL(5,2)  NOT NULL,
    -- Degenerate dimensions
    EstadoEmpleado       VARCHAR(20)   NOT NULL,
    TipoContrato         VARCHAR(50)   NOT NULL,
    Modalidad            VARCHAR(30)   NOT NULL,
    -- Indicadores binarios (útiles para conteo)
    EsActivo             BIT           NOT NULL DEFAULT 1,
    EsNuevoIngreso       BIT           NOT NULL DEFAULT 0, -- Ingresó ese mes
    EsRetiro             BIT           NOT NULL DEFAULT 0  -- Se retiró ese mes
);

-- ============================================================
-- ÍNDICES para optimizar consultas analíticas
-- ============================================================
CREATE INDEX IX_FactAus_Tiempo   ON Fact_Ausencias(TiempoKeyInicio);
CREATE INDEX IX_FactAus_Emp      ON Fact_Ausencias(EmpleadoKey);
CREATE INDEX IX_FactAus_Depto    ON Fact_Ausencias(DepartamentoKey);

CREATE INDEX IX_FactEval_Tiempo  ON Fact_Evaluaciones(TiempoKey);
CREATE INDEX IX_FactEval_Emp     ON Fact_Evaluaciones(EmpleadoKey);
CREATE INDEX IX_FactEval_Depto   ON Fact_Evaluaciones(DepartamentoKey);

CREATE INDEX IX_FactCap_Tiempo   ON Fact_Capacitaciones(TiempoKeyInicio);
CREATE INDEX IX_FactCap_Emp      ON Fact_Capacitaciones(EmpleadoKey);

CREATE INDEX IX_FactPla_Tiempo   ON Fact_PlantillaEmpleados(TiempoKey);
CREATE INDEX IX_FactPla_Depto    ON Fact_PlantillaEmpleados(DepartamentoKey);

PRINT '4 tablas de hechos creadas exitosamente con índices.';
GO
