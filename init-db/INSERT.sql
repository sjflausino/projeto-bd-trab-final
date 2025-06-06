-- Usuários
INSERT INTO usuarios (nome, email, senha, tipo) VALUES
('Alice Souza', 'alice@example.com', 'senha123', 'aluno'),
('Bruno Lima', 'bruno@example.com', 'senha123', 'aluno'),
('Carla Mendes', 'carla@example.com', 'senha123', 'professor'),
('Daniel Rocha', 'daniel@example.com', 'senha123', 'administrador');

-- Alunos
INSERT INTO alunos (aluno_id, data_nascimento, telefone) VALUES
(1, '2000-05-12', '(21) 99999-1111'),
(2, '1998-08-30', '(11) 98888-2222');

-- Professores
INSERT INTO professores (professor_id, curriculo, especialidade) VALUES
(3, 'Mestre em Educação pela UFRJ', 'Tecnologia Educacional');

-- Administradores
INSERT INTO administradores (administrador_id, cargo, nivel_acesso) VALUES
(4, 'Coordenador de Plataforma', 4);

-- Categorias
INSERT INTO categorias (nome, descricao) VALUES
('Programação', 'Cursos voltados para programação de sistemas e web'),
('Design', 'Cursos de design gráfico, UX/UI e similares');

-- Cursos
INSERT INTO cursos (titulo, descricao, categoria_id, professor_id) VALUES
('Introdução ao HTML', 'Curso básico para iniciantes em desenvolvimento web.', 1, 3),
('Design para Iniciantes', 'Conceitos básicos de design e estética visual.', 2, 3);

-- Módulos
INSERT INTO modulos (curso_id, titulo, ordem) VALUES
(1, 'Módulo 1: Fundamentos do HTML', 1),
(2, 'Módulo 1: Conceitos Visuais', 1);

-- Aulas
INSERT INTO aulas (modulo_id, titulo, descricao, video_url, ordem) VALUES
(1, 'Aula 1: O que é HTML?', 'Introdução ao HTML e suas aplicações.', 'https://video.example.com/html1', 1),
(1, 'Aula 2: Estrutura Básica', 'Como montar a estrutura de um HTML.', 'https://video.example.com/html2', 2),
(2, 'Aula 1: Princípios de Design', 'Teoria das cores, formas e tipografia.', 'https://video.example.com/design1', 1);

-- Inscrições
INSERT INTO inscricoes (aluno_id, curso_id, status) VALUES
(1, 1, 'em andamento'),
(2, 2, 'em andamento');

-- Progresso
INSERT INTO progresso (aula_id, aluno_id, assistido, data_visualizacao) VALUES
(1, 1, TRUE, CURRENT_DATE),
(2, 1, TRUE, CURRENT_DATE),
(3, 1, TRUE, CURRENT_DATE),
(2, 1, FALSE, NULL),
(3, 2, TRUE, CURRENT_DATE);

-- Certificados
INSERT INTO certificados (aluno_id, curso_id, data_emissao, codigo_validacao) VALUES
(1, 1, CURRENT_DATE, 'CERT-ALICE-001');

-- Avaliações
INSERT INTO avaliacoes (aluno_id, curso_id, nota, comentario) VALUES
(1, 1, 5, 'Excelente curso! Recomendo.'),
(2, 2, 4, 'Muito bom, mas poderia ter mais exemplos.');

-- Fóruns
INSERT INTO foruns (curso_id, titulo) VALUES
(1, 'Dúvidas sobre HTML'),
(2, 'Discussões sobre Design');

-- Postagens
INSERT INTO postagens (forum_id, usuario_id, conteudo) VALUES
(1, 1, 'Estou com dúvida sobre tags semânticas.'),
(2, 2, 'Qual ferramenta vocês usam para design?');

-- Comentários
INSERT INTO comentarios (postagem_id, usuario_id, conteudo) VALUES
(1, 3, 'Use <section>, <article> e <aside> para dar significado ao conteúdo.'),
(2, 3, 'Figma é uma excelente ferramenta gratuita.');

-- Monitores
INSERT INTO monitores (aluno_id, curso_id, data_inicio) VALUES
(1, 1, CURRENT_DATE);

-- Mensagens
INSERT INTO mensagens (remetente_id, destinatario_id, conteudo) VALUES
(1, 3, 'Professor, poderia revisar minha atividade?'),
(3, 1, 'Claro, vou verificar ainda hoje.');

