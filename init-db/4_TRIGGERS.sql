CREATE TRIGGER monitor_trigger
BEFORE INSERT ON monitores
FOR EACH ROW
EXECUTE FUNCTION check_monitor();

CREATE TRIGGER certificado_trigger
BEFORE INSERT ON certificados
FOR EACH ROW
EXECUTE FUNCTION check_certificado();

CREATE OR REPLACE TRIGGER concluir_inscricao_trigger AFTER INSERT ON certificados
FOR each ROW EXECUTE FUNCTION concluir_inscricao();

