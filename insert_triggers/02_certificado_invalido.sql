-- ==================================================================
-- CASO DE ERRO: Certificado emitido sem aluno assistir aula (SEM RETURNING)
-- ❌ O gatilho `certificado_trigger` DEVE impedir a emissão do certificado.
-- ATENÇÃO: Este script NÃO utiliza RETURNING para capturar IDs.
-- Ele ASSUME que os IDs gerados automaticamente (SERIAL) corresponderão
-- aos valores fixos usados (ex: 1, 2, 3) nas inserções de chaves estrangeiras.
-- Se seus IDs reais forem diferentes, o script falhará com erro de FK.
-- ==================================================================

-- Inserir professor (assumindo que o próximo usuario_id gerado será 1)
INSERT INTO usuarios (nome, email, senha, tipo) VALUES
('Professor Teste Certificado Fixed', 'prof_test_cert_fixed@example.com', 'senha123', 'professor');

INSERT INTO professores (professor_id, curriculo, especialidade) VALUES
(1, 'Especialista em Testes de Banco de Dados', 'PL/pgSQL');

-- Se o usuario_id gerado para 'prof_test_cert_fixed@example.com' não for 1, as próximas
-- inserções que usam '1' como professor_id falharão com erro de FK.

-- Inserir categoria (assumindo que o próximo categoria_id gerado será 1)
INSERT INTO categorias (nome, descricao) VALUES ('Testes de Certificado', 'Categoria para testes de emissão de certificado.');

-- Se o categoria_id gerado não for 1, as próximas inserções falharão.

-- Inserir curso (assumindo curso_id 1, categoria_id 1, professor_id 1)
INSERT INTO cursos (titulo, descricao, categoria_id, professor_id, ativo)
VALUES ('Curso de Teste de Certificado', 'Este curso é usado para validar a lógica de certificado.', 1, 1, TRUE);
-- Se os IDs gerados para curso, categoria ou professor não forem 1, as próximas inserções falharão.

-- Inserir módulo (assumindo modulo_id 1, curso_id 1)
INSERT INTO modulos (curso_id, titulo, ordem) VALUES (1, 'Módulo de Teste de Certificado', 1);
-- Se os IDs gerados para modulo ou curso não forem 1, as próximas inserções falharão.

-- Inserir aula (assumindo aula_id 1, modulo_id 1)
INSERT INTO aulas (modulo_id, titulo, descricao, video_url, ordem)
VALUES (1, 'Aula de Teste de Certificado', 'Aula essencial para a obtenção do certificado.', 'http://example.com/aula-teste', 1);
-- Se os IDs gerados para aula ou modulo não forem 1, as próximas inserções falharão.

-- Inserir novo aluno para o caso de erro (não assistirá a aula)
-- Assumindo que o próximo usuario_id gerado para este aluno será 2.
INSERT INTO usuarios (nome, email, senha, tipo) VALUES
('Aluno Teste Sem Aula Fixed', 'aluno_sem_aula_fixed@example.com', 'senha123', 'aluno');
INSERT INTO alunos (aluno_id, data_nascimento, telefone)
VALUES (2, '2000-01-01', '(99) 99999-9999');
-- Se o usuario_id gerado para 'aluno_sem_aula_fixed@example.com' não for 2, as próximas
-- inserções que usam '2' como aluno_id falharão com erro de FK.

-- Inscrição do aluno no curso (assumindo aluno_id 2, curso_id 1)
INSERT INTO inscricoes (aluno_id, curso_id, status) VALUES (2, 1, 'em andamento');

-- Registro da avaliação do aluno no curso (nota suficiente, mas sem progresso total)
-- Assumindo aluno_id 2, curso_id 1
INSERT INTO avaliacoes (aluno_id, curso_id, nota, comentario)
VALUES (2, 1, 4, 'Teste de certificado sem aula.');

-- ⚠️ Tenta gerar o certificado (ISSO DEVE FALHAR devido à falta de progresso na aula)
-- Assumindo aluno_id 2, curso_id 1
INSERT INTO certificados (aluno_id, curso_id, data_emissao, codigo_validacao)
VALUES (2, 1, CURRENT_DATE, 'CERT-ERRO-AULA-FIXED');

-- Para verificar o resultado (esta consulta deve retornar 0 linhas se o gatilho funcionar):
SELECT * FROM certificados WHERE aluno_id = 2 AND curso_id = 1;
