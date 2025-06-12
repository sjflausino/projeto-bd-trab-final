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
