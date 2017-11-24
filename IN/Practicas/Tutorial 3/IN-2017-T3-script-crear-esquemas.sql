DROP schema if exists dw_inbd00 cascade;
CREATE schema dw_inbd00 AUTHORIZATION inrol;

CREATE TABLE dw_inbd00.dw_fact_ingreso (
		fk_procedencia integer NOT NULL,
		fk_paciente integer NOT NULL,
		fk_tipo_ingreso integer NOT NULL,
		fk_tiempo integer NOT NULL,
		duracion integer NOT NULL
	);

CREATE TABLE dw_inbd00.dw_dim_proc (
		pk_procedencia integer NOT NULL,
		servicio_procedencia varchar NOT NULL
	);

CREATE TABLE dw_inbd00.dw_dim_time (
		fecha date NOT NULL,
		anno integer NOT NULL,
		mes integer NOT NULL,
		pk_tiempo integer NOT NULL
	);

CREATE TABLE dw_inbd00.dw_dim_tipoIngreso (
		pk_tipo_ingreso integer NOT NULL,
		tipo varchar NOT NULL
	);

CREATE TABLE dw_inbd00.dw_dim_paciente (
		pk_paciente integer NOT NULL,
		sexo varchar NOT NULL
	);

ALTER TABLE dw_inbd00.dw_fact_ingreso ADD CONSTRAINT pk_fac_ingreso PRIMARY KEY(fk_procedencia,fk_paciente,fk_tipo_ingreso,fk_tiempo);
ALTER TABLE dw_inbd00.dw_dim_proc ADD CONSTRAINT pk_proc PRIMARY KEY(pk_procedencia);
ALTER TABLE dw_inbd00.dw_dim_time ADD CONSTRAINT pk_tiempo PRIMARY KEY(pk_tiempo);
ALTER TABLE dw_inbd00.dw_dim_tipoIngreso ADD CONSTRAINT pk_ingresos PRIMARY KEY(pk_tipo_ingreso);
ALTER TABLE dw_inbd00.dw_dim_paciente ADD CONSTRAINT pk_pak PRIMARY KEY(pk_paciente);

ALTER TABLE dw_inbd00.dw_fact_ingreso ADD CONSTRAINT fk_a_proc FOREIGN KEY (fk_procedencia) REFERENCES dw_inbd00.dw_dim_proc(pk_procedencia) ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE dw_inbd00.dw_fact_ingreso ADD CONSTRAINT fk_a_tiempo FOREIGN KEY (fk_tiempo) REFERENCES dw_inbd00.dw_dim_time(pk_tiempo) ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE dw_inbd00.dw_fact_ingreso ADD CONSTRAINT fk_a_tipo_ing FOREIGN KEY (fk_tipo_ingreso) REFERENCES dw_inbd00.dw_dim_tipoIngreso(pk_tipo_ingreso) ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE dw_inbd00.dw_fact_ingreso ADD CONSTRAINT fk_a_pac FOREIGN KEY (fk_paciente) REFERENCES dw_inbd00.dw_dim_paciente(pk_paciente) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE dw_inbd00.dw_fact_ingreso OWNER TO inrol;
ALTER TABLE dw_inbd00.dw_dim_proc OWNER TO inrol;
ALTER TABLE dw_inbd00.dw_dim_time OWNER TO inrol;
ALTER TABLE dw_inbd00.dw_dim_tipoIngreso OWNER TO inrol;
ALTER TABLE dw_inbd00.dw_dim_paciente OWNER TO inrol;

