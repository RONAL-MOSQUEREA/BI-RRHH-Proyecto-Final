-- ============================================================
-- 02_Poblar_RRHH_OLTP.sql
-- Inserción de datos transaccionales en la BD RRHH_OLTP
-- Sistema BI - Proyecto Integrador Final
-- ============================================================

USE RRHH_OLTP;
GO

-- ============================================================
-- PAISES Y CIUDADES
-- ============================================================
INSERT INTO Paises (NombrePais, CodigoISO, Region) VALUES
('Colombia','COL','América del Sur'),
('México','MEX','América del Norte'),
('Argentina','ARG','América del Sur'),
('España','ESP','Europa'),
('Estados Unidos','USA','América del Norte');

INSERT INTO Ciudades (NombreCiudad, PaisID) VALUES
('Bogotá', 1), ('Medellín', 1), ('Cali', 1), ('Barranquilla', 1),
('Ciudad de México', 2), ('Guadalajara', 2),
('Buenos Aires', 3), ('Córdoba', 3),
('Madrid', 4), ('Barcelona', 4),
('Nueva York', 5), ('Miami', 5);

-- ============================================================
-- OFICINAS
-- ============================================================
INSERT INTO Oficinas (NombreOficina, Direccion, CiudadID, Telefono, Email) VALUES
('Sede Principal Bogotá',  'Cra 7 # 71-21',       1, '6017001000', 'bogota@empresa.com'),
('Oficina Medellín',       'Calle 10 # 43E-31',    2, '6044502000', 'medellin@empresa.com'),
('Oficina Cali',           'Av. 6N # 23-45',       3, '6023003000', 'cali@empresa.com'),
('Oficina Barranquilla',   'Cra 54 # 72-11',       4, '6055004000', 'barranquilla@empresa.com'),
('Oficina México DF',      'Paseo Reforma 505',    5, '5512345000', 'mexico@empresa.com');

-- ============================================================
-- DEPARTAMENTOS
-- ============================================================
INSERT INTO Departamentos (NombreDepartamento, OficinaID, Presupuesto) VALUES
('Recursos Humanos',         1, 500000000),
('Tecnología e Innovación',  1, 800000000),
('Finanzas y Contabilidad',  1, 600000000),
('Ventas y Marketing',       1, 700000000),
('Operaciones',              2, 450000000),
('Logística',                2, 350000000),
('Servicio al Cliente',      3, 300000000),
('Gestión de Proyectos',     4, 550000000),
('Desarrollo de Software',   5, 900000000),
('Auditoría Interna',        1, 250000000);

-- ============================================================
-- CARGOS
-- ============================================================
INSERT INTO Cargos (NombreCargo, Nivel, SalarioMin, SalarioMax) VALUES
('Gerente General',          'Estratégico', 15000000, 30000000),
('Director de RRHH',         'Estratégico', 8000000,  15000000),
('Director de TI',           'Estratégico', 10000000, 20000000),
('Director Financiero',      'Estratégico', 10000000, 18000000),
('Gerente de Ventas',        'Táctico',     6000000,  12000000),
('Coordinador de RRHH',      'Táctico',     3500000,  6000000),
('Analista de Datos',        'Táctico',     4000000,  7000000),
('Desarrollador Senior',     'Táctico',     5000000,  9000000),
('Desarrollador Junior',     'Operativo',   2500000,  4500000),
('Analista Financiero',      'Táctico',     3800000,  6500000),
('Asesor Comercial',         'Operativo',   2200000,  4000000),
('Técnico de Soporte',       'Operativo',   2000000,  3500000),
('Coordinador de Logística', 'Táctico',     3200000,  5500000),
('Auditor Interno',          'Táctico',     4200000,  7000000),
('Pasante',                  'Operativo',   1000000,  1500000);

