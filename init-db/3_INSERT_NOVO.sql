-- ================================
-- NOVOS USUÁRIOS (ALUNOS E PROF.)
-- ================================
INSERT INTO usuarios (nome, email, senha, tipo) VALUES
('Joana Oliveira', 'joana@example.com', 'senha123', 'aluno'),   -- ID 10
('Luciano Mendes', 'luciano@example.com', 'senha123', 'aluno'), -- ID 11
('Patrícia Gomes', 'patricia@example.com', 'senha123', 'professor'), -- ID 12
('Rafael Torres', 'rafael@example.com', 'senha123', 'aluno'),   -- ID 13
('Marina Rocha', 'marina@example.com', 'senha123', 'aluno');    -- ID 14

-- ALUNOS
INSERT INTO alunos (aluno_id, data_nascimento, telefone) VALUES
(10, '2000-01-01', '(21) 90000-0001'),
(11, '1999-04-15', '(21) 90000-0002'),
(13, '1998-07-22', '(21) 90000-0003'),
(14, '2001-11-10', '(21) 90000-0004');

-- PROFESSOR
INSERT INTO professores (professor_id, curriculo, especialidade) VALUES
(12, 'Especialista em SEO e Marketing', 'Marketing Digital');

-- NOVOS CURSOS
INSERT INTO cursos (titulo, descricao, categoria_id, professor_id) VALUES
('Google Ads Avançado', 'Curso sobre estratégias de campanhas e otimização.', 3, 12), -- ID 5
('Figma para UX Design', 'Aprenda a prototipar e criar interfaces.', 2, 6);           -- ID 6

-- INSCRIÇÕES
INSERT INTO inscricoes (aluno_id, curso_id, status) VALUES
(10, 1, 'em andamento'),
(11, 1, 'concluido'),
(11, 2, 'concluido'),
(13, 3, 'em andamento'),
(14, 3, 'cancelado'),
(13, 5, 'concluido');

-- PROGRESSO
INSERT INTO progresso (aula_id, aluno_id, assistido, data_visualizacao) VALUES
(1, 10, TRUE, CURRENT_DATE - INTERVAL '5 days'),
(2, 10, TRUE, CURRENT_DATE - INTERVAL '4 days'),
(3, 11, TRUE, CURRENT_DATE - INTERVAL '2 days'),
(4, 13, TRUE, CURRENT_DATE - INTERVAL '1 days'),
(6, 13, FALSE, NULL);

-- AVALIAÇÕES
INSERT INTO avaliacoes (aluno_id, curso_id, nota, comentario) VALUES
(11, 1, 4, 'Muito bom conteúdo.'),
(11, 2, 5, 'Excelente professor e materiais.'),
(13, 3, 3, 'Bom, mas poderia ter mais exemplos.'),
(13, 5, 5, 'Curso completo e bem explicado.');

-- CERTIFICADOS (Datas variadas para a consulta mensal)
INSERT INTO certificados (aluno_id, curso_id, data_emissao, codigo_validacao) VALUES
(11, 1, '2025-01-15', 'CERT-LUCIANO-001'),
(11, 2, '2025-02-10', 'CERT-LUCIANO-002'),
(13, 5, '2025-03-05', 'CERT-RAFAEL-001');

-- MONITORES
INSERT INTO monitores (aluno_id, curso_id, data_inicio) VALUES
(11, 1, CURRENT_DATE - INTERVAL '20 days'),
(13, 3, CURRENT_DATE - INTERVAL '15 days');

-- MENSAGENS (Exemplo com Eduardo ID 5 e Fernanda ID 6 já existentes)
INSERT INTO mensagens (remetente_id, destinatario_id, conteudo, data_envio) VALUES
(5, 6, 'Você tem alguma sugestão de livro sobre SEO?', '2025-06-01 09:00:00'),
(6, 5, 'Sim, o “SEO 2025” é excelente.', '2025-06-01 10:00:00'),
(5, 6, 'Obrigado! Vou procurar.', '2025-06-01 11:00:00'),
(6, 5, 'Qualquer dúvida, me avise.', '2025-06-01 12:00:00');


-- =============================================
-- INSERÇÃO DE NOVOS USUÁRIOS (Alunos e Professores)
-- =============================================
INSERT INTO usuarios (nome, email, senha, tipo) VALUES
('Bruna Nogueira', 'bruna@example.com', 'senha123', 'aluno'),         -- ID 15
('Caio Barbosa', 'caio@example.com', 'senha123', 'aluno'),            -- ID 16
('Diego Martins', 'diego@example.com', 'senha123', 'professor'),      -- ID 17
('Elaine Ferreira', 'elaine@example.com', 'senha123', 'professor'),   -- ID 18
('Fabiana Azevedo', 'fabiana@example.com', 'senha123', 'aluno'),      -- ID 19
('Heitor Ramos', 'heitor@example.com', 'senha123', 'aluno');          -- ID 20

