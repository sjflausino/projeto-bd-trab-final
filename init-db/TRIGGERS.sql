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
   	ELSE
		RAISE NOTICE 'Aluno pode adicionado como monitor';
    	RETURN NEW;
	END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER monitor_trigger
BEFORE INSERT ON monitores
FOR EACH ROW
EXECUTE FUNCTION check_monitor();


CREATE OR REPLACE FUNCTION check_nota(a_id integer,c_id integer) 
RETURNS FLOAT 
LANGUAGE plpgsql as $$
DECLARE
 	nota float;
BEGIN
    nota := nota FROM avaliacoes WHERE aluno_id = a_id AND curso_id = c_id;
	return nota;
END;
$$;



CREATE OR REPLACE FUNCTION check_certificado()
RETURNS TRIGGER AS $$
DECLARE
    aula_rec RECORD;
    _assistido BOOLEAN;
    modulo_rec RECORD;
BEGIN
    -- Loop pelos módulos do curso do aluno
    FOR modulo_rec IN
        SELECT * FROM modulos
        WHERE curso_id = NEW.curso_id
    LOOP
        -- Loop pelas aulas do módulo
        FOR aula_rec IN
 			SELECT * FROM aulas
            WHERE modulo_id = modulo_rec.modulo_id
        LOOP
            -- Verifica se o aluno assistiu a aula
            SELECT assistido INTO _assistido
            FROM progresso
            WHERE aula_id = aula_rec.aula_id AND aluno_id = NEW.aluno_id;

            IF NOT _assistido THEN
                RAISE EXCEPTION 'Aluno não assistiu todas as aulas do módulo %.', modulo_rec.modulo_id;
            END IF;
        END LOOP;
    END LOOP;

    -- Verifica a nota mínima para certificado
    IF check_nota(NEW.aluno_id, NEW.curso_id) < 6.0 THEN
        RAISE EXCEPTION 'Aluno não possui nota suficiente para obter o certificado.';
    ELSE
        RAISE NOTICE 'Certificado criado com sucesso.';
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER certificado_trigger
BEFORE INSERT ON certificados
FOR EACH ROW
EXECUTE FUNCTION check_certificado();