-- ============================================================
-- EMPLEADOS
-- ============================================================
INSERT INTO Empleados (Cedula, Nombres, Apellidos, FechaNacimiento, Genero,
    Email, Telefono, FechaIngreso, DepartamentoID, CargoID, JefeID, Salario, TipoContrato, Modalidad) VALUES
('10001','Carlos','Rodríguez Gómez','1975-03-15','M','c.rodriguez@empresa.com','3101001001','2015-01-05',1,1,NULL,25000000,'Indefinido','Presencial'),
('10002','María','González López','1980-07-22','F','m.gonzalez@empresa.com','3102002002','2016-03-01',1,2,1,10000000,'Indefinido','Hibrido'),
('10003','Andrés','Martínez Ruiz','1982-11-10','M','a.martinez@empresa.com','3103003003','2017-05-15',2,3,1,15000000,'Indefinido','Presencial'),
('10004','Laura','Sánchez Torres','1985-04-28','F','l.sanchez@empresa.com','3104004004','2018-01-10',3,4,1,12000000,'Indefinido','Presencial'),
('10005','Jorge','Pérez Castro','1983-09-14','M','j.perez@empresa.com','3105005005','2016-07-20',4,5,1,9000000,'Indefinido','Hibrido'),
('10006','Ana','Díaz Vargas','1990-02-18','F','a.diaz@empresa.com','3106006006','2019-02-01',1,6,2,4500000,'Indefinido','Hibrido'),
('10007','Luis','Fernández Mora','1988-06-30','M','l.fernandez@empresa.com','3107007007','2018-08-01',2,7,3,5500000,'Indefinido','Remoto'),
('10008','Paula','Hernández Rios','1992-12-05','F','p.hernandez@empresa.com','3108008008','2020-03-15',2,8,3,7000000,'Indefinido','Remoto'),
('10009','Ricardo','López Suárez','1993-08-17','M','r.lopez@empresa.com','3109009009','2021-01-10',2,9,3,3500000,'Fijo','Remoto'),
('10010','Carolina','Gómez Ramos','1991-05-23','F','c.gomez@empresa.com','3110010010','2019-06-01',3,10,4,5000000,'Indefinido','Presencial'),
('10011','Santiago','Torres Mendez','1987-03-11','M','s.torres@empresa.com','3111011011','2017-11-01',4,11,5,3200000,'Indefinido','Presencial'),
('10012','Valentina','Ramírez Cruz','1994-10-09','F','v.ramirez@empresa.com','3112012012','2022-02-01',4,11,5,3000000,'Fijo','Presencial'),
('10013','Daniela','Morales Vega','1989-01-27','F','d.morales@empresa.com','3113013013','2018-05-15',5,13,NULL,4200000,'Indefinido','Presencial'),
('10014','Sebastián','Vargas Pinto','1986-07-04','M','se.vargas@empresa.com','3114014014','2016-09-01',10,14,2,5800000,'Indefinido','Presencial'),
('10015','Camila','Ortiz Rojas','1996-04-16','F','c.ortiz@empresa.com','3115015015','2023-01-15',1,15,2,1200000,'Temporal','Presencial'),
('10016','Felipe','Castro Niño','1984-11-21','M','f.castro@empresa.com','3116016016','2017-03-01',6,13,NULL,4500000,'Indefinido','Presencial'),
('10017','Marcela','Gutiérrez Paz','1991-08-08','F','m.gutierrez@empresa.com','3117017017','2020-07-01',7,6,NULL,4000000,'Indefinido','Presencial'),
('10018','Julián','Reyes Torres','1993-02-14','M','j.reyes@empresa.com','3118018018','2021-05-01',8,7,NULL,5200000,'Fijo','Hibrido'),
('10019','Natalia','Blanco Sierra','1990-09-30','F','n.blanco@empresa.com','3119019019','2019-10-01',9,8,3,6500000,'Indefinido','Remoto'),
('10020','Esteban','Pineda Ossa','1988-12-12','M','e.pineda@empresa.com','3120020020','2018-04-01',9,9,3,3800000,'Fijo','Remoto');

