-- ==========================================================
-- CONSULTAS COM EXPLAIN ANALYZE
-- ==========================================================

-- CONSULTA 1: Listar todos os alunos com seus dados de contato
EXPLAIN ANALYZE
SELECT u.usuario_id, u.nome, u.email, a.data_nascimento, a.telefone
FROM usuarios u
JOIN alunos a ON u.usuario_id = a.aluno_id;

-- CONSULTA 2: Listar os cursos com o nome do professor
EXPLAIN ANALYZE
SELECT c.curso_id, c.titulo, c.descricao, u.nome AS professor
FROM cursos c
JOIN professores p ON c.professor_id = p.professor_id
JOIN usuarios u ON p.professor_id = u.usuario_id;

-- CONSULTA 3: Ver o progresso de um aluno específico (Exemplo para 'Alice Souza')
EXPLAIN ANALYZE
SELECT u.nome AS aluno, c.titulo AS curso, a.titulo AS aula, pr.assistido, pr.data_visualizacao
FROM progresso pr
JOIN aulas a ON pr.aula_id = a.aula_id
JOIN modulos m ON a.modulo_id = m.modulo_id
JOIN cursos c ON m.curso_id = c.curso_id
JOIN alunos al ON pr.aluno_id = al.aluno_id
JOIN usuarios u ON al.aluno_id = u.usuario_id
WHERE LOWER(u.nome) LIKE '%alice%';

-- CONSULTA 4: Ver a média de avaliações por curso
EXPLAIN ANALYZE
SELECT c.titulo, ROUND(AVG(av.nota), 2) AS media_nota, COUNT(av.avaliacao_id) AS total_avaliacoes
FROM cursos c
JOIN avaliacoes av ON c.curso_id = av.curso_id
GROUP BY c.titulo
ORDER BY media_nota DESC;

-- CONSULTA 5: Alunos que concluíram cursos e receberam certificado
EXPLAIN ANALYZE
SELECT u.nome AS aluno, c.titulo AS curso, cert.data_emissao, cert.codigo_validacao
FROM certificados cert
JOIN alunos a ON cert.aluno_id = a.aluno_id
JOIN usuarios u ON a.aluno_id = u.usuario_id
JOIN cursos c ON cert.curso_id = c.curso_id;

-- CONSULTA 6: Ver quem são os monitores de cada curso
EXPLAIN ANALYZE
SELECT u.nome AS monitor, c.titulo AS curso, m.data_inicio, m.data_fim
FROM monitores m
JOIN alunos a ON m.aluno_id = a.aluno_id
JOIN usuarios u ON a.aluno_id = u.usuario_id
JOIN cursos c ON m.curso_id = c.curso_id;

-- CONSULTA 7: Conversas entre dois usuários (Exemplo: Eduardo (5) e Fernanda (6))
EXPLAIN ANALYZE
SELECT m.mensagem_id, remetente.nome AS de, destinatario.nome AS para, m.conteudo, m.data_envio, m.lida
FROM mensagens m
JOIN usuarios remetente ON m.remetente_id = remetente.usuario_id
JOIN usuarios destinatario ON m.destinatario_id = destinatario.usuario_id
WHERE (m.remetente_id = 5 AND m.destinatario_id = 6)
   OR (m.remetente_id = 6 AND m.destinatario_id = 5)
ORDER BY m.data_envio;

-- CONSULTA 8: Cursos mais populares
EXPLAIN ANALYZE
SELECT c.titulo, COUNT(i.aluno_id) AS total_matriculados
FROM cursos c
JOIN inscricoes i ON c.curso_id = i.curso_id
GROUP BY c.curso_id, c.titulo
ORDER BY total_matriculados DESC;

-- CONSULTA 9: Relatório de certificados emitidos por mês
EXPLAIN ANALYZE
SELECT TO_CHAR(cert.data_emissao, 'YYYY-MM') AS mes_emissao,
       COUNT(cert.certificado_id) AS total_emitidos
FROM certificados cert
GROUP BY TO_CHAR(cert.data_emissao, 'YYYY-MM')
ORDER BY mes_emissao DESC;

-- CONSULTA 10: Alunos com mais cursos concluídos
EXPLAIN ANALYZE
SELECT u.nome, COUNT(cert.certificado_id) AS cursos_concluidos
FROM certificados cert
JOIN alunos a ON cert.aluno_id = a.aluno_id
JOIN usuarios u ON a.aluno_id = u.usuario_id
GROUP BY u.usuario_id, u.nome
ORDER BY cursos_concluidos DESC
LIMIT 10;
