-- drop table dw_prof.familiar_clausura;
create table dw_prof.familiar_clausura (
	padre int,
	hijo int,
	profundidad int,
	constraint padre_fk foreign key (padre) references dw_prof.dw_dim_paciente(pk_paciente),
	constraint hijo_fk foreign key (hijo) references dw_prof.dw_dim_paciente(pk_paciente)
);	

ALTER TABLE dw_prof.familiar_clausura OWNER TO inrol;

--select * from dw_prof.familiar_clausura order by padre desc, profundidad;

--DROP TABLE dw_prof.patient_prescription;
--DROP TABLE dw_prof.dw_dim_via;
-- ﻿CREATE 
CREATE TABLE dw_prof.dw_dim_via
(
  cod_via integer,
  desc_via character varying(150) NOT NULL,
  CONSTRAINT pk_codigo PRIMARY KEY (cod_via)
);
ALTER TABLE dw_prof.dw_dim_via OWNER TO inrol;

CREATE TABLE dw_prof.patient_prescription
(
  cod_paciente integer NOT NULL,
  cod_nacional character varying(6) NOT NULL,
  fecha timestamp without time zone,
  dosis real,
  unidad character varying(50),
  pauta character varying(100),
  via integer,
  descripcion character varying(200),
  cod_act character varying(8),
  cod_principio_activo character varying ,
  CONSTRAINT pk_prescripcion PRIMARY KEY (cod_paciente, cod_nacional, fecha),
  CONSTRAINT fk_to_paciente FOREIGN KEY (cod_paciente)
      REFERENCES dw_prof.dw_dim_paciente (pk_paciente) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_to_via FOREIGN KEY (via) REFERENCES dw_prof.dw_dim_via (cod_via)
);
ALTER TABLE dw_prof.patient_prescription OWNER TO inrol;