-- ============================================================
-- TIPOS DE AUSENCIA
-- ============================================================
INSERT INTO TiposAusencia (NombreTipo, Remunerada, RequiereAprobacion) VALUES
('Vacaciones',             1, 1),
('Licencia de Maternidad', 1, 1),
('Licencia de Paternidad', 1, 1),
('Incapacidad Médica',     1, 0),
('Permiso Personal',       0, 1),
('Calamidad Doméstica',    1, 1),
('Comisión de Servicios',  1, 1),
('Suspensión Disciplinaria',0,0);

-- ============================================================
-- AUSENCIAS
-- ============================================================
INSERT INTO Ausencias (EmpleadoID, TipoAusenciaID, FechaInicio, FechaFin, Motivo, Estado, AprobadoPor) VALUES
(6,  1, '2023-01-02','2023-01-13','Vacaciones anuales','Aprobada',2),
(9,  4, '2023-02-10','2023-02-17','Gripe severa','Aprobada',2),
(11, 1, '2023-03-06','2023-03-17','Vacaciones','Aprobada',5),
(7,  5, '2023-04-14','2023-04-14','Diligencia personal','Aprobada',3),
(12, 4, '2023-05-08','2023-05-12','Fractura mano','Aprobada',5),
(15, 1, '2023-06-19','2023-06-23','Vacaciones','Aprobada',2),
(8,  4, '2023-07-03','2023-07-07','Cirugía menor','Aprobada',3),
(10, 6, '2023-08-21','2023-08-22','Fallecimiento familiar','Aprobada',4),
(13, 7, '2023-09-11','2023-09-15','Visita cliente Medellín','Aprobada',NULL),
(20, 1, '2023-10-02','2023-10-13','Vacaciones','Aprobada',3),
(5,  1, '2023-11-06','2023-11-17','Vacaciones anuales','Aprobada',1),
(14, 4, '2023-12-04','2023-12-08','Gripe','Aprobada',2),
(2,  3, '2024-01-15','2024-02-16','Licencia de paternidad','Aprobada',1),
(16, 1, '2024-02-05','2024-02-16','Vacaciones','Aprobada',NULL),
(19, 4, '2024-03-18','2024-03-22','Alergia severa','Aprobada',3),
(6,  1, '2024-06-03','2024-06-14','Vacaciones anuales','Aprobada',2),
(9,  5, '2024-07-19','2024-07-19','Cita médica','Aprobada',2),
(3,  7, '2024-08-05','2024-08-09','Conferencia TI Madrid','Aprobada',1),
(17, 1, '2024-09-02','2024-09-13','Vacaciones','Aprobada',NULL),
(1,  1, '2024-12-23','2025-01-03','Vacaciones navideñas','Aprobada',NULL);

-- ============================================================
-- PERIODOS DE EVALUACION
-- ============================================================
INSERT INTO PeriodosEvaluacion (NombrePeriodo, FechaInicio, FechaFin, Anio, Semestre) VALUES
('S1-2022','2022-01-01','2022-06-30',2022,1),
('S2-2022','2022-07-01','2022-12-31',2022,2),
('S1-2023','2023-01-01','2023-06-30',2023,1),
('S2-2023','2023-07-01','2023-12-31',2023,2),
('S1-2024','2024-01-01','2024-06-30',2024,1),
('S2-2024','2024-07-01','2024-12-31',2024,2);

-- ============================================================
-- EVALUACIONES DE DESEMPEÑO
-- ============================================================
INSERT INTO EvaluacionesDesempeno (EmpleadoID,EvaluadorID,PeriodoEvalID,FechaEvaluacion,
    CalificacionTotal,NotaCalidad,NotaProductividad,NotaCompetencias,NotaLiderazgo,NivelDesempeno,Comentarios) VALUES
