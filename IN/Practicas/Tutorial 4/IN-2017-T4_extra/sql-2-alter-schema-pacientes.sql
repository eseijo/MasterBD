alter table pacientes.paciente add column padre int;
alter table pacientes.paciente add constraint padre_fk foreign key (padre) references pacientes.paciente(codpaciente);
-- alter table pacientes.paciente drop column familiar;
--rellenar algunos

update pacientes.paciente P set padre = null;
update pacientes.paciente P set padre = codpaciente * 2 -- correlación para que lo haga individualmente
	where codpaciente < 300 and
		codpaciente in (select codpaciente from pacientes.paciente Q where P.codpaciente=Q.codpaciente);



