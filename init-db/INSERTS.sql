

-- Tabela passageiros
INSERT INTO passageiros (nome, cpf, telefone, email, data_nascimento)
VALUES
    ('Carlos Silva', '123.456.789-01', '21999999999', 'carlos.silva@example.com', '1985-04-15'),
    ('Ana Paula', '987.654.321-02', '21988888888', 'ana.paula@example.com', '1992-11-23'),
    ('Marcos Ferreira', '456.789.123-03', '21977777777', 'marcos.ferreira@example.com', '1978-06-09'),
    ('Beatriz Souza', '654.321.987-04', '21966666666', 'beatriz.souza@example.com', '2000-03-30'),
    ('João Mendes', '321.654.987-05', '21955555555', 'joao.mendes@example.com', '1995-09-12');

-- Tabela motoristas
INSERT INTO motoristas (nome, cpf, cnh, telefone, data_admissao)
VALUES
    ('José Oliveira', '741.852.963-10', 'CNH123456789', '21944444444', '2018-05-10'),
    ('Maria Pereira', '963.852.741-11', 'CNH987654321', '21933333333', '2015-02-20');

-- Tabela onibus
INSERT INTO onibus (placa, modelo, capacidade, status, ano_fabricacao)
VALUES
    ('ABC1D23', 'Mercedes-Benz O500', 45, 'Ativo', 2015),
    ('EFG4H56', 'Volkswagen 17.260', 42, 'Ativo', 2018),
    ('IJK7L89', 'Volvo B270F', 50, 'Ativo', 2020);

-- Tabela rotas
INSERT INTO rotas (nome, origem, destino, distancia, tempo_estimado) 
VALUES
    ('Centro - Alcântara', 'Centro de São Gonçalo', 'Alcântara', 8.0, '00:25:00'),
    ('Alcântara - Neves', 'Alcântara', 'Neves', 6.0, '00:20:00'),
    ('Centro - Tribobó', 'Centro de São Gonçalo', 'Tribobó', 12.0, '00:35:00'),
    ('Neves - Gradim', 'Neves', 'Gradim', 4.5, '00:15:00'),
    ('Alcântara - Jardim Catarina', 'Alcântara', 'Jardim Catarina', 10.0, '00:30:00'),
    ('Jardim Catarina - Guaxindiba', 'Jardim Catarina', 'Guaxindiba', 7.0, '00:20:00'),
    ('Centro - Guaxindiba', 'Centro de São Gonçalo', 'Guaxindiba', 15.0, '00:45:00'),
    ('Alcântara - Colubandê', 'Alcântara', 'Colubandê', 9.0, '00:25:00'),
    ('Tribobó - Colubandê', 'Tribobó', 'Colubandê', 5.5, '00:18:00'),
    ('Centro - Itaúna', 'Centro de São Gonçalo', 'Itaúna', 10.5, '00:30:00');    

-- Tabela viagens
INSERT INTO viagens (rota_id, onibus_id, motorista_id, data_partida, data_chegada)
VALUES
    (1, 1, 1, '2024-12-10 08:00:00', '2024-12-10 08:25:00'),
    (2, 2, 2, '2024-12-10 09:00:00', '2024-12-10 09:20:00'),
    (3, 3, 1, '2024-12-10 10:00:00', '2024-12-10 10:35:00'),
    (4, 1, 2, '2024-12-10 11:00:00', '2024-12-10 11:15:00'),
    (5, 2, 1, '2024-12-10 12:00:00', '2024-12-10 12:30:00');

-- Tabela bilhetes
INSERT INTO bilhetes (passageiro_id, viagem_id, assento, preco, status)
VALUES
    (1, 1, 12, 4.50, 'Emitido'),
    (2, 2, 20, 3.80, 'Emitido'),
    (3, 3, 7, 5.00, 'Cancelado'),
    (4, 4, 15, 3.50, 'Emitido'),
    (5, 5, 22, 4.20, 'Emitido');

-- Tabela pagamentos
INSERT INTO pagamentos (bilhete_id, data_pagamento, valor, metodo_pagamento)
VALUES
    (1, '2024-12-09 15:00:00', 4.50, 'Cartão de Crédito'),
    (2, '2024-12-09 15:30:00', 3.80, 'PIX'),
    (4, '2024-12-09 16:00:00', 3.50, 'Cartão de Débito'),
    (5, '2024-12-09 16:30:00', 4.20, 'Dinheiro');

-- Tabela reclamacoes
INSERT INTO reclamacoes (passageiro_id, data_reclamacao, descricao)
VALUES
    (1, '2024-12-10 09:00:00', 'Atraso na partida do ônibus'),
    (3, '2024-12-10 11:00:00', 'Assento danificado'),
    (5, '2024-12-10 13:00:00', 'Motorista dirigiu muito rápido');

-- Tabela manutencoes
INSERT INTO manutencoes (onibus_id, data_manutencao, descricao, custo)
VALUES
    (1, '2024-12-01', 'Troca de pneus', 1500.00),
    (2, '2024-11-25', 'Revisão geral', 2500.00),
    (3, '2024-12-05', 'Troca de óleo e filtro', 500.00);

-- Tabela avaliacoes
INSERT INTO avaliacoes (bilhete_id, nota, comentario)
VALUES
    (1, 5, 'Excelente viagem!'),
    (2, 4, 'Ônibus confortável, mas estava lotado'),
    (4, 3, 'Viagem ok, mas atrasou um pouco');

-- Tabela gps_localizacao
INSERT INTO gps_localizacao (onibus_id, latitude, longitude, data_horario)
VALUES
    (1, -22.8265, -43.0635, '2024-12-10 08:10:00'),
    (2, -22.8260, -43.0700, '2024-12-10 09:10:00'),
    (3, -22.8250, -43.0800, '2024-12-10 10:10:00');