(6,2,3,'2023-07-05',88,90,85,88,89,'Bueno','Excelente desempeño en el semestre'),
(9,3,3,'2023-07-08',72,70,75,70,73,'Satisfactorio','Cumple con los objetivos mínimos'),
(7,3,3,'2023-07-06',91,92,90,93,89,'Sobresaliente','Rendimiento excepcional'),
(8,3,3,'2023-07-07',85,86,84,85,85,'Bueno','Muy buen trabajo en equipo'),
(11,5,3,'2023-07-10',78,80,75,78,79,'Satisfactorio','Requiere mejorar habilidades técnicas'),
(12,5,3,'2023-07-11',65,62,68,65,65,'Satisfactorio','En desarrollo'),
(10,4,3,'2023-07-09',87,88,86,87,87,'Bueno','Muy confiable'),
(14,2,3,'2023-07-12',90,91,89,91,89,'Sobresaliente','Hallazgos de gran valor'),
(6,2,4,'2024-01-10',90,91,88,91,90,'Sobresaliente','Mejora continua notable'),
(9,3,4,'2024-01-13',75,73,78,74,75,'Satisfactorio','Progreso desde semestre anterior'),
(7,3,4,'2024-01-11',93,94,92,93,93,'Sobresaliente','Top performer del área'),
(8,3,4,'2024-01-12',87,88,86,88,86,'Bueno','Liderazgo emergente'),
(11,5,4,'2024-01-15',80,82,78,80,80,'Bueno','Mejora significativa'),
(10,4,4,'2024-01-14',89,90,88,89,89,'Bueno','Consistente y confiable'),
(19,3,4,'2024-01-16',88,87,89,88,88,'Bueno','Buen aporte al equipo remoto'),
(20,3,4,'2024-01-17',76,74,78,76,76,'Satisfactorio','Requiere acompañamiento'),
(6,2,5,'2024-07-07',92,93,91,92,92,'Sobresaliente','Líder informal del equipo'),
(7,3,5,'2024-07-08',95,95,95,95,95,'Sobresaliente','Mejor empleado del semestre'),
(8,3,5,'2024-07-09',89,90,88,89,89,'Bueno','Continúa mejorando'),
(14,2,5,'2024-07-10',91,92,90,91,91,'Sobresaliente','Auditor del año');

-- ============================================================
-- AREAS DE CURSO Y CURSOS
-- ============================================================
INSERT INTO AreasCurso (NombreArea, Descripcion) VALUES
('Tecnología','Cursos de TI, software y herramientas digitales'),
('Liderazgo','Habilidades de gestión y liderazgo'),
('Finanzas','Cursos financieros y contables'),
('Ventas','Técnicas de venta y negociación'),
('Bienestar','Salud mental, ergonomía y bienestar laboral'),
('Cumplimiento','Ética, normativas y compliance'),
('Idiomas','Inglés, francés y otros idiomas');

INSERT INTO Cursos (NombreCurso, AreaCursoID, Modalidad, DuracionHoras, Costo, Proveedor) VALUES
('Power BI Avanzado',              1,'Virtual',   40, 800000,'Udemy Business'),
('Python para Análisis de Datos',  1,'Virtual',   60, 1200000,'Coursera'),
('Liderazgo Transformacional',     2,'Presencial', 16, 600000,'CCL Colombia'),
('Gestión del Cambio',             2,'Hibrido',    24, 900000,'LHH'),
('Contabilidad NIIF',              3,'Presencial', 32, 750000,'KPMG'),
('Excel Financiero',               3,'Virtual',    20, 300000,'Udemy Business'),
('Técnicas de Negociación',        4,'Presencial', 16, 500000,'Dale Carnegie'),
('Inbound Marketing',              4,'Virtual',    30, 700000,'HubSpot Academy'),
('Mindfulness en el Trabajo',      5,'Presencial',  8, 200000,'InternoCorp'),
('SQL Server y BI',                1,'Virtual',    50, 1100000,'Platzi'),
('Auditoría Basada en Riesgos',    6,'Presencial', 24, 850000,'Deloitte'),
('Inglés de Negocios B2',          7,'Hibrido',    80, 1500000,'British Council'),
('Azure DevOps',                   1,'Virtual',    45, 950000,'Microsoft Learn'),
('Gestión de Proyectos PMP',       2,'Hibrido',    40, 1800000,'PMI'),
('Comunicación Efectiva',          2,'Presencial', 12, 350000,'InternoCorp');