-- Novos Usuários
INSERT INTO usuarios (nome, email, senha, tipo) VALUES
('Eduardo Santos', 'eduardo@example.com', 'senha123', 'aluno'),
('Fernanda Costa', 'fernanda@example.com', 'senha123', 'professor'),
('Gustavo Almeida', 'gustavo@example.com', 'senha123', 'administrador');

-- Novos Alunos
INSERT INTO alunos (aluno_id, data_nascimento, telefone) VALUES
(5, '1995-12-20', '(31) 97777-3333');

-- Novos Professores
INSERT INTO professores (professor_id, curriculo, especialidade) VALUES
(6, 'Doutora em Design pela PUC-SP', 'Design Gráfico');

-- Novos Administradores
INSERT INTO administradores (administrador_id, cargo, nivel_acesso) VALUES
(7, 'Gerente de TI', 5);

-- Novas Categorias
INSERT INTO categorias (nome, descricao) VALUES
('Marketing Digital', 'Cursos sobre estratégias e ferramentas de marketing online');

-- Novos Cursos
INSERT INTO cursos (titulo, descricao, categoria_id, professor_id) VALUES
('SEO para Iniciantes', 'Aprenda os fundamentos de SEO para melhorar seu site.', 3, 6),
('JavaScript Básico', 'Introdução à linguagem de programação JavaScript.', 1, 3);

-- Novos Módulos
INSERT INTO modulos (curso_id, titulo, ordem) VALUES
(3, 'Módulo 1: Fundamentos de SEO', 1),
(4, 'Módulo 1: Conceitos Básicos de JavaScript', 1),
(4, 'Módulo 2: Manipulação do DOM', 2);

-- Novas Aulas
INSERT INTO aulas (modulo_id, titulo, descricao, video_url, ordem) VALUES
(3, 'Aula 1: O que é SEO?', 'Introdução aos conceitos básicos de SEO.', 'https://video.example.com/seo1', 1),
(4, 'Aula 1: Variáveis e Tipos', 'Aprenda sobre variáveis em JavaScript.', 'https://video.example.com/js1', 1),
(5, 'Aula 1: Manipulando Elementos', 'Como usar JavaScript para alterar o DOM.', 'https://video.example.com/js2', 1);

-- Novas Inscrições
INSERT INTO inscricoes (aluno_id, curso_id, status) VALUES
(5, 3, 'em andamento'),
(1, 4, 'em andamento');

-- Novo Progresso
INSERT INTO progresso (aula_id, aluno_id, assistido, data_visualizacao) VALUES
(4, 5, TRUE, CURRENT_DATE),
(6, 1, FALSE, NULL);

-- Novos Certificados
INSERT INTO certificados (aluno_id, curso_id, data_emissao, codigo_validacao) VALUES
(5, 3, CURRENT_DATE, 'CERT-EDUARDO-001');

-- Novas Avaliações
INSERT INTO avaliacoes (aluno_id, curso_id, nota, comentario) VALUES
(5, 3, 5, 'Conteúdo muito relevante para iniciantes.'),
(1, 4, 4, 'Gostei, mas faltou exercícios práticos.');

-- Novos Fóruns
INSERT INTO foruns (curso_id, titulo) VALUES
(3, 'Dúvidas sobre SEO'),
(4, 'Discussões sobre JavaScript');

-- Novas Postagens
INSERT INTO postagens (forum_id, usuario_id, conteudo) VALUES
(3, 5, 'Qual a melhor ferramenta para análise de palavras-chave?'),
(4, 1, 'Como faço para manipular eventos no DOM?');

-- Novos Comentários
INSERT INTO comentarios (postagem_id, usuario_id, conteudo) VALUES
(3, 6, 'Recomendo o Google Keyword Planner para começar.'),
(4, 3, 'Você pode usar addEventListener para eventos.');

-- Novos Monitores
INSERT INTO monitores (aluno_id, curso_id, data_inicio) VALUES
(5, 3, CURRENT_DATE),
(1, 1, CURRENT_DATE);




-- Novas Mensagens
INSERT INTO mensagens (remetente_id, destinatario_id, conteudo) VALUES
(5, 6, 'Professora, poderia indicar materiais extras de SEO?'),
(6, 5, 'Claro, vou enviar por e-mail hoje.');


