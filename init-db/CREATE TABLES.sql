CREATE TABLE passageiros (
    cpf VARCHAR(14) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    telefone VARCHAR(15),
    email VARCHAR(100),
    data_nascimento DATE,
    PRIMARY KEY (cpf)
);

CREATE TABLE funcionarios (
    cpf VARCHAR(14) NOT NULL,
    nome VARCHAR(100) NOT NULL,
    telefone VARCHAR(15),
    data_admissao DATE NOT NULL ,
    salario NUMERIC(10, 2),
    PRIMARY KEY (cpf)          
);

CREATE TABLE motoristas (
    cpf VARCHAR(14) NOT NULL,
    cnh VARCHAR(20) NOT NULL,
    PRIMARY KEY (cpf, cnh),
    FOREIGN KEY (cpf) REFERENCES funcionarios (cpf) 
);

CREATE TABLE mecanico (
    cpf VARCHAR(14) NOT NULL,
    crea VARCHAR(9) NOT NULL,
    PRIMARY KEY (cpf, crea),
    FOREIGN KEY (cpf) REFERENCES funcionarios (cpf) 
);

CREATE TABLE onibus (
    placa VARCHAR(10),
    modelo VARCHAR(50),
    capacidade INT NOT NULL,
    status VARCHAR(20) NOT NULL,
    ano_fabricacao INT NOT NULL,
    PRIMARY KEY (placa)
);

CREATE TABLE rotas (
    id INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    origem VARCHAR(100) NOT NULL,
    destino VARCHAR(100) NOT NULL,
    distancia NUMERIC(10, 2),
    tempo_estimado INTERVAL
);

CREATE TABLE paradas (
    id INT PRIMARY KEY,
    rota_id INT NOT NULL,
    nome_parada VARCHAR(100) NOT NULL,
    ordem INT NOT NULL,
    latitude NUMERIC(10, 6) NOT NULL,
    longitude NUMERIC(10, 6) NOT NULL,
    FOREIGN KEY (rota_id) REFERENCES rotas (id) ON DELETE CASCADE
);

CREATE TABLE viagens (
    id INT PRIMARY KEY,
    rota_id INT NOT NULL,
    onibus_placa INT,
    motorista_cpf INT,
    data_partida TIMESTAMP NOT NULL,
    data_chegada TIMESTAMP,
    FOREIGN KEY (rota_id) REFERENCES rotas (id) ON DELETE CASCADE,
    FOREIGN KEY (onibus_placa) REFERENCES onibus (placa) ON DELETE SET NULL,
    FOREIGN KEY (motorista_cpf) REFERENCES motoristas (cpf) ON DELETE SET NULL
);

CREATE TABLE bilhetes (
    id INT PRIMARY KEY,
    passageiro_cpf INT NOT NULL,
    viagem_id INT NOT NULL,
    assento INT NOT NULL,
    preco NUMERIC(10, 2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    FOREIGN KEY (passageiro_cpf) REFERENCES passageiros (cpf) ON DELETE CASCADE,
    FOREIGN KEY (viagem_id) REFERENCES viagens (id) ON DELETE CASCADE
);

CREATE TABLE pagamentos (
    id INT PRIMARY KEY,
    bilhete_id INT NOT NULL,
    data_pagamento TIMESTAMP NOT NULL,
    valor NUMERIC(10, 2) NOT NULL,
    metodo_pagamento VARCHAR(50) NOT NULL,
    FOREIGN KEY (bilhete_id) REFERENCES bilhetes (id) ON DELETE CASCADE
);

CREATE TABLE manutencoes (
    id INT PRIMARY KEY,
    onibus_placa INT NOT NULL,
    data_manutencao DATE NOT NULL,
    descricao TEXT NOT NULL,
    custo NUMERIC(10, 2),
    FOREIGN KEY (onibus_placa) REFERENCES onibus (placa) ON DELETE CASCADE
);


/*
CREATE TABLE usuarios_sistema (
    id INT PRIMARY KEY,
    funcionario_id INT NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    nivel_acesso VARCHAR(20) NOT NULL,
    FOREIGN KEY (funcionario_id) REFERENCES funcionarios (id) ON DELETE CASCADE
);*/

CREATE TABLE horarios_rotas (
    id INT PRIMARY KEY,
    rota_id INT NOT NULL,
    horario_partida TIME NOT NULL,
    horario_chegada TIME NOT NULL,
    FOREIGN KEY (rota_id) REFERENCES rotas (id) ON DELETE CASCADE
);

CREATE TABLE reclamacoes (
    id INT PRIMARY KEY,
    passageiro_cpf INT NOT NULL,
    data_reclamacao TIMESTAMP NOT NULL,
    descricao TEXT NOT NULL,
    FOREIGN KEY (passageiro_cpf) REFERENCES passageiros (cpf) ON DELETE CASCADE
);

CREATE TABLE avaliacoes (
    id INT PRIMARY KEY,
    bilhete_id INT NOT NULL,
    nota INT CHECK (nota BETWEEN 1 AND 5),
    comentario TEXT,
    FOREIGN KEY (bilhete_id) REFERENCES bilhetes (id) ON DELETE CASCADE
);

CREATE TABLE gps_localizacao (
    id INT PRIMARY KEY,
    onibus_placa INT NOT NULL,
    latitude NUMERIC(10, 6) NOT NULL,
    longitude NUMERIC(10, 6) NOT NULL,
    data_horario TIMESTAMP NOT NULL,
    FOREIGN KEY (onibus_placa) REFERENCES onibus (placa) ON DELETE CASCADE
);