-- ============================================================
-- CAPACITACIONES
-- ============================================================
INSERT INTO Capacitaciones (EmpleadoID,CursoID,FechaInicio,FechaFin,Estado,Calificacion,Certificado) VALUES
(7,  1,  '2023-02-01','2023-03-15','Completado',88,1),
(7,  2,  '2023-04-01','2023-05-31','Completado',92,1),
(8,  1,  '2023-02-01','2023-03-15','Completado',90,1),
(9,  10, '2023-03-01','2023-04-20','Completado',75,0),
(6,  3,  '2023-05-15','2023-05-16','Completado',85,1),
(11, 7,  '2023-06-01','2023-06-02','Completado',80,1),
(12, 7,  '2023-06-01','2023-06-02','Completado',78,0),
(10, 5,  '2023-07-10','2023-07-21','Completado',88,1),
(14, 11, '2023-08-07','2023-08-09','Completado',95,1),
(3,  12, '2023-09-01','2023-12-15','Completado',82,1),
(19, 13, '2023-10-02','2023-11-30','Completado',87,1),
(20, 2,  '2023-10-02','2023-11-30','Completado',71,0),
(6,  4,  '2024-01-15','2024-02-05','Completado',90,1),
(8,  14, '2024-02-01','2024-03-15','Completado',88,1),
(7,  13, '2024-03-01','2024-04-15','Completado',94,1),
(9,  1,  '2024-04-01','2024-05-15','Completado',80,1),
(15, 9,  '2024-05-06','2024-05-06','Completado',NULL,0),
(10, 6,  '2024-06-01','2024-06-20','Completado',86,1),
(11, 3,  '2024-07-08','2024-07-09','Completado',83,1),
(14, 11, '2024-08-05','2024-08-07','Completado',97,1),
(5,  7,  '2024-09-02','2024-09-03','Completado',88,1),
(18, 14, '2024-10-01','2024-11-15','En Progreso',NULL,0),
(2,  15, '2024-11-01','2024-11-01','Completado',90,1),
(16, 4,  '2024-11-11','2024-12-02','Completado',85,1),
(20, 12, '2024-11-01','2025-02-28','Inscrito',NULL,0);

-- ============================================================
-- HISTORIAL DE SALARIOS
-- ============================================================
INSERT INTO HistorialSalarios (EmpleadoID,SalarioAnterior,SalarioNuevo,FechaCambio,Motivo,AprobadoPor) VALUES
(6, 4000000,4500000,'2023-01-01','Incremento salarial anual',2),
(7, 5000000,5500000,'2023-01-01','Incremento salarial anual',3),
(9, 3200000,3500000,'2023-01-01','Incremento salarial anual',3),
(8, 6500000,7000000,'2023-07-01','Ascenso a Senior',3),
(11,2800000,3200000,'2023-01-01','Incremento por mérito',5),
(10,4500000,5000000,'2023-01-01','Incremento salarial anual',4),
(12,2700000,3000000,'2023-01-01','Incremento salarial anual',5),
(6, 4500000,5000000,'2024-01-01','Incremento por desempeño',2),
(7, 5500000,6000000,'2024-01-01','Aumento por retención',3),
(9, 3500000,3800000,'2024-07-01','Incremento semestral',3);

PRINT 'Datos poblados exitosamente en RRHH_OLTP.';
GO
