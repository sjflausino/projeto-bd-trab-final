-- ==================================================================
-- Criação das tabelas principais para a Plataforma de Cursos Online
-- ==================================================================

CREATE TABLE usuarios (
    usuario_id SERIAL,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('aluno', 'professor', 'administrador')),
    data_cadastro DATE DEFAULT CURRENT_DATE,
    CONSTRAINT pk_usuarios PRIMARY KEY (usuario_id)
);

CREATE TABLE alunos (
    aluno_id INT,
    data_nascimento DATE,
    telefone VARCHAR(20),
    CONSTRAINT pk_alunos PRIMARY KEY (aluno_id),
    CONSTRAINT fk_aluno_usuario FOREIGN KEY (aluno_id) REFERENCES usuarios(usuario_id)
);

CREATE TABLE professores (
    professor_id INT,
    curriculo TEXT,
    especialidade VARCHAR(100),
    CONSTRAINT pk_professores PRIMARY KEY (professor_id),
    CONSTRAINT fk_professor_usuario FOREIGN KEY (professor_id) REFERENCES usuarios(usuario_id)
);

CREATE TABLE administradores (
    administrador_id INT,
    cargo VARCHAR(50),
    nivel_acesso INT CHECK (nivel_acesso BETWEEN 1 AND 5),
    CONSTRAINT pk_administradores PRIMARY KEY (administrador_id),
    CONSTRAINT fk_administrador_usuario FOREIGN KEY (administrador_id) REFERENCES usuarios(usuario_id)
);

CREATE TABLE categorias (
    categoria_id SERIAL,
    nome VARCHAR(50) NOT NULL,
    descricao TEXT,
    CONSTRAINT pk_categorias PRIMARY KEY (categoria_id)
);

CREATE TABLE cursos (
    curso_id SERIAL,
    titulo VARCHAR(100) NOT NULL,
    descricao TEXT,
    categoria_id INT,
    professor_id INT,
    data_criacao DATE DEFAULT CURRENT_DATE,
    ativo BOOLEAN DEFAULT TRUE,
    CONSTRAINT pk_cursos PRIMARY KEY (curso_id),
    CONSTRAINT fk_curso_categoria FOREIGN KEY (categoria_id) REFERENCES categorias(categoria_id),
    CONSTRAINT fk_curso_professor FOREIGN KEY (professor_id) REFERENCES professores(professor_id)
);

CREATE TABLE modulos (
    modulo_id SERIAL,
    curso_id INT,
    titulo VARCHAR(100) NOT NULL,
    ordem INT NOT NULL,
    CONSTRAINT pk_modulos PRIMARY KEY (modulo_id),
    CONSTRAINT fk_modulo_curso FOREIGN KEY (curso_id) REFERENCES cursos(curso_id)
);

CREATE TABLE aulas (
    aula_id SERIAL,
    modulo_id INT,
    titulo VARCHAR(100) NOT NULL,
    descricao TEXT,
    video_url TEXT,
    ordem INT NOT NULL,
    CONSTRAINT pk_aulas PRIMARY KEY (aula_id),
    CONSTRAINT fk_aula_modulo FOREIGN KEY (modulo_id) REFERENCES modulos(modulo_id)
);

CREATE TABLE inscricoes (
    inscricao_id SERIAL,
    aluno_id INT,
    curso_id INT,
    status VARCHAR(20) CHECK (status IN ('em andamento', 'concluido', 'cancelado')),
    data_inscricao DATE DEFAULT CURRENT_DATE,
    CONSTRAINT pk_inscricoes PRIMARY KEY (inscricao_id, aluno_id, curso_id),
    CONSTRAINT fk_inscricao_aluno FOREIGN KEY (aluno_id) REFERENCES alunos(aluno_id),
    CONSTRAINT fk_inscricao_curso FOREIGN KEY (curso_id) REFERENCES cursos(curso_id)
);

CREATE TABLE progresso (
    progresso_id SERIAL,
    aula_id INT,
    aluno_id INT,
    assistido BOOLEAN DEFAULT FALSE,
    data_visualizacao DATE,
    CONSTRAINT pk_progresso PRIMARY KEY (progresso_id, aula_id, aluno_id),
    CONSTRAINT fk_progresso_aula FOREIGN KEY (aula_id) REFERENCES aulas(aula_id),
    CONSTRAINT fk_progresso_aluno FOREIGN KEY (aluno_id) REFERENCES alunos(aluno_id)
);

