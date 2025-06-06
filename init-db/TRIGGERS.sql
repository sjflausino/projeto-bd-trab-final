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


CREATE OR REPLACE FUNCTION check_certificado()
RETURNS TRIGGER AS $$
DECLARE
	aula_rec record;
	assistido bool;
    modulo_rec record;
	nota float;
BEGIN
 

    FOR modulo_rec in SELECT * FROM modulos WHERE aluno_id = NEW.aluno_id AND curso_id = NEW.curso_id loop
		FOR aula_rec in SELECT * FROM Aulas where aluno_id = modelo_rec.aluno_id and modelo_id = modelo_rec.id LOOP
			assistido := assistido FROM progresso where aula_id = aula_rec.aula_id and aluno_id = aula_rec.aluno_id;
			IF not assistido Then 
				RAISE EXCEPTION 'Aluno não assistiu todas as aulas.';
			END IF;
		END LOOP;	
	END LOOP;

	nota := nota from avaliacoes where curso_id = new.curso_id and aluno_id = new.aluno_id;

    IF nota < 6.0 THEN
        RAISE EXCEPTION 'Aluno não possui nota para passar no curso.';
   	ELSE
		RAISE NOTICE 'Cetificado criado.';
    	RETURN NEW;
	END IF;
END;
$$ LANGUAGE plpgsql;
