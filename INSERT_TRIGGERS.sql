-- 1. Adiciona monitor valido
INSERT INTO monitores (aluno_id, curso_id, data_inicio) VALUES
(1, 1, CURRENT_DATE);

-- 2. Adiciona monitor inválido (sem certificado)
INSERT INTO monitores (aluno_id, curso_id, data_inicio) VALUES
(3, 5, CURRENT_DATE);

-- 3. Verifica progresso e conclui curso
INSERT INTO certificados (aluno_id, curso_id, codigo_validacao)
VALUES (1, 1, 'CERT-TESTE-VAL');