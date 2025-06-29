-- ==================================================================
-- CASO DE SUCESSO: Aluno com certificado é adicionado como monitor
-- ✅ O gatilho `check_certificado` (se aplicado em 'certificados')
--    DEVE permitir a emissão do certificado para este aluno.
-- ✅ A inserção em 'monitores' DEVE ser bem-sucedida.
-- ATENÇÃO: Este script NÃO utiliza RETURNING para capturar IDs.
-- Ele ASSUME que os IDs gerados automaticamente (SERIAL) corresponderão
-- aos valores fixos usados (ex: 1, 2, 3) nas inserções de chaves estrangeiras.
-- Se seus IDs reais forem diferentes, o script falhará com erro de FK.
-- ==================================================================

-- Inserir professor (assumindo que o próximo usuario_id gerado será 1)
INSERT INTO usuarios (nome, email, senha, tipo) VALUES
('Professor Monitor Success', 'prof_monitor_success@example.com', 'senha123', 'professor');
INSERT INTO professores (professor_id, curriculo, especialidade) VALUES
(1, 'Especialista em Monitoria', 'Apoio ao Aluno');
-- Se o usuario_id gerado para 'prof_monitor_success@example.com' não for 1, as próximas
-- inserções que usam '1' como professor_id falharão com erro de FK.

-- Inserir categoria (assumindo que o próximo categoria_id gerado será 1)
INSERT INTO categorias (nome, descricao) VALUES ('Monitoria', 'Categoria para cursos com monitoria.');
-- Se o categoria_id gerado não for 1, as próximas inserções falharão.

-- Inserir curso (assumindo curso_id 1, categoria_id 1, professor_id 1)
INSERT INTO cursos (titulo, descricao, categoria_id, professor_id, ativo)
VALUES ('Curso para Monitoria', 'Este curso é para testar a adição de monitores.', 1, 1, TRUE);
-- Se os IDs gerados para curso, categoria ou professor não forem 1, as próximas inserções falharão.

-- Inserir módulo (assumindo modulo_id 1, curso_id 1)
INSERT INTO modulos (curso_id, titulo, ordem) VALUES (1, 'Módulo para Monitor', 1);
-- Se os IDs gerados para modulo ou curso não forem 1, as próximas inserções falharão.

-- Inserir aula (assumindo aula_id 1, modulo_id 1)
INSERT INTO aulas (modulo_id, titulo, descricao, video_url, ordem)
VALUES (1, 'Aula Essencial para Monitor', 'Esta aula precisa ser assistida para o certificado.', 'http://example.com/aula-monitor', 1);
-- Se os IDs gerados para aula ou modulo não forem 1, as próximas inserções falharão.

-- Inserir aluno para o caso de sucesso (assistirá a aula e obterá certificado)
-- Assumindo que o próximo usuario_id gerado para este aluno será 2.
INSERT INTO usuarios (nome, email, senha, tipo) VALUES
('Aluno Monitor Success', 'aluno_monitor_success@example.com', 'senha123', 'aluno');
INSERT INTO alunos (aluno_id, data_nascimento, telefone)
VALUES (2, '1995-05-05', '(88) 88888-8888');
-- Se o usuario_id gerado para 'aluno_monitor_success@example.com' não for 2, as próximas
-- inserções que usam '2' como aluno_id falharão com erro de FK.

-- Inscrição do aluno no curso (assumindo aluno_id 2, curso_id 1)
INSERT INTO inscricoes (aluno_id, curso_id, status) VALUES (2, 1, 'concluido');

-- Registrar progresso: Aluno assistiu à aula (essencial para o certificado)
-- Assumindo aula_id 1, aluno_id 2
INSERT INTO progresso (aula_id, aluno_id, assistido, data_visualizacao)
VALUES (1, 2, TRUE, CURRENT_DATE);

-- Registro da avaliação do aluno no curso (nota suficiente para certificado)
-- Assumindo aluno_id 2, curso_id 1
INSERT INTO avaliacoes (aluno_id, curso_id, nota, comentario)
VALUES (2, 1, 5, 'Curso excelente, pronto para ser monitor!');

-- Tenta gerar o certificado (ISSO DEVE TER SUCESSO)
-- Assumindo aluno_id 2, curso_id 1
INSERT INTO certificados (aluno_id, curso_id, data_emissao, codigo_validacao)
VALUES (2, 1, CURRENT_DATE, 'CERT-SUCESSO-MONITOR');

-- ✅ Tenta adicionar o aluno como monitor (ISSO DEVE TER SUCESSO)
-- Usa aluno_id = 2 e curso_id = 1
INSERT INTO monitores (aluno_id, curso_id, data_inicio)
VALUES (2, 1, CURRENT_DATE);

-- Para verificar o resultado (esta consulta deve retornar 1 linha se o gatilho funcionar):
SELECT * FROM monitores WHERE aluno_id = 2 AND curso_id = 1;
