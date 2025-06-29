-- ==================================================================
-- CASO DE ERRO: Aluno sem certificado é adicionado como monitor
-- ❌ O gatilho `monitor_trigger` DEVE impedir a inserção em 'monitores'.
-- ATENÇÃO: Este script NÃO utiliza RETURNING para capturar IDs.
-- Ele ASSUME que os IDs gerados automaticamente (SERIAL) corresponderão
-- aos valores fixos usados (ex: 1, 2, 3) nas inserções de chaves estrangeiras.
-- Se seus IDs reais forem diferentes, o script falhará com erro de FK.
-- ==================================================================

-- Inserir professor (assumindo que o próximo usuario_id gerado será 1)
INSERT INTO usuarios (nome, email, senha, tipo) VALUES
('Professor Monitor Invalido', 'prof_monitor_invalido@example.com', 'senha123', 'professor');
INSERT INTO professores (professor_id, curriculo, especialidade) VALUES
(1, 'Especialista em Testes de Monitoria', 'Validações');
-- Se o usuario_id gerado para 'prof_monitor_invalido@example.com' não for 1, as próximas
-- inserções que usam '1' como professor_id falharão com erro de FK.

-- Inserir categoria (assumindo que o próximo categoria_id gerado será 1)
INSERT INTO categorias (nome, descricao) VALUES ('Monitoria Invalida', 'Categoria para testes de monitoria sem certificado.');
-- Se o categoria_id gerado não for 1, as próximas inserções falharão.

-- Inserir curso (assumindo curso_id 1, categoria_id 1, professor_id 1)
INSERT INTO cursos (titulo, descricao, categoria_id, professor_id, ativo)
VALUES ('Curso para Monitoria Invalida', 'Este curso é para testar a validação de monitoria.', 1, 1, TRUE);
-- Se os IDs gerados para curso, categoria ou professor não forem 1, as próximas inserções falharão.

-- Inserir módulo (assumindo modulo_id 1, curso_id 1)
INSERT INTO modulos (curso_id, titulo, ordem) VALUES (1, 'Módulo para Monitoria Invalida', 1);
-- Se os IDs gerados para modulo ou curso não forem 1, as próximas inserções falharão.

-- Inserir aula (assumindo aula_id 1, modulo_id 1)
INSERT INTO aulas (modulo_id, titulo, descricao, video_url, ordem)
VALUES (1, 'Aula para Monitoria Invalida', 'Esta aula NÃO será assistida para o teste.', 'http://example.com/aula-invalida', 1);
-- Se os IDs gerados para aula ou modulo não forem 1, as próximas inserções falharão.

-- Inserir aluno para o caso de erro (NÃO assistirá a aula e NÃO obterá certificado)
-- Assumindo que o próximo usuario_id gerado para este aluno será 2.
INSERT INTO usuarios (nome, email, senha, tipo) VALUES
('Aluno Monitor Invalido', 'aluno_monitor_invalido@example.com', 'senha123', 'aluno');
INSERT INTO alunos (aluno_id, data_nascimento, telefone)
VALUES (2, '2001-01-01', '(77) 77777-7777');
-- Se o usuario_id gerado para 'aluno_monitor_invalido@example.com' não for 2, as próximas
-- inserções que usam '2' como aluno_id falharão com erro de FK.

-- Inscrição do aluno no curso (assumindo aluno_id 2, curso_id 1)
INSERT INTO inscricoes (aluno_id, curso_id, status) VALUES (2, 1, 'em andamento');

-- NOTA: Não há INSERT para progresso.assistido = TRUE para esta aula.
-- NOTA: Não há INSERT para certificados para este aluno/curso.

-- Registro de uma avaliação (opcional, mas não afeta a validação do certificado/monitoria)
-- Assumindo aluno_id 2, curso_id 1
INSERT INTO avaliacoes (aluno_id, curso_id, nota, comentario)
VALUES (2, 1, 3, 'Gostei do curso, mas não terminei.');

-- ❌ Tenta adicionar o aluno como monitor (ISSO DEVE FALHAR)
-- Usa aluno_id = 2 e curso_id = 1
INSERT INTO monitores (aluno_id, curso_id, data_inicio)
VALUES (2, 1, CURRENT_DATE);

-- Para verificar o resultado (esta consulta deve retornar 0 linhas se o gatilho funcionar):
SELECT * FROM monitores WHERE aluno_id = 2 AND curso_id = 1;
