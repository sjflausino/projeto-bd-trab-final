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

CREATE OR REPLACE FUNCTION media_de_nota_curso(cursoid integer) 
RETURNS float  
LANGUAGE plpgsql AS $$
DECLARE
 	n float;
BEGIN
    SELECT ROUND(AVG(avaliacoes.nota),2) FROM avaliacoes INTO n WHERE curso_id = cursoid;
	RETURN n;
END;
$$;

CREATE OR REPLACE FUNCTION func_inscrever_aluno(p_aluno_id INT, p_curso_id INT)
RETURNS TEXT AS $$
DECLARE
    ja_inscrito BOOLEAN;
    curso_ativo BOOLEAN;
BEGIN
    SELECT TRUE INTO ja_inscrito
    FROM inscricoes
    WHERE aluno_id = p_aluno_id AND curso_id = p_curso_id;

    IF ja_inscrito THEN
        RETURN 'Aluno já inscrito no curso.';
    END IF;

    SELECT ativo INTO curso_ativo FROM cursos WHERE curso_id = p_curso_id;

    IF NOT curso_ativo THEN
        RETURN 'Curso inativo.';
    END IF;

    INSERT INTO inscricoes (aluno_id, curso_id, status)
    VALUES (p_aluno_id, p_curso_id, 'em andamento');

    RETURN 'Inscrição realizada com sucesso.';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION func_mensagens_nao_lidas(p_usuario_id INT)
RETURNS INT AS $$
DECLARE
    total INT;
BEGIN
    SELECT COUNT(*) INTO total
    FROM mensagens
    WHERE destinatario_id = p_usuario_id AND lida = FALSE;

    RETURN total;
END;
$$ LANGUAGE plpgsql;