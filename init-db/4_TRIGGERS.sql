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
            -- Inicializa _assistido para FALSE antes de cada consulta
            _assistido := FALSE;

            -- Tenta verificar se o aluno assistiu a aula
            SELECT assistido INTO _assistido
            FROM progresso
            WHERE aula_id = aula_rec.aula_id AND aluno_id = NEW.aluno_id;

            -- Se nenhuma linha foi encontrada (NOT FOUND) ou se _assistido for FALSE,
            -- significa que o aluno não assistiu a esta aula.
            IF NOT FOUND OR NOT _assistido THEN
                RAISE EXCEPTION 'Aluno não assistiu todas as aulas do módulo % (Aula ID: %).', modulo_rec.modulo_id, aula_rec.aula_id;
            END IF;
        END LOOP;
    END LOOP;

    -- Verifica a nota mínima para certificado
    -- Assumindo que a função check_nota() existe e retorna a nota
    IF check_nota(NEW.aluno_id, NEW.curso_id) < 3 THEN
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

CREATE OR REPLACE FUNCTION concluir_inscricao()
RETURNS trigger AS $$
BEGIN
	UPDATE inscricoes SET STATUS = 'concluido' WHERE aluno_id = new.aluno_id AND curso_id = new.curso_id;
	RETURN new;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER concluir_inscricao_trigger AFTER INSERT ON certificados
FOR each ROW EXECUTE FUNCTION concluir_inscricao();

