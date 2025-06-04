-- Seleções úteis para o sistema de cursos online

-- 1. Listar todos os alunos com seus dados de contato
SELECT u.usuario_id, u.nome, u.email, a.data_nascimento, a.telefone
FROM usuarios u
JOIN alunos a ON u.usuario_id = a.aluno_id;

-- 2. Listar os cursos com o nome do professor
SELECT c.curso_id, c.titulo, c.descricao, u.nome AS professor
FROM cursos c
JOIN professores p ON c.professor_id = p.professor_id
JOIN usuarios u ON p.professor_id = u.usuario_id;

-- 3. Ver o progresso de um aluno específico (por nome ou ID)
SELECT u.nome AS aluno, c.titulo AS curso, a.titulo AS aula, pr.assistido, pr.data_visualizacao
FROM progresso pr
JOIN aulas a ON pr.aula_id = a.aula_id
JOIN modulos m ON a.modulo_id = m.modulo_id
JOIN cursos c ON m.curso_id = c.curso_id
JOIN alunos al ON pr.aluno_id = al.aluno_id
JOIN usuarios u ON al.aluno_id = u.usuario_id
WHERE u.nome ILIKE '%Eduardo%';  -- ou WHERE u.usuario_id = 8

-- 4. Ver a média de avaliações por curso
SELECT c.titulo, ROUND(AVG(av.nota), 2) AS media_nota, COUNT(av.avaliacao_id) AS total_avaliacoes
FROM cursos c
JOIN avaliacoes av ON c.curso_id = av.curso_id
GROUP BY c.titulo
ORDER BY media_nota DESC;

-- 5. Listar os alunos que concluíram cursos e receberam certificado
SELECT u.nome AS aluno, c.titulo AS curso, cert.data_emissao, cert.codigo_validacao
FROM certificados cert
JOIN alunos a ON cert.aluno_id = a.aluno_id
JOIN usuarios u ON a.aluno_id = u.usuario_id
JOIN cursos c ON cert.curso_id = c.curso_id;

-- 6. Ver quem são os monitores de cada curso
SELECT u.nome AS monitor, c.titulo AS curso, m.data_inicio, m.data_fim
FROM monitores m
JOIN alunos a ON m.aluno_id = a.aluno_id
JOIN usuarios u ON a.aluno_id = u.usuario_id
JOIN cursos c ON m.curso_id = c.curso_id;

-- 7. Conversas (mensagens) entre dois usuários
SELECT m.mensagem_id, remetente.nome AS de, destinatario.nome AS para, m.conteudo, m.data_envio, m.lida
FROM mensagens m
JOIN usuarios remetente ON m.remetente_id = remetente.usuario_id
JOIN usuarios destinatario ON m.destinatario_id = destinatario.usuario_id
WHERE (m.remetente_id = 5 AND m.destinatario_id = 6)
   OR (m.remetente_id = 6 AND m.destinatario_id = 5)
ORDER BY m.data_envio;