-- =============================================
-- INSERÇÃO DE DADOS NA TABELA ALUNOS
-- =============================================
INSERT INTO alunos (aluno_id, data_nascimento, telefone) VALUES
(15, '1997-03-05', '(21) 91111-1001'),
(16, '2002-06-14', '(21) 92222-1002'),
(19, '2001-10-30', '(21) 93333-1003'),
(20, '1999-01-22', '(21) 94444-1004');

-- =============================================
-- INSERÇÃO DE DADOS NA TABELA PROFESSORES
-- =============================================
INSERT INTO professores (professor_id, curriculo, especialidade) VALUES
(17, 'Mestre em Banco de Dados pela UFMG', 'Banco de Dados'),
(18, 'Especialista em Experiência do Usuário', 'UX/UI Design');

-- =============================================
-- INSCRIÇÕES EM CURSOS (status variados)
-- =============================================
INSERT INTO inscricoes (aluno_id, curso_id, status) VALUES
(15, 1, 'em andamento'),     -- Bruna no curso HTML
(16, 2, 'concluido'),        -- Caio no curso de Design
(19, 3, 'concluido'),        -- Fabiana no curso de SEO
(20, 4, 'em andamento'),     -- Heitor no curso de JavaScript
(15, 5, 'cancelado'),        -- Bruna no curso de Google Ads
(16, 6, 'em andamento');     -- Caio no curso de Figma

-- =============================================
-- PROGRESSO DOS ALUNOS NAS AULAS
-- =============================================
INSERT INTO progresso (aula_id, aluno_id, assistido, data_visualizacao) VALUES
(1, 15, TRUE, CURRENT_DATE - INTERVAL '3 days'),  -- Bruna viu aula de HTML
(2, 15, TRUE, CURRENT_DATE - INTERVAL '2 days'),
(3, 16, TRUE, CURRENT_DATE - INTERVAL '5 days'),  -- Caio viu aula de Design
(4, 19, TRUE, CURRENT_DATE - INTERVAL '1 days'),  -- Fabiana viu aula de SEO
(6, 20, FALSE, NULL);                             -- Heitor não viu aula DOM

-- =============================================
-- AVALIAÇÕES DOS CURSOS PELOS ALUNOS
-- =============================================
INSERT INTO avaliacoes (aluno_id, curso_id, nota, comentario) VALUES
(16, 2, 5, 'Design explicado com clareza e bons exemplos.'),
(19, 3, 4, 'Muito bom, conteúdo útil.'),
(15, 1, 3, 'Achei um pouco rápido demais.'),
(20, 4, 5, 'Excelente conteúdo de JavaScript!'),
(16, 6, 5, 'Figma bem explorado, recomendo.');

-- =============================================
-- CERTIFICADOS EMITIDOS
-- =============================================
INSERT INTO certificados (aluno_id, curso_id, data_emissao, codigo_validacao) VALUES
(16, 2, '2025-04-15', 'CERT-CAIO-001'),
(19, 3, '2025-04-20', 'CERT-FABIANA-001'),
(16, 6, '2025-05-01', 'CERT-CAIO-002');

-- =============================================
-- MONITORES DESIGNADOS
-- =============================================
INSERT INTO monitores (aluno_id, curso_id, data_inicio) VALUES
(19, 3, CURRENT_DATE - INTERVAL '10 days'),  -- Fabiana monitora SEO
(16, 6, CURRENT_DATE - INTERVAL '8 days');   -- Caio monitora Figma

-- =============================================
-- MENSAGENS ENTRE USUÁRIOS
-- =============================================
INSERT INTO mensagens (remetente_id, destinatario_id, conteudo, data_envio) VALUES
(16, 17, 'Professor, qual será o conteúdo da próxima aula?', '2025-06-20 09:00:00'),
(17, 16, 'Vamos abordar consultas com JOINs.', '2025-06-20 10:00:00'),
(16, 17, 'Obrigado, estarei preparado!', '2025-06-20 10:15:00');

-- =============================================
-- FÓRUNS, POSTAGENS E COMENTÁRIOS ADICIONAIS
-- =============================================
INSERT INTO foruns (curso_id, titulo) VALUES
(6, 'Figma - Dúvidas e dicas');

INSERT INTO postagens (forum_id, usuario_id, conteudo) VALUES
(5, 16, 'Qual shortcut vocês usam mais no Figma?'),
(5, 18, 'Como melhorar a hierarquia visual em UI?');

INSERT INTO comentarios (postagem_id, usuario_id, conteudo) VALUES
(5, 6, 'Uso muito Shift + A para auto layout.'),
(6, 17, 'Pense sempre em contraste e espaçamento.');
