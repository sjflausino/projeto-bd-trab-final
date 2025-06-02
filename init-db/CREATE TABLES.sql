-- Criação das tabelas principais para a Plataforma de Cursos Online

-- Tabela base: usuarios
CREATE TABLE usuarios (
    usuario_id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('aluno', 'professor', 'administrador')),
    data_cadastro DATE DEFAULT CURRENT_DATE
);

-- Especialização: alunos
CREATE TABLE alunos (
    aluno_id INT PRIMARY KEY REFERENCES usuarios(usuario_id),
    data_nascimento DATE,
    telefone VARCHAR(20)
);

-- Especialização: professores
CREATE TABLE professores (
    professor_id INT PRIMARY KEY REFERENCES usuarios(usuario_id),
    curriculo TEXT,
    especialidade VARCHAR(100)
);

-- Especialização: administradores
CREATE TABLE administradores (
    administrador_id INT PRIMARY KEY REFERENCES usuarios(usuario_id),
    cargo VARCHAR(50),
    nivel_acesso INT CHECK (nivel_acesso BETWEEN 1 AND 5)
);

-- Categorias de curso
CREATE TABLE categorias (
    categoria_id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    descricao TEXT
);

-- Cursos
CREATE TABLE cursos (
    curso_id SERIAL PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL,
    descricao TEXT,
    categoria_id INT REFERENCES categorias(categoria_id),
    professor_id INT REFERENCES professores(professor_id),
    data_criacao DATE DEFAULT CURRENT_DATE,
    ativo BOOLEAN DEFAULT TRUE
);

-- Módulos dos cursos
CREATE TABLE modulos (
    modulo_id SERIAL PRIMARY KEY,
    curso_id INT REFERENCES cursos(curso_id),
    titulo VARCHAR(100) NOT NULL,
    ordem INT NOT NULL
);

-- Aulas dos módulos
CREATE TABLE aulas (
    aula_id SERIAL PRIMARY KEY,
    modulo_id INT REFERENCES modulos(modulo_id),
    titulo VARCHAR(100) NOT NULL,
    descricao TEXT,
    video_url TEXT,
    ordem INT NOT NULL
);

-- Inscrições de alunos nos cursos
CREATE TABLE inscricoes (
    inscricao_id SERIAL PRIMARY KEY,
    aluno_id INT REFERENCES alunos(aluno_id),
    curso_id INT REFERENCES cursos(curso_id),
    status VARCHAR(20) CHECK (status IN ('em andamento', 'concluido', 'cancelado')),
    data_inscricao DATE DEFAULT CURRENT_DATE
);

-- Progresso do aluno nas aulas
CREATE TABLE progresso (
    progresso_id SERIAL PRIMARY KEY,
    aula_id INT REFERENCES aulas(aula_id),
    aluno_id INT REFERENCES alunos(aluno_id),
    assistido BOOLEAN DEFAULT FALSE,
    data_visualizacao DATE
);

-- Certificados de conclusão
CREATE TABLE certificados (
    certificado_id SERIAL PRIMARY KEY,
    aluno_id INT REFERENCES alunos(aluno_id),
    curso_id INT REFERENCES cursos(curso_id),
    data_emissao DATE DEFAULT CURRENT_DATE,
    codigo_validacao VARCHAR(100) UNIQUE NOT NULL
);

-- Avaliações de cursos pelos alunos
CREATE TABLE avaliacoes (
    avaliacao_id SERIAL PRIMARY KEY,
    aluno_id INT REFERENCES alunos(aluno_id),
    curso_id INT REFERENCES cursos(curso_id),
    nota INT CHECK (nota BETWEEN 1 AND 5),
    comentario TEXT,
    data_avaliacao DATE DEFAULT CURRENT_DATE
);

-- Fóruns por curso
CREATE TABLE foruns (
    forum_id SERIAL PRIMARY KEY,
    curso_id INT REFERENCES cursos(curso_id),
    titulo VARCHAR(100) NOT NULL,
    data_criacao DATE DEFAULT CURRENT_DATE
);

-- Postagens nos fóruns
CREATE TABLE postagens (
    postagem_id SERIAL PRIMARY KEY,
    forum_id INT REFERENCES foruns(forum_id),
    usuario_id INT REFERENCES usuarios(usuario_id),
    conteudo TEXT NOT NULL,
    data_postagem DATE DEFAULT CURRENT_DATE
);

-- Comentários nas postagens
CREATE TABLE comentarios (
    comentario_id SERIAL PRIMARY KEY,
    postagem_id INT REFERENCES postagens(postagem_id),
    usuario_id INT REFERENCES usuarios(usuario_id),
    conteudo TEXT NOT NULL,
    data_comentario DATE DEFAULT CURRENT_DATE
);

-- Monitores (alunos que concluíram o curso e ajudam outros)
CREATE TABLE monitores (
    monitor_id SERIAL PRIMARY KEY,
    aluno_id INT REFERENCES alunos(aluno_id),
    curso_id INT REFERENCES cursos(curso_id),
    data_inicio DATE NOT NULL,
    data_fim DATE
);
