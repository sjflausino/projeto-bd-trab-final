CREATE OR REPLACE FUNCTION check_monitor()
RETURNS TRIGGER AS $$
DECLARE
    certificado_rec CERTIFICADOS%ROWTYPE;
BEGIN
    SELECT * INTO certificado_rec
    FROM certificados
    WHERE aluno_id = NEW.aluno_id AND curso_id = NEW.curso_id;

    IF certificado_rec IS NULL THEN
        RAISE EXCEPTION 'Aluno não possui certificado para o curso informado.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER monitor_trigger
BEFORE INSERT ON monitores
FOR EACH ROW
EXECUTE FUNCTION check_monitor();