CREATE TABLE certificados (
    certificado_id SERIAL,
    aluno_id INT,
    curso_id INT,
    data_emissao DATE DEFAULT CURRENT_DATE,
    codigo_validacao VARCHAR(100) UNIQUE NOT NULL,
    CONSTRAINT pk_certificados PRIMARY KEY (certificado_id, aluno_id, curso_id),
    CONSTRAINT fk_certificado_aluno FOREIGN KEY (aluno_id) REFERENCES alunos(aluno_id),
    CONSTRAINT fk_certificado_curso FOREIGN KEY (curso_id) REFERENCES cursos(curso_id)
);

CREATE TABLE avaliacoes (
    avaliacao_id SERIAL,
    aluno_id INT,
    curso_id INT,
    nota INT CHECK (nota BETWEEN 1 AND 5),
    comentario TEXT,
    data_avaliacao DATE DEFAULT CURRENT_DATE,
    CONSTRAINT pk_avaliacoes PRIMARY KEY (avaliacao_id, aluno_id, curso_id),
    CONSTRAINT fk_avaliacao_aluno FOREIGN KEY (aluno_id) REFERENCES alunos(aluno_id),
    CONSTRAINT fk_avaliacao_curso FOREIGN KEY (curso_id) REFERENCES cursos(curso_id)
);

CREATE TABLE foruns (
    forum_id SERIAL,
    curso_id INT,
    titulo VARCHAR(100) NOT NULL,
    data_criacao DATE DEFAULT CURRENT_DATE,
    CONSTRAINT pk_foruns PRIMARY KEY (forum_id),
    CONSTRAINT fk_forum_curso FOREIGN KEY (curso_id) REFERENCES cursos(curso_id)
);

CREATE TABLE postagens (
    postagem_id SERIAL,
    forum_id INT,
    usuario_id INT,
    conteudo TEXT NOT NULL,
    data_postagem DATE DEFAULT CURRENT_DATE,
    CONSTRAINT pk_postagens PRIMARY KEY (postagem_id),
    CONSTRAINT fk_postagem_forum FOREIGN KEY (forum_id) REFERENCES foruns(forum_id),
    CONSTRAINT fk_postagem_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id)
);

CREATE TABLE comentarios (
    comentario_id SERIAL,
    postagem_id INT,
    usuario_id INT,
    conteudo TEXT NOT NULL,
    data_comentario DATE DEFAULT CURRENT_DATE,
    CONSTRAINT pk_comentarios PRIMARY KEY (comentario_id, postagem_id, usuario_id),
    CONSTRAINT fk_comentario_postagem FOREIGN KEY (postagem_id) REFERENCES postagens(postagem_id),
    CONSTRAINT fk_comentario_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id)
);

CREATE TABLE monitores (
    aluno_id INT,
    curso_id INT,
    data_inicio DATE NOT NULL,
    data_fim DATE,
    CONSTRAINT pk_monitores PRIMARY KEY (aluno_id, curso_id),
    CONSTRAINT fk_monitor_aluno FOREIGN KEY (aluno_id) REFERENCES alunos(aluno_id),
    CONSTRAINT fk_monitor_curso FOREIGN KEY (curso_id) REFERENCES cursos(curso_id)
);

CREATE TABLE mensagens (
    mensagem_id SERIAL,
    remetente_id INT,
    destinatario_id INT,
    conteudo TEXT NOT NULL,
    data_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    lida BOOLEAN DEFAULT FALSE,
    CONSTRAINT pk_mensagens PRIMARY KEY (mensagem_id, remetente_id, destinatario_id),
    CONSTRAINT fk_mensagem_remetente FOREIGN KEY (remetente_id) REFERENCES usuarios(usuario_id) ON DELETE CASCADE,
    CONSTRAINT fk_mensagem_destinatario FOREIGN KEY (destinatario_id) REFERENCES usuarios(usuario_id) ON DELETE CASCADE
);
