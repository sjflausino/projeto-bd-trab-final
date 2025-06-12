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

CREATE OR REPLACE FUNCTION check_nota(a_id integer,c_id integer) 
RETURNS integer 
LANGUAGE plpgsql as $$
DECLARE
 	n integer;
BEGIN
    n := nota FROM avaliacoes WHERE aluno_id = a_id AND curso_id = c_id;
	return n;
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
    IF check_nota(NEW.aluno_id, NEW.curso_id) < 3 THEN
        RAISE EXCEPTION 'Aluno não possui nota suficiente para obter o certificado.';
    ELSE
        RAISE NOTICE 'Certificado criado com sucesso.';
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION concluir_inscricao()
RETURNS trigger AS $$
BEGIN
	UPDATE inscricoes SET STATUS = 'concluido' WHERE aluno_id = new.aluno_id AND curso_id = new.curso_id;
	RETURN new;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION calcular_porcentagem_assistido(p_aluno_id INT, p_curso_id INT)
RETURNS NUMERIC AS $$
DECLARE
    total_aulas INT;
    aulas_assistidas INT;
BEGIN
    -- Total de aulas no curso
    SELECT COUNT(*) INTO total_aulas
    FROM aulas a
    JOIN modulos m ON a.modulo_id = m.modulo_id
    WHERE m.curso_id = p_curso_id;

    -- Total de aulas assistidas pelo aluno
    SELECT COUNT(*) INTO aulas_assistidas
    FROM progresso p
    JOIN aulas a ON p.aula_id = a.aula_id
    JOIN modulos m ON a.modulo_id = m.modulo_id
    WHERE p.aluno_id = p_aluno_id
      AND m.curso_id = p_curso_id
      AND p.assistido IS TRUE;

    IF total_aulas = 0 THEN
        RETURN 0;
    END IF;

    RETURN ROUND((aulas_assistidas::NUMERIC / total_aulas) * 100, 2);
END;
$$ LANGUAGE plpgsql;
