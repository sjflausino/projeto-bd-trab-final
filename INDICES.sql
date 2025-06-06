
-- ==========================================================
-- CONSULTA 1: Listar todos os alunos com seus dados de contato
-- ==========================================================
-- SELECT u.usuario_id, u.nome, u.email, a.data_nascimento, a.telefone
-- FROM usuarios u
-- JOIN alunos a ON u.usuario_id = a.aluno_id;

-- Índices recomendados:
CREATE INDEX idx_usuarios_usuario_id ON usuarios (usuario_id);
-- -> Melhora o JOIN entre usuarios e alunos

CREATE INDEX idx_alunos_aluno_id ON alunos (aluno_id);
-- -> Melhora o JOIN entre alunos e usuarios

-- ==========================================================
-- CONSULTA 2: Listar os cursos com o nome do professor
-- ==========================================================
-- SELECT c.curso_id, c.titulo, c.descricao, u.nome AS professor
-- FROM cursos c
-- JOIN professores p ON c.professor_id = p.professor_id
-- JOIN usuarios u ON p.professor_id = u.usuario_id;

CREATE INDEX idx_cursos_professor_id ON cursos (professor_id);
-- -> Otimiza JOIN entre cursos e professores

CREATE INDEX idx_professores_professor_id ON professores (professor_id);
-- -> Otimiza JOIN com usuários

-- ==========================================================
-- CONSULTA 3: Ver o progresso de um aluno específico
-- ==========================================================
-- SELECT u.nome AS aluno, c.titulo AS curso, a.titulo AS aula, pr.assistido, pr.data_visualizacao
-- FROM progresso pr
-- JOIN aulas a ON pr.aula_id = a.aula_id
-- JOIN modulos m ON a.modulo_id = m.modulo_id
-- JOIN cursos c ON m.curso_id = c.curso_id
-- JOIN alunos al ON pr.aluno_id = al.aluno_id
-- JOIN usuarios u ON al.aluno_id = u.usuario_id
-- WHERE LOWER(u.nome) LIKE '%eduardo%'  -- ou WHERE u.usuario_id = 8;

CREATE INDEX idx_usuarios_lower_nome ON usuarios (LOWER(nome)); 
-- -> Acelera LIKE insensível a maiúsculas

CREATE INDEX idx_progresso_aula_id ON progresso (aula_id);
CREATE INDEX idx_progresso_aluno_id ON progresso (aluno_id);
CREATE INDEX idx_aulas_modulo_id ON aulas (modulo_id);
CREATE INDEX idx_modulos_curso_id ON modulos (curso_id);
-- -> Otimiza JOIN

-- ==========================================================
-- CONSULTA 4: Ver a média de avaliações por curso
-- ==========================================================
-- SELECT c.titulo, ROUND(AVG(av.nota), 2) AS media_nota, COUNT(av.avaliacao_id) AS total_avaliacoes
-- FROM cursos c
-- JOIN avaliacoes av ON c.curso_id = av.curso_id
-- GROUP BY c.titulo
-- ORDER BY media_nota DESC;

CREATE INDEX idx_avaliacoes_curso_id ON avaliacoes (curso_id);
-- -> Otimiza JOIN e agregações por curso

-- ==========================================================
-- CONSULTA 5: Alunos que concluíram cursos e receberam certificado
-- ==========================================================
-- SELECT u.nome AS aluno, c.titulo AS curso, cert.data_emissao, cert.codigo_validacao
-- FROM certificados cert
-- JOIN alunos a ON cert.aluno_id = a.aluno_id
-- JOIN usuarios u ON a.aluno_id = u.usuario_id
-- JOIN cursos c ON cert.curso_id = c.curso_id;

CREATE INDEX idx_certificados_aluno_id ON certificados (aluno_id);
CREATE INDEX idx_certificados_curso_id ON certificados (curso_id);
-- -> Melhoram JOINs com alunos e cursos

-- ==========================================================
-- CONSULTA 6: Ver quem são os monitores de cada curso
-- ==========================================================
-- SELECT u.nome AS monitor, c.titulo AS curso, m.data_inicio, m.data_fim
-- FROM monitores m
-- JOIN alunos a ON m.aluno_id = a.aluno_id
-- JOIN usuarios u ON a.aluno_id = u.usuario_id
-- JOIN cursos c ON m.curso_id = c.curso_id;

CREATE INDEX idx_monitores_aluno_id ON monitores (aluno_id);
CREATE INDEX idx_monitores_curso_id ON monitores (curso_id);
-- -> Melhoram os JOINs com alunos e cursos

-- ==========================================================
-- CONSULTA 7: Conversas entre dois usuários
-- ==========================================================
-- SELECT m.mensagem_id, remetente.nome AS de, destinatario.nome AS para, m.conteudo, m.data_envio, m.lida
-- FROM mensagens m
-- JOIN usuarios remetente ON m.remetente_id = remetente.usuario_id
-- JOIN usuarios destinatario ON m.destinatario_id = destinatario.usuario_id
-- WHERE (m.remetente_id = 5 AND m.destinatario_id = 6)
--    OR (m.remetente_id = 6 AND m.destinatario_id = 5)
-- ORDER BY m.data_envio;

CREATE INDEX idx_mensagens_rem_dest ON mensagens (remetente_id, destinatario_id);
-- -> Otimiza busca bidirecional entre dois usuários

CREATE INDEX idx_mensagens_data_envio ON mensagens (data_envio);
-- -> Acelera ordenação por data

-- ==========================================================
-- CONSULTA 8: Cursos mais populares
-- ==========================================================
-- SELECT c.titulo, COUNT(i.aluno_id) AS total_matriculados
-- FROM cursos c
-- JOIN inscricoes i ON c.curso_id = i.curso_id
-- GROUP BY c.curso_id, c.titulo
-- ORDER BY total_matriculados DESC;

CREATE INDEX idx_inscricoes_curso_id ON inscricoes (curso_id);
-- -> Melhora agregações por curso

-- ==========================================================
-- CONSULTA 9: Relatório de certificados emitidos por mês
-- ==========================================================
-- SELECT TO_CHAR(cert.data_emissao, 'YYYY-MM') AS mes_emissao,
--       COUNT(cert.certificado_id) AS total_emitidos
-- FROM certificados cert
-- GROUP BY TO_CHAR(cert.data_emissao, 'YYYY-MM')
-- ORDER BY mes_emissao DESC;

CREATE INDEX idx_certificados_data_emissao ON certificados (data_emissao);
-- -> Acelera filtro e agrupamento por mês de emissão

-- ==========================================================
-- CONSULTA 10: Alunos com mais cursos concluídos
-- ==========================================================
-- SELECT u.nome, COUNT(cert.certificado_id) AS cursos_concluidos
-- FROM certificados cert
-- JOIN alunos a ON cert.aluno_id = a.aluno_id
-- JOIN usuarios u ON a.aluno_id = u.usuario_id
-- GROUP BY u.usuario_id, u.nome
-- ORDER BY cursos_concluidos DESC
-- LIMIT 10;

-- Já coberta por idx_certificados_aluno_id e idx_alunos_aluno_id (consulta 5)
