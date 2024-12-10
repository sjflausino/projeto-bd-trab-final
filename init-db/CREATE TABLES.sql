CREATE TABLE passageiros (
    id PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE,
    telefone VARCHAR(15),
    email VARCHAR(100),
    data_nascimento DATE
);

CREATE TABLE motoristas (
    id PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE,
    cnh VARCHAR(20) NOT NULL,
    telefone VARCHAR(15),
    data_admissao DATE NOT NULL
);

CREATE TABLE onibus (
    id PRIMARY KEY,
    placa VARCHAR(10) UNIQUE,
    modelo VARCHAR(50),
    capacidade INT NOT NULL,
    status VARCHAR(20) NOT NULL,
    ano_fabricacao INT NOT NULL
);

CREATE TABLE rotas (
    id PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    origem VARCHAR(100) NOT NULL,
    destino VARCHAR(100) NOT NULL,
    distancia NUMERIC(10, 2),
    tempo_estimado INTERVAL
);

CREATE TABLE paradas (
    id PRIMARY KEY,
    rota_id INT NOT NULL,
    nome_parada VARCHAR(100) NOT NULL,
    ordem INT NOT NULL,
    FOREIGN KEY (rota_id) REFERENCES rotas (id) ON DELETE CASCADE
);

CREATE TABLE viagens (
    id PRIMARY KEY,
    rota_id INT NOT NULL,
    onibus_id INT,
    motorista_id INT,
    data_partida TIMESTAMP NOT NULL,
    data_chegada TIMESTAMP,
    FOREIGN KEY (rota_id) REFERENCES rotas (id) ON DELETE CASCADE,
    FOREIGN KEY (onibus_id) REFERENCES onibus (id) ON DELETE SET NULL,
    FOREIGN KEY (motorista_id) REFERENCES motoristas (id) ON DELETE SET NULL
);

CREATE TABLE bilhetes (
    id PRIMARY KEY,
    passageiro_id INT NOT NULL,
    viagem_id INT NOT NULL,
    assento INT NOT NULL,
    preco NUMERIC(10, 2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    FOREIGN KEY (passageiro_id) REFERENCES passageiros (id) ON DELETE CASCADE,
    FOREIGN KEY (viagem_id) REFERENCES viagens (id) ON DELETE CASCADE
);

CREATE TABLE pagamentos (
    id PRIMARY KEY,
    bilhete_id INT NOT NULL,
    data_pagamento TIMESTAMP NOT NULL,
    valor NUMERIC(10, 2) NOT NULL,
    metodo_pagamento VARCHAR(50) NOT NULL,
    FOREIGN KEY (bilhete_id) REFERENCES bilhetes (id) ON DELETE CASCADE
);

CREATE TABLE manutencoes (
    id PRIMARY KEY,
    onibus_id INT NOT NULL,
    data_manutencao DATE NOT NULL,
    descricao TEXT NOT NULL,
    custo NUMERIC(10, 2),
    FOREIGN KEY (onibus_id) REFERENCES onibus (id) ON DELETE CASCADE
);

CREATE TABLE funcionarios (
    id PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE,
    cargo VARCHAR(50),
    data_admissao DATE NOT NULL,
    salario NUMERIC(10, 2)
);

CREATE TABLE usuarios_sistema (
    id PRIMARY KEY,
    funcionario_id INT NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    nivel_acesso VARCHAR(20) NOT NULL,
    FOREIGN KEY (funcionario_id) REFERENCES funcionarios (id) ON DELETE CASCADE
);

CREATE TABLE horarios_rotas (
    id PRIMARY KEY,
    rota_id INT NOT NULL,
    horario_partida TIME NOT NULL,
    horario_chegada TIME NOT NULL,
    FOREIGN KEY (rota_id) REFERENCES rotas (id) ON DELETE CASCADE
);

CREATE TABLE reclamacoes (
    id PRIMARY KEY,
    passageiro_id INT NOT NULL,
    data_reclamacao TIMESTAMP NOT NULL,
    descricao TEXT NOT NULL,
    FOREIGN KEY (passageiro_id) REFERENCES passageiros (id) ON DELETE CASCADE
);

CREATE TABLE avaliacoes (
    id PRIMARY KEY,
    bilhete_id INT NOT NULL,
    nota INT CHECK (nota BETWEEN 1 AND 5),
    comentario TEXT,
    FOREIGN KEY (bilhete_id) REFERENCES bilhetes (id) ON DELETE CASCADE
);

CREATE TABLE gps_localizacao (
    id PRIMARY KEY,
    onibus_id INT NOT NULL,
    latitude NUMERIC(10, 6) NOT NULL,
    longitude NUMERIC(10, 6) NOT NULL,
    data_horario TIMESTAMP NOT NULL,
    FOREIGN KEY (onibus_id) REFERENCES onibus (id) ON DELETE CASCADE
);
