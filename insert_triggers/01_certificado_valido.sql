-- CASO DE SUCESSO: Geração de certificado válida
-- ✅ Aluno assistiu todas as aulas e teve nota >= 3
-- ✅ Triggers `certificado_trigger` e `concluir_inscricao_trigger` funcionam

-- Inserir professor
INSERT INTO usuarios (nome, email, senha, tipo) VALUES
('Professor Certificado OK', 'prof1@example.com', 'senha123', 'professor') RETURNING usuario_id;
-- Suponha que retorna: 1

INSERT INTO professores (professor_id, curriculo, especialidade) VALUES
(1, 'Mestre em Validação', 'Testes');

-- Inserir categoria, curso, módulo, aula
INSERT INTO categorias (nome, descricao) VALUES ('Certificado', 'Categoria teste'); -- ID 1

INSERT INTO cursos (titulo, descricao, categoria_id, professor_id, ativo)
VALUES ('Curso Certificado', 'Teste de certificado', 1, 1, TRUE) RETURNING curso_id;
-- Suponha que retorna: 1

INSERT INTO modulos (curso_id, titulo, ordem) VALUES (1, 'Módulo Certificado', 1) RETURNING modulo_id;
-- Supõe: 1

INSERT INTO aulas (modulo_id, titulo, descricao, video_url, ordem)
VALUES (1, 'Aula Única', 'Aula de teste', 'http://teste.com', 1) RETURNING aula_id;
-- Supõe: 1

-- Inserir aluno
INSERT INTO usuarios (nome, email, senha, tipo) VALUES
('Aluno Certificado OK', 'cert1@example.com', 'senha123', 'aluno') RETURNING usuario_id;
-- Suponha: 2

INSERT INTO alunos (aluno_id, data_nascimento, telefone) VALUES
(2, '1999-01-01', '(00) 90000-1010');

-- Inscrição, progresso e avaliação
INSERT INTO inscricoes (aluno_id, curso_id, status) VALUES (2, 1, 'em andamento');

INSERT INTO progresso (aula_id, aluno_id, assistido, data_visualizacao)
VALUES (1, 2, TRUE, CURRENT_DATE);

INSERT INTO avaliacoes (aluno_id, curso_id, nota, comentario)
VALUES (2, 1, 4, 'Curso bom');

-- Gera o certificado (valida triggers)
INSERT INTO certificados (aluno_id, curso_id, data_emissao, codigo_validacao)
VALUES (2, 1, CURRENT_DATE, 'CERT-OK-001');

-- Para verificar o resultado (esta consulta deve retornar 1 linha se o gatilho funcionar):
SELECT * FROM certificados WHERE aluno_id = 2 AND curso_id = 1;
