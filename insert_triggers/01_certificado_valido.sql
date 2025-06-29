-- ==================================================================
-- CASO DE SUCESSO: Status da inscrição muda para 'concluido' após emissão do certificado.
-- ✅ O gatilho `concluir_inscricao_trigger` DEVE atualizar o status da inscrição.
-- ATENÇÃO: Este script NÃO utiliza RETURNING para capturar IDs.
-- Ele ASSUME que os IDs gerados automaticamente (SERIAL) corresponderão
-- aos valores fixos usados (ex: 1, 2, 3) nas inserções de chaves estrangeiras.
-- Se seus IDs reais forem diferentes, o script falhará com erro de FK.
-- ==================================================================

-- Inserir professor (assumindo que o próximo usuario_id gerado será 1)
INSERT INTO usuarios (nome, email, senha, tipo) VALUES
('Professor Status Change No Ret', 'prof_status_change_no_ret@example.com', 'senha123', 'professor');
INSERT INTO professores (professor_id, curriculo, especialidade) VALUES
(1, 'Especialista em Gatilhos No Ret', 'PL/pgSQL');
-- Se o usuario_id gerado para 'prof_status_change_no_ret@example.com' não for 1, as próximas
-- inserções que usam '1' como professor_id falharão com erro de FK.

-- Inserir categoria (assumindo que o próximo categoria_id gerado será 1)
INSERT INTO categorias (nome, descricao) VALUES ('Mudanca de Status No Ret', 'Categoria para testes de mudança de status de inscrição sem RETURNING.');
-- Se o categoria_id gerado não for 1, as próximas inserções falharão.

-- Inserir curso (assumindo curso_id 1, categoria_id 1, professor_id 1)
INSERT INTO cursos (titulo, descricao, categoria_id, professor_id, ativo)
VALUES ('Curso para Mudanca de Status No Ret', 'Este curso é para testar a atualização do status da inscrição sem RETURNING.', 1, 1, TRUE);
-- Se os IDs gerados para curso, categoria ou professor não forem 1, as próximas inserções falharão.

-- Inserir módulo (assumindo modulo_id 1, curso_id 1)
INSERT INTO modulos (curso_id, titulo, ordem) VALUES (1, 'Modulo para Mudanca de Status No Ret', 1);
-- Se os IDs gerados para modulo ou curso não forem 1, as próximas inserções falharão.

-- Inserir aula (assumindo aula_id 1, modulo_id 1)
INSERT INTO aulas (modulo_id, titulo, descricao, video_url, ordem)
VALUES (1, 'Aula para Mudanca de Status No Ret', 'Esta aula será assistida para o teste sem RETURNING.', 'http://example.com/aula-status-no-ret', 1);
-- Se os IDs gerados para aula ou modulo não forem 1, as próximas inserções falharão.

-- Inserir aluno para o caso de sucesso
-- Assumindo que o próximo usuario_id gerado para este aluno será 2.
INSERT INTO usuarios (nome, email, senha, tipo) VALUES
('Aluno Status Change No Ret', 'aluno_status_change_no_ret@example.com', 'senha123', 'aluno');
INSERT INTO alunos (aluno_id, data_nascimento, telefone)
VALUES (2, '1990-10-10', '(66) 66666-6666');
-- Se o usuario_id gerado para 'aluno_status_change_no_ret@example.com' não for 2, as próximas
-- inserções que usam '2' como aluno_id falharão com erro de FK.

-- Inscrição do aluno no curso (assumindo aluno_id 2, curso_id 1)
-- Status inicial: 'em andamento'
INSERT INTO inscricoes (aluno_id, curso_id, status) VALUES (2, 1, 'em andamento');

-- Registrar progresso: Aluno assistiu à aula (essencial para o certificado)
-- Assumindo aula_id 1, aluno_id 2
INSERT INTO progresso (aula_id, aluno_id, assistido, data_visualizacao)
VALUES (1, 2, TRUE, CURRENT_DATE);

-- Registro da avaliação do aluno no curso (nota suficiente para certificado)
-- Assumindo aluno_id 2, curso_id 1
INSERT INTO avaliacoes (aluno_id, curso_id, nota, comentario)
VALUES (2, 1, 5, 'Curso ótimo, pronto para o certificado sem RETURNING!');

-- Tenta gerar o certificado (ISSO DEVE TER SUCESSO e acionar o gatilho de status)
-- Assumindo aluno_id 2, curso_id 1
INSERT INTO certificados (aluno_id, curso_id, data_emissao, codigo_validacao)
VALUES (2, 1, CURRENT_DATE, 'CERT-STATUS-CHANGE-NO-RET');

-- Para verificar o resultado:
-- Esta consulta DEVE retornar 1 linha com status = 'concluido' se o gatilho funcionar:
SELECT * FROM inscricoes WHERE aluno_id = 2 AND curso_id = 1;
